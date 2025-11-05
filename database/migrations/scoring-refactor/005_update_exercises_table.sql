-- Migration: Update exercises table for test vs practice distinction
-- Purpose: Add field to distinguish official tests from practice exercises
-- Database: exercise_db
-- Phase: 1 - Database Schema Updates

-- Add new columns to exercises table
ALTER TABLE exercises
    ADD COLUMN IF NOT EXISTS is_official_test BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS test_category VARCHAR(30) CHECK (test_category IS NULL OR test_category IN ('practice', 'mock_test', 'official_test', 'mini_test'));

-- Add comment
COMMENT ON COLUMN exercises.is_official_test IS 'True if this is an official full test (counts toward official scores)';
COMMENT ON COLUMN exercises.test_category IS 'Category: practice (drill), mock_test (practice full test), official_test (counts toward certification), mini_test (part test)';

-- Create index for querying official tests
CREATE INDEX IF NOT EXISTS idx_exercises_is_official_test ON exercises(is_official_test) WHERE is_official_test = TRUE;
CREATE INDEX IF NOT EXISTS idx_exercises_test_category ON exercises(test_category);
