-- Rollback: Drop practice_activities table
-- Purpose: Revert creation of practice_activities table
-- Database: user_db

-- Drop trigger
DROP TRIGGER IF EXISTS trigger_update_practice_activities_updated_at ON practice_activities;

-- Drop function
DROP FUNCTION IF EXISTS update_practice_activities_updated_at();

-- Drop indexes
DROP INDEX IF EXISTS idx_practice_activities_user_id;
DROP INDEX IF EXISTS idx_practice_activities_skill;
DROP INDEX IF EXISTS idx_practice_activities_user_skill;
DROP INDEX IF EXISTS idx_practice_activities_completed_at;
DROP INDEX IF EXISTS idx_practice_activities_user_completed;
DROP INDEX IF EXISTS idx_practice_activities_exercise_id;

-- Drop table
DROP TABLE IF EXISTS practice_activities;
