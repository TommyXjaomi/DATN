package ielts

// listeningConversionTable returns IELTS band score for Listening
// Based on official IELTS conversion table
// Same table used for both Academic and General Training
func listeningConversionTable(correctAnswers int) float64 {
	switch {
	case correctAnswers >= 39:
		return 9.0
	case correctAnswers >= 37:
		return 8.5
	case correctAnswers >= 35:
		return 8.0
	case correctAnswers >= 32:
		return 7.5
	case correctAnswers >= 30:
		return 7.0
	case correctAnswers >= 26:
		return 6.5
	case correctAnswers >= 23:
		return 6.0
	case correctAnswers >= 18:
		return 5.5
	case correctAnswers >= 16:
		return 5.0
	case correctAnswers >= 13:
		return 4.5
	case correctAnswers >= 10:
		return 4.0
	case correctAnswers >= 8:
		return 3.5
	case correctAnswers >= 6:
		return 3.0
	case correctAnswers >= 4:
		return 2.5
	case correctAnswers >= 2:
		return 2.0
	case correctAnswers >= 1:
		return 1.0
	default:
		return 0.0
	}
}

// readingAcademicConversionTable returns IELTS band score for Reading (Academic)
// Based on official IELTS conversion table for Academic module
func readingAcademicConversionTable(correctAnswers int) float64 {
	switch {
	case correctAnswers >= 39:
		return 9.0
	case correctAnswers >= 37:
		return 8.5
	case correctAnswers >= 35:
		return 8.0
	case correctAnswers >= 33:
		return 7.5
	case correctAnswers >= 30:
		return 7.0
	case correctAnswers >= 27:
		return 6.5
	case correctAnswers >= 23:
		return 6.0
	case correctAnswers >= 19:
		return 5.5
	case correctAnswers >= 15:
		return 5.0
	case correctAnswers >= 13:
		return 4.5
	case correctAnswers >= 10:
		return 4.0
	case correctAnswers >= 8:
		return 3.5
	case correctAnswers >= 6:
		return 3.0
	case correctAnswers >= 4:
		return 2.5
	case correctAnswers >= 2:
		return 2.0
	case correctAnswers >= 1:
		return 1.0
	default:
		return 0.0
	}
}

// readingGeneralConversionTable returns IELTS band score for Reading (General Training)
// Based on official IELTS conversion table for General Training module
func readingGeneralConversionTable(correctAnswers int) float64 {
	switch {
	case correctAnswers >= 40:
		return 9.0
	case correctAnswers >= 39:
		return 8.5
	case correctAnswers >= 37:
		return 8.0
	case correctAnswers >= 36:
		return 7.5
	case correctAnswers >= 34:
		return 7.0
	case correctAnswers >= 32:
		return 6.5
	case correctAnswers >= 30:
		return 6.0
	case correctAnswers >= 27:
		return 5.5
	case correctAnswers >= 23:
		return 5.0
	case correctAnswers >= 19:
		return 4.5
	case correctAnswers >= 15:
		return 4.0
	case correctAnswers >= 12:
		return 3.5
	case correctAnswers >= 9:
		return 3.0
	case correctAnswers >= 6:
		return 2.5
	case correctAnswers >= 4:
		return 2.0
	case correctAnswers >= 2:
		return 1.0
	default:
		return 0.0
	}
}
