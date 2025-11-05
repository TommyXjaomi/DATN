-- Rollback: Drop official_test_results table
-- Purpose: Revert creation of official_test_results table
-- Database: user_db

-- Drop trigger
DROP TRIGGER IF EXISTS trigger_update_official_test_results_updated_at ON official_test_results;

-- Drop function
DROP FUNCTION IF EXISTS update_official_test_results_updated_at();

-- Drop indexes (will be dropped automatically with table, but explicit for clarity)
DROP INDEX IF EXISTS idx_official_test_results_user_id;
DROP INDEX IF EXISTS idx_official_test_results_test_date;
DROP INDEX IF EXISTS idx_official_test_results_user_date;

-- Drop table
DROP TABLE IF EXISTS official_test_results;
