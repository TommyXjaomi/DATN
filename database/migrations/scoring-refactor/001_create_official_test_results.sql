-- Migration: Create official_test_results table
-- Purpose: Store official full test scores (source of truth for band scores)
-- Database: user_db
-- Phase: 1 - Database Schema Updates

-- Create official_test_results table
CREATE TABLE IF NOT EXISTS official_test_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    test_type VARCHAR(20) NOT NULL CHECK (test_type IN ('full_test', 'academic', 'general')),
    
    -- Overall band score (average of 4 skills)
    overall_band_score DECIMAL(3,1) NOT NULL CHECK (overall_band_score >= 0 AND overall_band_score <= 9),
    
    -- Individual skill scores
    listening_score DECIMAL(3,1) NOT NULL CHECK (listening_score >= 0 AND listening_score <= 9),
    reading_score DECIMAL(3,1) NOT NULL CHECK (reading_score >= 0 AND reading_score <= 9),
    writing_score DECIMAL(3,1) NOT NULL CHECK (writing_score >= 0 AND writing_score <= 9),
    speaking_score DECIMAL(3,1) NOT NULL CHECK (speaking_score >= 0 AND speaking_score <= 9),
    
    -- Raw scores for reference
    listening_raw_score INTEGER CHECK (listening_raw_score >= 0 AND listening_raw_score <= 40),
    reading_raw_score INTEGER CHECK (reading_raw_score >= 0 AND reading_raw_score <= 40),
    
    -- Test metadata
    test_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    test_duration_minutes INTEGER, -- Total time taken to complete test
    completion_status VARCHAR(20) DEFAULT 'completed' CHECK (completion_status IN ('completed', 'incomplete', 'abandoned')),
    
    -- Additional context
    test_source VARCHAR(50), -- e.g., 'platform', 'imported', 'manual_entry'
    notes TEXT, -- Any additional notes about this test
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for efficient querying
CREATE INDEX idx_official_test_results_user_id ON official_test_results(user_id);
CREATE INDEX idx_official_test_results_test_date ON official_test_results(test_date DESC);
CREATE INDEX idx_official_test_results_user_date ON official_test_results(user_id, test_date DESC);

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_official_test_results_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_official_test_results_updated_at
    BEFORE UPDATE ON official_test_results
    FOR EACH ROW
    EXECUTE FUNCTION update_official_test_results_updated_at();

-- Add comments for documentation
COMMENT ON TABLE official_test_results IS 'Stores official full IELTS test results - source of truth for band scores';
COMMENT ON COLUMN official_test_results.overall_band_score IS 'Average of 4 skill scores, rounded according to IELTS rules';
COMMENT ON COLUMN official_test_results.test_type IS 'Type of test: full_test, academic, or general';
COMMENT ON COLUMN official_test_results.test_source IS 'Origin of test data: platform (taken on our platform), imported (from external), manual_entry';
