-- ============================================
-- MIGRATION 018: ADD detailed_feedback_json TO writing_evaluations
-- ============================================
-- Purpose: Thêm column detailed_feedback_json để lưu structured feedback song ngữ (Anh/Việt)
-- Database: ai_db
-- Date: 2025-11-03
-- 
-- CHANGES:
-- 1. Add detailed_feedback_json JSONB column to writing_evaluations table
--    - Stores structured feedback for each criterion (Task Achievement, Coherence & Cohesion, Lexical Resource, Grammatical Range)
--    - Each criterion has both Vietnamese (vi) and English (en) versions
--    - Format: {
--        "task_achievement": { "vi": "...", "en": "..." },
--        "coherence_cohesion": { "vi": "...", "en": "..." },
--        "lexical_resource": { "vi": "...", "en": "..." },
--        "grammatical_range": { "vi": "...", "en": "..." }
--      }
-- 2. This column is optional (nullable) to maintain backward compatibility with existing evaluations
-- 3. Frontend can toggle between vi/en based on user preference
--
-- ROLLBACK: See 018_add_detailed_feedback_json_to_writing_evaluations.rollback.sql
-- ============================================

\c ai_db;

DO $$ 
BEGIN
    -- Check if column doesn't exist before adding
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public'
        AND table_name = 'writing_evaluations' 
        AND column_name = 'detailed_feedback_json'
    ) THEN
        -- Add JSONB column (nullable for backward compatibility)
        ALTER TABLE writing_evaluations 
        ADD COLUMN detailed_feedback_json JSONB;
        
        -- Add comment to document the structure
        COMMENT ON COLUMN writing_evaluations.detailed_feedback_json IS 
            'Structured feedback with bilingual support (Vietnamese and English) for each IELTS writing criterion. Format: {"task_achievement": {"vi": "...", "en": "..."}, "coherence_cohesion": {"vi": "...", "en": "..."}, "lexical_resource": {"vi": "...", "en": "..."}, "grammatical_range": {"vi": "...", "en": "..."}}';
        
        RAISE NOTICE '✅ Added detailed_feedback_json to writing_evaluations';
        RAISE NOTICE '   - Column type: JSONB (nullable)';
        RAISE NOTICE '   - Purpose: Bilingual structured feedback for IELTS writing criteria';
    ELSE
        RAISE NOTICE '⏭️  Column detailed_feedback_json already exists';
    END IF;
END $$;

-- Create GIN index for JSONB queries (optional, for performance if needed)
CREATE INDEX IF NOT EXISTS idx_writing_evaluations_detailed_feedback_json 
ON writing_evaluations USING GIN (detailed_feedback_json) 
WHERE detailed_feedback_json IS NOT NULL;

-- Verification
DO $$
DECLARE
    col_exists BOOLEAN;
    index_exists BOOLEAN;
BEGIN
    -- Check column
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public'
        AND table_name = 'writing_evaluations' 
        AND column_name = 'detailed_feedback_json'
    ) INTO col_exists;
    
    -- Check index
    SELECT EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE schemaname = 'public'
        AND tablename = 'writing_evaluations' 
        AND indexname = 'idx_writing_evaluations_detailed_feedback_json'
    ) INTO index_exists;
    
    IF col_exists THEN
        RAISE NOTICE '✅ Migration 018 verified:';
        RAISE NOTICE '   - Column detailed_feedback_json: EXISTS';
        IF index_exists THEN
            RAISE NOTICE '   - Index idx_writing_evaluations_detailed_feedback_json: EXISTS';
        ELSE
            RAISE NOTICE '   - Index idx_writing_evaluations_detailed_feedback_json: NOT CREATED';
        END IF;
    ELSE
        RAISE EXCEPTION 'Migration 018 failed: detailed_feedback_json column not found';
    END IF;
END $$;

