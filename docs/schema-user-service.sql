-- ===== USER SERVICE SCHEMA =====
-- Tables: user_profiles, learning_progress, study_sessions, achievements, user_achievements, study_goals, study_reminders, study_streaks

CREATE TABLE user_profiles (
    user_id UUID PRIMARY KEY,
    full_name VARCHAR(255),
    avatar_url VARCHAR(500),
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    city VARCHAR(100),
    country VARCHAR(100),
    timezone VARCHAR(50) DEFAULT 'UTC',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE learning_progress (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL UNIQUE,
    total_study_hours FLOAT DEFAULT 0,
    total_lessons_completed INTEGER DEFAULT 0,
    total_exercises_completed INTEGER DEFAULT 0,
    listening_progress FLOAT DEFAULT 0,
    reading_progress FLOAT DEFAULT 0,
    writing_progress FLOAT DEFAULT 0,
    speaking_progress FLOAT DEFAULT 0,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE
);

CREATE TABLE study_sessions (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    session_type VARCHAR(50) NOT NULL,
    skill_type VARCHAR(50) NOT NULL,
    duration_minutes INTEGER NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE
);

CREATE TABLE achievements (
    id UUID PRIMARY KEY,
    code VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(500),
    badge_points INTEGER DEFAULT 0,
    icon_url VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_achievements (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    achievement_id UUID NOT NULL,
    is_unlocked BOOLEAN DEFAULT FALSE,
    earned_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    FOREIGN KEY (achievement_id) REFERENCES achievements(id) ON DELETE CASCADE
);

CREATE TABLE study_goals (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    goal_type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    target_value INTEGER NOT NULL,
    current_value INTEGER DEFAULT 0,
    skill_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) DEFAULT 'active',
    target_date TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE
);

CREATE TABLE study_reminders (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    reminder_type VARCHAR(50) NOT NULL,
    reminder_time VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    frequency VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE
);

CREATE TABLE study_streaks (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL UNIQUE,
    streak_count INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    last_activity_date TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE
);

-- ===== INDEXES =====
CREATE INDEX idx_user_profiles_email ON user_profiles(email);
CREATE INDEX idx_learning_progress_user_id ON learning_progress(user_id);
CREATE INDEX idx_study_sessions_user_id ON study_sessions(user_id);
CREATE INDEX idx_study_sessions_skill_type ON study_sessions(skill_type);
CREATE INDEX idx_user_achievements_user_id ON user_achievements(user_id);
CREATE INDEX idx_study_goals_user_id ON study_goals(user_id);
CREATE INDEX idx_study_goals_status ON study_goals(status);
CREATE INDEX idx_study_reminders_user_id ON study_reminders(user_id);
