-- ============================================
-- AI Service Database Schema
-- ============================================
-- Database: ai_db
-- Purpose: AI-powered evaluation system for IELTS Writing and Speaking
-- Author: IELTS Platform Backend Team
-- Created: 2025-11-06
-- Last Modified: 2025-11-06

-- Create database (run separately)
-- CREATE DATABASE ai_db;

-- ============================================
-- EXTENSIONS
-- ============================================

-- Enable UUID extension for UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable dblink for cross-database queries
-- Used to query exercise_db from ai_db for submission details
CREATE EXTENSION IF NOT EXISTS dblink;

-- Enable pg_trgm for text similarity search
-- Used for fuzzy matching of prompts and feedback
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ============================================
-- PROMPT MANAGEMENT TABLES
-- ============================================

-- ============================================
-- WRITING_PROMPTS TABLE
-- ============================================
-- Stores IELTS Writing Task 1 & Task 2 prompts
-- Used for generating writing exercises and evaluations
CREATE TABLE writing_prompts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Task information
    task_type VARCHAR(20) NOT NULL, -- 'task1' or 'task2'
    prompt_text TEXT NOT NULL,
    
    -- Visual data for Task 1
    visual_type VARCHAR(50), -- 'bar_chart', 'line_graph', 'pie_chart', 'table', 'process_diagram'
    visual_url TEXT, -- URL to chart/diagram image
    
    -- Categorization
    topic VARCHAR(100), -- e.g., 'education', 'environment', 'technology'
    difficulty VARCHAR(20), -- 'beginner', 'intermediate', 'advanced'
    
    -- Sample answer
    has_sample_answer BOOLEAN DEFAULT false,
    sample_answer_text TEXT,
    sample_answer_band_score NUMERIC(2,1), -- 0.0 to 9.0
    
    -- Usage statistics
    times_used INT DEFAULT 0,
    average_score NUMERIC(2,1), -- Average score from all submissions
    
    -- Publishing
    is_published BOOLEAN DEFAULT true,
    created_by UUID, -- User ID of creator (instructor/admin)
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_writing_prompts_task_type ON writing_prompts(task_type);
CREATE INDEX idx_writing_prompts_topic ON writing_prompts(topic);
CREATE INDEX idx_writing_prompts_difficulty ON writing_prompts(difficulty);

-- ============================================
-- SPEAKING_PROMPTS TABLE
-- ============================================
-- Stores IELTS Speaking prompts for Part 1, 2, 3
CREATE TABLE speaking_prompts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Part information
    part_number INT NOT NULL, -- 1, 2, or 3
    prompt_text TEXT NOT NULL,
    
    -- Part 2 specific: Cue card
    cue_card_topic VARCHAR(200), -- Main topic for Part 2
    cue_card_points TEXT[], -- Array of points to cover
    preparation_time_seconds INT DEFAULT 60, -- Usually 1 minute
    speaking_time_seconds INT DEFAULT 120, -- Usually 2 minutes
    
    -- Part 3 specific: Follow-up questions
    follow_up_questions TEXT[], -- Array of related questions
    
    -- Categorization
    topic_category VARCHAR(100), -- 'hobbies', 'work', 'family', etc.
    difficulty VARCHAR(20),
    
    -- Sample answer
    has_sample_answer BOOLEAN DEFAULT false,
    sample_answer_text TEXT,
    sample_answer_audio_url TEXT, -- URL to audio file
    sample_answer_band_score NUMERIC(2,1),
    
    -- Usage statistics
    times_used INT DEFAULT 0,
    average_score NUMERIC(2,1),
    
    -- Publishing
    is_published BOOLEAN DEFAULT true,
    created_by UUID,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_speaking_prompts_part_number ON speaking_prompts(part_number);
CREATE INDEX idx_speaking_prompts_topic_category ON speaking_prompts(topic_category);
CREATE INDEX idx_speaking_prompts_difficulty ON speaking_prompts(difficulty);

-- ============================================
-- GRADING & EVALUATION TABLES
-- ============================================

-- ============================================
-- GRADING_CRITERIA TABLE
-- ============================================
-- Stores official IELTS band descriptors for each skill
-- Used as reference for AI evaluation
CREATE TABLE grading_criteria (
    id SERIAL PRIMARY KEY,
    
    skill_type VARCHAR(20) NOT NULL, -- 'writing' or 'speaking'
    criterion_name VARCHAR(100) NOT NULL, -- 'Task Achievement', 'Coherence and Cohesion', etc.
    band_score NUMERIC(2,1) NOT NULL, -- 0.0 to 9.0
    
    description TEXT NOT NULL, -- Band descriptor text
    key_features TEXT[], -- Array of key features for this band
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- AI_MODEL_VERSIONS TABLE
-- ============================================
-- Track different AI model versions for evaluation
-- Allows A/B testing and gradual rollout
CREATE TABLE ai_model_versions (
    id SERIAL PRIMARY KEY,
    
    model_type VARCHAR(50) NOT NULL, -- 'writing_evaluator', 'speaking_evaluator'
    model_name VARCHAR(100) NOT NULL, -- 'gpt-4', 'claude-3', etc.
    version VARCHAR(50) NOT NULL, -- '1.0', '2.0', etc.
    
    description TEXT,
    
    -- Performance metrics
    average_accuracy NUMERIC(5,2), -- Percentage
    average_processing_time_ms INT,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    is_default BOOLEAN DEFAULT false, -- Only one default per model_type
    
    deployed_at TIMESTAMP,
    deprecated_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(model_type, model_name, version)
);

-- ============================================
-- AI_EVALUATION_CACHE TABLE
-- ============================================
-- Cache AI evaluation results to reduce API costs and improve speed
-- If same content submitted again, return cached result
CREATE TABLE ai_evaluation_cache (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Cache key
    content_hash VARCHAR(64) NOT NULL UNIQUE, -- SHA-256 hash of submission content
    
    -- Submission info
    skill_type VARCHAR(20) NOT NULL CHECK (skill_type IN ('writing', 'speaking')),
    task_type VARCHAR(20), -- 'task1', 'task2', 'part1', 'part2', 'part3'
    
    -- Evaluation results
    overall_band_score NUMERIC(3,1) NOT NULL CHECK (overall_band_score >= 0 AND overall_band_score <= 9),
    detailed_scores JSONB NOT NULL, -- Score breakdown by criteria
    feedback JSONB NOT NULL, -- Detailed feedback
    
    -- AI model info
    ai_model_name VARCHAR(100),
    ai_model_version VARCHAR(50),
    
    -- Performance metrics
    processing_time_ms INT,
    confidence_score NUMERIC(3,2), -- 0.00 to 1.00
    
    -- API usage tracking
    prompt_tokens INT,
    completion_tokens INT,
    total_cost_usd NUMERIC(10,6),
    
    -- Cache management
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP, -- NULL = never expires
    hit_count INT DEFAULT 0, -- Number of cache hits
    last_hit_at TIMESTAMP,
    
    notes TEXT -- Optional notes about this cache entry
);

-- Indexes
CREATE INDEX idx_ai_cache_content_hash ON ai_evaluation_cache(content_hash);
CREATE INDEX idx_ai_cache_skill_type ON ai_evaluation_cache(skill_type);
CREATE INDEX idx_ai_cache_expires_at ON ai_evaluation_cache(expires_at) WHERE expires_at IS NOT NULL;
CREATE INDEX idx_ai_cache_hit_count ON ai_evaluation_cache(hit_count DESC);

-- ============================================
-- PROCESSING QUEUE TABLES
-- ============================================

-- ============================================
-- AI_PROCESSING_QUEUE TABLE
-- ============================================
-- Queue for async AI evaluation tasks
-- Used when evaluation takes longer than request timeout
CREATE TABLE ai_processing_queue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Task info
    task_type VARCHAR(50) NOT NULL, -- 'writing_evaluation', 'speaking_evaluation'
    submission_id UUID NOT NULL, -- Reference to writing_submission or speaking_submission
    submission_type VARCHAR(20) NOT NULL, -- 'writing' or 'speaking'
    
    -- Queue management
    priority INT DEFAULT 5, -- 1 (highest) to 10 (lowest)
    status VARCHAR(20) DEFAULT 'queued', -- 'queued', 'processing', 'completed', 'failed'
    
    -- Retry logic
    retry_count INT DEFAULT 0,
    max_retries INT DEFAULT 3,
    error_message TEXT,
    
    -- Worker info
    worker_id VARCHAR(100), -- ID of worker processing this task
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_ai_processing_queue_status ON ai_processing_queue(status);
CREATE INDEX idx_ai_processing_queue_priority ON ai_processing_queue(priority DESC, created_at);
CREATE INDEX idx_ai_processing_queue_submission ON ai_processing_queue(submission_id, submission_type);

-- ============================================
-- FEEDBACK & QUALITY TABLES
-- ============================================

-- ============================================
-- EVALUATION_FEEDBACK_RATINGS TABLE
-- ============================================
-- Collect user feedback on AI evaluations
-- Used to improve model accuracy and quality
CREATE TABLE evaluation_feedback_ratings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    user_id UUID NOT NULL, -- User who provided feedback
    
    -- Reference to evaluation
    evaluation_type VARCHAR(20) NOT NULL, -- 'writing' or 'speaking'
    evaluation_id UUID NOT NULL, -- writing_evaluation_id or speaking_evaluation_id
    
    -- Feedback
    is_helpful BOOLEAN, -- Was the feedback helpful?
    accuracy_rating INT CHECK (accuracy_rating BETWEEN 1 AND 5), -- 1-5 stars
    feedback_text TEXT, -- Optional written feedback
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_evaluation_feedback_user_id ON evaluation_feedback_ratings(user_id);
CREATE INDEX idx_evaluation_feedback_evaluation_id ON evaluation_feedback_ratings(evaluation_id);

-- ============================================
-- SYSTEM TABLES
-- ============================================

-- ============================================
-- SCHEMA_MIGRATIONS TABLE
-- ============================================
-- Tracks database migrations that have been applied
-- Used by migration system to prevent re-running migrations
CREATE TABLE schema_migrations (
    id SERIAL PRIMARY KEY,
    migration_file VARCHAR(255) UNIQUE NOT NULL,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    checksum VARCHAR(64) -- Optional: MD5/SHA hash of migration file
);

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for tables with updated_at
CREATE TRIGGER update_writing_prompts_updated_at
    BEFORE UPDATE ON writing_prompts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_speaking_prompts_updated_at
    BEFORE UPDATE ON speaking_prompts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ai_processing_queue_updated_at
    BEFORE UPDATE ON ai_processing_queue
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to calculate IELTS Writing band score
-- Takes 4 criteria scores and returns overall band score
CREATE OR REPLACE FUNCTION calculate_writing_band_score(
    task_achievement NUMERIC,
    coherence_cohesion NUMERIC,
    lexical_resource NUMERIC,
    grammar_accuracy NUMERIC
)
RETURNS NUMERIC AS $$
BEGIN
    RETURN ROUND((task_achievement + coherence_cohesion + lexical_resource + grammar_accuracy) / 4, 1);
END;
$$ LANGUAGE plpgsql;

-- Function to calculate IELTS Speaking band score
-- Takes 4 criteria scores and returns overall band score
CREATE OR REPLACE FUNCTION calculate_speaking_band_score(
    fluency_coherence NUMERIC,
    lexical_resource NUMERIC,
    grammar_accuracy NUMERIC,
    pronunciation NUMERIC
)
RETURNS NUMERIC AS $$
BEGIN
    RETURN ROUND((fluency_coherence + lexical_resource + grammar_accuracy + pronunciation) / 4, 1);
END;
$$ LANGUAGE plpgsql;

-- Function to create AI processing task automatically
-- Triggered when new submission is created in exercise_db
CREATE OR REPLACE FUNCTION create_ai_processing_task()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_TABLE_NAME = 'writing_submissions' THEN
        INSERT INTO ai_processing_queue (task_type, submission_id, submission_type)
        VALUES ('evaluate_writing', NEW.id, 'writing');
    ELSIF TG_TABLE_NAME = 'speaking_submissions' THEN
        -- First transcribe audio, then evaluate
        INSERT INTO ai_processing_queue (task_type, submission_id, submission_type, priority)
        VALUES ('transcribe_audio', NEW.id, 'speaking', 8);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Note: Triggers for create_ai_processing_task are in exercise_db
-- They are created on writing_submissions and speaking_submissions tables

-- ============================================
-- SEED DATA (Optional)
-- ============================================

-- Insert default AI models
INSERT INTO ai_model_versions (model_type, model_name, version, description, is_default) VALUES
('writing_evaluator', 'gpt-4', '1.0', 'OpenAI GPT-4 for writing evaluation', true),
('speaking_evaluator', 'gpt-4', '1.0', 'OpenAI GPT-4 for speaking evaluation', true);

-- Insert sample grading criteria (Task Achievement for Writing Task 2)
INSERT INTO grading_criteria (skill_type, criterion_name, band_score, description, key_features) VALUES
('writing', 'Task Achievement', 9.0, 'Fully addresses all parts of the task', 
 ARRAY['fully addresses the task', 'presents a fully developed position', 'ideas are highly relevant']),
('writing', 'Task Achievement', 8.0, 'Sufficiently addresses all parts of the task',
 ARRAY['sufficiently addresses the task', 'presents a well-developed response', 'ideas are mostly relevant']),
('writing', 'Task Achievement', 7.0, 'Addresses all parts of the task',
 ARRAY['addresses all parts', 'presents a clear position', 'main ideas are extended and supported']);

-- ============================================
-- COMMENTS
-- ============================================

COMMENT ON TABLE writing_prompts IS 'Bảng lưu đề bài IELTS Writing (Task 1 & 2)';
COMMENT ON TABLE speaking_prompts IS 'Bảng lưu câu hỏi IELTS Speaking (Part 1, 2, 3)';
COMMENT ON TABLE grading_criteria IS 'Bảng lưu tiêu chí chấm điểm IELTS chính thức';
COMMENT ON TABLE ai_model_versions IS 'Bảng quản lý phiên bản AI models';
COMMENT ON TABLE ai_evaluation_cache IS 'Bảng cache kết quả đánh giá AI để tối ưu chi phí và tốc độ';
COMMENT ON TABLE ai_processing_queue IS 'Hàng đợi xử lý đánh giá AI bất đồng bộ';
COMMENT ON TABLE evaluation_feedback_ratings IS 'Bảng thu thập phản hồi từ người dùng về chất lượng đánh giá AI';

-- Column comments for important fields
COMMENT ON COLUMN ai_evaluation_cache.content_hash IS 'SHA-256 hash của nội dung submission, dùng làm cache key';
COMMENT ON COLUMN ai_evaluation_cache.hit_count IS 'Số lần cache được sử dụng (cost savings metric)';
COMMENT ON COLUMN ai_processing_queue.priority IS 'Độ ưu tiên: 1 (cao nhất) đến 10 (thấp nhất)';
