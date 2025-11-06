-- ============================================================================
-- USER SERVICE DATABASE SCHEMA (CLEAN VERSION)
-- ============================================================================
-- Database: user_db
-- Purpose: User profiles, learning progress, and achievements
-- Version: 1.0
-- Last Updated: 2025-11-06
--
-- IMPORTANT: This is a CLEAN schema file that creates the database from scratch.
-- It is NOT a migration file. Use this to:
--   1. Create a new user_db database
--   2. Understand the current schema structure
--   3. Document the database design
--
-- DO NOT use this file to update an existing database.
-- ============================================================================

-- ============================================================================
-- EXTENSIONS
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- Full-text search
CREATE EXTENSION IF NOT EXISTS "dblink"; -- Cross-database queries

-- ============================================================================
-- CORE TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- User Profiles Table
-- ----------------------------------------------------------------------------
CREATE TABLE user_profiles (
    user_id UUID PRIMARY KEY, -- References auth_db.users.id
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    full_name VARCHAR(200),
    date_of_birth DATE,
    gender VARCHAR(20),
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100),
    timezone VARCHAR(50) DEFAULT 'Asia/Ho_Chi_Minh',
    avatar_url TEXT,
    cover_image_url TEXT,
    current_level VARCHAR(20), -- 'beginner', 'intermediate', 'advanced'
    target_band_score NUMERIC(2,1), -- IELTS target (0.0-9.0)
    target_exam_date DATE,
    bio TEXT,
    learning_preferences JSONB, -- Custom learning preferences
    language_preference VARCHAR(10) DEFAULT 'vi', -- 'vi', 'en'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP -- Soft delete
);

CREATE INDEX idx_user_profiles_country ON user_profiles(country);
CREATE INDEX idx_user_profiles_current_level ON user_profiles(current_level);
CREATE INDEX idx_user_profiles_leaderboard ON user_profiles(user_id, full_name) WHERE full_name IS NOT NULL;

-- ----------------------------------------------------------------------------
-- Learning Progress Table
-- ----------------------------------------------------------------------------
CREATE TABLE learning_progress (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL UNIQUE REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    
    -- Completion counters
    total_lessons_completed INTEGER DEFAULT 0,
    total_exercises_completed INTEGER DEFAULT 0,
    
    -- Progress by skill (percentage)
    listening_progress NUMERIC(5,2) DEFAULT 0,
    reading_progress NUMERIC(5,2) DEFAULT 0,
    writing_progress NUMERIC(5,2) DEFAULT 0,
    speaking_progress NUMERIC(5,2) DEFAULT 0,
    
    -- Band scores by skill
    listening_score NUMERIC(3,1) CONSTRAINT check_listening_score CHECK (listening_score IS NULL OR (listening_score >= 0 AND listening_score <= 9)),
    reading_score NUMERIC(3,1) CONSTRAINT check_reading_score CHECK (reading_score IS NULL OR (reading_score >= 0 AND reading_score <= 9)),
    writing_score NUMERIC(3,1) CONSTRAINT check_writing_score CHECK (writing_score IS NULL OR (writing_score >= 0 AND writing_score <= 9)),
    speaking_score NUMERIC(3,1) CONSTRAINT check_speaking_score CHECK (speaking_score IS NULL OR (speaking_score >= 0 AND speaking_score <= 9)),
    overall_score NUMERIC(3,1) CONSTRAINT check_overall_score CHECK (overall_score IS NULL OR (overall_score >= 0 AND overall_score <= 9)),
    
    -- Study streaks
    current_streak_days INTEGER DEFAULT 0,
    longest_streak_days INTEGER DEFAULT 0,
    last_study_date DATE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Test statistics
    last_test_date TIMESTAMP,
    total_tests_taken INTEGER DEFAULT 0,
    last_test_overall_score NUMERIC(3,1) CONSTRAINT check_last_test_overall_score CHECK (last_test_overall_score IS NULL OR (last_test_overall_score >= 0 AND last_test_overall_score <= 9)),
    highest_overall_score NUMERIC(3,1) CONSTRAINT check_highest_overall_score CHECK (highest_overall_score IS NULL OR (highest_overall_score >= 0 AND highest_overall_score <= 9)),
    tests_this_month INTEGER DEFAULT 0,
    last_test_id UUID
);

CREATE INDEX idx_learning_progress_user_id ON learning_progress(user_id);
CREATE INDEX idx_learning_progress_streak ON learning_progress(user_id, current_streak_days DESC);
CREATE INDEX idx_learning_progress_last_test_date ON learning_progress(last_test_date DESC);

-- ----------------------------------------------------------------------------
-- Skill Statistics Table
-- ----------------------------------------------------------------------------
CREATE TABLE skill_statistics (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    skill_type VARCHAR(20) NOT NULL CHECK (skill_type IN ('listening', 'reading', 'writing', 'speaking')),
    
    -- Practice statistics
    total_practices INTEGER DEFAULT 0,
    completed_practices INTEGER DEFAULT 0,
    average_score NUMERIC(5,2),
    best_score NUMERIC(5,2),
    total_time_minutes INTEGER DEFAULT 0,
    last_practice_date TIMESTAMP,
    last_practice_score NUMERIC(5,2),
    
    -- Analytics
    score_trend JSONB, -- Historical score data
    weak_areas JSONB, -- Identified weak areas
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Practice-only statistics (non-test exercises)
    practice_only_count INTEGER DEFAULT 0,
    practice_average_score NUMERIC(5,2),
    practice_best_score NUMERIC(5,2),
    
    -- Test statistics (full/mock tests)
    test_count INTEGER DEFAULT 0,
    test_average_band_score NUMERIC(3,1) CONSTRAINT check_test_average_band_score CHECK (test_average_band_score IS NULL OR (test_average_band_score >= 0 AND test_average_band_score <= 9)),
    test_best_band_score NUMERIC(3,1) CONSTRAINT check_test_best_band_score CHECK (test_best_band_score IS NULL OR (test_best_band_score >= 0 AND test_best_band_score <= 9)),
    last_test_date TIMESTAMP,
    last_test_band_score NUMERIC(3,1) CONSTRAINT check_last_test_band_score CHECK (last_test_band_score IS NULL OR (last_test_band_score >= 0 AND last_test_band_score <= 9)),
    
    UNIQUE(user_id, skill_type)
);

CREATE INDEX idx_skill_statistics_user_id ON skill_statistics(user_id);
CREATE INDEX idx_skill_statistics_skill_type ON skill_statistics(skill_type);
CREATE INDEX idx_skill_statistics_last_test_date ON skill_statistics(user_id, last_test_date DESC);

-- ----------------------------------------------------------------------------
-- Practice Activities Table
-- ----------------------------------------------------------------------------
CREATE TABLE practice_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    skill VARCHAR(20) NOT NULL CHECK (skill IN ('listening', 'reading', 'writing', 'speaking')),
    activity_type VARCHAR(30) NOT NULL CHECK (activity_type IN ('drill', 'part_test', 'section_practice', 'question_set')),
    
    -- Exercise reference
    exercise_id UUID,
    exercise_title VARCHAR(255),
    
    -- Scoring
    score NUMERIC(5,2),
    max_score NUMERIC(5,2),
    band_score NUMERIC(3,1) CHECK (band_score IS NULL OR (band_score >= 0 AND band_score <= 9)),
    correct_answers INTEGER DEFAULT 0,
    total_questions INTEGER,
    accuracy_percentage NUMERIC(5,2),
    
    -- Timing
    time_spent_seconds INTEGER,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    completion_status VARCHAR(20) DEFAULT 'completed' CHECK (completion_status IN ('completed', 'incomplete', 'abandoned', 'in_progress')),
    
    -- AI evaluation
    ai_evaluated BOOLEAN DEFAULT false,
    ai_feedback_summary TEXT,
    
    -- Metadata
    difficulty_level VARCHAR(20) CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced', 'expert')),
    tags TEXT[],
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_practice_activities_user_id ON practice_activities(user_id);
CREATE INDEX idx_practice_activities_skill ON practice_activities(skill);
CREATE INDEX idx_practice_activities_user_skill ON practice_activities(user_id, skill);
CREATE INDEX idx_practice_activities_user_completed ON practice_activities(user_id, completed_at DESC);
CREATE INDEX idx_practice_activities_completed_at ON practice_activities(completed_at DESC);
CREATE INDEX idx_practice_activities_exercise_id ON practice_activities(exercise_id);

-- ----------------------------------------------------------------------------
-- Official Test Results Table
-- ----------------------------------------------------------------------------
CREATE TABLE official_test_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    test_type VARCHAR(20) NOT NULL CHECK (test_type IN ('full_test', 'mock_test', 'sectional_test', 'practice')),
    
    -- Test details
    test_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    test_duration_minutes INTEGER,
    completion_status VARCHAR(20) DEFAULT 'completed' CHECK (completion_status IN ('completed', 'incomplete', 'abandoned')),
    test_source VARCHAR(50), -- 'cambridge', 'ielts_official', 'internal'
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    skill_type VARCHAR(20) NOT NULL CHECK (skill_type IN ('listening', 'reading', 'writing', 'speaking')),
    
    -- Scoring
    band_score NUMERIC(3,1) NOT NULL CHECK (band_score >= 0 AND band_score <= 9),
    raw_score INTEGER CHECK (raw_score IS NULL OR (raw_score >= 0 AND raw_score <= 40)),
    total_questions INTEGER,
    
    -- Source tracking (from which service/table this result came)
    source_service VARCHAR(50), -- 'exercise-service', 'ai-service'
    source_table VARCHAR(50), -- 'user_exercise_attempts', 'ai_evaluations'
    source_id UUID, -- Original record ID
    
    -- IELTS variant (for reading only)
    ielts_variant VARCHAR(20) CHECK (ielts_variant IS NULL OR ielts_variant IN ('academic', 'general_training')),
    
    -- Ensure reading tests have IELTS variant specified
    CONSTRAINT official_test_results_reading_variant_rule CHECK (
        (skill_type = 'reading' AND ielts_variant IS NOT NULL) OR
        (skill_type != 'reading' AND ielts_variant IS NULL)
    )
);

CREATE INDEX idx_official_test_results_user_id ON official_test_results(user_id);
CREATE INDEX idx_official_test_results_skill_type ON official_test_results(skill_type);
CREATE INDEX idx_official_test_results_test_date ON official_test_results(test_date DESC);
CREATE INDEX idx_official_test_results_user_skill_date ON official_test_results(user_id, skill_type, test_date DESC);
CREATE INDEX idx_official_test_results_variant ON official_test_results(skill_type, ielts_variant) WHERE ielts_variant IS NOT NULL;
CREATE INDEX idx_official_test_results_source ON official_test_results(source_service, source_id) WHERE source_id IS NOT NULL;
CREATE UNIQUE INDEX idx_official_test_results_source_unique ON official_test_results(source_service, source_table, source_id) WHERE source_id IS NOT NULL;

-- ============================================================================
-- STUDY TRACKING TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Study Sessions Table
-- ----------------------------------------------------------------------------
CREATE TABLE study_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    session_type VARCHAR(50) NOT NULL, -- 'lesson', 'exercise', 'test', 'review'
    skill_type VARCHAR(20), -- 'listening', 'reading', 'writing', 'speaking'
    resource_id UUID, -- ID of lesson, exercise, or test
    resource_type VARCHAR(50), -- 'lesson', 'exercise', 'test'
    started_at TIMESTAMP NOT NULL,
    ended_at TIMESTAMP,
    duration_minutes INTEGER,
    is_completed BOOLEAN DEFAULT false,
    completion_percentage NUMERIC(5,2),
    score NUMERIC(5,2),
    device_type VARCHAR(20), -- 'web', 'mobile', 'tablet'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_study_sessions_user_id ON study_sessions(user_id);
CREATE INDEX idx_study_sessions_skill_type ON study_sessions(skill_type);
CREATE INDEX idx_study_sessions_started_at ON study_sessions(started_at);
CREATE INDEX idx_study_sessions_user_duration ON study_sessions(user_id, duration_minutes);

-- ----------------------------------------------------------------------------
-- Study Goals Table
-- ----------------------------------------------------------------------------
CREATE TABLE study_goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    goal_type VARCHAR(50) NOT NULL, -- 'daily', 'weekly', 'monthly', 'custom'
    title VARCHAR(200) NOT NULL,
    description TEXT,
    target_value INTEGER NOT NULL, -- Target number
    target_unit VARCHAR(20) NOT NULL, -- 'lessons', 'exercises', 'hours', 'points'
    current_value INTEGER DEFAULT 0,
    skill_type VARCHAR(20), -- Optional: specific skill
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'active', -- 'active', 'completed', 'failed', 'cancelled'
    completed_at TIMESTAMP,
    reminder_enabled BOOLEAN DEFAULT true,
    reminder_time TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_study_goals_user_id ON study_goals(user_id);
CREATE INDEX idx_study_goals_status ON study_goals(status);
CREATE INDEX idx_study_goals_end_date ON study_goals(end_date);

-- ----------------------------------------------------------------------------
-- Study Reminders Table
-- ----------------------------------------------------------------------------
CREATE TABLE study_reminders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    message TEXT,
    reminder_type VARCHAR(20) NOT NULL, -- 'daily', 'custom'
    reminder_time TIME NOT NULL,
    days_of_week INTEGER[], -- [0-6] where 0=Monday, 6=Sunday
    is_active BOOLEAN DEFAULT true,
    last_sent_at TIMESTAMP,
    next_send_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_study_reminders_user_id ON study_reminders(user_id);
CREATE INDEX idx_study_reminders_next_send_at ON study_reminders(next_send_at) WHERE is_active = true;

-- ============================================================================
-- ACHIEVEMENTS AND SOCIAL
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Achievements Table
-- ----------------------------------------------------------------------------
CREATE TABLE achievements (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL, -- 'first_lesson', 'streak_7_days', etc.
    name VARCHAR(100) NOT NULL,
    description TEXT,
    criteria_type VARCHAR(50) NOT NULL, -- 'lessons_completed', 'streak_days', 'band_score'
    criteria_value INTEGER NOT NULL,
    icon_url TEXT,
    badge_color VARCHAR(20),
    points INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- User Achievements Table
-- ----------------------------------------------------------------------------
CREATE TABLE user_achievements (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    achievement_id INTEGER NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
    earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, achievement_id)
);

CREATE INDEX idx_user_achievements_user_id ON user_achievements(user_id);
CREATE INDEX idx_user_achievements_earned_at ON user_achievements(earned_at);
CREATE INDEX idx_user_achievements_user_earned ON user_achievements(user_id, earned_at DESC);
CREATE INDEX idx_user_achievements_user_id_count ON user_achievements(user_id);

-- ----------------------------------------------------------------------------
-- User Follows Table (Social feature)
-- ----------------------------------------------------------------------------
CREATE TABLE user_follows (
    id BIGSERIAL PRIMARY KEY,
    follower_id UUID NOT NULL REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(follower_id, following_id),
    CONSTRAINT check_no_self_follow CHECK (follower_id != following_id)
);

CREATE INDEX idx_user_follows_follower_id ON user_follows(follower_id);
CREATE INDEX idx_user_follows_following_id ON user_follows(following_id);
CREATE INDEX idx_user_follows_created_at ON user_follows(created_at DESC);

-- ============================================================================
-- USER PREFERENCES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- User Preferences Table
-- ----------------------------------------------------------------------------
CREATE TABLE user_preferences (
    user_id UUID PRIMARY KEY REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    
    -- Notification preferences
    email_notifications BOOLEAN DEFAULT true,
    push_notifications BOOLEAN DEFAULT true,
    study_reminders BOOLEAN DEFAULT true,
    weekly_report BOOLEAN DEFAULT true,
    
    -- UI preferences
    theme VARCHAR(20) DEFAULT 'light', -- 'light', 'dark', 'auto'
    font_size VARCHAR(20) DEFAULT 'medium', -- 'small', 'medium', 'large'
    locale VARCHAR(10) DEFAULT 'vi', -- 'vi', 'en'
    
    -- Learning preferences
    auto_play_next_lesson BOOLEAN DEFAULT true,
    show_answer_explanation BOOLEAN DEFAULT true,
    playback_speed NUMERIC(3,2) DEFAULT 1.0, -- 0.5, 0.75, 1.0, 1.25, 1.5, 2.0
    
    -- Privacy preferences
    profile_visibility VARCHAR(20) DEFAULT 'private', -- 'public', 'friends', 'private'
    show_study_stats BOOLEAN DEFAULT true,
    
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- FUNCTIONS AND TRIGGERS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Calculate overall IELTS band score
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION calculate_overall_score(listening NUMERIC, reading NUMERIC, writing NUMERIC, speaking NUMERIC)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN ROUND((listening + reading + writing + speaking) / 4, 1);
END;
$$;

-- ----------------------------------------------------------------------------
-- Auto-update updated_at timestamp
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_learning_progress_updated_at
    BEFORE UPDATE ON learning_progress
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_study_goals_updated_at
    BEFORE UPDATE ON study_goals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_skill_statistics_updated_at
    BEFORE UPDATE ON skill_statistics
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ----------------------------------------------------------------------------
-- Update practice_activities updated_at
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_practice_activities_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------------------
-- Update official_test_results updated_at
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_official_test_results_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_practice_activities_updated_at
    BEFORE UPDATE ON practice_activities
    FOR EACH ROW EXECUTE FUNCTION update_practice_activities_updated_at();

CREATE TRIGGER trigger_update_official_test_results_updated_at
    BEFORE UPDATE ON official_test_results
    FOR EACH ROW EXECUTE FUNCTION update_official_test_results_updated_at();

-- ----------------------------------------------------------------------------
-- Update study streak
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_study_streak(p_user_id UUID)
RETURNS void AS $$
DECLARE
    v_last_study_date DATE;
    v_current_streak INTEGER;
BEGIN
    SELECT last_study_date, current_streak_days
    INTO v_last_study_date, v_current_streak
    FROM learning_progress
    WHERE user_id = p_user_id;
    
    IF v_last_study_date IS NULL THEN
        -- First study session
        UPDATE learning_progress
        SET last_study_date = CURRENT_DATE,
            current_streak_days = 1,
            longest_streak_days = 1
        WHERE user_id = p_user_id;
    ELSIF v_last_study_date = CURRENT_DATE THEN
        -- Already studied today, no change
        RETURN;
    ELSIF v_last_study_date = CURRENT_DATE - INTERVAL '1 day' THEN
        -- Consecutive day
        UPDATE learning_progress
        SET last_study_date = CURRENT_DATE,
            current_streak_days = current_streak_days + 1,
            longest_streak_days = GREATEST(longest_streak_days, current_streak_days + 1)
        WHERE user_id = p_user_id;
    ELSE
        -- Streak broken, start new streak
        UPDATE learning_progress
        SET last_study_date = CURRENT_DATE,
            current_streak_days = 1
        WHERE user_id = p_user_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- SEED DATA
-- ============================================================================

-- Default achievements
INSERT INTO achievements (code, name, description, criteria_type, criteria_value, points) VALUES
    ('first_lesson', 'Bài học đầu tiên', 'Hoàn thành bài học đầu tiên', 'completion', 1, 10),
    ('streak_7', '7 ngày liên tiếp', 'Học 7 ngày liên tiếp', 'streak', 7, 50),
    ('streak_30', '30 ngày liên tiếp', 'Học 30 ngày liên tiếp', 'streak', 30, 200),
    ('band_6', 'IELTS 6.0', 'Đạt band 6.0 trong bài test', 'score', 60, 100),
    ('band_7', 'IELTS 7.0', 'Đạt band 7.0 trong bài test', 'score', 70, 150),
    ('listening_master', 'Listening Master', 'Hoàn thành 100 bài listening', 'completion', 100, 100);

-- ============================================================================
-- SCHEMA MIGRATIONS TRACKING
-- ============================================================================

CREATE TABLE schema_migrations (
    id SERIAL PRIMARY KEY,
    version VARCHAR(255) NOT NULL UNIQUE,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO schema_migrations (version) VALUES ('001_initial_schema');

-- ============================================================================
-- END OF USER SERVICE SCHEMA
-- ============================================================================
