-- ===== EXERCISE SERVICE SCHEMA =====
-- Tables: exercises, exercise_sections, questions, question_options, user_exercise_attempts, submission_answers, exercise_results

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
    description TEXT,
    time_limit_minutes INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE exercise_sections (
    id UUID PRIMARY KEY,
    exercise_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    section_number INTEGER NOT NULL,
    total_questions INTEGER NOT NULL,
    duration_minutes INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
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
    explanation VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE,
    FOREIGN KEY (section_id) REFERENCES exercise_sections(id) ON DELETE CASCADE
);

CREATE TABLE question_options (
    id UUID PRIMARY KEY,
    question_id UUID NOT NULL,
    option_label VARCHAR(50) NOT NULL,
    option_text TEXT NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
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
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
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
    FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
);

-- ===== INDEXES =====
CREATE INDEX idx_exercises_skill_type ON exercises(skill_type);
CREATE INDEX idx_exercises_difficulty ON exercises(difficulty);
CREATE INDEX idx_exercise_sections_exercise_id ON exercise_sections(exercise_id);
CREATE INDEX idx_questions_exercise_id ON questions(exercise_id);
CREATE INDEX idx_questions_section_id ON questions(section_id);
CREATE INDEX idx_question_options_question_id ON question_options(question_id);
CREATE INDEX idx_user_exercise_attempts_user_id ON user_exercise_attempts(user_id);
CREATE INDEX idx_user_exercise_attempts_exercise_id ON user_exercise_attempts(exercise_id);
CREATE INDEX idx_submission_answers_attempt_id ON submission_answers(attempt_id);
CREATE INDEX idx_exercise_results_exercise_id ON exercise_results(exercise_id);
