-- ============================================
-- PHASE 8: ADDITIONAL MISSING TABLES & RELATIONSHIPS
-- ============================================
-- Purpose: Seed data for tables that were missing
-- Database: exercise_db
-- 
-- Creates:
-- - exercise_tag_mapping
-- - exercise_analytics
-- ============================================

-- ============================================
-- 1. EXERCISE_TAG_MAPPING
-- ============================================
-- Link exercises to tags

INSERT INTO exercise_tag_mapping (exercise_id, tag_id)
SELECT DISTINCT
    e.id,
    et.id
FROM exercises e
CROSS JOIN exercise_tags et
WHERE random() > 0.7 -- 30% chance for each tag
  AND (
    -- Match tags based on exercise properties
    (et.slug = 'multiple-choice' AND e.skill_type = 'listening') OR
    (et.slug = 'cambridge-ielts' AND e.exercise_type = 'full_test') OR
    (et.slug = 'practice-test' AND e.exercise_type = 'practice') OR
    (et.slug = 'mock-test' AND e.exercise_type = 'mock_test') OR
    (et.slug = 'beginner-friendly' AND e.difficulty = 'easy') OR
    (et.slug = 'advanced-level' AND e.difficulty = 'hard') OR
    (et.slug = 'academic' AND e.skill_type = 'reading') OR
    (et.slug = 'true-false-not-given' AND e.skill_type = 'reading') OR
    random() > 0.9 -- 10% random tags
  )
LIMIT 200;

-- ============================================
-- 2. EXERCISE_ANALYTICS
-- ============================================
-- Detailed analytics for exercises based on actual attempts

INSERT INTO exercise_analytics (
    exercise_id, total_attempts, completed_attempts, abandoned_attempts,
    average_score, median_score, highest_score, lowest_score,
    average_completion_time, median_completion_time, actual_difficulty,
    question_statistics
)
SELECT 
    e.id,
    COALESCE(attempt_stats.total_attempts, 0),
    COALESCE(attempt_stats.completed_attempts, 0),
    COALESCE(attempt_stats.abandoned_attempts, 0),
    COALESCE(score_stats.avg_score, 0),
    COALESCE(score_stats.median_score, 0),
    COALESCE(score_stats.max_score, 0),
    COALESCE(score_stats.min_score, 0),
    COALESCE(time_stats.avg_time, 0),
    COALESCE(time_stats.median_time, 0),
    CASE 
        WHEN COALESCE(score_stats.avg_score, 0) >= 80 THEN 'easy'
        WHEN COALESCE(score_stats.avg_score, 0) >= 60 THEN 'medium'
        ELSE 'hard'
    END,
    COALESCE(q_stats.question_stats, '[]'::jsonb)
FROM exercises e
LEFT JOIN (
    SELECT 
        exercise_id,
        COUNT(*) as total_attempts,
        COUNT(*) FILTER (WHERE status = 'completed') as completed_attempts,
        COUNT(*) FILTER (WHERE status = 'abandoned') as abandoned_attempts
    FROM user_exercise_attempts
    GROUP BY exercise_id
) attempt_stats ON e.id = attempt_stats.exercise_id
LEFT JOIN (
    SELECT 
        exercise_id,
        AVG(score) as avg_score,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY score) as median_score,
        MAX(score) as max_score,
        MIN(score) as min_score
    FROM user_exercise_attempts
    WHERE status = 'completed' AND score IS NOT NULL
    GROUP BY exercise_id
) score_stats ON e.id = score_stats.exercise_id
LEFT JOIN (
    SELECT 
        exercise_id,
        AVG(time_spent_seconds) as avg_time,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY time_spent_seconds) as median_time
    FROM user_exercise_attempts
    WHERE status = 'completed' AND time_spent_seconds IS NOT NULL
    GROUP BY exercise_id
) time_stats ON e.id = time_stats.exercise_id
LEFT JOIN (
    SELECT 
        q.exercise_id,
        jsonb_agg(
            jsonb_build_object(
                'question_id', q.id,
                'correct_rate', COALESCE(
                    (SELECT COUNT(*)::DECIMAL / NULLIF(COUNT(*), 0)
                     FROM user_answers ua
                     JOIN user_exercise_attempts uea ON ua.attempt_id = uea.id
                     WHERE ua.question_id = q.id 
                       AND uea.status = 'completed'
                       AND ua.is_correct = true), 0
                )
            )
        ) as question_stats
    FROM questions q
    GROUP BY q.exercise_id
) q_stats ON e.id = q_stats.exercise_id
ON CONFLICT (exercise_id) DO UPDATE SET
    total_attempts = EXCLUDED.total_attempts,
    completed_attempts = EXCLUDED.completed_attempts,
    abandoned_attempts = EXCLUDED.abandoned_attempts,
    average_score = EXCLUDED.average_score,
    median_score = EXCLUDED.median_score,
    highest_score = EXCLUDED.highest_score,
    lowest_score = EXCLUDED.lowest_score,
    average_completion_time = EXCLUDED.average_completion_time,
    median_completion_time = EXCLUDED.median_completion_time,
    actual_difficulty = EXCLUDED.actual_difficulty,
    question_statistics = EXCLUDED.question_statistics,
    updated_at = CURRENT_TIMESTAMP;

-- Summary
SELECT 
    '✅ Exercise DB Phase 8 Complete' as status,
    (SELECT COUNT(*) FROM exercise_tag_mapping) as exercise_tag_mappings_count,
    (SELECT COUNT(*) FROM exercise_analytics) as exercise_analytics_count;

