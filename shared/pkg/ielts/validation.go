package ielts

import "fmt"

// ValidateBandScore checks if a band score is valid
// Valid range: 0.0 to 9.0 with 0.5 increments
//
// Parameters:
//   - score: Band score to validate
//
// Returns:
//   - error if invalid, nil if valid
func ValidateBandScore(score float64) error {
	if score < 0.0 || score > 9.0 {
		return fmt.Errorf("band score must be between 0.0 and 9.0, got %.1f", score)
	}

	// Check if score is a multiple of 0.5
	// Multiply by 2, should be a whole number
	doubled := score * 2.0
	if doubled != float64(int(doubled)) {
		return fmt.Errorf("band score must be in 0.5 increments, got %.2f", score)
	}

	return nil
}

// IsValidBandScore returns true if band score is valid
func IsValidBandScore(score float64) bool {
	return ValidateBandScore(score) == nil
}

// ValidateRawScore checks if a raw score is valid
//
// Parameters:
//   - correct: Number of correct answers
//   - total: Total number of questions
//
// Returns:
//   - error if invalid, nil if valid
func ValidateRawScore(correct, total int) error {
	if total <= 0 {
		return fmt.Errorf("total questions must be positive, got %d", total)
	}
	if correct < 0 {
		return fmt.Errorf("correct answers cannot be negative, got %d", correct)
	}
	if correct > total {
		return fmt.Errorf("correct answers (%d) cannot exceed total questions (%d)", correct, total)
	}
	return nil
}

// ValidateWritingCriteria validates writing assessment criteria scores
func ValidateWritingCriteria(taskAchievement, coherenceCohesion, lexicalResource, grammaticalAccuracy float64) error {
	if err := ValidateBandScore(taskAchievement); err != nil {
		return fmt.Errorf("task achievement: %w", err)
	}
	if err := ValidateBandScore(coherenceCohesion); err != nil {
		return fmt.Errorf("coherence and cohesion: %w", err)
	}
	if err := ValidateBandScore(lexicalResource); err != nil {
		return fmt.Errorf("lexical resource: %w", err)
	}
	if err := ValidateBandScore(grammaticalAccuracy); err != nil {
		return fmt.Errorf("grammatical range and accuracy: %w", err)
	}
	return nil
}

// ValidateSpeakingCriteria validates speaking assessment criteria scores
func ValidateSpeakingCriteria(fluencyCoherence, lexicalResource, grammaticalAccuracy, pronunciation float64) error {
	if err := ValidateBandScore(fluencyCoherence); err != nil {
		return fmt.Errorf("fluency and coherence: %w", err)
	}
	if err := ValidateBandScore(lexicalResource); err != nil {
		return fmt.Errorf("lexical resource: %w", err)
	}
	if err := ValidateBandScore(grammaticalAccuracy); err != nil {
		return fmt.Errorf("grammatical range and accuracy: %w", err)
	}
	if err := ValidateBandScore(pronunciation); err != nil {
		return fmt.Errorf("pronunciation: %w", err)
	}
	return nil
}

// ValidateOverallScores validates all 4 skill scores for overall calculation
func ValidateOverallScores(listening, reading, writing, speaking float64) error {
	scores := map[string]float64{
		"listening": listening,
		"reading":   reading,
		"writing":   writing,
		"speaking":  speaking,
	}

	for skill, score := range scores {
		if score > 0 { // Only validate non-zero scores
			if err := ValidateBandScore(score); err != nil {
				return fmt.Errorf("%s: %w", skill, err)
			}
		}
	}

	return nil
}
