-- ============================================
-- MIGRATION 019: ADD ielts_test_type TO EXERCISES
-- ============================================
-- Purpose: Add ielts_test_type field to exercises table for Reading exercises
--          to explicitly store Academic vs General Training test type
-- Author: System
-- Date: 2025-11-04
-- 
-- CHANGES:
-- 1. Add ielts_test_type column to exercises table
-- 2. Update existing Reading exercises based on title/slug
-- 3. Create index for performance
--
-- ROLLBACK: See rollback section at the end
-- ============================================

\c exercise_db;

-- ============================================
-- STEP 1: ADD COLUMN
-- ============================================

DO $$ 
BEGIN
    -- Check if column exists before adding
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public'
        AND table_name = 'exercises' 
        AND column_name = 'ielts_test_type'
    ) THEN
        -- Add column with default value
        ALTER TABLE exercises 
        ADD COLUMN ielts_test_type VARCHAR(20) DEFAULT 'academic';
        
        -- Add check constraint
        ALTER TABLE exercises 
        ADD CONSTRAINT chk_exercises_ielts_test_type 
        CHECK (ielts_test_type IN ('academic', 'general_training'));
        
        RAISE NOTICE '✅ Added ielts_test_type column to exercises table';
    ELSE
        RAISE NOTICE '⏭️  Column ielts_test_type already exists';
    END IF;
END $$;

-- ============================================
-- STEP 2: UPDATE EXISTING READING EXERCISES
-- ============================================
-- Update existing Reading exercises based on title/slug patterns
-- Uses same logic as in Go code for consistency

UPDATE exercises 
SET ielts_test_type = CASE
    -- Check for explicit "general training" patterns
    WHEN LOWER(title) LIKE '%general training%' 
         OR LOWER(title) LIKE '%general-training%'
         OR LOWER(title) LIKE '% general %'
         OR LOWER(title) LIKE '% gt %'
         OR LOWER(title) LIKE '%-gt%'
         OR LOWER(title) LIKE '%gt-%'
         OR LOWER(slug) LIKE '%general-training%'
         OR LOWER(slug) LIKE '%general-training%'
         OR LOWER(slug) LIKE '%-gt%'
         OR LOWER(slug) LIKE '%gt-%'
    THEN 'general_training'
    -- Check for standalone "gt" at start/end or with spaces/dashes
    WHEN LOWER(title) LIKE 'gt %'
         OR LOWER(title) LIKE '% gt'
         OR LOWER(title) LIKE '% gt %'
         OR LOWER(slug) LIKE 'gt-%'
         OR LOWER(slug) LIKE '%-gt'
         OR LOWER(slug) LIKE '%-gt-%'
    THEN 'general_training'
    -- Default to Academic
    ELSE 'academic'
END
WHERE skill_type = 'reading'
  AND (ielts_test_type IS NULL OR ielts_test_type = 'academic');

-- Set default for non-Reading exercises (should be NULL, but set to academic for consistency)
UPDATE exercises 
SET ielts_test_type = 'academic'
WHERE skill_type != 'reading'
  AND ielts_test_type IS NULL;

-- ============================================
-- STEP 3: CREATE INDEX
-- ============================================

CREATE INDEX IF NOT EXISTS idx_exercises_test_type 
ON exercises(skill_type, ielts_test_type) 
WHERE skill_type = 'reading';

-- ============================================
-- STEP 4: ADD COMMENT
-- ============================================

COMMENT ON COLUMN exercises.ielts_test_type IS 
'IELTS test type for Reading exercises: "academic" or "general_training". 
Only applicable for Reading skill type. 
For Listening, Writing, Speaking: always NULL or "academic" (not used).';

-- ============================================
-- VERIFICATION
-- ============================================

DO $$
DECLARE
    total_exercises INT;
    reading_exercises INT;
    academic_count INT;
    general_training_count INT;
BEGIN
    SELECT COUNT(*) INTO total_exercises FROM exercises;
    SELECT COUNT(*) INTO reading_exercises FROM exercises WHERE skill_type = 'reading';
    SELECT COUNT(*) INTO academic_count FROM exercises WHERE skill_type = 'reading' AND ielts_test_type = 'academic';
    SELECT COUNT(*) INTO general_training_count FROM exercises WHERE skill_type = 'reading' AND ielts_test_type = 'general_training';
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'MIGRATION 019 VERIFICATION:';
    RAISE NOTICE '  Total exercises: %', total_exercises;
    RAISE NOTICE '  Reading exercises: %', reading_exercises;
    RAISE NOTICE '  Academic: %', academic_count;
    RAISE NOTICE '  General Training: %', general_training_count;
    RAISE NOTICE '========================================';
END $$;

-- ============================================
-- ROLLBACK SCRIPT
-- ============================================
-- To rollback this migration, run:
-- 
-- \c exercise_db;
-- 
-- DROP INDEX IF EXISTS idx_exercises_test_type;
-- 
-- ALTER TABLE exercises DROP CONSTRAINT IF EXISTS chk_exercises_ielts_test_type;
-- ALTER TABLE exercises DROP COLUMN IF EXISTS ielts_test_type;
-- 
-- COMMENT ON COLUMN exercises.ielts_test_type IS NULL;
-- 
-- ============================================


