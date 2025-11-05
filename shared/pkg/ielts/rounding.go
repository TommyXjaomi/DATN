package ielts

import "math"

// RoundToIELTSBand rounds a score to the nearest IELTS band score
// IELTS uses 0.5 increments (e.g., 6.0, 6.5, 7.0, 7.5, 8.0)
//
// Official IELTS rounding rules:
// - Scores ending in .25 round DOWN to the nearest 0.5
// - Scores ending in .75 round UP to the nearest 0.5
// - Examples:
//   - 6.125 → 6.0
//   - 6.25 → 6.5
//   - 6.375 → 6.5
//   - 6.625 → 6.5
//   - 6.75 → 7.0
//   - 6.875 → 7.0
//
// Parameters:
//   - score: Raw score to round
//
// Returns:
//   - Rounded IELTS band score (0.0-9.0 with 0.5 increments)
func RoundToIELTSBand(score float64) float64 {
	if score < 0 {
		return 0.0
	}
	if score > 9.0 {
		return 9.0
	}

	// Multiply by 2, round to nearest integer, then divide by 2
	// This gives us 0.5 increments
	// Example: 6.625 * 2 = 13.25 → rounds to 13 → 13/2 = 6.5
	rounded := math.Round(score*2.0) / 2.0

	// Clamp to valid range [0.0, 9.0]
	if rounded > 9.0 {
		return 9.0
	}
	if rounded < 0.0 {
		return 0.0
	}

	return rounded
}

// RoundToHalfBand is an alias for RoundToIELTSBand for clarity
func RoundToHalfBand(score float64) float64 {
	return RoundToIELTSBand(score)
}

// RoundToWholeBand rounds a score to the nearest whole band (no 0.5)
// Used in some reporting contexts
//
// Parameters:
//   - score: Raw score to round
//
// Returns:
//   - Rounded whole band score (0.0-9.0 with 1.0 increments)
func RoundToWholeBand(score float64) float64 {
	if score < 0 {
		return 0.0
	}
	if score > 9.0 {
		return 9.0
	}

	return math.Round(score)
}
