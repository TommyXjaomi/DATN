-- ============================================================================
-- NOTIFICATION SERVICE DATABASE SCHEMA (CLEAN VERSION)
-- ============================================================================
-- Database: notification_db
-- Purpose: Notification management, delivery tracking, and user preferences
-- Version: 1.0
-- Last Updated: 2025-11-06
--
-- IMPORTANT: This is a CLEAN schema file that creates the database from scratch.
-- It is NOT a migration file. Use this to:
--   1. Create a new notification_db database
--   2. Understand the current schema structure
--   3. Document the database design
--
-- DO NOT use this file to update an existing database.
-- ============================================================================

-- ============================================================================
-- EXTENSIONS
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- Full-text search
CREATE EXTENSION IF NOT EXISTS "dblink"; -- Cross-database queries

-- ============================================================================
-- CORE TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Notifications Table
-- ----------------------------------------------------------------------------
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    type VARCHAR(50) NOT NULL, -- 'email', 'push', 'in_app', 'sms'
    category VARCHAR(50) NOT NULL, -- 'achievement', 'reminder', 'course_update', 'exercise_graded', 'system'
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    action_type VARCHAR(50), -- 'open_course', 'open_exercise', 'open_profile', 'external_link'
    action_data JSONB, -- Additional action data
    icon_url TEXT,
    image_url TEXT,
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP,
    is_sent BOOLEAN DEFAULT false,
    sent_at TIMESTAMP,
    scheduled_for TIMESTAMP,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX idx_notifications_scheduled_for ON notifications(scheduled_for) WHERE is_sent = false;

-- ----------------------------------------------------------------------------
-- Email Notifications Table
-- ----------------------------------------------------------------------------
CREATE TABLE email_notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    notification_id UUID REFERENCES notifications(id) ON DELETE CASCADE,
    user_id UUID NOT NULL,
    to_email VARCHAR(255) NOT NULL,
    subject VARCHAR(500) NOT NULL,
    body_html TEXT NOT NULL,
    body_text TEXT,
    template_name VARCHAR(100), -- Reference to notification_templates
    template_data JSONB, -- Variables for template
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'sent', 'delivered', 'failed', 'bounced'
    sent_at TIMESTAMP,
    delivered_at TIMESTAMP,
    opened_at TIMESTAMP, -- Email opened tracking
    clicked_at TIMESTAMP, -- Link clicked tracking
    external_id VARCHAR(255), -- ID from email service provider
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_email_notifications_user_id ON email_notifications(user_id);
CREATE INDEX idx_email_notifications_to_email ON email_notifications(to_email);
CREATE INDEX idx_email_notifications_status ON email_notifications(status);

-- ----------------------------------------------------------------------------
-- Push Notifications Table
-- ----------------------------------------------------------------------------
CREATE TABLE push_notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    notification_id UUID REFERENCES notifications(id) ON DELETE CASCADE,
    user_id UUID NOT NULL,
    device_token VARCHAR(500) NOT NULL,
    device_type VARCHAR(20) NOT NULL, -- 'ios', 'android', 'web'
    device_id VARCHAR(255),
    title VARCHAR(200) NOT NULL,
    body TEXT NOT NULL,
    data JSONB, -- Additional payload data
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'sent', 'delivered', 'failed'
    sent_at TIMESTAMP,
    delivered_at TIMESTAMP,
    clicked_at TIMESTAMP,
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_push_notifications_user_id ON push_notifications(user_id);
CREATE INDEX idx_push_notifications_device_token ON push_notifications(device_token);
CREATE INDEX idx_push_notifications_status ON push_notifications(status);

-- ============================================================================
-- DEVICE MANAGEMENT
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Device Tokens Table
-- ----------------------------------------------------------------------------
CREATE TABLE device_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    device_token VARCHAR(500) UNIQUE NOT NULL,
    device_type VARCHAR(20) NOT NULL, -- 'ios', 'android', 'web'
    device_id VARCHAR(255),
    device_name VARCHAR(100),
    app_version VARCHAR(50),
    os_version VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    last_used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_device_tokens_user_id ON device_tokens(user_id);
CREATE INDEX idx_device_tokens_device_token ON device_tokens(device_token);
CREATE INDEX idx_device_tokens_is_active ON device_tokens(is_active);
CREATE INDEX idx_device_tokens_user_active ON device_tokens(user_id, is_active);
CREATE UNIQUE INDEX idx_device_tokens_device_token_active ON device_tokens(device_token) WHERE is_active = true;

-- ============================================================================
-- TEMPLATES AND PREFERENCES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Notification Templates Table
-- ----------------------------------------------------------------------------
CREATE TABLE notification_templates (
    id SERIAL PRIMARY KEY,
    template_code VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    notification_type VARCHAR(50) NOT NULL, -- 'email', 'push', 'both'
    category VARCHAR(50) NOT NULL,
    title_template VARCHAR(500), -- For push notifications
    body_template TEXT NOT NULL,
    subject_template VARCHAR(500), -- For emails
    html_template TEXT, -- For HTML emails
    required_variables TEXT[], -- List of required template variables
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- Notification Preferences Table
-- ----------------------------------------------------------------------------
CREATE TABLE notification_preferences (
    user_id UUID PRIMARY KEY,
    
    -- Push notification preferences
    push_enabled BOOLEAN DEFAULT true,
    push_achievements BOOLEAN DEFAULT true,
    push_reminders BOOLEAN DEFAULT true,
    push_course_updates BOOLEAN DEFAULT true,
    push_exercise_graded BOOLEAN DEFAULT true,
    
    -- Email notification preferences
    email_enabled BOOLEAN DEFAULT true,
    email_weekly_report BOOLEAN DEFAULT true,
    email_course_updates BOOLEAN DEFAULT true,
    email_marketing BOOLEAN DEFAULT false,
    
    -- In-app notifications
    in_app_enabled BOOLEAN DEFAULT true,
    
    -- Quiet hours
    quiet_hours_enabled BOOLEAN DEFAULT false,
    quiet_hours_start TIME,
    quiet_hours_end TIME,
    
    -- Rate limiting
    max_notifications_per_day INTEGER DEFAULT 20,
    
    timezone VARCHAR(50) DEFAULT 'Asia/Ho_Chi_Minh',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- SCHEDULED NOTIFICATIONS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Scheduled Notifications Table
-- ----------------------------------------------------------------------------
CREATE TABLE scheduled_notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    schedule_type VARCHAR(20) NOT NULL, -- 'once', 'daily', 'weekly', 'custom'
    scheduled_time TIME NOT NULL,
    days_of_week INTEGER[], -- [0-6] where 0=Monday, 6=Sunday (for weekly)
    timezone VARCHAR(50) DEFAULT 'Asia/Ho_Chi_Minh',
    is_active BOOLEAN DEFAULT true,
    last_sent_at TIMESTAMP,
    next_send_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_scheduled_notifications_user_id ON scheduled_notifications(user_id);
CREATE INDEX idx_scheduled_notifications_next_send_at ON scheduled_notifications(next_send_at) WHERE is_active = true;
CREATE UNIQUE INDEX idx_scheduled_notifications_unique ON scheduled_notifications(user_id, schedule_type, scheduled_time, title) WHERE is_active = true;

-- ============================================================================
-- LOGGING AND ANALYTICS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Notification Logs Table
-- ----------------------------------------------------------------------------
CREATE TABLE notification_logs (
    id BIGSERIAL PRIMARY KEY,
    notification_id UUID REFERENCES notifications(id) ON DELETE SET NULL,
    user_id UUID NOT NULL,
    event_type VARCHAR(50) NOT NULL, -- 'sent', 'delivered', 'opened', 'clicked', 'failed', 'bounced'
    event_status VARCHAR(20) NOT NULL, -- 'success', 'failure'
    notification_type VARCHAR(50), -- 'email', 'push', 'in_app'
    error_message TEXT,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notification_logs_user_id ON notification_logs(user_id);
CREATE INDEX idx_notification_logs_notification_id ON notification_logs(notification_id);
CREATE INDEX idx_notification_logs_event_type ON notification_logs(event_type);
CREATE INDEX idx_notification_logs_created_at ON notification_logs(created_at);

-- ============================================================================
-- FUNCTIONS AND TRIGGERS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Auto-update updated_at timestamp
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------------------
-- Check if notification can be sent based on user preferences
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION can_send_notification(p_user_id UUID, p_notification_type VARCHAR, p_category VARCHAR)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_preferences RECORD;
    v_current_time TIME;
    v_notifications_today INT;
BEGIN
    -- Get user preferences
    SELECT * INTO v_preferences
    FROM notification_preferences
    WHERE user_id = p_user_id;
    
    -- If no preferences, use defaults (allow)
    IF NOT FOUND THEN
        RETURN true;
    END IF;
    
    -- Check if notification type is enabled
    IF p_notification_type = 'push' AND NOT v_preferences.push_enabled THEN
        RETURN false;
    ELSIF p_notification_type = 'email' AND NOT v_preferences.email_enabled THEN
        RETURN false;
    END IF;
    
    -- Check quiet hours
    IF v_preferences.quiet_hours_enabled THEN
        v_current_time := CURRENT_TIME;
        IF v_current_time >= v_preferences.quiet_hours_start
           OR v_current_time <= v_preferences.quiet_hours_end THEN
            RETURN false;
        END IF;
    END IF;
    
    -- Check daily limit
    SELECT COUNT(*) INTO v_notifications_today
    FROM notifications
    WHERE user_id = p_user_id
    AND created_at >= CURRENT_DATE
    AND is_sent = true;
    
    IF v_notifications_today >= v_preferences.max_notifications_per_day THEN
        RETURN false;
    END IF;
    
    RETURN true;
END;
$$;

-- ----------------------------------------------------------------------------
-- Cleanup old notifications
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION cleanup_old_notifications()
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Delete read notifications older than 30 days
    DELETE FROM notifications
    WHERE is_read = true
    AND read_at < CURRENT_TIMESTAMP - INTERVAL '30 days';
    
    -- Delete expired notifications
    DELETE FROM notifications
    WHERE expires_at IS NOT NULL
    AND expires_at < CURRENT_TIMESTAMP;
    
    -- Delete old notification logs (keep 90 days)
    DELETE FROM notification_logs
    WHERE created_at < CURRENT_TIMESTAMP - INTERVAL '90 days';
END;
$$;

-- Apply triggers
CREATE TRIGGER update_notifications_updated_at
    BEFORE UPDATE ON notifications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_device_tokens_updated_at
    BEFORE UPDATE ON device_tokens
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notification_preferences_updated_at
    BEFORE UPDATE ON notification_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- SEED DATA
-- ============================================================================

-- Default notification templates
INSERT INTO notification_templates (template_code, name, notification_type, category, title_template, body_template, subject_template, required_variables) VALUES
    ('achievement_unlocked', 'Achievement Unlocked', 'push', 'success',
     'Chúc mừng! 🎉',
     'Bạn đã đạt được thành tựu "{{achievement_name}}". Tiếp tục phấn đấu!',
     NULL,
     ARRAY['achievement_name']),
    
    ('daily_reminder', 'Daily Study Reminder', 'push', 'info',
     'Đã đến giờ học rồi! 📚',
     'Hãy dành thời gian học IELTS hôm nay. Streak hiện tại: {{streak_days}} ngày!',
     NULL,
     ARRAY['streak_days']),
    
    ('exercise_graded', 'Exercise Graded', 'push', 'success',
     'Bài tập đã được chấm điểm',
     'Bài tập "{{exercise_title}}" của bạn đã được chấm điểm.',
     NULL,
     ARRAY['exercise_title']),
    
    ('writing_evaluated', 'Writing Evaluated', 'push', 'success',
     'Bài viết đã được đánh giá',
     'Bài viết của bạn đã được AI đánh giá với band score {{band_score}}.',
     NULL,
     ARRAY['band_score']),
    
    ('course_enrolled', 'Course Enrolled', 'email', 'info',
     'Chào mừng đến với khóa học',
     'Chào mừng bạn đến với khóa học "{{course_title}}". Chúc bạn học tập hiệu quả!',
     NULL,
     ARRAY['course_title']);

-- ============================================================================
-- SCHEMA MIGRATIONS TRACKING
-- ============================================================================

CREATE TABLE schema_migrations (
    id SERIAL PRIMARY KEY,
    version VARCHAR(255) NOT NULL UNIQUE,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO schema_migrations (version) VALUES ('001_initial_schema');

-- ============================================================================
-- END OF NOTIFICATION SERVICE SCHEMA
-- ============================================================================
