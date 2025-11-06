-- Migration 032: Add User Service Sync Tracking
-- Purpose: Track sync status between Exercise Service and User Service to prevent data loss
-- FIX #9: Silent failure on User Service sync
-- FIX #8: Async goroutine data loss risk

-- Add sync tracking columns to user_exercise_attempts
ALTER TABLE user_exercise_attempts 
ADD COLUMN IF NOT EXISTS user_service_sync_status VARCHAR(20) DEFAULT 'pending' CHECK (user_service_sync_status IN ('pending', 'synced', 'failed', 'not_required')),
ADD COLUMN IF NOT EXISTS user_service_sync_attempts INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS user_service_last_sync_attempt TIMESTAMP,
ADD COLUMN IF NOT EXISTS user_service_sync_error TEXT;

-- Add index for finding failed syncs
CREATE INDEX IF NOT EXISTS idx_user_exercise_attempts_sync_status 
ON user_exercise_attempts(user_service_sync_status, user_service_last_sync_attempt) 
WHERE user_service_sync_status IN ('pending', 'failed');

-- Add comment
COMMENT ON COLUMN user_exercise_attempts.user_service_sync_status IS 'Sync status: pending (not synced yet), synced (successfully synced), failed (sync failed after retries), not_required (practice or incomplete)';
COMMENT ON COLUMN user_exercise_attempts.user_service_sync_attempts IS 'Number of sync attempts made';
COMMENT ON COLUMN user_exercise_attempts.user_service_last_sync_attempt IS 'Timestamp of last sync attempt';
COMMENT ON COLUMN user_exercise_attempts.user_service_sync_error IS 'Last sync error message if failed';

-- Update existing completed official tests to 'pending' (need to be synced)
UPDATE user_exercise_attempts 
SET user_service_sync_status = 'pending'
WHERE status = 'completed' 
  AND user_service_sync_status IS NULL;

-- Update existing non-official tests to 'not_required'
UPDATE user_exercise_attempts 
SET user_service_sync_status = 'not_required'
WHERE (status != 'completed' OR user_service_sync_status = 'not_required');
