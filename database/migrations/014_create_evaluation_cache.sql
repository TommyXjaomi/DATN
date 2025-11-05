-- Create evaluation cache table for Phase 5.3
-- This table stores cached evaluation results to reduce OpenAI API calls

CREATE TABLE IF NOT EXISTS evaluation_cache (
    hash VARCHAR(64) PRIMARY KEY,
    content TEXT NOT NULL,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Index for cleanup queries
CREATE INDEX idx_evaluation_cache_expires_at ON evaluation_cache(expires_at);

-- Add comment
COMMENT ON TABLE evaluation_cache IS 'Cache table for AI evaluation results (Phase 5.3)';
COMMENT ON COLUMN evaluation_cache.hash IS 'SHA256 hash of input content (essay/transcript)';
COMMENT ON COLUMN evaluation_cache.content IS 'JSON serialized evaluation result';
COMMENT ON COLUMN evaluation_cache.expires_at IS 'Cache expiry time (7 days default)';
