-- Rollback migration for official_test_results refactor
-- This script reverts the per-skill model back to the 4-skills-in-one-record model

BEGIN;

-- Step 1: Add back old columns
ALTER TABLE official_test_results
    ADD COLUMN listening_score DECIMAL(3,1),
    ADD COLUMN reading_score DECIMAL(3,1),
    ADD COLUMN writing_score DECIMAL(3,1),
    ADD COLUMN speaking_score DECIMAL(3,1),
    ADD COLUMN overall_band_score DECIMAL(3,1),
    ADD COLUMN listening_raw_score INT,
    ADD COLUMN reading_raw_score INT;

-- Step 2: Aggregate per-skill records back into single records
-- Group by user + test_date to reconstruct original records
CREATE TEMP TABLE temp_aggregated_test_results AS
SELECT 
    gen_random_uuid() as new_id,
    user_id,
    test_type,
    test_date,
    test_duration_minutes,
    completion_status,
    test_source,
    notes,
    MIN(created_at) as created_at,
    MAX(updated_at) as updated_at,
    MAX(CASE WHEN skill_type = 'listening' THEN band_score ELSE 0 END) as listening_score,
    MAX(CASE WHEN skill_type = 'reading' THEN band_score ELSE 0 END) as reading_score,
    MAX(CASE WHEN skill_type = 'writing' THEN band_score ELSE 0 END) as writing_score,
    MAX(CASE WHEN skill_type = 'speaking' THEN band_score ELSE 0 END) as speaking_score,
    MAX(CASE WHEN skill_type = 'listening' THEN raw_score END) as listening_raw_score,
    MAX(CASE WHEN skill_type = 'reading' THEN raw_score END) as reading_raw_score,
    -- Calculate overall as average of non-zero scores
    (
        COALESCE(MAX(CASE WHEN skill_type = 'listening' THEN band_score END), 0) +
        COALESCE(MAX(CASE WHEN skill_type = 'reading' THEN band_score END), 0) +
        COALESCE(MAX(CASE WHEN skill_type = 'writing' THEN band_score END), 0) +
        COALESCE(MAX(CASE WHEN skill_type = 'speaking' THEN band_score END), 0)
    ) / NULLIF(
        (CASE WHEN MAX(CASE WHEN skill_type = 'listening' THEN band_score END) > 0 THEN 1 ELSE 0 END +
         CASE WHEN MAX(CASE WHEN skill_type = 'reading' THEN band_score END) > 0 THEN 1 ELSE 0 END +
         CASE WHEN MAX(CASE WHEN skill_type = 'writing' THEN band_score END) > 0 THEN 1 ELSE 0 END +
         CASE WHEN MAX(CASE WHEN skill_type = 'speaking' THEN band_score END) > 0 THEN 1 ELSE 0 END),
        0
    ) as overall_band_score
FROM official_test_results
GROUP BY user_id, test_type, test_date, test_duration_minutes, completion_status, test_source, notes;

-- Step 3: Delete per-skill records
DELETE FROM official_test_results;

-- Step 4: Insert aggregated records
INSERT INTO official_test_results (
    id, user_id, test_type, test_date, test_duration_minutes, completion_status,
    test_source, notes, created_at, updated_at,
    listening_score, reading_score, writing_score, speaking_score, overall_band_score,
    listening_raw_score, reading_raw_score
)
SELECT * FROM temp_aggregated_test_results;

-- Step 5: Make old columns NOT NULL
ALTER TABLE official_test_results
    ALTER COLUMN listening_score SET NOT NULL,
    ALTER COLUMN reading_score SET NOT NULL,
    ALTER COLUMN writing_score SET NOT NULL,
    ALTER COLUMN speaking_score SET NOT NULL,
    ALTER COLUMN overall_band_score SET NOT NULL;

-- Step 6: Add back old constraints
ALTER TABLE official_test_results
    ADD CONSTRAINT official_test_results_listening_score_check 
        CHECK (listening_score >= 0 AND listening_score <= 9),
    ADD CONSTRAINT official_test_results_reading_score_check 
        CHECK (reading_score >= 0 AND reading_score <= 9),
    ADD CONSTRAINT official_test_results_writing_score_check 
        CHECK (writing_score >= 0 AND writing_score <= 9),
    ADD CONSTRAINT official_test_results_speaking_score_check 
        CHECK (speaking_score >= 0 AND speaking_score <= 9),
    ADD CONSTRAINT official_test_results_overall_band_score_check 
        CHECK (overall_band_score >= 0 AND overall_band_score <= 9),
    ADD CONSTRAINT official_test_results_listening_raw_score_check 
        CHECK (listening_raw_score >= 0 AND listening_raw_score <= 40),
    ADD CONSTRAINT official_test_results_reading_raw_score_check 
        CHECK (reading_raw_score >= 0 AND reading_raw_score <= 40);

-- Step 7: Drop new columns
ALTER TABLE official_test_results
    DROP COLUMN skill_type,
    DROP COLUMN band_score,
    DROP COLUMN raw_score,
    DROP COLUMN total_questions,
    DROP COLUMN source_service,
    DROP COLUMN source_table,
    DROP COLUMN source_id;

-- Step 8: Restore old indexes
DROP INDEX IF EXISTS idx_official_test_results_user_skill_date;
DROP INDEX IF EXISTS idx_official_test_results_skill_type;
DROP INDEX IF EXISTS idx_official_test_results_source;

CREATE INDEX idx_official_test_results_user_date 
    ON official_test_results(user_id, test_date DESC);

COMMIT;

SELECT 'Rollback completed' as status;
