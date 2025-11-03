-- ============================================
-- ROLLBACK MIGRATION 018: REMOVE detailed_feedback_json FROM writing_evaluations
-- ============================================
-- Purpose: Rollback migration 018 - Remove detailed_feedback_json column
-- Database: ai_db
-- Date: 2025-11-03
-- 
-- WARNING: This will permanently delete all structured feedback data in detailed_feedback_json column!
-- Make sure to backup data before running this rollback.
-- ============================================

\c ai_db;

DO $$ 
BEGIN
    -- Drop index first
    IF EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE schemaname = 'public'
        AND tablename = 'writing_evaluations' 
        AND indexname = 'idx_writing_evaluations_detailed_feedback_json'
    ) THEN
        DROP INDEX IF EXISTS idx_writing_evaluations_detailed_feedback_json;
        RAISE NOTICE '✅ Dropped index idx_writing_evaluations_detailed_feedback_json';
    ELSE
        RAISE NOTICE '⏭️  Index idx_writing_evaluations_detailed_feedback_json does not exist';
    END IF;
    
    -- Drop column
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public'
        AND table_name = 'writing_evaluations' 
        AND column_name = 'detailed_feedback_json'
    ) THEN
        ALTER TABLE writing_evaluations 
        DROP COLUMN detailed_feedback_json;
        
        RAISE NOTICE '✅ Removed detailed_feedback_json from writing_evaluations';
        RAISE NOTICE '   ⚠️  All structured feedback data has been deleted!';
    ELSE
        RAISE NOTICE '⏭️  Column detailed_feedback_json does not exist';
    END IF;
END $$;

-- Verification
DO $$
DECLARE
    col_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public'
        AND table_name = 'writing_evaluations' 
        AND column_name = 'detailed_feedback_json'
    ) INTO col_exists;
    
    IF NOT col_exists THEN
        RAISE NOTICE '✅ Rollback 018 verified: detailed_feedback_json column removed';
    ELSE
        RAISE EXCEPTION 'Rollback 018 failed: detailed_feedback_json column still exists';
    END IF;
END $$;

