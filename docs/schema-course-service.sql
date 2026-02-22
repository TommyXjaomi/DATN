-- ===== COURSE SERVICE SCHEMA =====
-- Tables: courses, modules, lessons, lesson_videos, lesson_materials, lesson_transcripts, course_enrollments, lesson_progress, course_reviews, course_prerequisites

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
    instructor_id UUID,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE modules (
    id UUID PRIMARY KEY,
    course_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    total_lessons INTEGER DEFAULT 0,
    total_exercises INTEGER DEFAULT 0,
    is_published BOOLEAN DEFAULT FALSE,
    module_order INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
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
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
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
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE
);

CREATE TABLE lesson_materials (
    id UUID PRIMARY KEY,
    lesson_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    file_type VARCHAR(50) NOT NULL,
    file_url VARCHAR(500) NOT NULL,
    file_size_bytes INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE
);

CREATE TABLE lesson_transcripts (
    id UUID PRIMARY KEY,
    lesson_id UUID NOT NULL,
    video_id UUID NOT NULL,
    language VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    transcript_type VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
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
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

CREATE TABLE course_prerequisites (
    id UUID PRIMARY KEY,
    course_id UUID NOT NULL,
    prerequisite_course_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    FOREIGN KEY (prerequisite_course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- ===== INDEXES =====
CREATE INDEX idx_courses_skill_type ON courses(skill_type);
CREATE INDEX idx_courses_level ON courses(level);
CREATE INDEX idx_modules_course_id ON modules(course_id);
CREATE INDEX idx_lessons_module_id ON lessons(module_id);
CREATE INDEX idx_lessons_course_id ON lessons(course_id);
CREATE INDEX idx_lesson_videos_lesson_id ON lesson_videos(lesson_id);
CREATE INDEX idx_lesson_materials_lesson_id ON lesson_materials(lesson_id);
CREATE INDEX idx_course_enrollments_course_id ON course_enrollments(course_id);
CREATE INDEX idx_lesson_progress_lesson_id ON lesson_progress(lesson_id);
CREATE INDEX idx_lesson_progress_course_id ON lesson_progress(course_id);
CREATE INDEX idx_course_reviews_course_id ON course_reviews(course_id);
