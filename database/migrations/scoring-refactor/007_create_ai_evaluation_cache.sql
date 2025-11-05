-- Migration: Create AI evaluation cache table
-- Purpose: Cache AI evaluation results to reduce OpenAI API costs
-- Database: ai_db
-- Phase: 1 - Database Schema Updates

-- Create ai_evaluation_cache table
CREATE TABLE IF NOT EXISTS ai_evaluation_cache (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Content identification
    content_hash VARCHAR(64) UNIQUE NOT NULL,  -- SHA256 hash of input content
    skill_type VARCHAR(20) NOT NULL CHECK (skill_type IN ('writing', 'speaking')),
    task_type VARCHAR(20), -- task1, task2 for writing; part1, part2, part3 for speaking
    
    -- Cached evaluation result
    overall_band_score DECIMAL(3,1) NOT NULL CHECK (overall_band_score >= 0 AND overall_band_score <= 9),
    detailed_scores JSONB NOT NULL, -- {task_achievement: 7.0, coherence: 6.5, ...}
    feedback JSONB NOT NULL, -- Structured feedback from AI
    
    -- AI metadata
    ai_model_name VARCHAR(100),
    ai_model_version VARCHAR(50),
    processing_time_ms INTEGER,
    confidence_score DECIMAL(3,2),
    prompt_tokens INTEGER,
    completion_tokens INTEGER,
    total_cost_usd DECIMAL(10,6),
    
    -- Cache management
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP, -- NULL = never expires
    hit_count INTEGER DEFAULT 0, -- Track how many times this cache was used
    last_hit_at TIMESTAMP,
    
    -- Metadata
    notes TEXT
);

-- Create indexes
CREATE INDEX idx_ai_cache_content_hash ON ai_evaluation_cache(content_hash);
CREATE INDEX idx_ai_cache_skill_type ON ai_evaluation_cache(skill_type);
CREATE INDEX idx_ai_cache_expires_at ON ai_evaluation_cache(expires_at) WHERE expires_at IS NOT NULL;
CREATE INDEX idx_ai_cache_hit_count ON ai_evaluation_cache(hit_count DESC);

-- Add comments
COMMENT ON TABLE ai_evaluation_cache IS 'Caches AI evaluation results to reduce API costs and improve response time';
COMMENT ON COLUMN ai_evaluation_cache.content_hash IS 'SHA256 hash of essay_text or audio transcript for deduplication';
COMMENT ON COLUMN ai_evaluation_cache.hit_count IS 'Number of times this cached result was reused';
COMMENT ON COLUMN ai_evaluation_cache.expires_at IS 'Cache expiration date - NULL means never expires';
COMMENT ON COLUMN ai_evaluation_cache.total_cost_usd IS 'OpenAI API cost for this evaluation';

-- ============================================
-- DEPRECATION NOTICE
-- ============================================
-- The following tables will be DEPRECATED and REMOVED in Phase 8:
-- 
-- - writing_submissions → Data will be moved to exercise_db.user_exercise_attempts
-- - writing_evaluations → Evaluation data will be in user_exercise_attempts.detailed_scores
-- - speaking_submissions → Data will be moved to exercise_db.user_exercise_attempts  
-- - speaking_evaluations → Evaluation data will be in user_exercise_attempts.detailed_scores
--
-- These tables will remain temporarily during migration phase for data safety.
-- DO NOT add new features that depend on these tables.
-- All new submissions should go to exercise_db.user_exercise_attempts.
--
-- Tables to KEEP (question bank - AI service owns these):
-- - writing_prompts ✅
-- - speaking_prompts ✅
-- - grading_criteria ✅
-- - ai_model_versions ✅
