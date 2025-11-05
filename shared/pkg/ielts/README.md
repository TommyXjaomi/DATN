# IELTS Scoring Library

Centralized IELTS band score calculation library for all services in the platform.

## Features

- ✅ Listening score conversion (raw → band score)
- ✅ Reading score conversion for Academic and General Training
- ✅ Writing band calculation from 4 criteria
- ✅ Speaking band calculation from 4 criteria
- ✅ Overall band calculation
- ✅ Official IELTS rounding rules
- ✅ Comprehensive validation
- ✅ 100% test coverage

## Installation

```go
import "github.com/bisosad1501/DATN/shared/pkg/ielts"
```

## Usage

### Listening Score Conversion

```go
// Full test: 35/40 correct
bandScore := ielts.ConvertListeningScore(35, 40)
fmt.Println(bandScore) // Output: 8.0

// Practice test: 15/20 correct (normalized to 40)
bandScore = ielts.ConvertListeningScore(15, 20)
fmt.Println(bandScore) // Output: 7.0
```

### Reading Score Conversion

```go
// Academic: 30/40 correct
bandScore := ielts.ConvertReadingScore(30, 40, "academic")
fmt.Println(bandScore) // Output: 7.0

// General Training: 34/40 correct
bandScore = ielts.ConvertReadingScore(34, 40, "general")
fmt.Println(bandScore) // Output: 7.0
```

### Writing Band Calculation

```go
// Calculate from 4 criteria scores
bandScore := ielts.CalculateWritingBand(
	7.0, // Task Achievement
	6.5, // Coherence and Cohesion
	7.0, // Lexical Resource
	6.5, // Grammatical Range and Accuracy
)
fmt.Println(bandScore) // Output: 6.5 (average 6.75 → rounds to 7.0)
```

### Speaking Band Calculation

```go
// Calculate from 4 criteria scores
bandScore := ielts.CalculateSpeakingBand(
	7.5, // Fluency and Coherence
	7.0, // Lexical Resource
	7.0, // Grammatical Range and Accuracy
	7.5, // Pronunciation
)
fmt.Println(bandScore) // Output: 7.0 (average 7.25 → rounds to 7.0)
```

### Overall Band Calculation

```go
// Calculate overall band from 4 skills
overallBand := ielts.CalculateOverallBand(
	8.0, // Listening
	7.0, // Reading
	7.0, // Writing
	7.5, // Speaking
)
fmt.Println(overallBand) // Output: 7.5 (average 7.375 → rounds to 7.5)

// Partial calculation (some skills not taken)
overallBand = ielts.CalculateOverallBand(7.0, 7.0, 0.0, 0.0)
fmt.Println(overallBand) // Output: 7.0 (only L&R)
```

### Rounding

```go
// IELTS uses 0.5 increments
rounded := ielts.RoundToIELTSBand(6.625)
fmt.Println(rounded) // Output: 6.5

rounded = ielts.RoundToIELTSBand(6.75)
fmt.Println(rounded) // Output: 7.0
```

### Validation

```go
// Validate band score
err := ielts.ValidateBandScore(7.5)
if err != nil {
    // Handle error
}

// Check if valid (boolean)
isValid := ielts.IsValidBandScore(7.3)
fmt.Println(isValid) // Output: false (not 0.5 increment)

// Validate raw score
err = ielts.ValidateRawScore(35, 40)
if err != nil {
    // Handle error
}

// Validate writing criteria
err = ielts.ValidateWritingCriteria(7.0, 6.5, 7.0, 6.5)
if err != nil {
    // Handle error
}
```

## Official IELTS Conversion Tables

### Listening (Academic & General Training - Same)

| Correct | Band |
|---------|------|
| 39-40   | 9.0  |
| 37-38   | 8.5  |
| 35-36   | 8.0  |
| 32-34   | 7.5  |
| 30-31   | 7.0  |
| 26-29   | 6.5  |
| 23-25   | 6.0  |
| 18-22   | 5.5  |
| 16-17   | 5.0  |
| ...     | ...  |

### Reading - Academic

| Correct | Band |
|---------|------|
| 39-40   | 9.0  |
| 37-38   | 8.5  |
| 35-36   | 8.0  |
| 33-34   | 7.5  |
| 30-32   | 7.0  |
| 27-29   | 6.5  |
| 23-26   | 6.0  |
| ...     | ...  |

### Reading - General Training

| Correct | Band |
|---------|------|
| 40      | 9.0  |
| 39      | 8.5  |
| 37-38   | 8.0  |
| 36      | 7.5  |
| 34-35   | 7.0  |
| 32-33   | 6.5  |
| 30-31   | 6.0  |
| ...     | ...  |

## Rounding Rules

IELTS uses specific rounding rules for half bands:

- `.25` → rounds to nearest `.5` (down)
- `.75` → rounds to nearest `.5` (up)

Examples:
- `6.125` → `6.0`
- `6.25` → `6.5`
- `6.375` → `6.5`
- `6.625` → `6.5`
- `6.75` → `7.0`
- `6.875` → `7.0`

## Testing

Run tests with coverage:

```bash
cd shared/pkg/ielts
go test -v -cover
go test -coverprofile=coverage.out
go tool cover -html=coverage.out
```

## Design Principles

1. **Accuracy**: Uses official IELTS conversion tables
2. **Consistency**: Same percentage = same band score regardless of question count
3. **Flexibility**: Supports both full tests (40q) and practice tests (any count)
4. **Validation**: Comprehensive error checking
5. **Testability**: 100% test coverage
6. **Reusability**: Can be used by all services

## Integration

This library is used by:
- **user-service**: Calculate band scores when recording test results
- **exercise-service**: Convert raw scores for L/R submissions
- **ai-service**: Validate AI-generated band scores for W/S
- **frontend**: Display scores correctly

## Contributing

When adding new functions:
1. Follow existing naming conventions
2. Add comprehensive tests (aim for 100% coverage)
3. Document with clear examples
4. Follow official IELTS guidelines

## References

- [IELTS Official Scoring Guide](https://www.ielts.org/for-test-takers/how-ielts-is-scored)
- [IELTS Band Scores Explained](https://www.ielts.org/for-organisations/ielts-scoring-in-detail)
