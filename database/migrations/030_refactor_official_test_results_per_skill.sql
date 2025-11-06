-- Migration: Refactor official_test_results to per-skill model (following docs)
-- Date: 2025-11-06
-- Purpose: Change from "4 skills in 1 record" to "1 skill per record" for clarity

BEGIN;

-- Step 0: Drop NOT NULL constraint from old columns to allow migration
ALTER TABLE official_test_results
    ALTER COLUMN listening_score DROP NOT NULL,
    ALTER COLUMN reading_score DROP NOT NULL,
    ALTER COLUMN writing_score DROP NOT NULL,
    ALTER COLUMN speaking_score DROP NOT NULL,
    ALTER COLUMN overall_band_score DROP NOT NULL;

-- Step 1: Add new columns
ALTER TABLE official_test_results
    ADD COLUMN skill_type VARCHAR(20),
    ADD COLUMN band_score DECIMAL(3,1),
    ADD COLUMN raw_score INT,
    ADD COLUMN total_questions INT,
    ADD COLUMN source_service VARCHAR(50),
    ADD COLUMN source_table VARCHAR(50),
    ADD COLUMN source_id UUID;

-- Step 2: Add comments
COMMENT ON COLUMN official_test_results.skill_type IS 'Which skill was tested: listening, reading, writing, speaking';
COMMENT ON COLUMN official_test_results.band_score IS 'Final IELTS band score for this skill (0-9)';
COMMENT ON COLUMN official_test_results.raw_score IS 'Raw score for L/R (number of correct answers)';
COMMENT ON COLUMN official_test_results.total_questions IS 'Total questions for L/R (usually 40)';
COMMENT ON COLUMN official_test_results.source_service IS 'Which service created this record (exercise_service)';
COMMENT ON COLUMN official_test_results.source_table IS 'Which table holds the original submission (user_exercise_attempts)';
COMMENT ON COLUMN official_test_results.source_id IS 'UUID of the original submission';

-- Step 3: Migrate existing data - Split records with multiple skills into separate records
-- We'll create new records for each skill that has a score > 0

-- Create temporary table to hold expanded records
CREATE TEMP TABLE temp_expanded_test_results AS
SELECT 
    gen_random_uuid() as new_id,
    user_id,
    test_type,
    test_date,
    test_duration_minutes,
    completion_status,
    test_source,
    notes,
    created_at,
    updated_at,
    -- Skill-specific data
    'listening' as skill_type,
    listening_score as band_score,
    listening_raw_score as raw_score,
    CASE WHEN listening_raw_score IS NOT NULL THEN 40 ELSE NULL END as total_questions
FROM official_test_results
WHERE listening_score > 0

UNION ALL

SELECT 
    gen_random_uuid() as new_id,
    user_id,
    test_type,
    test_date,
    test_duration_minutes,
    completion_status,
    test_source,
    notes,
    created_at,
    updated_at,
    'reading' as skill_type,
    reading_score as band_score,
    reading_raw_score as raw_score,
    CASE WHEN reading_raw_score IS NOT NULL THEN 40 ELSE NULL END as total_questions
FROM official_test_results
WHERE reading_score > 0

UNION ALL

SELECT 
    gen_random_uuid() as new_id,
    user_id,
    test_type,
    test_date,
    test_duration_minutes,
    completion_status,
    test_source,
    notes,
    created_at,
    updated_at,
    'writing' as skill_type,
    writing_score as band_score,
    NULL as raw_score,
    NULL as total_questions
FROM official_test_results
WHERE writing_score > 0

UNION ALL

SELECT 
    gen_random_uuid() as new_id,
    user_id,
    test_type,
    test_date,
    test_duration_minutes,
    completion_status,
    test_source,
    notes,
    created_at,
    updated_at,
    'speaking' as skill_type,
    speaking_score as band_score,
    NULL as raw_score,
    NULL as total_questions
FROM official_test_results
WHERE speaking_score > 0;

-- Step 4: Delete old records
DELETE FROM official_test_results;

-- Step 5: Insert expanded records with new schema
INSERT INTO official_test_results (
    id, user_id, test_type, test_date, test_duration_minutes, completion_status,
    test_source, notes, created_at, updated_at,
    skill_type, band_score, raw_score, total_questions,
    source_service
)
SELECT 
    new_id, user_id, test_type, test_date, test_duration_minutes, completion_status,
    test_source, notes, created_at, updated_at,
    skill_type, band_score, raw_score, total_questions,
    'exercise_service' as source_service
FROM temp_expanded_test_results;

-- Step 6: Make new columns NOT NULL
ALTER TABLE official_test_results
    ALTER COLUMN skill_type SET NOT NULL,
    ALTER COLUMN band_score SET NOT NULL;

-- Step 7: Add constraints
ALTER TABLE official_test_results
    ADD CONSTRAINT official_test_results_skill_type_check 
        CHECK (skill_type IN ('listening', 'reading', 'writing', 'speaking'));

ALTER TABLE official_test_results
    ADD CONSTRAINT official_test_results_band_score_check 
        CHECK (band_score >= 0 AND band_score <= 9);

ALTER TABLE official_test_results
    ADD CONSTRAINT official_test_results_raw_score_check 
        CHECK (raw_score IS NULL OR (raw_score >= 0 AND raw_score <= 40));

-- Step 8: Drop old columns (all 4 skill scores + overall)
ALTER TABLE official_test_results
    DROP COLUMN listening_score,
    DROP COLUMN reading_score,
    DROP COLUMN writing_score,
    DROP COLUMN speaking_score,
    DROP COLUMN overall_band_score,
    DROP COLUMN listening_raw_score,
    DROP COLUMN reading_raw_score;

-- Step 9: Update indexes
DROP INDEX IF EXISTS idx_official_test_results_user_date;
CREATE INDEX idx_official_test_results_user_skill_date 
    ON official_test_results(user_id, skill_type, test_date DESC);

CREATE INDEX idx_official_test_results_skill_type 
    ON official_test_results(skill_type);

CREATE INDEX idx_official_test_results_source 
    ON official_test_results(source_service, source_id) 
    WHERE source_id IS NOT NULL;

-- Step 10: Drop old constraints
ALTER TABLE official_test_results
    DROP CONSTRAINT IF EXISTS official_test_results_listening_score_check,
    DROP CONSTRAINT IF EXISTS official_test_results_reading_score_check,
    DROP CONSTRAINT IF EXISTS official_test_results_writing_score_check,
    DROP CONSTRAINT IF EXISTS official_test_results_speaking_score_check,
    DROP CONSTRAINT IF EXISTS official_test_results_overall_band_score_check,
    DROP CONSTRAINT IF EXISTS official_test_results_listening_raw_score_check,
    DROP CONSTRAINT IF EXISTS official_test_results_reading_raw_score_check;

COMMIT;

-- Verification queries
SELECT 
    skill_type,
    COUNT(*) as total_tests,
    AVG(band_score) as avg_score,
    MIN(band_score) as min_score,
    MAX(band_score) as max_score
FROM official_test_results
GROUP BY skill_type
ORDER BY skill_type;

SELECT 
    user_id,
    skill_type,
    band_score,
    test_date
FROM official_test_results
ORDER BY user_id, test_date DESC
LIMIT 20;
