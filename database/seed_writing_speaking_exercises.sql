-- ============================================
-- SEED DATA FOR WRITING AND SPEAKING EXERCISES
-- ============================================
-- Purpose: Insert comprehensive sample data for AI-evaluated Writing and Speaking exercises
-- Usage: psql -U ielts_admin -d exercise_db -f seed_writing_speaking_exercises.sql

-- Note: These exercises use skill_type = 'writing' or 'speaking' and will be evaluated by AI Service

-- ============================================
-- WRITING EXERCISES
-- ============================================

-- ============================================
-- 1. WRITING TASK 1 (ACADEMIC) - Easy
-- ============================================
INSERT INTO exercises (
    id, title, slug, description, exercise_type, skill_type, difficulty, ielts_level,
    total_questions, total_sections, time_limit_minutes, passing_score, total_points,
    is_free, is_published, created_by, published_at, display_order, created_at, updated_at
) VALUES (
    'e8888881-8888-8888-8888-888888888881',
    'Writing Task 1: Bar Chart - Population Growth',
    'writing-task1-bar-chart-population',
    'Practice describing a bar chart showing population growth in different countries. Minimum 150 words required.',
    'practice',
    'writing',
    'easy',
    'band 5.0-6.0',
    0, -- No questions for writing exercises
    1,
    20,
    60.00,
    100.00,
    true,
    true,
    '00000000-0000-0000-0000-000000000001',
    NOW(),
    1,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- Section with prompt
INSERT INTO exercise_sections (
    id, exercise_id, title, description, section_number,
    instructions, total_questions, display_order, created_at, updated_at
) VALUES (
    'e8888881-8888-8888-8888-888888888811',
    'e8888881-8888-8888-8888-888888888881',
    'Task 1: Bar Chart Description',
    'Describe the bar chart showing population growth data',
    1,
    'The chart below shows the population growth of five countries from 2000 to 2020.

Summarize the information by selecting and reporting the main features, and make comparisons where relevant.

Write at least 150 words.',
    0,
    1,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 2. WRITING TASK 1 (ACADEMIC) - Medium
-- ============================================
INSERT INTO exercises (
    id, title, slug, description, exercise_type, skill_type, difficulty, ielts_level,
    total_questions, total_sections, time_limit_minutes, passing_score, total_points,
    is_free, is_published, created_by, published_at, display_order, created_at, updated_at
) VALUES (
    'e8888882-8888-8888-8888-888888888882',
    'Writing Task 1: Line Graph - Energy Consumption',
    'writing-task1-line-graph-energy',
    'Practice describing a line graph showing energy consumption trends. Minimum 150 words required.',
    'practice',
    'writing',
    'medium',
    'band 6.0-7.0',
    0,
    1,
    20,
    65.00,
    100.00,
    true,
    true,
    '00000000-0000-0000-0000-000000000001',
    NOW(),
    2,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_sections (
    id, exercise_id, title, description, section_number,
    instructions, total_questions, display_order, created_at, updated_at
) VALUES (
    'e8888882-8888-8888-8888-888888888812',
    'e8888882-8888-8888-8888-888888888882',
    'Task 1: Line Graph Description',
    'Describe the line graph showing energy consumption trends',
    1,
    'The graph below shows the energy consumption in three countries (USA, China, and India) between 1990 and 2020.

Summarize the information by selecting and reporting the main features, and make comparisons where relevant.

Write at least 150 words.',
    0,
    1,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 3. WRITING TASK 1 (ACADEMIC) - Hard
-- ============================================
INSERT INTO exercises (
    id, title, slug, description, exercise_type, skill_type, difficulty, ielts_level,
    total_questions, total_sections, time_limit_minutes, passing_score, total_points,
    is_free, is_published, created_by, published_at, display_order, created_at, updated_at
) VALUES (
    'e8888883-8888-8888-8888-888888888883',
    'Writing Task 1: Process Diagram - Water Cycle',
    'writing-task1-process-water-cycle',
    'Practice describing a process diagram showing the water cycle. Minimum 150 words required.',
    'practice',
    'writing',
    'hard',
    'band 7.0-8.0',
    0,
    1,
    20,
    70.00,
    100.00,
    true,
    true,
    '00000000-0000-0000-0000-000000000001',
    NOW(),
    3,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_sections (
    id, exercise_id, title, description, section_number,
    instructions, total_questions, display_order, created_at, updated_at
) VALUES (
    'e8888883-8888-8888-8888-888888888813',
    'e8888883-8888-8888-8888-888888888883',
    'Task 1: Process Diagram Description',
    'Describe the process diagram showing the water cycle',
    1,
    'The diagram below shows the water cycle, which is the continuous movement of water on, above, and below the surface of the Earth.

Summarize the information by selecting and reporting the main features.

Write at least 150 words.',
    0,
    1,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 4. WRITING TASK 2 (OPINION ESSAY) - Easy
-- ============================================
INSERT INTO exercises (
    id, title, slug, description, exercise_type, skill_type, difficulty, ielts_level,
    total_questions, total_sections, time_limit_minutes, passing_score, total_points,
    is_free, is_published, created_by, published_at, display_order, created_at, updated_at
) VALUES (
    'e8888884-8888-8888-8888-888888888884',
    'Writing Task 2: Opinion Essay - Technology',
    'writing-task2-opinion-technology',
    'Practice writing an opinion essay about technology. Minimum 250 words required.',
    'practice',
    'writing',
    'easy',
    'band 5.0-6.0',
    0,
    1,
    40,
    60.00,
    100.00,
    true,
    true,
    '00000000-0000-0000-0000-000000000001',
    NOW(),
    4,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_sections (
    id, exercise_id, title, description, section_number,
    instructions, total_questions, display_order, created_at, updated_at
) VALUES (
    'e8888884-8888-8888-8888-888888888814',
    'e8888884-8888-8888-8888-888888888884',
    'Task 2: Opinion Essay',
    'Write an opinion essay on the given topic',
    1,
    'Some people believe that technology has made our lives more complicated, while others think it has made life easier. 

Discuss both views and give your own opinion.

Give reasons for your answer and include any relevant examples from your own knowledge or experience.

Write at least 250 words.',
    0,
    1,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 5. WRITING TASK 2 (OPINION ESSAY) - Medium
-- ============================================
INSERT INTO exercises (
    id, title, slug, description, exercise_type, skill_type, difficulty, ielts_level,
    total_questions, total_sections, time_limit_minutes, passing_score, total_points,
    is_free, is_published, created_by, published_at, display_order, created_at, updated_at
) VALUES (
    'e8888885-8888-8888-8888-888888888885',
    'Writing Task 2: Opinion Essay - Environment',
    'writing-task2-opinion-environment',
    'Practice writing an opinion essay about environmental issues. Minimum 250 words required.',
    'practice',
    'writing',
    'medium',
    'band 6.0-7.0',
    0,
    1,
    40,
    65.00,
    100.00,
    true,
    true,
    '00000000-0000-0000-0000-000000000001',
    NOW(),
    5,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_sections (
    id, exercise_id, title, description, section_number,
    instructions, total_questions, display_order, created_at, updated_at
) VALUES (
    'e8888885-8888-8888-8888-888888888815',
    'e8888885-8888-8888-8888-888888888885',
    'Task 2: Opinion Essay',
    'Write an opinion essay on environmental issues',
    1,
    'Some people think that environmental problems are too big for individual countries to solve and should be addressed by international organizations. 

To what extent do you agree or disagree?

Give reasons for your answer and include any relevant examples from your own knowledge or experience.

Write at least 250 words.',
    0,
    1,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 6. WRITING TASK 2 (OPINION ESSAY) - Hard
-- ============================================
INSERT INTO exercises (
    id, title, slug, description, exercise_type, skill_type, difficulty, ielts_level,
    total_questions, total_sections, time_limit_minutes, passing_score, total_points,
    is_free, is_published, created_by, published_at, display_order, created_at, updated_at
) VALUES (
    'e8888886-8888-8888-8888-888888888886',
    'Writing Task 2: Discussion Essay - Education',
    'writing-task2-discussion-education',
    'Practice writing a discussion essay about education. Minimum 250 words required.',
    'practice',
    'writing',
    'hard',
    'band 7.0-8.0',
    0,
    1,
    40,
    70.00,
    100.00,
    true,
    true,
    '00000000-0000-0000-0000-000000000001',
    NOW(),
    6,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_sections (
    id, exercise_id, title, description, section_number,
    instructions, total_questions, display_order, created_at, updated_at
) VALUES (
    'e8888886-8888-8888-8888-888888888816',
    'e8888886-8888-8888-8888-888888888886',
    'Task 2: Discussion Essay',
    'Write a discussion essay on education',
    1,
    'Some people believe that universities should only accept students with high academic achievements. Others, however, think that universities should accept people of all ages and backgrounds.

Discuss both views and give your own opinion.

Give reasons for your answer and include any relevant examples from your own knowledge or experience.

Write at least 250 words.',
    0,
    1,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- ============================================
-- SPEAKING EXERCISES
-- ============================================

-- ============================================
-- 7. SPEAKING PART 1 - Easy
-- ============================================
INSERT INTO exercises (
    id, title, slug, description, exercise_type, skill_type, difficulty, ielts_level,
    total_questions, total_sections, time_limit_minutes, passing_score, total_points,
    is_free, is_published, created_by, published_at, display_order, created_at, updated_at
) VALUES (
    'e8888887-8888-8888-8888-888888888887',
    'Speaking Part 1: Personal Questions',
    'speaking-part1-personal-questions',
    'Practice answering personal questions in Speaking Part 1. Record your responses (30-60 seconds each).',
    'practice',
    'speaking',
    'easy',
    'band 5.0-6.0',
    0,
    1,
    5,
    60.00,
    100.00,
    true,
    true,
    '00000000-0000-0000-0000-000000000001',
    NOW(),
    7,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_sections (
    id, exercise_id, title, description, section_number,
    instructions, total_questions, display_order, created_at, updated_at
) VALUES (
    'e8888887-8888-8888-8888-888888888817',
    'e8888887-8888-8888-8888-888888888887',
    'Part 1: Introduction and Interview',
    'Answer personal questions about yourself',
    1,
    'In this part of the test, the examiner will ask you some questions about yourself.

Please answer the following questions. Record your responses clearly. Each answer should be 30-60 seconds.

Questions:
1. What is your full name?
2. Where are you from?
3. Do you work or study?
4. What do you like about your job/studies?
5. What do you do in your free time?
6. Do you enjoy reading? What kind of books do you read?

Speak clearly and naturally. Give detailed answers where appropriate.',
    0,
    1,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 8. SPEAKING PART 2 - Medium
-- ============================================
INSERT INTO exercises (
    id, title, slug, description, exercise_type, skill_type, difficulty, ielts_level,
    total_questions, total_sections, time_limit_minutes, passing_score, total_points,
    is_free, is_published, created_by, published_at, display_order, created_at, updated_at
) VALUES (
    'e8888888-8888-8888-8888-888888888888',
    'Speaking Part 2: Describe a Place',
    'speaking-part2-describe-place',
    'Practice describing a place in Speaking Part 2. Record a 1-2 minute response with 1 minute preparation time.',
    'practice',
    'speaking',
    'medium',
    'band 6.0-7.0',
    0,
    1,
    3,
    65.00,
    100.00,
    true,
    true,
    '00000000-0000-0000-0000-000000000001',
    NOW(),
    8,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_sections (
    id, exercise_id, title, description, section_number,
    instructions, total_questions, display_order, created_at, updated_at
) VALUES (
    'e8888888-8888-8888-8888-888888888818',
    'e8888888-8888-8888-8888-888888888888',
    'Part 2: Long Turn',
    'Describe a place you have visited',
    1,
    'Describe a place you have visited that you liked.

You should say:
- Where this place is
- When you visited it
- What you did there
- And explain why you liked this place

You have 1 minute to prepare. You can make notes if you wish.

Then speak for 1-2 minutes. Record your response clearly.

After you finish, the examiner may ask you one or two questions about what you said.',
    0,
    1,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 9. SPEAKING PART 2 - Hard
-- ============================================
INSERT INTO exercises (
    id, title, slug, description, exercise_type, skill_type, difficulty, ielts_level,
    total_questions, total_sections, time_limit_minutes, passing_score, total_points,
    is_free, is_published, created_by, published_at, display_order, created_at, updated_at
) VALUES (
    'e8888889-8888-8888-8888-888888888889',
    'Speaking Part 2: Describe a Person',
    'speaking-part2-describe-person',
    'Practice describing a person in Speaking Part 2. Record a 1-2 minute response with 1 minute preparation time.',
    'practice',
    'speaking',
    'hard',
    'band 7.0-8.0',
    0,
    1,
    3,
    70.00,
    100.00,
    true,
    true,
    '00000000-0000-0000-0000-000000000001',
    NOW(),
    9,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_sections (
    id, exercise_id, title, description, section_number,
    instructions, total_questions, display_order, created_at, updated_at
) VALUES (
    'e8888889-8888-8888-8888-888888888819',
    'e8888889-8888-8888-8888-888888888889',
    'Part 2: Long Turn',
    'Describe someone who has influenced you',
    1,
    'Describe someone who has influenced you in your life.

You should say:
- Who this person is
- How you know them
- What they have done to influence you
- And explain why this person has been important in your life

You have 1 minute to prepare. You can make notes if you wish.

Then speak for 1-2 minutes. Record your response clearly.

After you finish, the examiner may ask you one or two questions about what you said.',
    0,
    1,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 10. SPEAKING PART 3 - Medium
-- ============================================
INSERT INTO exercises (
    id, title, slug, description, exercise_type, skill_type, difficulty, ielts_level,
    total_questions, total_sections, time_limit_minutes, passing_score, total_points,
    is_free, is_published, created_by, published_at, display_order, created_at, updated_at
) VALUES (
    'e8888890-8888-8888-8888-888888888890',
    'Speaking Part 3: Discussion - Technology',
    'speaking-part3-discussion-technology',
    'Practice discussing abstract topics in Speaking Part 3. Record your responses (1-2 minutes each).',
    'practice',
    'speaking',
    'medium',
    'band 6.0-7.0',
    0,
    1,
    5,
    65.00,
    100.00,
    true,
    true,
    '00000000-0000-0000-0000-000000000001',
    NOW(),
    10,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO exercise_sections (
    id, exercise_id, title, description, section_number,
    instructions, total_questions, display_order, created_at, updated_at
) VALUES (
    'e8888890-8888-8888-8888-888888888820',
    'e8888890-8888-8888-8888-888888888890',
    'Part 3: Two-way Discussion',
    'Discuss abstract topics related to technology',
    1,
    'In this part of the test, you will discuss some abstract topics related to technology.

The examiner may ask you questions like:

1. How has technology changed the way people communicate?
2. Do you think technology has made life easier or more complicated?
3. What are the benefits and drawbacks of using social media?
4. How do you think technology will change in the future?
5. Should governments regulate technology use? Why or why not?

Please record your responses. Each answer should be 1-2 minutes. Speak clearly and give detailed, thoughtful answers.

The examiner may ask follow-up questions based on your responses.',
    0,
    1,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- ============================================
-- VERIFICATION
-- ============================================
DO $$
DECLARE
    writing_count INT;
    speaking_count INT;
BEGIN
    SELECT COUNT(*) INTO writing_count FROM exercises WHERE skill_type = 'writing' AND is_published = true;
    SELECT COUNT(*) INTO speaking_count FROM exercises WHERE skill_type = 'speaking' AND is_published = true;
    
    RAISE NOTICE 'Writing exercises created: %', writing_count;
    RAISE NOTICE 'Speaking exercises created: %', speaking_count;
    RAISE NOTICE 'Total AI-evaluated exercises: %', writing_count + speaking_count;
END $$;

-- Display summary
SELECT 
    skill_type,
    difficulty,
    COUNT(*) as count,
    array_agg(title ORDER BY display_order) as exercises
FROM exercises
WHERE skill_type IN ('writing', 'speaking') AND is_published = true
GROUP BY skill_type, difficulty
ORDER BY skill_type, difficulty;

