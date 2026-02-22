# AI Service - Writing Evaluation Architecture

## Overview
AI Service là một **stateless evaluation engine** dùng để đánh giá Writing và Speaking submissions. Tất cả các submission management được xử lý bởi **Exercise Service**, trong khi AI Service chỉ chịu trách nhiệm thực hiện evaluation và trả về kết quả.

---

## 1. AI Service Endpoints

### Writing Evaluation Endpoint

**Endpoint:** `POST /api/v1/ai/internal/writing/evaluate`

**URL Pattern:** `http://ai-service:8086/api/v1/ai/internal/writing/evaluate`

**Request Format:**
```json
{
  "essay_text": "string (required) - The written essay text",
  "task_type": "string (optional) - 'task1' or 'task2'",
  "prompt_text": "string (optional) - The writing prompt/question"
}
```

**Response Format (HTTP 200 OK):**
```json
{
  "success": true,
  "data": {
    "overall_band": 7.5,
    "criteria_scores": {
      "task_achievement": 7.0,
      "coherence_cohesion": 7.5,
      "lexical_resource": 8.0,
      "grammatical_range": 7.0
    },
    "detailed_feedback": {
      "task_achievement": {
        "vi": "Bạn đã hoàn thành yêu cầu của bài...",
        "en": "You have completed the task requirements..."
      },
      "coherence_cohesion": {...},
      "lexical_resource": {...},
      "grammatical_range": {...}
    },
    "examiner_feedback": "Overall feedback from AI examiner...",
    "strengths": ["Well-organized essay", "Clear thesis statement"],
    "areas_for_improvement": ["Expand with more examples", "Improve word variety"]
  }
}
```

---

## 2. Speaking Evaluation Endpoints

### Speaking Transcription Endpoint

**Endpoint:** `POST /api/v1/ai/internal/speaking/transcribe`

**Request Format:**
```json
{
  "audio_url": "string (required) - URL to audio file"
}
```

**Response Format:**
```json
{
  "success": true,
  "data": {
    "transcript_text": "The transcribed text from audio...",
    "audio_duration_seconds": 120
  }
}
```

### Speaking Evaluation Endpoint

**Endpoint:** `POST /api/v1/ai/internal/speaking/evaluate`

**Request Format:**
```json
{
  "audio_url": "string (required) - URL to audio file",
  "transcript_text": "string (optional) - Pre-transcribed text",
  "prompt_text": "string (optional) - The speaking prompt",
  "part_number": 1-3 (integer),
  "word_count": 150 (integer, calculated from transcript),
  "duration": 120.0 (float, seconds)
}
```

**Response Format:**
```json
{
  "success": true,
  "data": {
    "overall_band": 7.0,
    "criteria_scores": {
      "fluency_coherence": 7.0,
      "lexical_resource": 6.5,
      "grammatical_range": 7.5,
      "pronunciation": 7.0
    },
    "detailed_feedback": {
      "fluency_coherence": {
        "score": 7.0,
        "analysis": "Good fluency and coherence..."
      },
      "lexical_resource": {...},
      "grammatical_range": {...},
      "pronunciation": {...}
    },
    "examiner_feedback": "Overall feedback...",
    "strengths": ["Clear pronunciation", "Good pace"],
    "areas_for_improvement": ["Use more complex vocabulary"]
  }
}
```

---

## 3. Exercise Service Integration

### How Exercise Service Calls AI Service

**File:** [services/exercise-service/internal/client/ai_service_client.go](services/exercise-service/internal/client/ai_service_client.go)

#### Writing Evaluation Flow:

```go
// Exercise Service calls AI Service
result, err := s.aiServiceClient.EvaluateWriting(aiClient.WritingEvaluationRequest{
    EssayText:  essayText,
    TaskType:   taskTypeStr,  // "task1" or "task2"
    PromptText: promptStr,
})
```

**Key Points:**
- AI Service URL configured via `AI_SERVICE_URL` environment variable (default: `http://ai-service:8086`)
- Internal API Key sent via `X-API-Key` header
- Timeout: **60 seconds** (AI calls can take longer)
- Retry logic with exponential backoff for transient failures

#### Speaking Evaluation Flow:

```go
// Step 1: Transcribe
transcriptResult, err := s.aiServiceClient.TranscribeSpeaking(aiClient.SpeakingTranscriptionRequest{
    AudioURL: audioURL,
})

// Step 2: Evaluate (after transcription completes)
evalResult, err := s.aiServiceClient.EvaluateSpeaking(aiClient.SpeakingEvaluationRequest{
    AudioURL:       audioURL,
    TranscriptText: transcriptResult.Data.TranscriptText,
    PromptText:     promptText,
    PartNumber:     partNum,
    WordCount:      wordCount,
    Duration:       duration,
})
```

---

## 4. Evaluation Status Lifecycle

### Writing Submission Status Flow:

```
START
  ↓
submitted (immediate, when user clicks submit)
  ↓
pending (evaluation starts in async goroutine)
  ↓
completed (AI evaluation finished and saved)
  ↓
END
```

### Speaking Submission Status Flow:

```
START
  ↓
submitted (immediate, when user clicks submit)
  ↓
processing (transcription + evaluation starts in async goroutine)
  ↓
completed (transcription + evaluation finished and saved)
  ↓
END
```

**Possible Status Values:**
- `pending` - Evaluation queued (Writing only, very brief)
- `processing` - Currently evaluating/transcribing (Speaking)
- `completed` - Evaluation finished, results saved
- `failed` - Evaluation failed after retries

---

## 5. Evaluation Criteria

### Writing Evaluation Criteria (IELTS Task 1 & 2)

| Criterion | Field Name | Weight | Description |
|-----------|-----------|--------|-------------|
| Task Achievement | `task_achievement` | 1/4 | How well the essay addresses the prompt |
| Coherence & Cohesion | `coherence_cohesion` | 1/4 | Organization, flow, linking between ideas |
| Lexical Resource | `lexical_resource` | 1/4 | Range and accuracy of vocabulary |
| Grammatical Range | `grammatical_range` | 1/4 | Range and accuracy of grammar structures |

**Overall Band Calculation:**
```
Overall Band = Average of 4 criteria (rounded to nearest 0.5)
```

### Speaking Evaluation Criteria (Part 1, 2, 3)

| Criterion | Field Name | Weight | Description |
|-----------|-----------|--------|-------------|
| Fluency & Coherence | `fluency_coherence` | 1/4 | Fluency, flow, coherence of ideas |
| Lexical Resource | `lexical_resource` | 1/4 | Vocabulary range and accuracy |
| Grammatical Range | `grammatical_range` | 1/4 | Grammar structures and accuracy |
| Pronunciation | `pronunciation` | 1/4 | Clarity, stress, intonation |

**Overall Band Calculation:**
```
Overall Band = Average of 4 criteria (rounded to nearest 0.5)
```

---

## 6. AI Service Architecture (Internal)

### File Structure:
```
services/ai-service/
├── cmd/main.go                          # Entry point
├── internal/
│   ├── handlers/ai_handler.go           # HTTP request handlers
│   ├── routes/routes.go                 # Route definitions
│   ├── service/
│   │   ├── ai_service.go               # Core evaluation logic
│   │   ├── openai_client.go            # OpenAI API calls
│   │   └── cache_service.go            # Response caching
│   ├── models/
│   │   ├── models.go                   # OpenAI response structures
│   │   └── dto.go                      # Request/Response DTOs
│   └── middleware/
│       ├── auth.go                     # JWT authentication
│       └── rate_limit.go               # Rate limiting
```

### AI Service as Stateless Engine:

**Important:** AI Service **does NOT store** evaluation results. It:
1. ✅ Receives evaluation requests from Exercise Service
2. ✅ Calls OpenAI API (GPT-4) with specialized prompts
3. ✅ Caches responses (for identical essays/audio)
4. ✅ Returns evaluation results immediately
5. ❌ Does NOT persist evaluation records

**All database persistence** is handled by Exercise Service in `user_exercise_attempts` table.

---

## 7. Exercise Service Data Model

### UserExerciseAttempt Table (Simplified for Writing/Speaking)

```go
type UserExerciseAttempt struct {
    // Submission Metadata
    ID                uuid.UUID  `json:"id"`
    UserID            uuid.UUID  `json:"user_id"`
    ExerciseID        uuid.UUID  `json:"exercise_id"`
    Status            string     `json:"status"`                    // in_progress, completed
    TimeSpentSeconds  int        `json:"time_spent_seconds"`
    StartedAt         time.Time  `json:"started_at"`
    CompletedAt       *time.Time `json:"completed_at"`              // Set when submitted
    
    // Writing-specific
    EssayText         *string    `json:"essay_text"`
    WordCount         *int       `json:"word_count"`
    TaskType          *string    `json:"task_type"`                 // task1, task2
    PromptText        *string    `json:"prompt_text"`
    
    // Speaking-specific
    AudioURL          *string    `json:"audio_url"`
    AudioDurationSeconds *int    `json:"audio_duration_seconds"`
    TranscriptText    *string    `json:"transcript_text"`           // Filled after transcription
    SpeakingPartNumber *int      `json:"speaking_part_number"`      // 1, 2, 3
    
    // AI Evaluation Results
    EvaluationStatus  *string    `json:"evaluation_status"`         // pending, processing, completed, failed
    BandScore         *float64   `json:"band_score"`                // Overall IELTS band (0-9)
    DetailedScores    *string    `json:"detailed_scores"`           // JSONB with criteria scores
    AIFeedback        *string    `json:"ai_feedback"`               // Examiner feedback from AI
    AIEvaluationID    *string    `json:"ai_evaluation_id"`          // Reference to AI evaluation
    
    // Sync Tracking
    UserServiceSyncStatus string  `json:"user_service_sync_status"` // pending, synced, failed
    
    CreatedAt         time.Time  `json:"created_at"`
    UpdatedAt         time.Time  `json:"updated_at"`
}
```

### AIEvaluationResult Structure (Returned by AI Service)

```go
type AIEvaluationResult struct {
    OverallBandScore float64                `json:"overall_band_score"`
    DetailedScores   map[string]interface{} `json:"detailed_scores"`
    Feedback         string                 `json:"feedback"`
    CriteriaScores   map[string]float64     `json:"criteria_scores"`
}
```

**DetailedScores example (Writing):**
```json
{
  "task_achievement": 7.0,
  "coherence_cohesion": 7.5,
  "lexical_resource": 8.0,
  "grammatical_range": 7.0,
  "overall_band": 7.4,
  "strengths": ["Well-structured", "Clear ideas"],
  "weaknesses": ["Limited vocabulary", "Some grammar errors"]
}
```

---

## 8. Async Processing Architecture

### Writing Evaluation Flow (Detailed):

```
User clicks "Submit" (WritingSubmissionActivity)
        ↓
Exercise Service receives submit request
        ↓
1. Save essay text to database
2. Update submission status to "submitted" (immediate)
3. Mark evaluation status as "pending" (immediate)
4. Trigger async evaluation in background goroutine
        ↓
[Async Goroutine]
        ├─ Call AI Service: /api/v1/ai/internal/writing/evaluate
        ├─ Receive evaluation result (with band score + criteria scores)
        ├─ Update submission in database with AI results
        ├─ Change evaluation_status to "completed"
        └─ Record score to User Service (for learning progress)
        ↓
Frontend polls /api/v1/submissions/{id} to check evaluation_status
        ↓
When status = "completed", display results
```

### Speaking Evaluation Flow (Detailed):

```
User clicks "Submit" (SpeakingSubmissionActivity)
        ↓
Exercise Service receives submit request
        ↓
1. Save audio URL to database
2. Update submission status to "submitted" (immediate)
3. Mark evaluation status as "processing" (immediate)
4. Trigger async processing in background goroutine
        ↓
[Async Goroutine]
        ├─ Step 1: Transcribe audio
        │  └─ Call AI Service: /api/v1/ai/internal/speaking/transcribe
        ├─ Save transcript to database
        │
        ├─ Step 2: Evaluate speaking
        │  └─ Call AI Service: /api/v1/ai/internal/speaking/evaluate
        │  └─ Pass transcript + audio metadata
        │
        ├─ Receive evaluation result (with band score + criteria scores)
        ├─ Update submission in database with AI results + transcript
        ├─ Change evaluation_status to "completed"
        └─ Record score to User Service (for learning progress)
        ↓
Frontend polls /api/v1/submissions/{id} to check evaluation_status
        ↓
When status = "completed", display results (including transcript)
```

---

## 9. Configuration

### Environment Variables (Exercise Service)

```bash
# AI Service Configuration
AI_SERVICE_URL=http://ai-service:8086          # AI Service base URL
INTERNAL_API_KEY=internal_secret_key_ielts_2025  # Shared internal API key
```

### AI Service Client Initialization

```go
// In Exercise Service main.go
aiServiceClient := aiClient.NewAIServiceClient(
    cfg.AIServiceURL,      // "http://ai-service:8086"
    cfg.InternalAPIKey,    // Internal authentication
)
```

---

## 10. Error Handling & Retries

### Retry Configuration

**File:** [services/exercise-service/internal/service/submission_handler.go](services/exercise-service/internal/service/submission_handler.go)

```go
// Retry strategy with exponential backoff
AIServiceRetryConfig() → 
  Max Attempts: 3
  Initial Delay: 1 second
  Max Delay: 10 seconds
  Backoff Factor: 2x
```

**Retryable Errors:**
- Network timeouts
- HTTP 503 (Service Unavailable)
- HTTP 504 (Gateway Timeout)
- Connection reset

**Non-Retryable Errors:**
- HTTP 400 (Bad Request)
- HTTP 401 (Unauthorized)
- HTTP 404 (Not Found)

### Error Handling Example (Writing)

```go
result, err := s.aiServiceClient.EvaluateWriting(request)
if err != nil {
    log.Printf("❌ AI evaluation failed after retries: %v", err)
    s.repo.UpdateSubmissionEvaluationStatus(submissionID, "failed")
    return
}
```

---

## 11. Timing & Performance

### Expected Response Times

| Operation | Duration | Notes |
|-----------|----------|-------|
| Writing Evaluation | 5-15 seconds | Depends on essay length |
| Speaking Transcription | 10-30 seconds | Depends on audio duration |
| Speaking Evaluation | 5-10 seconds | Uses pre-transcribed text |
| **Total Speaking** | **20-40 seconds** | Transcription + Evaluation |

### HTTP Timeouts

- **AI Service client timeout:** 60 seconds (covers both evaluation types)
- **AI Service HTTP handler timeout:** Inherited from Gin framework

---

## 12. Example API Calls

### Writing Evaluation (cURL)

```bash
curl -X POST http://localhost:8086/api/v1/ai/internal/writing/evaluate \
  -H "Content-Type: application/json" \
  -H "X-API-Key: internal_secret_key_ielts_2025" \
  -d '{
    "essay_text": "Some IELTS writing sample essay...",
    "task_type": "task2",
    "prompt_text": "What are the benefits of remote work?"
  }'
```

### Speaking Evaluation (cURL)

```bash
curl -X POST http://localhost:8086/api/v1/ai/internal/speaking/evaluate \
  -H "Content-Type: application/json" \
  -H "X-API-Key: internal_secret_key_ielts_2025" \
  -d '{
    "audio_url": "http://minio:9000/bucket/audio.mp3",
    "transcript_text": "Well, I think...",
    "prompt_text": "Describe a person you admire",
    "part_number": 2,
    "word_count": 250,
    "duration": 120.5
  }'
```

---

## 13. Key Implementation Details

### Audio URL Conversion (Speaking)

When Exercise Service calls AI Service for speaking evaluation, it converts presigned URLs to internal URLs:

```go
audioURLForAI := audioURL

// Remove query parameters (presigned signature)
if strings.Contains(audioURL, "?") {
    parts := strings.Split(audioURL, "?")
    audioURLForAI = parts[0]  // Keep only base URL
}

// Replace localhost:9000 with minio:9000 (Docker internal network)
if strings.Contains(audioURLForAI, "localhost:9000") {
    audioURLForAI = strings.Replace(audioURLForAI, "localhost:9000", "minio:9000", 1)
}
```

### Database Persistence Flow

```
AI Service returns evaluation result
        ↓
Exercise Service receives result
        ↓
UpdateSubmissionWithAIResult() method:
  ├─ Update evaluation_status = "completed"
  ├─ Save overall band score
  ├─ Save detailed criteria scores (JSONB)
  ├─ Save AI examiner feedback
  └─ Update updated_at timestamp
        ↓
Results available in user_exercise_attempts table
```

---

## 14. Frontend Integration (Android)

### Writing Submission Activity

**File:** [ieltsapp/app/src/main/java/com/example/ieltsapp/ui/exercise/WritingSubmissionActivity.java](ieltsapp/app/src/main/java/com/example/ieltsapp/ui/exercise/WritingSubmissionActivity.java)

```java
// User clicks submit
viewModel.submitWriting(
    submissionId, 
    essayText, 
    taskType,
    promptText,
    timeSpentSeconds
);
```

### Writing Result Display

**File:** [ieltsapp/app/src/main/java/com/example/ieltsapp/ui/exercise/WritingResultActivity.java](ieltsapp/app/src/main/java/com/example/ieltsapp/ui/exercise/WritingResultActivity.java)

```java
private void displayWritingEvaluation(WritingEvaluationResponse evaluation) {
    WritingEvaluationResponse.CriteriaScores scores = evaluation.getCriteriaScores();
    
    // Display individual criteria
    taskAchievementScore.setText(String.format("%.1f", scores.taskAchievement));
    coherenceScore.setText(String.format("%.1f", scores.coherenceCohesion));
    lexicalScore.setText(String.format("%.1f", scores.lexicalResource));
    grammarScore.setText(String.format("%.1f", scores.grammaticalRange));
    
    // Display overall band
    overallBand.setText(String.format("%.1f", evaluation.overallBand));
    
    // Display feedback
    feedbackText.setText(evaluation.examinerFeedback);
}
```

---

## 15. Monitoring & Logging

### Log Examples from AI Service

```
✅ [AI Service] Downloaded audio: 245000 bytes
🎤 [AI Service] Calling OpenAI Whisper API to transcribe audio...
✅ [AI Service] Transcription successful. Transcript length: 1250 characters
📊 Speaking Evaluation Summary:
   Transcript: 250 words, 1250 characters
   Fluency & Coherence: 7.0
   Lexical Resource: 6.5
   Grammatical Range: 7.5
   Pronunciation: 7.0
   Overall Band: 7.1 (calculated from average)
```

### Log Examples from Exercise Service

```
🔄 Starting writing evaluation for submission [uuid]
📎 Removed query parameters from URL: http://minio:9000/bucket/audio.mp3
✅ Writing evaluation completed: 7.5 band
📊 Evaluation result: Band Score = 7.5
```

---

## 16. Summary Table

| Component | Location | Responsibility |
|-----------|----------|-----------------|
| **AI Service** | `services/ai-service/` | Evaluate essays/audio, return scores |
| **Exercise Service** | `services/exercise-service/` | Manage submissions, persist results, call AI |
| **Database** | PostgreSQL | Store submissions + evaluation results |
| **Android App** | `ieltsapp/` | Collect essay/audio, display results |
| **Frontend** | `Frontend-IELTSGo/` | Collect essay/audio, poll results, display |

---

## 17. Important Notes

✅ **AI Service is stateless** - No database access, pure evaluation engine

✅ **Async evaluation** - Results available ~5-40 seconds after submission

✅ **Criteria-based scoring** - 4 IELTS criteria, averaged for overall band

✅ **Bilingual feedback** - Feedback in Vietnamese + English

✅ **Caching enabled** - Identical inputs return cached results (faster)

✅ **Error resilient** - Automatic retries, graceful degradation on failure

⚠️ **Long timeouts possible** - Speaking evaluation can take 20-40 seconds

⚠️ **Async design** - Results NOT available immediately, frontend must poll

⚠️ **Empty transcript handling** - Speaking with empty transcript marked as failed

---

**Last Updated:** December 18, 2025

**Architecture Version:** 2.0 (Stateless AI Service with Async Evaluation)
