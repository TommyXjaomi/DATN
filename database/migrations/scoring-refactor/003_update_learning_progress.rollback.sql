-- Rollback: Revert learning_progress table updates
-- Purpose: Remove new columns added for official test tracking
-- Database: user_db

-- Drop index
DROP INDEX IF EXISTS idx_learning_progress_last_test_date;

-- Drop constraints
ALTER TABLE learning_progress
    DROP CONSTRAINT IF EXISTS check_last_test_overall_score,
    DROP CONSTRAINT IF EXISTS check_highest_overall_score,
    DROP CONSTRAINT IF EXISTS check_listening_score,
    DROP CONSTRAINT IF EXISTS check_reading_score,
    DROP CONSTRAINT IF EXISTS check_writing_score,
    DROP CONSTRAINT IF EXISTS check_speaking_score,
    DROP CONSTRAINT IF EXISTS check_overall_score;

-- Revert column types back to DECIMAL(2,1)
ALTER TABLE learning_progress
    ALTER COLUMN listening_score TYPE DECIMAL(2,1),
    ALTER COLUMN reading_score TYPE DECIMAL(2,1),
    ALTER COLUMN writing_score TYPE DECIMAL(2,1),
    ALTER COLUMN speaking_score TYPE DECIMAL(2,1),
    ALTER COLUMN overall_score TYPE DECIMAL(2,1);

-- Drop new columns
ALTER TABLE learning_progress
    DROP COLUMN IF EXISTS last_test_date,
    DROP COLUMN IF EXISTS total_tests_taken,
    DROP COLUMN IF EXISTS last_test_overall_score,
    DROP COLUMN IF EXISTS highest_overall_score,
    DROP COLUMN IF EXISTS tests_this_month,
    DROP COLUMN IF EXISTS last_test_id;
