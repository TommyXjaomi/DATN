-- Rollback Migration 031: Remove ielts_variant field
-- Date: 2025-11-06

BEGIN;

-- Step 1: Migrate ielts_variant back to test_type for Reading
UPDATE official_test_results
SET test_type = CASE
    WHEN ielts_variant = 'academic' THEN 'academic'
    WHEN ielts_variant = 'general_training' THEN 'general'
    ELSE test_type
END
WHERE skill_type = 'reading' AND ielts_variant IS NOT NULL;

-- Step 2: Drop constraints
ALTER TABLE official_test_results
    DROP CONSTRAINT IF EXISTS official_test_results_reading_variant_rule,
    DROP CONSTRAINT IF EXISTS official_test_results_ielts_variant_check;

-- Step 3: Drop index
DROP INDEX IF EXISTS idx_official_test_results_variant;

-- Step 4: Drop column
ALTER TABLE official_test_results
    DROP COLUMN IF EXISTS ielts_variant;

-- Step 5: Restore old test_type constraint
ALTER TABLE official_test_results
    DROP CONSTRAINT IF EXISTS official_test_results_test_type_check;

ALTER TABLE official_test_results
    ADD CONSTRAINT official_test_results_test_type_check
    CHECK (test_type IN ('full_test', 'academic', 'general'));

COMMIT;

-- Verification
DO $$
BEGIN
    RAISE NOTICE '=== Rollback 031 Complete ===';
    RAISE NOTICE 'Column ielts_variant removed: %', NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'official_test_results' 
        AND column_name = 'ielts_variant'
    );
END $$;
