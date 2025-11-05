-- Migration: Update skill_statistics table
-- Purpose: Separate test statistics from practice statistics
-- Database: user_db
-- Phase: 1 - Database Schema Updates

-- Add new columns to separate practice from test performance
ALTER TABLE skill_statistics
    ADD COLUMN IF NOT EXISTS practice_only_count INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS practice_average_score DECIMAL(5,2),
    ADD COLUMN IF NOT EXISTS practice_best_score DECIMAL(5,2),
    ADD COLUMN IF NOT EXISTS test_count INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS test_average_band_score DECIMAL(3,1),
    ADD COLUMN IF NOT EXISTS test_best_band_score DECIMAL(3,1),
    ADD COLUMN IF NOT EXISTS last_test_date TIMESTAMP,
    ADD COLUMN IF NOT EXISTS last_test_band_score DECIMAL(3,1);

-- Add check constraints for band scores
ALTER TABLE skill_statistics
    ADD CONSTRAINT check_test_average_band_score CHECK (test_average_band_score IS NULL OR (test_average_band_score >= 0 AND test_average_band_score <= 9)),
    ADD CONSTRAINT check_test_best_band_score CHECK (test_best_band_score IS NULL OR (test_best_band_score >= 0 AND test_best_band_score <= 9)),
    ADD CONSTRAINT check_last_test_band_score CHECK (last_test_band_score IS NULL OR (last_test_band_score >= 0 AND last_test_band_score <= 9));

-- Create index on last_test_date
CREATE INDEX IF NOT EXISTS idx_skill_statistics_last_test_date ON skill_statistics(user_id, last_test_date DESC);

-- Add comments
COMMENT ON COLUMN skill_statistics.practice_only_count IS 'Number of practice drills completed (excludes official tests)';
COMMENT ON COLUMN skill_statistics.practice_average_score IS 'Average score from practice activities only';
COMMENT ON COLUMN skill_statistics.practice_best_score IS 'Best score from practice activities only';
COMMENT ON COLUMN skill_statistics.test_count IS 'Number of official tests completed for this skill';
COMMENT ON COLUMN skill_statistics.test_average_band_score IS 'Average IELTS band score from official tests';
COMMENT ON COLUMN skill_statistics.test_best_band_score IS 'Best IELTS band score from official tests';
COMMENT ON COLUMN skill_statistics.last_test_date IS 'Date of most recent official test for this skill';
COMMENT ON COLUMN skill_statistics.last_test_band_score IS 'Band score from most recent official test';

-- Update existing columns comments for clarity
COMMENT ON COLUMN skill_statistics.total_practices IS 'Total activities (both practice and tests) - will be deprecated';
COMMENT ON COLUMN skill_statistics.completed_practices IS 'Completed activities (both practice and tests) - will be deprecated';
COMMENT ON COLUMN skill_statistics.average_score IS 'Overall average score (mixed practice and tests) - will be deprecated';
COMMENT ON COLUMN skill_statistics.best_score IS 'Overall best score (mixed practice and tests) - will be deprecated';
