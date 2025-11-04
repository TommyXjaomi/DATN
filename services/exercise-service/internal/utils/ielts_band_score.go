package utils

// ConvertRawScoreToBandScore converts raw score (number of correct answers) to IELTS band score
// Based on official IELTS conversion tables
// Listening: Same for Academic and General Training
// Reading: Different for Academic and General Training
//
// This function handles both:
// - Full tests (40 questions): Uses conversion table directly
// - Practice tests (any number of questions): Normalizes to 40 questions first, then uses conversion table
//
// This approach ensures consistency with official IELTS scoring while supporting flexible practice exercises
//
// Parameters:
//   - skillType: "listening" or "reading"
//   - correctCount: Number of correct answers
//   - totalQuestions: Total number of questions
//   - testType: "academic" or "general_training" (optional, defaults to "academic" for reading)
func ConvertRawScoreToBandScore(skillType string, correctCount, totalQuestions int, testType ...string) float64 {
	if totalQuestions == 0 || correctCount < 0 {
		return 0.0
	}

	// Normalize to 40 questions (IELTS standard)
	// For practice tests with different number of questions, scale proportionally
	// This ensures consistency: same percentage = same band score regardless of total questions
	var normalizedCorrect int
	if totalQuestions == 40 {
		// Full test: use raw score directly
		normalizedCorrect = correctCount
	} else if totalQuestions > 0 {
		// Practice test: scale proportionally to 40 questions
		// Formula: (correctCount / totalQuestions) * 40
		// Example: 15/20 correct = 30/40 normalized = same band score
		normalizedCorrect = int(float64(correctCount) / float64(totalQuestions) * 40.0)
		if normalizedCorrect > 40 {
			normalizedCorrect = 40
		}
		if normalizedCorrect < 0 {
			normalizedCorrect = 0
		}
	} else {
		return 0.0
	}

	switch skillType {
	case "listening":
		// Listening uses same conversion table for both Academic and General Training
		return convertListeningBandScore(normalizedCorrect)
	case "reading":
		// Reading has different conversion tables for Academic vs General Training
		// Determine test type from parameter or default to "academic"
		readingTestType := "academic"
		if len(testType) > 0 && testType[0] != "" {
			// Normalize test type values
			testTypeValue := testType[0]
			if testTypeValue == "general_training" || testTypeValue == "general" || testTypeValue == "gt" {
				readingTestType = "general_training"
			}
		}
		
		if readingTestType == "general_training" {
			return convertReadingGeneralBandScore(normalizedCorrect)
		}
		// Default to Academic
		return convertReadingAcademicBandScore(normalizedCorrect)
	default:
		// For other skills (writing, speaking) or unknown, return 0
		// These skills are scored directly by AI, not by raw score conversion
		return 0.0
	}
}

// convertListeningBandScore converts raw score to band score for Listening
// Academic and General Training use the same conversion table
func convertListeningBandScore(correct int) float64 {
	switch {
	case correct >= 39:
		return 9.0
	case correct >= 37:
		return 8.5
	case correct >= 35:
		return 8.0
	case correct >= 32:
		return 7.5
	case correct >= 30:
		return 7.0
	case correct >= 26:
		return 6.5
	case correct >= 23:
		return 6.0
	case correct >= 18:
		return 5.5
	case correct >= 16:
		return 5.0
	case correct >= 13:
		return 4.5
	case correct >= 10:
		return 4.0
	case correct >= 8:
		return 3.5
	case correct >= 6:
		return 3.0
	case correct >= 4:
		return 2.5
	case correct >= 2:
		return 2.0
	case correct >= 1:
		return 1.0
	default:
		return 0.0
	}
}

// convertReadingAcademicBandScore converts raw score to band score for Reading (Academic)
func convertReadingAcademicBandScore(correct int) float64 {
	switch {
	case correct >= 39:
		return 9.0
	case correct >= 37:
		return 8.5
	case correct >= 35:
		return 8.0
	case correct >= 33:
		return 7.5
	case correct >= 30:
		return 7.0
	case correct >= 27:
		return 6.5
	case correct >= 23:
		return 6.0
	case correct >= 19:
		return 5.5
	case correct >= 15:
		return 5.0
	case correct >= 13:
		return 4.5
	case correct >= 10:
		return 4.0
	case correct >= 8:
		return 3.5
	case correct >= 6:
		return 3.0
	case correct >= 4:
		return 2.5
	case correct >= 2:
		return 2.0
	case correct >= 1:
		return 1.0
	default:
		return 0.0
	}
}

// convertReadingGeneralBandScore converts raw score to band score for Reading (General Training)
func convertReadingGeneralBandScore(correct int) float64 {
	switch {
	case correct >= 40:
		return 9.0
	case correct >= 39:
		return 8.5
	case correct >= 37:
		return 8.0
	case correct >= 36:
		return 7.5
	case correct >= 34:
		return 7.0
	case correct >= 32:
		return 6.5
	case correct >= 30:
		return 6.0
	case correct >= 27:
		return 5.5
	case correct >= 23:
		return 5.0
	case correct >= 19:
		return 4.5
	case correct >= 15:
		return 4.0
	case correct >= 12:
		return 3.5
	case correct >= 9:
		return 3.0
	case correct >= 6:
		return 2.5
	case correct >= 4:
		return 2.0
	case correct >= 2:
		return 1.0
	default:
		return 0.0
	}
}

