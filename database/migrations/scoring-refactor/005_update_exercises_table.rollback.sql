-- Rollback: Revert exercises table updates
-- Purpose: Remove test categorization fields
-- Database: exercise_db

-- Drop indexes
DROP INDEX IF EXISTS idx_exercises_is_official_test;
DROP INDEX IF EXISTS idx_exercises_test_category;

-- Remove check constraint
ALTER TABLE exercises
    DROP CONSTRAINT IF EXISTS exercises_test_category_check;

-- Drop columns
ALTER TABLE exercises
    DROP COLUMN IF EXISTS is_official_test,
    DROP COLUMN IF EXISTS test_category;
