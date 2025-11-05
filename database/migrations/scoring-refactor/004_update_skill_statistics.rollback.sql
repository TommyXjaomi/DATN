-- Rollback: Revert skill_statistics table updates
-- Purpose: Remove new columns for test/practice separation
-- Database: user_db

-- Drop index
DROP INDEX IF EXISTS idx_skill_statistics_last_test_date;

-- Drop constraints
ALTER TABLE skill_statistics
    DROP CONSTRAINT IF EXISTS check_test_average_band_score,
    DROP CONSTRAINT IF EXISTS check_test_best_band_score,
    DROP CONSTRAINT IF EXISTS check_last_test_band_score;

-- Drop new columns
ALTER TABLE skill_statistics
    DROP COLUMN IF EXISTS practice_only_count,
    DROP COLUMN IF EXISTS practice_average_score,
    DROP COLUMN IF EXISTS practice_best_score,
    DROP COLUMN IF EXISTS test_count,
    DROP COLUMN IF EXISTS test_average_band_score,
    DROP COLUMN IF EXISTS test_best_band_score,
    DROP COLUMN IF EXISTS last_test_date,
    DROP COLUMN IF EXISTS last_test_band_score;
