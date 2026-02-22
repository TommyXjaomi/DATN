-- ===== AUTH SERVICE SCHEMA =====

CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255)
);

CREATE TABLE auth_users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    email_verified BOOLEAN DEFAULT FALSE,
    failed_login_attempts INTEGER DEFAULT 0,
    is_locked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role) REFERENCES roles(name)
);

CREATE TABLE email_verifications (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    code VARCHAR(255) NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES auth_users(id) ON DELETE CASCADE
);

CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    token_hash VARCHAR(255) NOT NULL,
    is_revoked BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES auth_users(id) ON DELETE CASCADE
);

-- ===== USER SERVICE SCHEMA =====

CREATE TABLE user_profiles (
    user_id UUID PRIMARY KEY,
    full_name VARCHAR(255),
    avatar_url VARCHAR(500),
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    city VARCHAR(100),
    country VARCHAR(100),
    timezone VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES auth_users(id) ON DELETE CASCADE
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
    FOREIGN KEY (user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE
);

CREATE TABLE achievements (
    id UUID PRIMARY KEY,
    code VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(500),
    badge_points INTEGER DEFAULT 0,
    icon_url VARCHAR(500)
);

CREATE TABLE user_achievements (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    achievement_id UUID NOT NULL,
    is_unlocked BOOLEAN DEFAULT FALSE,
    earned_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    FOREIGN KEY (achievement_id) REFERENCES achievements(id) ON DELETE CASCADE
);

CREATE TABLE study_goals (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    goal_type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    target_value INTEGER NOT NULL,
    skill_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) DEFAULT 'active',
    target_date TIMESTAMP,
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
    FOREIGN KEY (user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE
);

CREATE TABLE study_streaks (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL UNIQUE,
    streak_count INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    last_activity_date TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE
);

-- ===== COURSE SERVICE SCHEMA =====

CREATE TABLE courses (
    id UUID PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    skill_type VARCHAR(50) NOT NULL,
    level VARCHAR(50) NOT NULL,
    price FLOAT DEFAULT 0,
    total_lessons INTEGER DEFAULT 0,
    total_modules INTEGER DEFAULT 0,
    average_rating FLOAT DEFAULT 0,
    is_published BOOLEAN DEFAULT FALSE,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE modules (
    id UUID PRIMARY KEY,
    course_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    total_lessons INTEGER DEFAULT 0,
    total_exercises INTEGER DEFAULT 0,
    is_published BOOLEAN DEFAULT FALSE,
    module_order INTEGER NOT NULL,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

CREATE TABLE lessons (
    id UUID PRIMARY KEY,
    module_id UUID NOT NULL,
    course_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    content_type VARCHAR(50) NOT NULL,
    duration_minutes INTEGER DEFAULT 0,
    is_free BOOLEAN DEFAULT FALSE,
    is_published BOOLEAN DEFAULT FALSE,
    lesson_order INTEGER NOT NULL,
    FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

CREATE TABLE lesson_videos (
    id UUID PRIMARY KEY,
    lesson_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    video_url VARCHAR(500) NOT NULL,
    video_provider VARCHAR(50) NOT NULL,
    duration_seconds INTEGER NOT NULL,
    FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE
);

CREATE TABLE lesson_materials (
    id UUID PRIMARY KEY,
    lesson_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    file_type VARCHAR(50) NOT NULL,
    file_url VARCHAR(500) NOT NULL,
    file_size_bytes INTEGER NOT NULL,
    FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE
);

CREATE TABLE lesson_transcripts (
    id UUID PRIMARY KEY,
    lesson_id UUID NOT NULL,
    video_id UUID NOT NULL,
    language VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    transcript_type VARCHAR(50),
    FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE,
    FOREIGN KEY (video_id) REFERENCES lesson_videos(id) ON DELETE CASCADE
);

CREATE TABLE course_enrollments (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    course_id UUID NOT NULL,
    enrollment_type VARCHAR(50) NOT NULL,
    progress_percentage FLOAT DEFAULT 0,
    lessons_completed INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'active',
    certificate_issued BOOLEAN DEFAULT FALSE,
    enrolled_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

CREATE TABLE lesson_progress (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    lesson_id UUID NOT NULL,
    course_id UUID NOT NULL,
    status VARCHAR(50) DEFAULT 'not_started',
    progress_percentage FLOAT DEFAULT 0,
    video_watched_seconds INTEGER DEFAULT 0,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

CREATE TABLE course_reviews (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    course_id UUID NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

CREATE TABLE course_prerequisites (
    id UUID PRIMARY KEY,
    course_id UUID NOT NULL,
    prerequisite_course_id UUID NOT NULL,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    FOREIGN KEY (prerequisite_course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- ===== EXERCISE SERVICE SCHEMA =====

CREATE TABLE exercises (
    id UUID PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    exercise_type VARCHAR(50) NOT NULL,
    skill_type VARCHAR(50) NOT NULL,
    total_questions INTEGER NOT NULL,
    total_sections INTEGER NOT NULL,
    difficulty VARCHAR(50) NOT NULL,
    passing_score FLOAT NOT NULL,
    is_free BOOLEAN DEFAULT FALSE,
    is_published BOOLEAN DEFAULT FALSE,
    description TEXT
);

CREATE TABLE exercise_sections (
    id UUID PRIMARY KEY,
    exercise_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    section_number INTEGER NOT NULL,
    total_questions INTEGER NOT NULL,
    duration_minutes INTEGER,
    FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
);

CREATE TABLE questions (
    id UUID PRIMARY KEY,
    exercise_id UUID NOT NULL,
    section_id UUID NOT NULL,
    question_text TEXT NOT NULL,
    question_type VARCHAR(50) NOT NULL,
    points FLOAT NOT NULL,
    difficulty VARCHAR(50) NOT NULL,
    question_number INTEGER NOT NULL,
    FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE,
    FOREIGN KEY (section_id) REFERENCES exercise_sections(id) ON DELETE CASCADE
);

CREATE TABLE question_options (
    id UUID PRIMARY KEY,
    question_id UUID NOT NULL,
    option_label VARCHAR(50) NOT NULL,
    option_text TEXT NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
);

CREATE TABLE user_exercise_attempts (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    exercise_id UUID NOT NULL,
    attempt_number INTEGER NOT NULL,
    status VARCHAR(50) NOT NULL,
    total_questions INTEGER NOT NULL,
    correct_answers INTEGER DEFAULT 0,
    score FLOAT DEFAULT 0,
    band_score FLOAT,
    started_at TIMESTAMP NOT NULL,
    completed_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
);

CREATE TABLE submission_answers (
    id UUID PRIMARY KEY,
    attempt_id UUID NOT NULL,
    question_id UUID NOT NULL,
    answer_text TEXT,
    is_correct BOOLEAN DEFAULT FALSE,
    points_earned FLOAT DEFAULT 0,
    submitted_at TIMESTAMP NOT NULL,
    FOREIGN KEY (attempt_id) REFERENCES user_exercise_attempts(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
);

CREATE TABLE exercise_results (
    id UUID PRIMARY KEY,
    attempt_id UUID NOT NULL UNIQUE,
    exercise_id UUID NOT NULL,
    user_id UUID NOT NULL,
    final_score FLOAT NOT NULL,
    band_score FLOAT,
    passed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (attempt_id) REFERENCES user_exercise_attempts(id) ON DELETE CASCADE,
    FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE
);

-- ===== NOTIFICATION SERVICE SCHEMA =====

CREATE TABLE notifications (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    channel VARCHAR(50) NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE
);

CREATE TABLE notification_events (
    id UUID PRIMARY KEY,
    event_type VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE notification_templates (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    channel VARCHAR(50) NOT NULL,
    title_template VARCHAR(500) NOT NULL,
    body_template TEXT NOT NULL,
    FOREIGN KEY (event_type) REFERENCES notification_events(event_type) ON DELETE CASCADE
);

CREATE TABLE device_tokens (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    token VARCHAR(500) NOT NULL,
    device_type VARCHAR(50) NOT NULL,
    device_os VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_used_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE
);

CREATE TABLE scheduled_notifications (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    channel VARCHAR(50) NOT NULL,
    frequency VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    next_schedule_time TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE
);

CREATE TABLE notification_preferences (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    notification_event_id UUID NOT NULL,
    email_enabled BOOLEAN DEFAULT TRUE,
    push_enabled BOOLEAN DEFAULT TRUE,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    FOREIGN KEY (notification_event_id) REFERENCES notification_events(id) ON DELETE CASCADE
);

CREATE TABLE notification_logs (
    id UUID PRIMARY KEY,
    notification_id UUID NOT NULL,
    device_token_id UUID NOT NULL,
    channel VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    sent_at TIMESTAMP NOT NULL,
    FOREIGN KEY (notification_id) REFERENCES notifications(id) ON DELETE CASCADE,
    FOREIGN KEY (device_token_id) REFERENCES device_tokens(id) ON DELETE CASCADE
);

-- ===== AI SERVICE SCHEMA =====

CREATE TABLE ai_models (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    version VARCHAR(50) NOT NULL,
    provider VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ai_evaluation_requests (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    exercise_attempt_id UUID NOT NULL,
    question_id UUID NOT NULL,
    skill_type VARCHAR(50) NOT NULL,
    task_type VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    FOREIGN KEY (exercise_attempt_id) REFERENCES user_exercise_attempts(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
);

CREATE TABLE ai_evaluation_results (
    id UUID PRIMARY KEY,
    request_id UUID NOT NULL UNIQUE,
    overall_band_score FLOAT NOT NULL,
    fluency_score FLOAT,
    accuracy_score FLOAT,
    detailed_scores JSONB,
    evaluated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (request_id) REFERENCES ai_evaluation_requests(id) ON DELETE CASCADE
);

CREATE TABLE ai_evaluation_cache (
    id UUID PRIMARY KEY,
    content_hash VARCHAR(255) NOT NULL UNIQUE,
    skill_type VARCHAR(50) NOT NULL,
    overall_band_score FLOAT NOT NULL,
    hit_count INTEGER DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ai_evaluation_logs (
    id UUID PRIMARY KEY,
    request_id UUID NOT NULL,
    task_type VARCHAR(100) NOT NULL,
    cache_hit BOOLEAN DEFAULT FALSE,
    processing_time_ms INTEGER NOT NULL,
    evaluated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (request_id) REFERENCES ai_evaluation_requests(id) ON DELETE CASCADE
);

-- ===== STORAGE SERVICE SCHEMA =====

CREATE TABLE storage_buckets (
    name VARCHAR(255) PRIMARY KEY,
    region VARCHAR(100) NOT NULL,
    policy VARCHAR(255),
    is_public BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE file_objects (
    id VARCHAR(255) PRIMARY KEY,
    bucket_name VARCHAR(255) NOT NULL,
    object_name VARCHAR(500) NOT NULL,
    url VARCHAR(500) NOT NULL,
    size BIGINT NOT NULL,
    content_type VARCHAR(100) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bucket_name) REFERENCES storage_buckets(name) ON DELETE CASCADE
);

CREATE TABLE file_versions (
    id VARCHAR(255) PRIMARY KEY,
    object_id VARCHAR(255) NOT NULL,
    bucket_name VARCHAR(255) NOT NULL,
    version_number INTEGER NOT NULL,
    size BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (object_id) REFERENCES file_objects(id) ON DELETE CASCADE,
    FOREIGN KEY (bucket_name) REFERENCES storage_buckets(name) ON DELETE CASCADE
);

CREATE TABLE file_access (
    id UUID PRIMARY KEY,
    object_id VARCHAR(255) NOT NULL,
    user_id UUID NOT NULL,
    access_type VARCHAR(50) NOT NULL,
    accessed_at TIMESTAMP NOT NULL,
    FOREIGN KEY (object_id) REFERENCES file_objects(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE
);

CREATE TABLE file_metadata (
    id VARCHAR(255) PRIMARY KEY,
    object_id VARCHAR(255) NOT NULL UNIQUE,
    metadata JSONB,
    tags VARCHAR(500),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (object_id) REFERENCES file_objects(id) ON DELETE CASCADE
);

CREATE TABLE deleted_files (
    id UUID PRIMARY KEY,
    object_id VARCHAR(255) NOT NULL,
    deleted_by UUID NOT NULL,
    deletion_reason VARCHAR(500),
    deleted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (object_id) REFERENCES file_objects(id) ON DELETE CASCADE,
    FOREIGN KEY (deleted_by) REFERENCES user_profiles(user_id) ON DELETE SET NULL
);

CREATE TABLE file_quotas (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL UNIQUE,
    total_quota_bytes BIGINT NOT NULL,
    used_bytes BIGINT DEFAULT 0,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE
);

-- ===== INDEXES =====

CREATE INDEX idx_auth_users_email ON auth_users(email);
CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX idx_courses_skill_type ON courses(skill_type);
CREATE INDEX idx_course_enrollments_user_id ON course_enrollments(user_id);
CREATE INDEX idx_course_enrollments_course_id ON course_enrollments(course_id);
CREATE INDEX idx_lesson_progress_user_id ON lesson_progress(user_id);
CREATE INDEX idx_exercises_skill_type ON exercises(skill_type);
CREATE INDEX idx_user_exercise_attempts_user_id ON user_exercise_attempts(user_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_file_objects_bucket_name ON file_objects(bucket_name);
