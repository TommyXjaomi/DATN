-- Rollback: Revert user_exercise_attempts table updates
-- Purpose: Remove all new columns added for Writing/Speaking support
-- Database: exercise_db

-- Drop indexes
DROP INDEX IF EXISTS idx_user_exercise_attempts_is_official;
DROP INDEX IF EXISTS idx_user_exercise_attempts_official_test_result_id;
DROP INDEX IF EXISTS idx_user_exercise_attempts_evaluation_status;

-- Drop constraints
ALTER TABLE user_exercise_attempts
    DROP CONSTRAINT IF EXISTS check_band_score_range,
    DROP CONSTRAINT IF EXISTS user_exercise_attempts_speaking_part_number_check,
    DROP CONSTRAINT IF EXISTS user_exercise_attempts_evaluation_status_check;

-- Revert band_score type
ALTER TABLE user_exercise_attempts
    ALTER COLUMN band_score TYPE DECIMAL(2,1);

-- Drop all new columns
ALTER TABLE user_exercise_attempts
    DROP COLUMN IF EXISTS is_official_test,
    DROP COLUMN IF EXISTS official_test_result_id,
    DROP COLUMN IF EXISTS practice_activity_id,
    DROP COLUMN IF EXISTS essay_text,
    DROP COLUMN IF EXISTS word_count,
    DROP COLUMN IF EXISTS task_type,
    DROP COLUMN IF EXISTS prompt_text,
    DROP COLUMN IF EXISTS audio_url,
    DROP COLUMN IF EXISTS audio_duration_seconds,
    DROP COLUMN IF EXISTS audio_format,
    DROP COLUMN IF EXISTS transcript_text,
    DROP COLUMN IF EXISTS transcript_word_count,
    DROP COLUMN IF EXISTS speaking_part_number,
    DROP COLUMN IF EXISTS evaluation_status,
    DROP COLUMN IF EXISTS ai_evaluation_id,
    DROP COLUMN IF EXISTS detailed_scores,
    DROP COLUMN IF EXISTS ai_feedback,
    DROP COLUMN IF EXISTS ai_model_name,
    DROP COLUMN IF EXISTS ai_processing_time_ms;
