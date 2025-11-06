package models

import (
	"time"

	"github.com/google/uuid"
)

// Exercise represents an exercise/test
type Exercise struct {
	ID                    uuid.UUID  `json:"id"`
	Title                 string     `json:"title"`
	Slug                  string     `json:"slug"`
	Description           *string    `json:"description,omitempty"`
	ExerciseType          string     `json:"exercise_type"`             // practice, mock_test, full_test, mini_test
	SkillType             string     `json:"skill_type"`                // listening, reading, writing, speaking
	IELTSTestType         *string    `json:"ielts_test_type,omitempty"` // academic, general_training (only for Reading)
	Difficulty            string     `json:"difficulty"`                // easy, medium, hard
	IELTSLevel            *string    `json:"ielts_level,omitempty"`
	TotalQuestions        int        `json:"total_questions"`
	TotalSections         int        `json:"total_sections"`
	TimeLimitMinutes      *int       `json:"time_limit_minutes,omitempty"`
	ThumbnailURL          *string    `json:"thumbnail_url,omitempty"`
	AudioURL              *string    `json:"audio_url,omitempty"`
	AudioDurationSeconds  *int       `json:"audio_duration_seconds,omitempty"`
	AudioTranscript       *string    `json:"audio_transcript,omitempty"`
	PassageCount          *int       `json:"passage_count,omitempty"`
	CourseID              *uuid.UUID `json:"course_id,omitempty"`
	ModuleID              *uuid.UUID `json:"module_id,omitempty"`
	PassingScore          *float64   `json:"passing_score,omitempty"`
	TotalPoints           *float64   `json:"total_points,omitempty"`
	IsFree                bool       `json:"is_free"`
	IsPublished           bool       `json:"is_published"`
	TotalAttempts         int        `json:"total_attempts"`
	AverageScore          *float64   `json:"average_score,omitempty"` // Average percentage (0-100) of all completed attempts
	AverageCompletionTime *int       `json:"average_completion_time,omitempty"`
	DisplayOrder          int        `json:"display_order"`
	CreatedBy             uuid.UUID  `json:"created_by"`
	PublishedAt           *time.Time `json:"published_at,omitempty"`
	CreatedAt             time.Time  `json:"created_at"`
	UpdatedAt             time.Time  `json:"updated_at"`

	// Writing exercise fields (Phase 4)
	WritingTaskType        *string `json:"writing_task_type,omitempty"`        // task1, task2
	WritingPromptText      *string `json:"writing_prompt_text,omitempty"`      // Prompt text directly embedded
	WritingVisualType      *string `json:"writing_visual_type,omitempty"`      // bar_chart, line_graph, pie_chart, etc.
	WritingVisualURL       *string `json:"writing_visual_url,omitempty"`       // URL to visual for Task 1
	WritingWordRequirement *int    `json:"writing_word_requirement,omitempty"` // 150 for Task 1, 250 for Task 2

	// Speaking exercise fields (Phase 4)
	SpeakingPartNumber        *int     `json:"speaking_part_number,omitempty"`         // 1, 2, 3
	SpeakingPromptText        *string  `json:"speaking_prompt_text,omitempty"`         // Main prompt
	SpeakingCueCardTopic      *string  `json:"speaking_cue_card_topic,omitempty"`      // For Part 2
	SpeakingCueCardPoints     []string `json:"speaking_cue_card_points,omitempty"`     // Bullet points for Part 2
	SpeakingPreparationTime   *int     `json:"speaking_preparation_time,omitempty"`    // Seconds (60 for Part 2)
	SpeakingResponseTime      *int     `json:"speaking_response_time,omitempty"`       // Seconds (120 for Part 2)
	SpeakingFollowUpQuestions []string `json:"speaking_follow_up_questions,omitempty"` // For Part 3
}

// IsOfficialTest returns true if this is an official full test
func (e *Exercise) IsOfficialTest() bool {
	return e.ExerciseType == "full_test"
}

// RequiresAIEvaluation returns true if this exercise requires AI evaluation (Writing/Speaking)
func (e *Exercise) RequiresAIEvaluation() bool {
	return e.SkillType == "writing" || e.SkillType == "speaking"
}

// ExerciseSection represents a section within an exercise
type ExerciseSection struct {
	ID               uuid.UUID `json:"id"`
	ExerciseID       uuid.UUID `json:"exercise_id"`
	Title            string    `json:"title"`
	Description      *string   `json:"description,omitempty"`
	SectionNumber    int       `json:"section_number"`
	AudioURL         *string   `json:"audio_url,omitempty"`
	AudioStartTime   *int      `json:"audio_start_time,omitempty"`
	AudioEndTime     *int      `json:"audio_end_time,omitempty"`
	Transcript       *string   `json:"transcript,omitempty"`
	PassageTitle     *string   `json:"passage_title,omitempty"`
	PassageContent   *string   `json:"passage_content,omitempty"`
	PassageWordCount *int      `json:"passage_word_count,omitempty"`
	Instructions     *string   `json:"instructions,omitempty"`
	TotalQuestions   int       `json:"total_questions"`
	TimeLimitMinutes *int      `json:"time_limit_minutes,omitempty"`
	DisplayOrder     int       `json:"display_order"`
	CreatedAt        time.Time `json:"created_at"`
	UpdatedAt        time.Time `json:"updated_at"`
}

// Question represents a question in an exercise
type Question struct {
	ID             uuid.UUID  `json:"id"`
	ExerciseID     uuid.UUID  `json:"exercise_id"`
	SectionID      *uuid.UUID `json:"section_id,omitempty"`
	QuestionNumber int        `json:"question_number"`
	QuestionText   string     `json:"question_text"`
	QuestionType   string     `json:"question_type"` // multiple_choice, true_false_not_given, matching, fill_in_blank, etc.
	AudioURL       *string    `json:"audio_url,omitempty"`
	ImageURL       *string    `json:"image_url,omitempty"`
	ContextText    *string    `json:"context_text,omitempty"`
	Points         float64    `json:"points"`
	Difficulty     *string    `json:"difficulty,omitempty"`
	Explanation    *string    `json:"explanation,omitempty"`
	Tips           *string    `json:"tips,omitempty"`
	DisplayOrder   int        `json:"display_order"`
	CreatedAt      time.Time  `json:"created_at"`
	UpdatedAt      time.Time  `json:"updated_at"`
}

// QuestionOption represents an option for multiple choice questions
type QuestionOption struct {
	ID             uuid.UUID `json:"id"`
	QuestionID     uuid.UUID `json:"question_id"`
	OptionLabel    string    `json:"option_label"` // A, B, C, D
	OptionText     string    `json:"option_text"`
	OptionImageURL *string   `json:"option_image_url,omitempty"`
	IsCorrect      bool      `json:"is_correct"`
	DisplayOrder   int       `json:"display_order"`
	CreatedAt      time.Time `json:"created_at"`
}

// QuestionAnswer represents correct answer for fill-in-blank, matching, etc.
type QuestionAnswer struct {
	ID                 uuid.UUID `json:"id"`
	QuestionID         uuid.UUID `json:"question_id"`
	AnswerText         string    `json:"answer_text"`
	AlternativeAnswers *string   `json:"alternative_answers,omitempty"` // JSON array
	IsCaseSensitive    bool      `json:"is_case_sensitive"`
	MatchingOrder      *int      `json:"matching_order,omitempty"`
	CreatedAt          time.Time `json:"created_at"`
}

// Submission represents a student's submission (maps to user_exercise_attempts table)
// UserExerciseAttempt represents a user's attempt at completing an exercise.
// Maps to table: user_exercise_attempts
// Used for all 4 skills (Listening, Reading, Writing, Speaking) with skill-specific fields.
type UserExerciseAttempt struct {
	ID                uuid.UUID  `json:"id"`
	UserID            uuid.UUID  `json:"user_id"`
	ExerciseID        uuid.UUID  `json:"exercise_id"`
	AttemptNumber     int        `json:"attempt_number"`
	Status            string     `json:"status"` // in_progress, completed, abandoned
	TotalQuestions    int        `json:"total_questions"`
	QuestionsAnswered int        `json:"questions_answered"`
	CorrectAnswers    int        `json:"correct_answers"`
	Score             *float64   `json:"score,omitempty"`      // Percentage or points
	BandScore         *float64   `json:"band_score,omitempty"` // IELTS band score
	TimeLimitMinutes  *int       `json:"time_limit_minutes,omitempty"`
	TimeSpentSeconds  int        `json:"time_spent_seconds"`
	StartedAt         time.Time  `json:"started_at"`
	CompletedAt       *time.Time `json:"completed_at,omitempty"`
	DeviceType        *string    `json:"device_type,omitempty"` // web, android, ios

	// Writing-specific fields (Phase 4)
	EssayText  *string `json:"essay_text,omitempty"`
	WordCount  *int    `json:"word_count,omitempty"`
	TaskType   *string `json:"task_type,omitempty"` // task1, task2
	PromptText *string `json:"prompt_text,omitempty"`

	// Speaking-specific fields (Phase 4)
	AudioURL             *string `json:"audio_url,omitempty"`
	AudioDurationSeconds *int    `json:"audio_duration_seconds,omitempty"`
	TranscriptText       *string `json:"transcript_text,omitempty"`
	SpeakingPartNumber   *int    `json:"speaking_part_number,omitempty"` // 1, 2, 3

	// AI Evaluation fields (Phase 4)
	EvaluationStatus *string `json:"evaluation_status,omitempty"` // pending, processing, completed, failed
	AIEvaluationID   *string `json:"ai_evaluation_id,omitempty"`  // Reference to AI evaluation
	DetailedScores   *string `json:"detailed_scores,omitempty"`   // JSONB with criteria scores
	AIFeedback       *string `json:"ai_feedback,omitempty"`       // AI-generated feedback

	// Test/Practice linking (Phase 4)
	OfficialTestResultID *uuid.UUID `json:"official_test_result_id,omitempty"` // FK to user_db.official_test_results
	PracticeActivityID   *uuid.UUID `json:"practice_activity_id,omitempty"`    // FK to user_db.practice_activities

	// User Service Sync Tracking (FIX #9, #8)
	UserServiceSyncStatus      string     `json:"user_service_sync_status"`       // pending, synced, failed, not_required
	UserServiceSyncAttempts    int        `json:"user_service_sync_attempts"`     // Number of sync attempts
	UserServiceLastSyncAttempt *time.Time `json:"user_service_last_sync_attempt"` // Last sync attempt timestamp
	UserServiceSyncError       *string    `json:"user_service_sync_error"`        // Last sync error message

	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// SubmissionAnswer represents an answer in a submission (maps to user_answers table)
type SubmissionAnswer struct {
	ID               uuid.UUID  `json:"id"`
	AttemptID        uuid.UUID  `json:"attempt_id"` // FK to user_exercise_attempts
	QuestionID       uuid.UUID  `json:"question_id"`
	UserID           uuid.UUID  `json:"user_id"`
	AnswerText       *string    `json:"answer_text,omitempty"`
	SelectedOptionID *uuid.UUID `json:"selected_option_id,omitempty"`
	IsCorrect        *bool      `json:"is_correct,omitempty"`
	PointsEarned     *float64   `json:"points_earned,omitempty"`
	TimeSpentSeconds *int       `json:"time_spent_seconds,omitempty"`
	AnsweredAt       time.Time  `json:"answered_at"`
}

// ExerciseTag represents a tag for exercises
type ExerciseTag struct {
	ID        int       `json:"id"`
	Name      string    `json:"name"`
	Slug      string    `json:"slug"`
	CreatedAt time.Time `json:"created_at"`
}

// QuestionBank represents reusable question in question bank
type QuestionBank struct {
	ID           uuid.UUID `json:"id"`
	Title        *string   `json:"title,omitempty"`
	SkillType    string    `json:"skill_type"` // listening, reading
	QuestionType string    `json:"question_type"`
	Difficulty   *string   `json:"difficulty,omitempty"`
	Topic        *string   `json:"topic,omitempty"`
	QuestionText string    `json:"question_text"`
	ContextText  *string   `json:"context_text,omitempty"`
	AudioURL     *string   `json:"audio_url,omitempty"`
	ImageURL     *string   `json:"image_url,omitempty"`
	AnswerData   string    `json:"answer_data"` // JSONB stored as string
	Tags         []string  `json:"tags,omitempty"`
	TimesUsed    int       `json:"times_used"`
	CreatedBy    uuid.UUID `json:"created_by"`
	IsVerified   bool      `json:"is_verified"`
	IsPublished  bool      `json:"is_published"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
}

// ExerciseAnalytics represents analytics for an exercise
type ExerciseAnalytics struct {
	ExerciseID            uuid.UUID `json:"exercise_id"`
	TotalAttempts         int       `json:"total_attempts"`
	CompletedAttempts     int       `json:"completed_attempts"`
	AbandonedAttempts     int       `json:"abandoned_attempts"`
	AverageScore          *float64  `json:"average_score,omitempty"`
	MedianScore           *float64  `json:"median_score,omitempty"`
	HighestScore          *float64  `json:"highest_score,omitempty"`
	LowestScore           *float64  `json:"lowest_score,omitempty"`
	AverageCompletionTime *int      `json:"average_completion_time,omitempty"` // seconds
	MedianCompletionTime  *int      `json:"median_completion_time,omitempty"`
	ActualDifficulty      *string   `json:"actual_difficulty,omitempty"`
	QuestionStatistics    *string   `json:"question_statistics,omitempty"` // JSONB
	UpdatedAt             time.Time `json:"updated_at"`
}

// ============================================
// Request/Response Models
// ============================================

// CreateBankQuestionRequest represents request to create a question bank question
type CreateBankQuestionRequest struct {
	Title        *string                `json:"title,omitempty"`
	SkillType    string                 `json:"skill_type" binding:"required"`
	QuestionType string                 `json:"question_type" binding:"required"`
	Difficulty   *string                `json:"difficulty,omitempty"`
	Topic        *string                `json:"topic,omitempty"`
	QuestionText string                 `json:"question_text" binding:"required"`
	ContextText  *string                `json:"context_text,omitempty"`
	AudioURL     *string                `json:"audio_url,omitempty"`
	ImageURL     *string                `json:"image_url,omitempty"`
	AnswerData   map[string]interface{} `json:"answer_data" binding:"required"`
	Tags         []string               `json:"tags,omitempty"`
}

// UpdateBankQuestionRequest represents request to update a question bank question
type UpdateBankQuestionRequest struct {
	Title        *string                `json:"title,omitempty"`
	SkillType    string                 `json:"skill_type" binding:"required"`
	QuestionText string                 `json:"question_text" binding:"required"`
	QuestionType string                 `json:"question_type" binding:"required"`
	Difficulty   *string                `json:"difficulty,omitempty"`
	Topic        *string                `json:"topic,omitempty"`
	ContextText  *string                `json:"context_text,omitempty"`
	AudioURL     *string                `json:"audio_url,omitempty"`
	ImageURL     *string                `json:"image_url,omitempty"`
	AnswerData   map[string]interface{} `json:"answer_data" binding:"required"`
	Tags         []string               `json:"tags,omitempty"`
}

// CreateTagRequest represents request to create a tag
type CreateTagRequest struct {
	Name string `json:"name" binding:"required"`
	Slug string `json:"slug" binding:"required"`
}

// AddTagRequest represents request to add tag to exercise
type AddTagRequest struct {
	TagID int `json:"tag_id" binding:"required"`
}

// SubmitExerciseRequest represents unified submission request for all skills
type SubmitExerciseRequest struct {
	// For Listening/Reading
	Answers []SubmitAnswerItem `json:"answers,omitempty"`

	// For Writing
	WritingData *WritingSubmissionData `json:"writing_data,omitempty"`

	// For Speaking
	SpeakingData *SpeakingSubmissionData `json:"speaking_data,omitempty"`

	// Common metadata
	TimeSpentSeconds int  `json:"time_spent_seconds"`
	IsOfficialTest   bool `json:"is_official_test"`
}

// WritingSubmissionData represents writing-specific submission data
type WritingSubmissionData struct {
	EssayText  string `json:"essay_text" binding:"required"`
	WordCount  int    `json:"word_count"`
	TaskType   string `json:"task_type"` // task1, task2
	PromptText string `json:"prompt_text"`
}

// SpeakingSubmissionData represents speaking-specific submission data
type SpeakingSubmissionData struct {
	AudioURL             string `json:"audio_url" binding:"required"`
	AudioDurationSeconds int    `json:"audio_duration_seconds"`
	SpeakingPartNumber   int    `json:"speaking_part_number"` // 1, 2, 3
}

// ============================================================================
// PROMPT MODELS (for future prompt management if needed)
// ============================================================================
// Note: Prompts are currently embedded directly in exercises table
// These models can be used later if we want separate prompt management

// WritingPrompt represents a writing prompt (for future use)
type WritingPrompt struct {
	ID                    uuid.UUID  `json:"id"`
	TaskType              string     `json:"task_type"` // task1, task2
	PromptText            string     `json:"prompt_text"`
	VisualType            *string    `json:"visual_type,omitempty"`
	VisualURL             *string    `json:"visual_url,omitempty"`
	Topic                 *string    `json:"topic,omitempty"`
	Difficulty            *string    `json:"difficulty,omitempty"`
	HasSampleAnswer       bool       `json:"has_sample_answer"`
	SampleAnswerText      *string    `json:"sample_answer_text,omitempty"`
	SampleAnswerBandScore *float64   `json:"sample_answer_band_score,omitempty"`
	TimesUsed             int        `json:"times_used"`
	AverageScore          *float64   `json:"average_score,omitempty"`
	IsPublished           bool       `json:"is_published"`
	CreatedBy             *uuid.UUID `json:"created_by,omitempty"`
	CreatedAt             time.Time  `json:"created_at"`
	UpdatedAt             time.Time  `json:"updated_at"`
}

// SpeakingPrompt represents a speaking prompt (for future use)
type SpeakingPrompt struct {
	ID                     uuid.UUID  `json:"id"`
	PartNumber             int        `json:"part_number"` // 1, 2, 3
	PromptText             string     `json:"prompt_text"`
	CueCardTopic           *string    `json:"cue_card_topic,omitempty"`
	CueCardPoints          []string   `json:"cue_card_points,omitempty"`
	PreparationTimeSeconds *int       `json:"preparation_time_seconds,omitempty"`
	SpeakingTimeSeconds    *int       `json:"speaking_time_seconds,omitempty"`
	FollowUpQuestions      []string   `json:"follow_up_questions,omitempty"`
	TopicCategory          *string    `json:"topic_category,omitempty"`
	Difficulty             *string    `json:"difficulty,omitempty"`
	HasSampleAnswer        bool       `json:"has_sample_answer"`
	SampleAnswerText       *string    `json:"sample_answer_text,omitempty"`
	SampleAnswerAudioURL   *string    `json:"sample_answer_audio_url,omitempty"`
	SampleAnswerBandScore  *float64   `json:"sample_answer_band_score,omitempty"`
	TimesUsed              int        `json:"times_used"`
	AverageScore           *float64   `json:"average_score,omitempty"`
	IsPublished            bool       `json:"is_published"`
	CreatedBy              *uuid.UUID `json:"created_by,omitempty"`
	CreatedAt              time.Time  `json:"created_at"`
	UpdatedAt              time.Time  `json:"updated_at"`
}

// AIEvaluationResult represents AI evaluation response structure
type AIEvaluationResult struct {
	OverallBandScore float64                `json:"overall_band_score"`
	DetailedScores   map[string]interface{} `json:"detailed_scores"`
	Feedback         string                 `json:"feedback"`
	CriteriaScores   map[string]float64     `json:"criteria_scores"` // TA, CC, LR, GRA for writing; Fluency, Lexical, Grammar, Pronunciation for speaking
}
