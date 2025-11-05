package ielts

// ConvertListeningScore converts raw listening score to IELTS band score (0-9 scale)
// Listening uses the same conversion table for both Academic and General Training
//
// Parameters:
//   - correctAnswers: Number of correct answers (0-40)
//   - totalQuestions: Total number of questions in the test
//
// Returns:
//   - IELTS band score (0.0-9.0)
//
// For tests with fewer than 40 questions, the score is normalized proportionally
// Example: 15/20 correct = 75% = 30/40 normalized = Band 7.0
func ConvertListeningScore(correctAnswers, totalQuestions int) float64 {
	if totalQuestions <= 0 || correctAnswers < 0 {
		return 0.0
	}

	// Normalize to 40 questions (IELTS standard)
	normalizedCorrect := normalizeToFortyQuestions(correctAnswers, totalQuestions)

	// Apply official IELTS Listening conversion table
	return listeningConversionTable(normalizedCorrect)
}

// ConvertReadingScore converts raw reading score to IELTS band score (0-9 scale)
// Reading has different conversion tables for Academic and General Training
//
// Parameters:
//   - correctAnswers: Number of correct answers (0-40)
//   - totalQuestions: Total number of questions in the test
//   - testType: "academic" or "general" (defaults to "academic" if empty)
//
// Returns:
//   - IELTS band score (0.0-9.0)
func ConvertReadingScore(correctAnswers, totalQuestions int, testType string) float64 {
	if totalQuestions <= 0 || correctAnswers < 0 {
		return 0.0
	}

	// Normalize to 40 questions
	normalizedCorrect := normalizeToFortyQuestions(correctAnswers, totalQuestions)

	// Normalize test type
	normalizedTestType := normalizeTestType(testType)

	// Apply appropriate conversion table
	if normalizedTestType == "general" {
		return readingGeneralConversionTable(normalizedCorrect)
	}
	return readingAcademicConversionTable(normalizedCorrect)
}

// CalculateWritingBand calculates overall writing band score from 4 criteria
// Each criterion is scored 0-9 with 0.5 increments
//
// Parameters:
//   - taskAchievement: Task Achievement score (0.0-9.0)
//   - coherenceCohesion: Coherence and Cohesion score (0.0-9.0)
//   - lexicalResource: Lexical Resource score (0.0-9.0)
//   - grammaticalAccuracy: Grammatical Range and Accuracy score (0.0-9.0)
//
// Returns:
//   - Overall IELTS writing band score (0.0-9.0), rounded to nearest 0.5
//
// Formula: Average of 4 criteria, rounded according to IELTS rules
func CalculateWritingBand(taskAchievement, coherenceCohesion, lexicalResource, grammaticalAccuracy float64) float64 {
	// Validate inputs
	if !isValidBandScore(taskAchievement) || !isValidBandScore(coherenceCohesion) ||
		!isValidBandScore(lexicalResource) || !isValidBandScore(grammaticalAccuracy) {
		return 0.0
	}

	// Calculate average
	average := (taskAchievement + coherenceCohesion + lexicalResource + grammaticalAccuracy) / 4.0

	// Round to IELTS band (nearest 0.5)
	return RoundToIELTSBand(average)
}

// CalculateSpeakingBand calculates overall speaking band score from 4 criteria
// Each criterion is scored 0-9 with 0.5 increments
//
// Parameters:
//   - fluencyCoherence: Fluency and Coherence score (0.0-9.0)
//   - lexicalResource: Lexical Resource score (0.0-9.0)
//   - grammaticalAccuracy: Grammatical Range and Accuracy score (0.0-9.0)
//   - pronunciation: Pronunciation score (0.0-9.0)
//
// Returns:
//   - Overall IELTS speaking band score (0.0-9.0), rounded to nearest 0.5
//
// Formula: Average of 4 criteria, rounded according to IELTS rules
func CalculateSpeakingBand(fluencyCoherence, lexicalResource, grammaticalAccuracy, pronunciation float64) float64 {
	// Validate inputs
	if !isValidBandScore(fluencyCoherence) || !isValidBandScore(lexicalResource) ||
		!isValidBandScore(grammaticalAccuracy) || !isValidBandScore(pronunciation) {
		return 0.0
	}

	// Calculate average
	average := (fluencyCoherence + lexicalResource + grammaticalAccuracy + pronunciation) / 4.0

	// Round to IELTS band (nearest 0.5)
	return RoundToIELTSBand(average)
}

// CalculateOverallBand calculates overall IELTS band score from 4 skill scores
//
// Parameters:
//   - listening: Listening band score (0.0-9.0)
//   - reading: Reading band score (0.0-9.0)
//   - writing: Writing band score (0.0-9.0)
//   - speaking: Speaking band score (0.0-9.0)
//
// Returns:
//   - Overall IELTS band score (0.0-9.0), rounded to nearest 0.5
//
// Formula: Average of 4 skills, rounded according to IELTS rules
// If any skill is 0 (not taken), it's excluded from calculation
func CalculateOverallBand(listening, reading, writing, speaking float64) float64 {
	var sum float64
	var count int

	// Only include non-zero scores
	if listening > 0 {
		sum += listening
		count++
	}
	if reading > 0 {
		sum += reading
		count++
	}
	if writing > 0 {
		sum += writing
		count++
	}
	if speaking > 0 {
		sum += speaking
		count++
	}

	if count == 0 {
		return 0.0
	}

	average := sum / float64(count)
	return RoundToIELTSBand(average)
}

// normalizeToFortyQuestions normalizes a score to 40 questions standard
func normalizeToFortyQuestions(correct, total int) int {
	if total == 40 {
		return correct
	}
	if total <= 0 {
		return 0
	}

	// Scale proportionally: (correct / total) * 40
	normalized := int(float64(correct) / float64(total) * 40.0)

	// Clamp to valid range [0, 40]
	if normalized > 40 {
		return 40
	}
	if normalized < 0 {
		return 0
	}
	return normalized
}

// normalizeTestType normalizes test type string to "academic" or "general"
func normalizeTestType(testType string) string {
	switch testType {
	case "general", "general_training", "gt", "General", "General Training":
		return "general"
	default:
		return "academic"
	}
}

// isValidBandScore checks if a band score is in valid range
func isValidBandScore(score float64) bool {
	return score >= 0.0 && score <= 9.0
}
