-- Rollback for 014_create_evaluation_cache.sql

DROP INDEX IF EXISTS idx_evaluation_cache_expires_at;
DROP TABLE IF EXISTS evaluation_cache;
