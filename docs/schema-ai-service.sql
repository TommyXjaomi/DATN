-- ===== AI SERVICE SCHEMA =====
-- Tables: ai_models, ai_evaluation_requests, ai_evaluation_results, ai_evaluation_cache, ai_evaluation_logs

CREATE TABLE ai_models (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    version VARCHAR(50) NOT NULL,
    provider VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    model_type VARCHAR(100),
    configuration JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ai_evaluation_requests (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    exercise_attempt_id UUID NOT NULL,
    question_id UUID NOT NULL,
    skill_type VARCHAR(50) NOT NULL,
    task_type VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

CREATE TABLE ai_evaluation_results (
    id UUID PRIMARY KEY,
    request_id UUID NOT NULL UNIQUE,
    overall_band_score FLOAT NOT NULL,
    fluency_score FLOAT,
    accuracy_score FLOAT,
    vocabulary_score FLOAT,
    grammar_score FLOAT,
    pronunciation_score FLOAT,
    detailed_scores JSONB,
    feedback TEXT,
    evaluated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (request_id) REFERENCES ai_evaluation_requests(id) ON DELETE CASCADE
);

CREATE TABLE ai_evaluation_cache (
    id UUID PRIMARY KEY,
    content_hash VARCHAR(255) NOT NULL UNIQUE,
    skill_type VARCHAR(50) NOT NULL,
    task_type VARCHAR(100) NOT NULL,
    overall_band_score FLOAT NOT NULL,
    result_data JSONB,
    hit_count INTEGER DEFAULT 0,
    last_accessed_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP
);

CREATE TABLE ai_evaluation_logs (
    id UUID PRIMARY KEY,
    request_id UUID NOT NULL,
    task_type VARCHAR(100) NOT NULL,
    model_id UUID NOT NULL,
    cache_hit BOOLEAN DEFAULT FALSE,
    processing_time_ms INTEGER NOT NULL,
    input_tokens INTEGER,
    output_tokens INTEGER,
    total_tokens INTEGER,
    cost_usd FLOAT,
    status VARCHAR(50),
    error_message VARCHAR(500),
    evaluated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (request_id) REFERENCES ai_evaluation_requests(id) ON DELETE CASCADE,
    FOREIGN KEY (model_id) REFERENCES ai_models(id) ON DELETE SET NULL
);

-- ===== INDEXES =====
CREATE INDEX idx_ai_evaluation_requests_user_id ON ai_evaluation_requests(user_id);
CREATE INDEX idx_ai_evaluation_requests_status ON ai_evaluation_requests(status);
CREATE INDEX idx_ai_evaluation_requests_skill_type ON ai_evaluation_requests(skill_type);
CREATE INDEX idx_ai_evaluation_results_request_id ON ai_evaluation_results(request_id);
CREATE INDEX idx_ai_evaluation_cache_content_hash ON ai_evaluation_cache(content_hash);
CREATE INDEX idx_ai_evaluation_cache_skill_type ON ai_evaluation_cache(skill_type);
CREATE INDEX idx_ai_evaluation_logs_request_id ON ai_evaluation_logs(request_id);
CREATE INDEX idx_ai_evaluation_logs_model_id ON ai_evaluation_logs(model_id);
