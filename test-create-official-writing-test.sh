#!/bin/bash

# Create an OFFICIAL writing test exercise for testing

docker exec -i ielts_postgres psql -U ielts_admin -d exercise_db << EOF
-- Insert OFFICIAL writing test exercise
INSERT INTO exercises (
    id, title, slug, description, exercise_type, skill_type, difficulty,
    ielts_level, total_questions, total_sections, time_limit_minutes,
    is_published, is_free, created_by
) VALUES (
    'e2000002-0000-0000-0000-000000000001',
    'IELTS Writing Official Test - Task 2',
    'writing-official-test-task2',
    'Official IELTS Writing Test - Academic Task 2: Argumentative Essay',
    'full_test',  -- This makes it an OFFICIAL test
    'writing',
    'advanced',
    'band_7_8',
    1,
    1,
    40,
    true,
    false,
    'a0000001-0000-0000-0000-000000000001'
) ON CONFLICT (id) DO UPDATE SET
    exercise_type = EXCLUDED.exercise_type,
    title = EXCLUDED.title;

-- Insert section for the official test
INSERT INTO exercise_sections (
    id, exercise_id, section_number, title, instructions, display_order
) VALUES (
    'f2000002-0000-0000-0000-000000000001',
    'e2000002-0000-0000-0000-000000000001',
    1,
    'Task 2: Essay Writing',
    'Write an essay in response to the point of view, argument or problem. You should write at least 250 words.',
    1
) ON CONFLICT (id) DO UPDATE SET
    title = EXCLUDED.title;

-- Insert the writing question/prompt
INSERT INTO questions (
    id, exercise_id, section_id, question_number, question_text,
    question_type, points, difficulty, display_order
) VALUES (
    'a2000002-0000-0000-0000-000000000001',
    'e2000002-0000-0000-0000-000000000001',
    'f2000002-0000-0000-0000-000000000001',
    1,
    'Some people think that parents should teach children how to be good members of society. Others, however, believe that school is the place to learn this. Discuss both these views and give your own opinion.',
    'essay',
    100,
    'advanced',
    1
) ON CONFLICT (id) DO UPDATE SET
    question_text = EXCLUDED.question_text;

EOF

echo "✅ Created OFFICIAL writing test exercise: e2000002-0000-0000-0000-000000000001"
