-- Migration: Create practice_activities table
-- Purpose: Track individual practice drills and part tests (separate from official scores)
-- Database: user_db
-- Phase: 1 - Database Schema Updates

-- Create practice_activities table
CREATE TABLE IF NOT EXISTS practice_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    
    -- Activity identification
    skill VARCHAR(20) NOT NULL CHECK (skill IN ('listening', 'reading', 'writing', 'speaking')),
    activity_type VARCHAR(30) NOT NULL CHECK (activity_type IN ('drill', 'part_test', 'section_practice', 'question_set')),
    
    -- Exercise reference (from exercise_db)
    exercise_id UUID, -- Reference to exercise in exercise_db
    exercise_title VARCHAR(255),
    
    -- Performance metrics
    score DECIMAL(5,2), -- Can be percentage, raw score, or band score depending on activity
    max_score DECIMAL(5,2), -- Maximum possible score for this activity
    band_score DECIMAL(3,1) CHECK (band_score IS NULL OR (band_score >= 0 AND band_score <= 9)), -- If applicable
    
    -- Detailed results
    correct_answers INTEGER DEFAULT 0,
    total_questions INTEGER,
    accuracy_percentage DECIMAL(5,2),
    
    -- Time tracking
    time_spent_seconds INTEGER, -- Actual time spent on activity
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    
    -- Status
    completion_status VARCHAR(20) DEFAULT 'completed' CHECK (completion_status IN ('completed', 'incomplete', 'abandoned', 'in_progress')),
    
    -- AI evaluation (for Writing/Speaking)
    ai_evaluated BOOLEAN DEFAULT FALSE,
    ai_feedback_summary TEXT,
    
    -- Additional metadata
    difficulty_level VARCHAR(20) CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced', 'expert')),
    tags TEXT[], -- Array of tags for categorization
    notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for efficient querying
CREATE INDEX idx_practice_activities_user_id ON practice_activities(user_id);
CREATE INDEX idx_practice_activities_skill ON practice_activities(skill);
CREATE INDEX idx_practice_activities_user_skill ON practice_activities(user_id, skill);
CREATE INDEX idx_practice_activities_completed_at ON practice_activities(completed_at DESC);
CREATE INDEX idx_practice_activities_user_completed ON practice_activities(user_id, completed_at DESC);
CREATE INDEX idx_practice_activities_exercise_id ON practice_activities(exercise_id);

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_practice_activities_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_practice_activities_updated_at
    BEFORE UPDATE ON practice_activities
    FOR EACH ROW
    EXECUTE FUNCTION update_practice_activities_updated_at();

-- Add comments for documentation
COMMENT ON TABLE practice_activities IS 'Tracks individual practice drills and part tests - separate from official test scores';
COMMENT ON COLUMN practice_activities.activity_type IS 'Type: drill (single concept), part_test (one part of IELTS), section_practice, question_set';
COMMENT ON COLUMN practice_activities.score IS 'Raw score - can be percentage, count, or band score depending on activity type';
COMMENT ON COLUMN practice_activities.band_score IS 'IELTS band score if applicable (mainly for part tests)';
COMMENT ON COLUMN practice_activities.ai_evaluated IS 'True if this activity was evaluated by AI (Writing/Speaking)';
