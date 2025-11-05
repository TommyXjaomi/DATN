-- Migration: Update user_exercise_attempts table to support all 4 skills
-- Purpose: Extend table to handle Writing/Speaking submissions (currently in ai_db)
-- Database: exercise_db
-- Phase: 1 - Database Schema Updates

-- Add new columns for test categorization
ALTER TABLE user_exercise_attempts
    ADD COLUMN IF NOT EXISTS is_official_test BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS official_test_result_id UUID, -- Reference to official_test_results in user_db
    ADD COLUMN IF NOT EXISTS practice_activity_id UUID; -- Reference to practice_activities in user_db

-- Add columns for Writing submissions
ALTER TABLE user_exercise_attempts
    ADD COLUMN IF NOT EXISTS essay_text TEXT,
    ADD COLUMN IF NOT EXISTS word_count INTEGER,
    ADD COLUMN IF NOT EXISTS task_type VARCHAR(20), -- task1, task2
    ADD COLUMN IF NOT EXISTS prompt_text TEXT;

-- Add columns for Speaking submissions
ALTER TABLE user_exercise_attempts
    ADD COLUMN IF NOT EXISTS audio_url TEXT,
    ADD COLUMN IF NOT EXISTS audio_duration_seconds INTEGER,
    ADD COLUMN IF NOT EXISTS audio_format VARCHAR(20),
    ADD COLUMN IF NOT EXISTS transcript_text TEXT,
    ADD COLUMN IF NOT EXISTS transcript_word_count INTEGER,
    ADD COLUMN IF NOT EXISTS speaking_part_number INTEGER CHECK (speaking_part_number IS NULL OR speaking_part_number IN (1, 2, 3));

-- Add AI evaluation tracking columns
ALTER TABLE user_exercise_attempts
    ADD COLUMN IF NOT EXISTS evaluation_status VARCHAR(20) DEFAULT 'pending' CHECK (evaluation_status IN ('pending', 'processing', 'completed', 'failed', 'skipped')),
    ADD COLUMN IF NOT EXISTS ai_evaluation_id UUID, -- Reference to evaluation in ai_db
    ADD COLUMN IF NOT EXISTS detailed_scores JSONB, -- {task_achievement: 7.0, coherence: 6.5, ...}
    ADD COLUMN IF NOT EXISTS ai_feedback TEXT,
    ADD COLUMN IF NOT EXISTS ai_model_name VARCHAR(100),
    ADD COLUMN IF NOT EXISTS ai_processing_time_ms INTEGER;

-- Update band_score to DECIMAL(3,1) for consistency
ALTER TABLE user_exercise_attempts
    ALTER COLUMN band_score TYPE DECIMAL(3,1);

-- Add check constraint for band score
ALTER TABLE user_exercise_attempts
    ADD CONSTRAINT check_band_score_range CHECK (band_score IS NULL OR (band_score >= 0 AND band_score <= 9));

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_user_exercise_attempts_is_official ON user_exercise_attempts(is_official_test) WHERE is_official_test = TRUE;
CREATE INDEX IF NOT EXISTS idx_user_exercise_attempts_official_test_result_id ON user_exercise_attempts(official_test_result_id) WHERE official_test_result_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_user_exercise_attempts_evaluation_status ON user_exercise_attempts(evaluation_status) WHERE evaluation_status IN ('pending', 'processing');

-- Add comments
COMMENT ON COLUMN user_exercise_attempts.is_official_test IS 'True if this attempt is part of an official test (not practice)';
COMMENT ON COLUMN user_exercise_attempts.official_test_result_id IS 'UUID linking to official_test_results table in user_db (for official tests only)';
COMMENT ON COLUMN user_exercise_attempts.practice_activity_id IS 'UUID linking to practice_activities table in user_db (for practice only)';
COMMENT ON COLUMN user_exercise_attempts.essay_text IS 'Writing essay content (for Writing exercises)';
COMMENT ON COLUMN user_exercise_attempts.audio_url IS 'Speaking audio file URL (for Speaking exercises)';
COMMENT ON COLUMN user_exercise_attempts.evaluation_status IS 'AI evaluation status: pending (waiting), processing (in progress), completed (done), failed (error), skipped (L/R only)';
COMMENT ON COLUMN user_exercise_attempts.detailed_scores IS 'JSONB containing detailed scoring breakdown from AI evaluation';
COMMENT ON COLUMN user_exercise_attempts.speaking_part_number IS 'Speaking part: 1 (intro), 2 (cue card), 3 (discussion)';
