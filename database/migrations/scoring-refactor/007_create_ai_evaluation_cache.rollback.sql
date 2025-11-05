-- Rollback: Drop AI evaluation cache table
-- Purpose: Revert creation of ai_evaluation_cache table
-- Database: ai_db

-- Drop indexes
DROP INDEX IF EXISTS idx_ai_cache_content_hash;
DROP INDEX IF EXISTS idx_ai_cache_skill_type;
DROP INDEX IF EXISTS idx_ai_cache_expires_at;
DROP INDEX IF EXISTS idx_ai_cache_hit_count;

-- Drop table
DROP TABLE IF EXISTS ai_evaluation_cache;
