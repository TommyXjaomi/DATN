-- Migration: Update learning_progress table
-- Purpose: Add fields for tracking official tests
-- Database: user_db
-- Phase: 1 - Database Schema Updates

-- Add new columns to learning_progress table
ALTER TABLE learning_progress
    ADD COLUMN IF NOT EXISTS last_test_date TIMESTAMP,
    ADD COLUMN IF NOT EXISTS total_tests_taken INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS last_test_overall_score DECIMAL(3,1),
    ADD COLUMN IF NOT EXISTS highest_overall_score DECIMAL(3,1),
    ADD COLUMN IF NOT EXISTS tests_this_month INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS last_test_id UUID; -- Reference to official_test_results(id)

-- Add check constraints
ALTER TABLE learning_progress
    ADD CONSTRAINT check_last_test_overall_score CHECK (last_test_overall_score IS NULL OR (last_test_overall_score >= 0 AND last_test_overall_score <= 9)),
    ADD CONSTRAINT check_highest_overall_score CHECK (highest_overall_score IS NULL OR (highest_overall_score >= 0 AND highest_overall_score <= 9));

-- Update score columns to use DECIMAL(3,1) for consistency
ALTER TABLE learning_progress
    ALTER COLUMN listening_score TYPE DECIMAL(3,1),
    ALTER COLUMN reading_score TYPE DECIMAL(3,1),
    ALTER COLUMN writing_score TYPE DECIMAL(3,1),
    ALTER COLUMN speaking_score TYPE DECIMAL(3,1),
    ALTER COLUMN overall_score TYPE DECIMAL(3,1);

-- Add check constraints for score columns
ALTER TABLE learning_progress
    ADD CONSTRAINT check_listening_score CHECK (listening_score IS NULL OR (listening_score >= 0 AND listening_score <= 9)),
    ADD CONSTRAINT check_reading_score CHECK (reading_score IS NULL OR (reading_score >= 0 AND reading_score <= 9)),
    ADD CONSTRAINT check_writing_score CHECK (writing_score IS NULL OR (writing_score >= 0 AND writing_score <= 9)),
    ADD CONSTRAINT check_speaking_score CHECK (speaking_score IS NULL OR (speaking_score >= 0 AND speaking_score <= 9)),
    ADD CONSTRAINT check_overall_score CHECK (overall_score IS NULL OR (overall_score >= 0 AND overall_score <= 9));

-- Create index on last_test_date
CREATE INDEX IF NOT EXISTS idx_learning_progress_last_test_date ON learning_progress(last_test_date DESC);

-- Add comments
COMMENT ON COLUMN learning_progress.last_test_date IS 'Date of most recent official test completion';
COMMENT ON COLUMN learning_progress.total_tests_taken IS 'Total number of official full tests completed';
COMMENT ON COLUMN learning_progress.last_test_overall_score IS 'Overall band score from most recent official test';
COMMENT ON COLUMN learning_progress.highest_overall_score IS 'Best overall band score achieved from official tests';
COMMENT ON COLUMN learning_progress.tests_this_month IS 'Number of official tests taken in current calendar month';
COMMENT ON COLUMN learning_progress.last_test_id IS 'UUID reference to most recent test in official_test_results';
COMMENT ON COLUMN learning_progress.listening_score IS 'Most recent listening band score from official test (not practice)';
COMMENT ON COLUMN learning_progress.reading_score IS 'Most recent reading band score from official test (not practice)';
COMMENT ON COLUMN learning_progress.writing_score IS 'Most recent writing band score from official test (not practice)';
COMMENT ON COLUMN learning_progress.speaking_score IS 'Most recent speaking band score from official test (not practice)';
COMMENT ON COLUMN learning_progress.overall_score IS 'Most recent overall band score from official test (not practice)';
