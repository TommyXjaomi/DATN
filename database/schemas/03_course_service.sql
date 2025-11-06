-- ============================================
-- Course Service Database Schema
-- ============================================
-- Database: course_db
-- Purpose: Course management, lessons, videos, and student progress tracking
-- Author: IELTS Platform Backend Team
-- Created: 2025-11-06
-- Last Modified: 2025-11-06

-- Create database (run separately)
-- CREATE DATABASE course_db;

-- ============================================
-- EXTENSIONS
-- ============================================

-- Enable UUID extension for UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable dblink for cross-database queries
CREATE EXTENSION IF NOT EXISTS dblink;

-- Enable pg_trgm for full-text search on course titles and descriptions
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ============================================
-- CATEGORY MANAGEMENT TABLES
-- ============================================

-- ============================================
-- COURSE_CATEGORIES TABLE
-- ============================================
-- Hierarchical category system for organizing courses
-- Supports nested categories (parent-child relationship)
CREATE TABLE course_categories (
    id SERIAL PRIMARY KEY,
    
    name VARCHAR(100) UNIQUE NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL, -- URL-friendly name
    description TEXT,
    
    -- Hierarchy support
    parent_id INT REFERENCES course_categories(id), -- NULL for top-level categories
    
    -- Display
    display_order INT DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- CORE COURSE TABLES
-- ============================================

-- ============================================
-- COURSES TABLE
-- ============================================
-- Main course information
-- Supports different IELTS skills (Listening, Reading, Writing, Speaking)
CREATE TABLE courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Basic info
    title VARCHAR(200) NOT NULL,
    slug VARCHAR(250) UNIQUE NOT NULL, -- URL-friendly identifier
    description TEXT,
    short_description VARCHAR(500),
    
    -- Course classification
    skill_type VARCHAR(20) NOT NULL, -- 'listening', 'reading', 'writing', 'speaking', 'general'
    level VARCHAR(20) NOT NULL, -- 'beginner', 'intermediate', 'advanced'
    target_band_score NUMERIC(2,1), -- Target IELTS band score (e.g., 6.5, 7.0)
    
    -- Media
    thumbnail_url TEXT,
    preview_video_url TEXT,
    
    -- Instructor
    instructor_id UUID NOT NULL, -- Reference to user in auth_db
    instructor_name VARCHAR(200), -- Denormalized for performance
    
    -- Course structure
    duration_hours NUMERIC(5,2), -- Total course duration
    total_lessons INT DEFAULT 0, -- Calculated from modules
    total_videos INT DEFAULT 0, -- Calculated from lessons
    
    -- Pricing
    enrollment_type VARCHAR(20) DEFAULT 'free', -- 'free', 'paid', 'subscription'
    price NUMERIC(10,2) DEFAULT 0,
    currency VARCHAR(10) DEFAULT 'VND',
    
    -- Status
    status VARCHAR(20) DEFAULT 'draft', -- 'draft', 'published', 'archived'
    is_featured BOOLEAN DEFAULT false, -- Show on homepage
    is_recommended BOOLEAN DEFAULT false, -- Recommended for students
    
    -- Statistics (updated by triggers)
    total_enrollments INT DEFAULT 0,
    average_rating NUMERIC(3,2) DEFAULT 0, -- 0.00 to 5.00
    total_reviews INT DEFAULT 0,
    
    -- SEO
    meta_title VARCHAR(200),
    meta_description TEXT,
    meta_keywords VARCHAR(500),
    
    -- Display
    display_order INT DEFAULT 0,
    
    -- Publishing
    published_at TIMESTAMP,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP -- Soft delete
);

-- Indexes for courses
CREATE INDEX idx_courses_instructor_id ON courses(instructor_id);
CREATE INDEX idx_courses_skill_type ON courses(skill_type);
CREATE INDEX idx_courses_level ON courses(level);
CREATE INDEX idx_courses_skill_level ON courses(skill_type, level);
CREATE INDEX idx_courses_status ON courses(status);
CREATE INDEX idx_courses_enrollment_type ON courses(enrollment_type);
CREATE INDEX idx_courses_featured ON courses(is_featured) WHERE is_featured = true;
CREATE INDEX idx_courses_slug ON courses(slug) WHERE deleted_at IS NULL;
CREATE INDEX idx_courses_status_display ON courses(status, display_order, created_at);

-- Full-text search indexes
CREATE INDEX idx_courses_title_search ON courses USING gin (title gin_trgm_ops);
CREATE INDEX idx_courses_desc_search ON courses USING gin (description gin_trgm_ops);

-- ============================================
-- COURSE_CATEGORY_MAPPING TABLE
-- ============================================
-- Many-to-many relationship between courses and categories
-- A course can belong to multiple categories
-- Note: Created here after courses table exists
CREATE TABLE course_category_mapping (
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    category_id INT NOT NULL REFERENCES course_categories(id) ON DELETE CASCADE,
    
    PRIMARY KEY (course_id, category_id)
);

-- Indexes
CREATE INDEX idx_course_category_mapping_course_id ON course_category_mapping(course_id);
CREATE INDEX idx_course_category_mapping_category_id ON course_category_mapping(category_id);

-- ============================================
-- MODULES TABLE
-- ============================================
-- Course modules (sections/chapters)
-- Each course has multiple modules
CREATE TABLE modules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    
    title VARCHAR(200) NOT NULL,
    description TEXT,
    
    -- Statistics
    duration_hours NUMERIC(5,2),
    total_lessons INT DEFAULT 0, -- Count of lessons in this module
    total_exercises INT DEFAULT 0 NOT NULL, -- Count of exercises linked to this module
    
    -- Display
    display_order INT NOT NULL DEFAULT 0,
    is_published BOOLEAN DEFAULT true,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_modules_course_id ON modules(course_id);
CREATE INDEX idx_modules_course_id_perf ON modules(course_id);
CREATE INDEX idx_modules_display_order ON modules(course_id, display_order);

-- ============================================
-- LESSONS TABLE
-- ============================================
-- Individual lessons within modules
-- Can be video, text, quiz, or exercise
CREATE TABLE lessons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    module_id UUID NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE, -- Denormalized for performance
    
    title VARCHAR(200) NOT NULL,
    description TEXT,
    
    -- Content type
    content_type VARCHAR(50) NOT NULL, -- 'video', 'text', 'quiz', 'exercise', 'interactive'
    
    -- Duration
    duration_minutes INT, -- Estimated time to complete
    
    -- Display
    display_order INT NOT NULL DEFAULT 0,
    is_free BOOLEAN DEFAULT false, -- Can be accessed without enrollment
    is_published BOOLEAN DEFAULT true,
    
    -- Statistics
    total_completions INT DEFAULT 0,
    average_time_spent INT, -- Average minutes spent by students
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_lessons_module_id ON lessons(module_id);
CREATE INDEX idx_lessons_module_id_perf ON lessons(module_id);
CREATE INDEX idx_lessons_course_id ON lessons(course_id);
CREATE INDEX idx_lessons_course_id_perf ON lessons(course_id);
CREATE INDEX idx_lessons_display_order ON lessons(module_id, display_order);

-- ============================================
-- VIDEO & MATERIAL TABLES
-- ============================================

-- ============================================
-- LESSON_VIDEOS TABLE
-- ============================================
-- Video content for lessons
-- Supports multiple video providers (YouTube, Vimeo, self-hosted)
CREATE TABLE lesson_videos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    
    title VARCHAR(200),
    description TEXT,
    
    -- Video info
    video_url TEXT NOT NULL, -- URL to video file or embed URL
    video_provider VARCHAR(50) DEFAULT 'self-hosted', -- 'youtube', 'vimeo', 'self-hosted'
    video_id VARCHAR(200), -- Provider-specific video ID
    
    duration_seconds INT,
    thumbnail_url TEXT,
    
    -- Quality/formats
    resolutions JSONB, -- Available resolutions: {"1080p": "url", "720p": "url"}
    
    -- Subtitles
    has_subtitles BOOLEAN DEFAULT false,
    subtitle_languages VARCHAR(100)[], -- Array of language codes: ['vi', 'en']
    
    -- Display
    display_order INT DEFAULT 0,
    
    -- Statistics
    total_views INT DEFAULT 0,
    average_watch_percentage NUMERIC(5,2), -- Average % of video watched
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_lesson_videos_lesson_id ON lesson_videos(lesson_id);

-- ============================================
-- VIDEO_SUBTITLES TABLE
-- ============================================
-- Subtitle files for videos
CREATE TABLE video_subtitles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    video_id UUID NOT NULL REFERENCES lesson_videos(id) ON DELETE CASCADE,
    
    language VARCHAR(10) NOT NULL, -- 'vi', 'en', etc.
    subtitle_url TEXT NOT NULL, -- URL to subtitle file (.vtt, .srt)
    format VARCHAR(20) DEFAULT 'vtt', -- 'vtt', 'srt'
    
    is_default BOOLEAN DEFAULT false, -- Default subtitle track
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_video_subtitles_video_id ON video_subtitles(video_id);

-- ============================================
-- LESSON_MATERIALS TABLE
-- ============================================
-- Downloadable materials for lessons
-- PDFs, slides, worksheets, etc.
CREATE TABLE lesson_materials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    
    title VARCHAR(200) NOT NULL,
    description TEXT,
    
    -- File info
    file_type VARCHAR(50) NOT NULL, -- 'pdf', 'docx', 'pptx', 'zip', etc.
    file_url TEXT NOT NULL,
    file_size_bytes BIGINT,
    
    -- Display
    display_order INT DEFAULT 0,
    
    -- Statistics
    total_downloads INT DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_lesson_materials_lesson_id ON lesson_materials(lesson_id);

-- ============================================
-- ENROLLMENT & PROGRESS TABLES
-- ============================================

-- ============================================
-- COURSE_ENROLLMENTS TABLE
-- ============================================
-- Student enrollments in courses
CREATE TABLE course_enrollments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL, -- Reference to user in auth_db
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    
    -- Enrollment info
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    enrollment_type VARCHAR(20) NOT NULL, -- 'free', 'paid', 'trial'
    
    -- Payment (if paid)
    payment_id UUID, -- Reference to payment transaction
    amount_paid NUMERIC(10,2),
    currency VARCHAR(10),
    
    -- Progress tracking
    progress_percentage NUMERIC(5,2) DEFAULT 0, -- 0.00 to 100.00
    lessons_completed INT DEFAULT 0,
    total_time_spent_minutes INT DEFAULT 0,
    
    -- Status
    status VARCHAR(20) DEFAULT 'active', -- 'active', 'completed', 'expired', 'cancelled'
    completed_at TIMESTAMP,
    
    -- Certificate
    certificate_issued BOOLEAN DEFAULT false,
    certificate_url TEXT,
    
    -- Expiry (for time-limited access)
    expires_at TIMESTAMP,
    
    -- Activity
    last_accessed_at TIMESTAMP,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id, course_id) -- One enrollment per user per course
);

-- Indexes
CREATE INDEX idx_course_enrollments_user_id ON course_enrollments(user_id);
CREATE INDEX idx_course_enrollments_course_id ON course_enrollments(course_id);
CREATE INDEX idx_course_enrollments_status ON course_enrollments(status);

-- ============================================
-- LESSON_PROGRESS TABLE
-- ============================================
-- Track student progress for each lesson
CREATE TABLE lesson_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL, -- Reference to user in auth_db
    lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE, -- Denormalized
    
    -- Status
    status VARCHAR(20) DEFAULT 'not_started', -- 'not_started', 'in_progress', 'completed'
    progress_percentage NUMERIC(5,2) DEFAULT 0,
    
    -- Video progress
    video_watched_seconds INT NOT NULL DEFAULT 0,
    video_total_seconds INT,
    last_position_seconds INT NOT NULL DEFAULT 0, -- Resume position
    
    -- Completion
    completed_at TIMESTAMP,
    
    -- Activity
    first_accessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_accessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id, lesson_id)
);

-- Indexes
CREATE INDEX idx_lesson_progress_user_id ON lesson_progress(user_id);
CREATE INDEX idx_lesson_progress_lesson_id ON lesson_progress(lesson_id);
CREATE INDEX idx_lesson_progress_status ON lesson_progress(status);
CREATE INDEX idx_lesson_progress_last_position ON lesson_progress(user_id, last_position_seconds) WHERE last_position_seconds > 0;

-- ============================================
-- VIDEO_WATCH_HISTORY TABLE
-- ============================================
-- Detailed video watch history for analytics
CREATE TABLE video_watch_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    video_id UUID NOT NULL REFERENCES lesson_videos(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    
    -- Watch data
    watched_seconds INT NOT NULL,
    total_seconds INT NOT NULL,
    watch_percentage NUMERIC(5,2), -- Calculated: watched/total * 100
    
    -- Session info
    session_id UUID, -- Group related watch events
    device_type VARCHAR(20), -- 'desktop', 'mobile', 'tablet'
    
    watched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_video_watch_history_user_id ON video_watch_history(user_id);
CREATE INDEX idx_video_watch_history_video_id ON video_watch_history(video_id);
CREATE INDEX idx_video_watch_history_watched_at ON video_watch_history(watched_at);

-- ============================================
-- REVIEW & RATING TABLES
-- ============================================

-- ============================================
-- COURSE_REVIEWS TABLE
-- ============================================
-- Student reviews and ratings for courses
CREATE TABLE course_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL, -- Reference to user in auth_db
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    
    -- Review
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5), -- 1-5 stars
    title VARCHAR(200),
    comment TEXT,
    
    -- Engagement
    helpful_count INT DEFAULT 0, -- Number of "helpful" votes
    
    -- Moderation
    is_approved BOOLEAN DEFAULT false,
    approved_by UUID, -- Admin who approved
    approved_at TIMESTAMP,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id, course_id) -- One review per user per course
);

-- Indexes
CREATE INDEX idx_course_reviews_course_id ON course_reviews(course_id);
CREATE INDEX idx_course_reviews_rating ON course_reviews(rating);
CREATE INDEX idx_course_reviews_is_approved ON course_reviews(is_approved);

-- ============================================
-- SYSTEM TABLES
-- ============================================

-- ============================================
-- SCHEMA_MIGRATIONS TABLE
-- ============================================
-- Tracks database migrations
CREATE TABLE schema_migrations (
    id SERIAL PRIMARY KEY,
    migration_file VARCHAR(255) UNIQUE NOT NULL,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    checksum VARCHAR(64)
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
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_courses_updated_at
    BEFORE UPDATE ON courses
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_modules_updated_at
    BEFORE UPDATE ON modules
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_lessons_updated_at
    BEFORE UPDATE ON lessons
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to update course enrollment count
CREATE OR REPLACE FUNCTION update_course_enrollment_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE courses
        SET total_enrollments = total_enrollments + 1
        WHERE id = NEW.course_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE courses
        SET total_enrollments = GREATEST(0, total_enrollments - 1)
        WHERE id = OLD.course_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update enrollment count
CREATE TRIGGER trigger_update_course_enrollment_count
    AFTER INSERT OR DELETE ON course_enrollments
    FOR EACH ROW
    EXECUTE FUNCTION update_course_enrollment_count();

-- Function to update course rating
CREATE OR REPLACE FUNCTION update_course_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE courses
    SET average_rating = (
        SELECT COALESCE(AVG(rating), 0)
        FROM course_reviews
        WHERE course_id = NEW.course_id AND is_approved = true
    ),
    total_reviews = (
        SELECT COUNT(*)
        FROM course_reviews
        WHERE course_id = NEW.course_id AND is_approved = true
    )
    WHERE id = NEW.course_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update rating
CREATE TRIGGER trigger_update_course_rating
    AFTER INSERT OR UPDATE ON course_reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_course_rating();

-- ============================================
-- SEED DATA (Optional)
-- ============================================

-- Insert default course categories
-- Default course categories
INSERT INTO course_categories (name, slug, description, display_order) VALUES
    ('Listening', 'listening', 'Các khóa học kỹ năng Listening', 1),
    ('Reading', 'reading', 'Các khóa học kỹ năng Reading', 2),
    ('Writing', 'writing', 'Các khóa học kỹ năng Writing', 3),
    ('Speaking', 'speaking', 'Các khóa học kỹ năng Speaking', 4),
    ('Grammar', 'grammar', 'Các khóa học ngữ pháp', 5),
    ('Vocabulary', 'vocabulary', 'Các khóa học từ vựng', 6),
    ('Test Preparation', 'test-preparation', 'Luyện đề thi IELTS', 7),
    ('Academic IELTS', 'academic-ielts', 'IELTS Academic', 8),
    ('General IELTS', 'general-ielts', 'IELTS General Training', 9);-- ============================================
-- COMMENTS
-- ============================================

COMMENT ON TABLE courses IS 'Bảng lưu thông tin khóa học IELTS';
COMMENT ON TABLE modules IS 'Bảng lưu các module (chương) trong khóa học';
COMMENT ON TABLE lessons IS 'Bảng lưu các bài học trong module';
COMMENT ON TABLE lesson_videos IS 'Bảng lưu video bài học';
COMMENT ON TABLE lesson_materials IS 'Bảng lưu tài liệu học tập (PDF, slides, etc.)';
COMMENT ON TABLE video_subtitles IS 'Bảng lưu phụ đề cho video';
COMMENT ON TABLE course_enrollments IS 'Bảng lưu thông tin đăng ký khóa học của học viên';
COMMENT ON TABLE lesson_progress IS 'Bảng lưu tiến trình học của từng bài học';
COMMENT ON TABLE video_watch_history IS 'Bảng lưu lịch sử xem video để phân tích';
COMMENT ON TABLE course_reviews IS 'Bảng lưu đánh giá và nhận xét về khóa học';
COMMENT ON TABLE course_categories IS 'Bảng danh mục khóa học (có hỗ trợ phân cấp)';
COMMENT ON TABLE course_category_mapping IS 'Bảng mapping nhiều-nhiều giữa course và category';

-- Column comments
COMMENT ON COLUMN courses.skill_type IS 'Loại kỹ năng IELTS: listening, reading, writing, speaking, general';
COMMENT ON COLUMN courses.total_enrollments IS 'Số lượng học viên đã đăng ký (cập nhật tự động bởi trigger)';
COMMENT ON COLUMN courses.average_rating IS 'Điểm đánh giá trung bình (cập nhật tự động bởi trigger)';
COMMENT ON COLUMN lesson_progress.last_position_seconds IS 'Vị trí dừng video để tiếp tục xem lần sau';
COMMENT ON COLUMN course_reviews.is_approved IS 'Review cần được admin phê duyệt trước khi hiển thị';
