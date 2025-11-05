package service

import (
	"fmt"
	"log"

	sharedClient "github.com/bisosad1501/DATN/shared/pkg/client"
	"github.com/bisosad1501/DATN/shared/pkg/ielts"
	aiClient "github.com/bisosad1501/ielts-platform/exercise-service/internal/client"
	"github.com/bisosad1501/ielts-platform/exercise-service/internal/models"
	"github.com/google/uuid"
)

// SubmitExercise is the unified submission handler for all 4 skills
func (s *ExerciseService) SubmitExercise(submissionID uuid.UUID, req *models.SubmitExerciseRequest) error {
	// Get submission and exercise info
	submission, err := s.repo.GetSubmissionByID(submissionID)
	if err != nil {
		return fmt.Errorf("get submission: %w", err)
	}

	exercise, err := s.repo.GetExerciseByIDSimple(submission.ExerciseID)
	if err != nil {
		return fmt.Errorf("get exercise: %w", err)
	}

	// Route to appropriate handler based on skill type
	switch exercise.SkillType {
	case "listening", "reading":
		return s.handleListeningReadingSubmission(submission, exercise, req)
	case "writing":
		return s.handleWritingSubmission(submission, exercise, req)
	case "speaking":
		return s.handleSpeakingSubmission(submission, exercise, req)
	default:
		return fmt.Errorf("unsupported skill type: %s", exercise.SkillType)
	}
}

// handleListeningReadingSubmission handles L/R with immediate grading
func (s *ExerciseService) handleListeningReadingSubmission(
	submission *models.Submission,
	exercise *models.Exercise,
	req *models.SubmitExerciseRequest,
) error {
	// 1. Save answers
	if len(req.Answers) == 0 {
		return fmt.Errorf("no answers provided")
	}

	err := s.repo.SaveSubmissionAnswers(submission.ID, req.Answers)
	if err != nil {
		return fmt.Errorf("save answers: %w", err)
	}

	// 2. Grade immediately
	err = s.repo.CompleteSubmission(submission.ID)
	if err != nil {
		return fmt.Errorf("complete submission: %w", err)
	}

	// 3. Get updated submission with score
	result, err := s.repo.GetSubmissionResult(submission.ID)
	if err != nil {
		return fmt.Errorf("get result: %w", err)
	}

	// 4. Convert to band score using shared library
	correctAnswers := result.Submission.CorrectAnswers
	totalQuestions := result.Submission.TotalQuestions
	var bandScore float64

	if exercise.SkillType == "listening" {
		bandScore = ielts.ConvertListeningScore(correctAnswers, totalQuestions)
	} else { // reading
		testType := "academic"
		if exercise.IELTSTestType != nil && *exercise.IELTSTestType == "general_training" {
			testType = "general"
		}
		bandScore = ielts.ConvertReadingScore(correctAnswers, totalQuestions, testType)
	}

	// 5. Update submission with band score
	err = s.repo.UpdateSubmissionBandScore(submission.ID, bandScore)
	if err != nil {
		log.Printf("⚠️ Failed to update band score: %v", err)
	}

	// 6. Record to user service (async)
	go s.recordToUserService(submission.ID, exercise, bandScore)

	return nil
}

// handleWritingSubmission handles Writing with async AI evaluation
func (s *ExerciseService) handleWritingSubmission(
	submission *models.Submission,
	exercise *models.Exercise,
	req *models.SubmitExerciseRequest,
) error {
	// 1. Validate essay
	if req.WritingData == nil || req.WritingData.EssayText == "" {
		return fmt.Errorf("essay text is required for writing submission")
	}

	// 2. Save essay data
	wordCount := req.WritingData.WordCount
	if wordCount == 0 {
		wordCount = len([]rune(req.WritingData.EssayText))
	}

	err := s.repo.UpdateSubmissionWritingData(
		submission.ID,
		req.WritingData.EssayText,
		wordCount,
		req.WritingData.TaskType,
		req.WritingData.PromptText,
	)
	if err != nil {
		return fmt.Errorf("save writing data: %w", err)
	}

	// Set pending status
	if err := s.repo.UpdateSubmissionEvaluationStatus(submission.ID, "pending"); err != nil {
		return fmt.Errorf("update evaluation status: %w", err)
	}

	// 3. Start async evaluation
	taskType := req.WritingData.TaskType
	promptText := req.WritingData.PromptText
	go s.evaluateWritingAsync(submission.ID, exercise, req.WritingData.EssayText, &taskType, &promptText)

	return nil
}

// handleSpeakingSubmission handles Speaking with async transcription + evaluation
func (s *ExerciseService) handleSpeakingSubmission(
	submission *models.Submission,
	exercise *models.Exercise,
	req *models.SubmitExerciseRequest,
) error {
	// 1. Validate audio
	if req.SpeakingData == nil || req.SpeakingData.AudioURL == "" {
		return fmt.Errorf("audio URL is required for speaking submission")
	}

	// 2. Save audio data
	err := s.repo.UpdateSubmissionSpeakingData(
		submission.ID,
		req.SpeakingData.AudioURL,
		req.SpeakingData.AudioDurationSeconds,
		req.SpeakingData.SpeakingPartNumber,
	)
	if err != nil {
		return fmt.Errorf("save speaking data: %w", err)
	}

	// Set processing status
	if err := s.repo.UpdateSubmissionEvaluationStatus(submission.ID, "processing"); err != nil {
		return fmt.Errorf("update evaluation status: %w", err)
	}

	// 3. Start async processing (transcribe + evaluate)
	speakingPart := req.SpeakingData.SpeakingPartNumber
	go s.evaluateSpeakingAsync(submission.ID, exercise, req.SpeakingData.AudioURL, &speakingPart)

	return nil
}

// evaluateWritingAsync performs async writing evaluation
func (s *ExerciseService) evaluateWritingAsync(
	submissionID uuid.UUID,
	exercise *models.Exercise,
	essayText string,
	taskType *string,
	promptText *string,
) {
	defer func() {
		if r := recover(); r != nil {
			log.Printf("❌ PANIC in evaluateWritingAsync: %v", r)
			s.repo.UpdateSubmissionEvaluationStatus(submissionID, "failed")
		}
	}()

	log.Printf("🔄 Starting writing evaluation for submission %s", submissionID)

	// Check if AI client exists
	if s.aiServiceClient == nil {
		log.Printf("❌ AI service client not configured")
		s.repo.UpdateSubmissionEvaluationStatus(submissionID, "failed")
		return
	}

	// Call AI service with retry
	taskTypeStr := "task2"
	if taskType != nil {
		taskTypeStr = *taskType
	}

	promptStr := ""
	if promptText != nil {
		promptStr = *promptText
	}

	var result *aiClient.WritingEvaluationResponse
	err := RetryWithBackoff(AIServiceRetryConfig(), func() error {
		var evalErr error
		result, evalErr = s.aiServiceClient.EvaluateWriting(aiClient.WritingEvaluationRequest{
			EssayText:  essayText,
			TaskType:   taskTypeStr,
			PromptText: promptStr,
		})

		if evalErr != nil && IsRetryableError(evalErr) {
			log.Printf("⚠️ Retryable error in writing evaluation: %v", evalErr)
			return evalErr
		}

		return evalErr
	})

	if err != nil {
		log.Printf("❌ AI evaluation failed after retries: %v", err)
		s.repo.UpdateSubmissionEvaluationStatus(submissionID, "failed")
		return
	}

	// Calculate overall band using shared library
	overallBand := ielts.CalculateWritingBand(
		result.Data.TaskAchievement,
		result.Data.CoherenceCohesion,
		result.Data.LexicalResource,
		result.Data.GrammarAccuracy,
	)

	// Prepare detailed scores
	detailedScores := map[string]interface{}{
		"task_achievement":   result.Data.TaskAchievement,
		"coherence_cohesion": result.Data.CoherenceCohesion,
		"lexical_resource":   result.Data.LexicalResource,
		"grammar_accuracy":   result.Data.GrammarAccuracy,
		"overall_band":       overallBand,
		"strengths":          result.Data.Strengths,
		"weaknesses":         result.Data.Weaknesses,
		"suggestions":        result.Data.Suggestions,
	}

	// Update submission with results
	err = s.repo.UpdateSubmissionWithAIResult(submissionID, &models.AIEvaluationResult{
		OverallBandScore: overallBand,
		DetailedScores:   detailedScores,
		Feedback:         result.Data.Feedback,
		CriteriaScores: map[string]float64{
			"task_achievement":   result.Data.TaskAchievement,
			"coherence_cohesion": result.Data.CoherenceCohesion,
			"lexical_resource":   result.Data.LexicalResource,
			"grammar_accuracy":   result.Data.GrammarAccuracy,
		},
	})
	if err != nil {
		log.Printf("❌ Failed to update submission: %v", err)
		return
	}

	log.Printf("✅ Writing evaluation completed: %.1f band", overallBand)

	// Record to user service
	go s.recordToUserService(submissionID, exercise, overallBand)
}

// evaluateSpeakingAsync performs async speaking transcription + evaluation
func (s *ExerciseService) evaluateSpeakingAsync(
	submissionID uuid.UUID,
	exercise *models.Exercise,
	audioURL string,
	partNumber *int,
) {
	defer func() {
		if r := recover(); r != nil {
			log.Printf("❌ PANIC in evaluateSpeakingAsync: %v", r)
			s.repo.UpdateSubmissionEvaluationStatus(submissionID, "failed")
		}
	}()

	log.Printf("🔄 Starting speaking evaluation for submission %s", submissionID)

	// Check if AI client exists
	if s.aiServiceClient == nil {
		log.Printf("❌ AI service client not configured")
		s.repo.UpdateSubmissionEvaluationStatus(submissionID, "failed")
		return
	}

	// Step 1: Transcribe audio with retry
	var transcriptResult *aiClient.SpeakingTranscriptionResponse
	err := RetryWithBackoff(AIServiceRetryConfig(), func() error {
		var transcribeErr error
		transcriptResult, transcribeErr = s.aiServiceClient.TranscribeSpeaking(aiClient.SpeakingTranscriptionRequest{
			AudioURL: audioURL,
		})

		if transcribeErr != nil && IsRetryableError(transcribeErr) {
			log.Printf("⚠️ Retryable error in transcription: %v", transcribeErr)
			return transcribeErr
		}

		return transcribeErr
	})

	if err != nil {
		log.Printf("❌ Transcription failed after retries: %v", err)
		s.repo.UpdateSubmissionEvaluationStatus(submissionID, "failed")
		return
	}

	// Update submission with transcript
	err = s.repo.UpdateSubmissionTranscript(submissionID, transcriptResult.Data.TranscriptText)
	if err != nil {
		log.Printf("⚠️ Failed to save transcript: %v", err)
		// Continue even if transcript save fails
	}

	// Step 2: Evaluate speaking with retry
	partNum := 1
	if partNumber != nil {
		partNum = *partNumber
	}

	var evalResult *aiClient.SpeakingEvaluationResponse
	err = RetryWithBackoff(AIServiceRetryConfig(), func() error {
		var evalErr error
		evalResult, evalErr = s.aiServiceClient.EvaluateSpeaking(aiClient.SpeakingEvaluationRequest{
			AudioURL:       audioURL,
			TranscriptText: transcriptResult.Data.TranscriptText,
			PartNumber:     partNum,
		})

		if evalErr != nil && IsRetryableError(evalErr) {
			log.Printf("⚠️ Retryable error in speaking evaluation: %v", evalErr)
			return evalErr
		}

		return evalErr
	})

	if err != nil {
		log.Printf("❌ Speaking evaluation failed after retries: %v", err)
		s.repo.UpdateSubmissionEvaluationStatus(submissionID, "failed")
		return
	}

	// Calculate overall band using shared library
	overallBand := ielts.CalculateSpeakingBand(
		evalResult.Data.Fluency,
		evalResult.Data.LexicalResource,
		evalResult.Data.Grammar,
		evalResult.Data.Pronunciation,
	)

	// Prepare detailed scores
	detailedScores := map[string]interface{}{
		"fluency":          evalResult.Data.Fluency,
		"lexical_resource": evalResult.Data.LexicalResource,
		"grammar":          evalResult.Data.Grammar,
		"pronunciation":    evalResult.Data.Pronunciation,
		"overall_band":     overallBand,
		"strengths":        evalResult.Data.Strengths,
		"weaknesses":       evalResult.Data.Weaknesses,
		"suggestions":      evalResult.Data.Suggestions,
	}

	// Update submission with results
	err = s.repo.UpdateSubmissionWithAIResult(submissionID, &models.AIEvaluationResult{
		OverallBandScore: overallBand,
		DetailedScores:   detailedScores,
		Feedback:         evalResult.Data.Feedback,
		CriteriaScores: map[string]float64{
			"fluency":          evalResult.Data.Fluency,
			"lexical_resource": evalResult.Data.LexicalResource,
			"grammar":          evalResult.Data.Grammar,
			"pronunciation":    evalResult.Data.Pronunciation,
		},
	})
	if err != nil {
		log.Printf("❌ Failed to update submission: %v", err)
		return
	}

	log.Printf("✅ Speaking evaluation completed: %.1f band", overallBand)

	// Record to user service
	go s.recordToUserService(submissionID, exercise, overallBand)
}

// recordToUserService records results to user service (for all 4 skills)
func (s *ExerciseService) recordToUserService(
	submissionID uuid.UUID,
	exercise *models.Exercise,
	bandScore float64,
) {
	defer func() {
		if r := recover(); r != nil {
			log.Printf("❌ PANIC in recordToUserService: %v", r)
		}
	}()

	// Get submission to get user_id
	submission, err := s.repo.GetSubmissionByID(submissionID)
	if err != nil {
		log.Printf("❌ Failed to get submission: %v", err)
		return
	}

	// Determine if this is official test or practice
	isOfficialTest := exercise.IsOfficialTest()

	if isOfficialTest {
		// Record as official test result
		log.Printf("📊 Recording official test result for user %s", submission.UserID)

		// For now, we'll use a simple approach - need all 4 skills for full test
		// This would need to be enhanced based on your business logic
		req := sharedClient.RecordTestResultRequest{
			TestType:         "full_test",
			OverallBandScore: bandScore,
			ListeningScore:   bandScore,
			ReadingScore:     bandScore,
			WritingScore:     bandScore,
			SpeakingScore:    bandScore,
			TestSource:       "platform",
		}

		err := RetryWithBackoff(DefaultRetryConfig(), func() error {
			return s.userServiceClient.RecordTestResult(submission.UserID.String(), req)
		})

		if err != nil {
			log.Printf("❌ Failed to record test result after retries: %v", err)
			// Don't fail the whole operation - user service recording is not critical
		} else {
			log.Printf("✅ Recorded official test result")
		}
	} else {
		// Record as practice activity
		log.Printf("📊 Recording practice activity for user %s", submission.UserID)

		timeSpent := 0
		if submission.CompletedAt != nil {
			timeSpent = int(submission.CompletedAt.Sub(submission.StartedAt).Seconds())
		}

		exerciseIDStr := exercise.ID.String()
		req := sharedClient.RecordPracticeActivityRequest{
			Skill:            exercise.SkillType,
			ActivityType:     "drill",
			ExerciseID:       &exerciseIDStr,
			ExerciseTitle:    &exercise.Title,
			BandScore:        &bandScore,
			TimeSpentSeconds: &timeSpent,
			CompletionStatus: "completed",
		}

		err := RetryWithBackoff(DefaultRetryConfig(), func() error {
			return s.userServiceClient.RecordPracticeActivity(submission.UserID.String(), req)
		})

		if err != nil {
			log.Printf("❌ Failed to record practice activity after retries: %v", err)
			// Don't fail the whole operation - user service recording is not critical
		} else {
			log.Printf("✅ Recorded practice activity")
		}
	}
}
