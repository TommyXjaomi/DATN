package models

import (
	"time"

	"github.com/google/uuid"
)

// OfficialTestResult represents an official IELTS test result for ONE skill
// Per-skill model: Each record represents one skill test (listening, reading, writing, or speaking)
// This is the SOURCE OF TRUTH for user's official band scores
type OfficialTestResult struct {
	ID     uuid.UUID `json:"id" db:"id"`
	UserID uuid.UUID `json:"user_id" db:"user_id" validate:"required"`

	// Test classification: full_test, mock_test, sectional_test, practice
	TestType string `json:"test_type" db:"test_type" validate:"required,oneof=full_test mock_test sectional_test practice"`

	// Which skill was tested
	SkillType string `json:"skill_type" db:"skill_type" validate:"required,oneof=listening reading writing speaking"`

	// IELTS test variant (academic/general_training) - ONLY for Reading skill
	// For Listening/Writing/Speaking, this should be NULL
	IELTSVariant *string `json:"ielts_variant,omitempty" db:"ielts_variant" validate:"omitempty,oneof=academic general_training"`

	// Final IELTS band score for THIS skill (0-9)
	BandScore float64 `json:"band_score" db:"band_score" validate:"required,min=0,max=9"`

	// Raw score for Listening/Reading only (number of correct answers)
	RawScore *int `json:"raw_score,omitempty" db:"raw_score" validate:"omitempty,min=0,max=40"`

	// Total questions for Listening/Reading (usually 40)
	TotalQuestions *int `json:"total_questions,omitempty" db:"total_questions" validate:"omitempty,min=0"`

	// Source tracking (audit trail)
	SourceService *string    `json:"source_service,omitempty" db:"source_service"` // exercise_service
	SourceTable   *string    `json:"source_table,omitempty" db:"source_table"`     // user_exercise_attempts
	SourceID      *uuid.UUID `json:"source_id,omitempty" db:"source_id"`           // submission_id

	// Test metadata
	TestDate            time.Time `json:"test_date" db:"test_date"`
	TestDurationMinutes *int      `json:"test_duration_minutes,omitempty" db:"test_duration_minutes" validate:"omitempty,min=0"`
	CompletionStatus    string    `json:"completion_status" db:"completion_status" validate:"required,oneof=completed incomplete abandoned"`
	TestSource          *string   `json:"test_source,omitempty" db:"test_source"` // platform, imported, manual_entry
	Notes               *string   `json:"notes,omitempty" db:"notes"`

	// Timestamps
	CreatedAt time.Time `json:"created_at" db:"created_at"`
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

// TableName returns the table name for OfficialTestResult
func (OfficialTestResult) TableName() string {
	return "official_test_results"
}

// Validate performs business logic validation
func (o *OfficialTestResult) Validate() error {
	// Additional business logic validation beyond struct tags
	// This could include checking if overall score matches average of skill scores
	return nil
}
