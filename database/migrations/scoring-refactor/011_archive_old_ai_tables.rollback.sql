-- Rollback Migration: Restore dropped tables from backup
-- Purpose: Emergency rollback if DROP was premature
-- Database: ai_db

-- WARNING: This requires manual restoration from backup
-- The tables have been dropped and data must be restored from:
-- 1. Database backup taken before migration
-- 2. Original ai_db dump files

-- Step 1: Restore schema from backup
-- Run this manually with your backup file:
-- pg_restore -U ielts_admin -d ai_db -t writing_submissions -t writing_evaluations -t speaking_submissions -t speaking_evaluations /path/to/backup.dump

-- Step 2: Verify restoration
DO $$
DECLARE
    writing_count INT;
    speaking_count INT;
BEGIN
    SELECT COUNT(*) INTO writing_count FROM writing_submissions;
    SELECT COUNT(*) INTO speaking_count FROM speaking_submissions;
    
    RAISE NOTICE '✓ Rollback check:';
    RAISE NOTICE '  - writing_submissions: % records', writing_count;
    RAISE NOTICE '  - speaking_submissions: % records', speaking_count;
    
    IF writing_count = 0 AND speaking_count = 0 THEN
        RAISE WARNING 'Tables exist but are empty! Restore from backup required.';
    ELSE
        RAISE NOTICE '✓ Data restored successfully';
    END IF;
END $$;

-- Note: If rollback is needed, you should:
-- 1. Stop the application
-- 2. Restore ai_db from backup taken before migration
-- 3. Delete migrated data from exercise_db.user_exercise_attempts
-- 4. Restart services with old code
-- 5. Investigate why rollback was necessary
