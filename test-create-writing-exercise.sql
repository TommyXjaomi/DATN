-- Create a simple Writing Task 2 exercise for testing
INSERT INTO exercises (
    id, title, slug, description, exercise_type, skill_type, difficulty, ielts_level,
    total_questions, total_sections, time_limit_minutes,
    thumbnail_url, is_free, is_published, display_order,
    created_by, published_at, created_at, updated_at
) VALUES (
    'e2000001-0000-0000-0000-000000000001',
    'IELTS Writing Task 2 - Environment Essay',
    'ielts-writing-task-2-environment-essay',
    'Write an essay discussing environmental protection measures. Minimum 250 words.',
    'practice',
    'writing',
    'intermediate',
    'band 6.0-7.0',
    1,
    1,
    40,
    'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09',
    true,
    true,
    0,
    'b0000001-0000-0000-0000-000000000001',
    NOW(),
    NOW(),
    NOW()
);

-- Create the writing section
INSERT INTO exercise_sections (
    id, exercise_id, section_number, title, instructions, display_order, created_at, updated_at
) VALUES (
    'e2001001-0000-0000-0000-000000000001',
    'e2000001-0000-0000-0000-000000000001',
    1,
    'Task 2: Essay Writing',
    'Some people believe that protecting the environment is the government''s responsibility, while others think individuals should take action. Discuss both views and give your opinion. Write at least 250 words.',
    0,
    NOW(),
    NOW()
);

-- Create a question (for metadata purposes)
INSERT INTO questions (
    id, exercise_id, section_id, question_number, question_type, question_text,
    display_order, points, created_at, updated_at
) VALUES (
    'e2002001-0000-0000-0000-000000000001',
    'e2000001-0000-0000-0000-000000000001',
    'e2001001-0000-0000-0000-000000000001',
    1,
    'essay',
    'Write your essay here',
    1,
    9.0,
    NOW(),
    NOW()
);
