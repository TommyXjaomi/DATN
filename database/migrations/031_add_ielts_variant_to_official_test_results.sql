-- Migration 031: Add ielts_variant field to official_test_results
-- Date: 2025-11-06
-- Purpose: Separate IELTS test variant (academic/general) from test classification

BEGIN;

-- Step 1: Add ielts_variant column
ALTER TABLE official_test_results
    ADD COLUMN ielts_variant VARCHAR(20);

-- Step 2: Add comment
COMMENT ON COLUMN official_test_results.ielts_variant IS 
    'IELTS test variant: academic or general_training. Only applicable for Reading skill. NULL for Listening/Writing/Speaking.';

-- Step 3: Migrate existing data
-- Records with test_type = 'academic' or 'general' are Reading tests
UPDATE official_test_results
SET ielts_variant = CASE
    WHEN test_type = 'academic' THEN 'academic'
    WHEN test_type = 'general' THEN 'general_training'
    ELSE NULL
END
WHERE skill_type = 'reading' AND test_type IN ('academic', 'general');

-- For Reading records, set default to 'academic' if not set
UPDATE official_test_results
SET ielts_variant = 'academic'
WHERE skill_type = 'reading' AND ielts_variant IS NULL;

-- Step 4: Update test_type for migrated records
-- Change 'academic'/'general' back to 'full_test' (proper test classification)
UPDATE official_test_results
SET test_type = 'full_test'
WHERE test_type IN ('academic', 'general');

-- Step 5: Update constraint for test_type
ALTER TABLE official_test_results
    DROP CONSTRAINT IF EXISTS official_test_results_test_type_check;

ALTER TABLE official_test_results
    ADD CONSTRAINT official_test_results_test_type_check
    CHECK (test_type IN ('full_test', 'mock_test', 'sectional_test', 'practice'));

-- Step 6: Add constraint for ielts_variant values
ALTER TABLE official_test_results
    ADD CONSTRAINT official_test_results_ielts_variant_check
    CHECK (ielts_variant IS NULL OR ielts_variant IN ('academic', 'general_training'));

-- Step 7: Add business rule constraint
-- ielts_variant should only be set for Reading skill
ALTER TABLE official_test_results
    ADD CONSTRAINT official_test_results_reading_variant_rule
    CHECK (
        (skill_type = 'reading' AND ielts_variant IS NOT NULL) OR
        (skill_type != 'reading' AND ielts_variant IS NULL)
    );

-- Step 8: Create index for common queries
CREATE INDEX idx_official_test_results_variant 
    ON official_test_results(skill_type, ielts_variant) 
    WHERE ielts_variant IS NOT NULL;

COMMIT;

-- Verification queries
DO $$
BEGIN
    RAISE NOTICE '=== Migration 031 Verification ===';
    RAISE NOTICE 'Total records: %', (SELECT COUNT(*) FROM official_test_results);
    RAISE NOTICE 'Reading records with variant: %', (SELECT COUNT(*) FROM official_test_results WHERE skill_type = 'reading' AND ielts_variant IS NOT NULL);
    RAISE NOTICE 'Non-reading records (should have NULL variant): %', (SELECT COUNT(*) FROM official_test_results WHERE skill_type != 'reading' AND ielts_variant IS NULL);
    RAISE NOTICE 'Test types distribution:';
    RAISE NOTICE '%', (SELECT string_agg(test_type || ': ' || cnt::text, ', ') FROM (SELECT test_type, COUNT(*) as cnt FROM official_test_results GROUP BY test_type) sub);
END $$;
