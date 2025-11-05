-- Migration: Drop old submission tables in ai_db
-- Purpose: Remove obsolete tables after successful migration to exercise_db
-- Database: ai_db
-- Phase: 6 - Post-Migration Cleanup

-- IMPORTANT: Only run this AFTER verifying Phase 6 migration is successful
-- IMPORTANT: Data has been migrated to exercise_db.user_exercise_attempts
-- IMPORTANT: Rollback script available if needed

-- Drop writing_submissions table
DROP TABLE IF EXISTS writing_submissions CASCADE;

-- Drop writing_evaluations table  
DROP TABLE IF EXISTS writing_evaluations CASCADE;

-- Drop speaking_submissions table
DROP TABLE IF EXISTS speaking_submissions CASCADE;

-- Drop speaking_evaluations table
DROP TABLE IF EXISTS speaking_evaluations CASCADE;

-- Log cleanup action
DO $$
BEGIN
    RAISE NOTICE '✓ Successfully dropped 4 obsolete tables from ai_db';
    RAISE NOTICE '  - writing_submissions (DROPPED)';
    RAISE NOTICE '  - writing_evaluations (DROPPED)';
    RAISE NOTICE '  - speaking_submissions (DROPPED)';
    RAISE NOTICE '  - speaking_evaluations (DROPPED)';
    RAISE NOTICE '';
    RAISE NOTICE '✓ All data preserved in exercise_db.user_exercise_attempts';
    RAISE NOTICE '✓ AI service now uses pure evaluation APIs (stateless)';
    RAISE NOTICE '✓ Rollback available: 011_archive_old_ai_tables.rollback.sql';
END $$;
