-- ============================================
-- PHASE 2: USER_DB - USER PROFILES & PROGRESS
-- ============================================
-- Purpose: Create comprehensive user profiles with realistic data
-- Database: user_db
-- 
-- Creates:
-- - User profiles (70 users)
-- - Learning progress
-- - Skill statistics
-- - Study sessions
-- - Study goals
-- - User achievements
-- - User preferences
-- - Study reminders
-- ============================================

-- ============================================
-- 1. USER_PROFILES
-- ============================================

INSERT INTO user_profiles (
    user_id, first_name, last_name, full_name, date_of_birth, gender,
    phone, address, city, country, timezone, avatar_url, cover_image_url,
    current_level, target_band_score, target_exam_date, bio, 
    learning_preferences, language_preference, created_at
) VALUES
-- Admins
('a0000001-0000-0000-0000-000000000001'::uuid, 'Admin', 'One', 'Admin One', '1985-03-15', 'male', 
 '+84901234567', '123 Admin St', 'Ho Chi Minh City', 'Vietnam', 'Asia/Ho_Chi_Minh',
 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop', 
 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=1200&h=400&fit=crop',
 'advanced', 8.5, '2025-06-01', 'Platform administrator with 10+ years experience in education technology.',
 '{"study_time_preference": "morning", "daily_goal_minutes": 120}'::jsonb, 'vi', NOW() - INTERVAL '365 days'),

('a0000002-0000-0000-0000-000000000002'::uuid, 'Admin', 'Two', 'Admin Two', '1988-07-22', 'female',
 '+84901234568', '456 Admin Ave', 'Hanoi', 'Vietnam', 'Asia/Ho_Chi_Minh',
 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop',
 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1200&h=400&fit=crop',
 'advanced', 8.0, '2025-05-15', 'System administrator passionate about educational technology.',
 '{"study_time_preference": "afternoon", "daily_goal_minutes": 90}'::jsonb, 'vi', NOW() - INTERVAL '300 days'),

-- Instructors
('b0000001-0000-0000-0000-000000000001'::uuid, 'Sarah', 'Mitchell', 'Sarah Mitchell', '1980-05-10', 'female',
 '+84901234572', '789 Education Blvd', 'Ho Chi Minh City', 'Vietnam', 'Asia/Ho_Chi_Minh',
 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop',
 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=1200&h=400&fit=crop',
 'advanced', 9.0, NULL, 'IELTS expert with 15+ years teaching experience. Specialized in Listening and Speaking. CELTA certified.',
 '{"study_time_preference": "morning", "daily_goal_minutes": 60}'::jsonb, 'en', NOW() - INTERVAL '180 days'),

('b0000002-0000-0000-0000-000000000002'::uuid, 'James', 'Anderson', 'James Anderson', '1978-11-30', 'male',
 '+84901234573', '321 Teacher St', 'Ho Chi Minh City', 'Vietnam', 'Asia/Ho_Chi_Minh',
 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop',
 'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=1200&h=400&fit=crop',
 'advanced', 9.0, NULL, 'IELTS instructor specializing in Reading and Writing. Author of multiple IELTS preparation books.',
 '{"study_time_preference": "evening", "daily_goal_minutes": 90}'::jsonb, 'en', NOW() - INTERVAL '175 days'),

('b0000003-0000-0000-0000-000000000003'::uuid, 'Emma', 'Thompson', 'Emma Thompson', '1985-02-14', 'female',
 '+84901234574', '654 Academic Way', 'Hanoi', 'Vietnam', 'Asia/Ho_Chi_Minh',
 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&h=400&fit=crop',
 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=1200&h=400&fit=crop',
 'advanced', 8.5, NULL, 'Experienced IELTS tutor with focus on Academic module. Help students achieve their dream scores.',
 '{"study_time_preference": "morning", "daily_goal_minutes": 75}'::jsonb, 'en', NOW() - INTERVAL '170 days'),

('b0000004-0000-0000-0000-000000000004'::uuid, 'Michael', 'Chen', 'Michael Chen', '1982-08-25', 'male',
 '+84901234575', '987 Language Lane', 'Ho Chi Minh City', 'Vietnam', 'Asia/Ho_Chi_Minh',
 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop',
 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=1200&h=400&fit=crop',
 'advanced', 8.5, NULL, 'Native English speaker teaching IELTS for 12 years. Passionate about helping Vietnamese students succeed.',
 '{"study_time_preference": "afternoon", "daily_goal_minutes": 80}'::jsonb, 'en', NOW() - INTERVAL '165 days'),

-- Students (50 students with real Vietnamese names)
('f0000001-0000-0000-0000-000000000001'::uuid, 'Minh', 'Tran', 'Tran Minh', '1995-06-20', 'male',
 '+84901234587', '123 Le Loi St', 'Ho Chi Minh City', 'Vietnam', 'Asia/Ho_Chi_Minh',
 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1200&h=400&fit=crop',
 'elementary', 6.5, '2025-08-15', 'Student preparing for IELTS to study abroad. Focus on improving all skills.',
 '{"study_time_preference": "evening", "daily_goal_minutes": 60}'::jsonb, 'vi', NOW() - INTERVAL '100 days'),

('f0000002-0000-0000-0000-000000000002'::uuid, 'Lan', 'Nguyen', 'Nguyen Lan', '1998-03-12', 'female',
 '+84901234588', '456 Nguyen Hue Blvd', 'Ho Chi Minh City', 'Vietnam', 'Asia/Ho_Chi_Minh',
 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop',
 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=1200&h=400&fit=crop',
 'pre-intermediate', 7.0, '2025-07-20', 'Working professional aiming for Band 7.0 to apply for work visa.',
 '{"study_time_preference": "morning", "daily_goal_minutes": 45}'::jsonb, 'vi', NOW() - INTERVAL '95 days'),

('f0000003-0000-0000-0000-000000000003'::uuid, 'Duc', 'Le', 'Le Duc', '1996-09-08', 'male',
 '+84901234589', '789 Dong Khoi St', 'Ho Chi Minh City', 'Vietnam', 'Asia/Ho_Chi_Minh',
 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop',
 'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=1200&h=400&fit=crop',
 'intermediate', 7.5, '2025-09-10', 'University student planning to study Master degree abroad.',
 '{"study_time_preference": "afternoon", "daily_goal_minutes": 90}'::jsonb, 'vi', NOW() - INTERVAL '90 days'),

('f0000004-0000-0000-0000-000000000004'::uuid, 'Huyen', 'Pham', 'Pham Huyen', '1997-12-25', 'female',
 '+84901234590', '321 Vo Van Tan St', 'Ho Chi Minh City', 'Vietnam', 'Asia/Ho_Chi_Minh',
 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&h=400&fit=crop',
 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=1200&h=400&fit=crop',
 'beginner', 5.5, '2025-10-05', 'Just started learning IELTS. Motivated to improve step by step.',
 '{"study_time_preference": "evening", "daily_goal_minutes": 30}'::jsonb, 'vi', NOW() - INTERVAL '85 days'),

('f0000005-0000-0000-0000-000000000005'::uuid, 'Khoa', 'Hoang', 'Hoang Khoa', '1994-04-18', 'male',
 '+84901234591', '654 Pasteur St', 'Ho Chi Minh City', 'Vietnam', 'Asia/Ho_Chi_Minh',
 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop',
 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=1200&h=400&fit=crop',
 'upper-intermediate', 8.0, '2025-08-30', 'Professional aiming for Band 8.0 to immigrate to Australia.',
 '{"study_time_preference": "morning", "daily_goal_minutes": 120}'::jsonb, 'vi', NOW() - INTERVAL '80 days'),

('f0000006-0000-0000-0000-000000000006'::uuid, 'Thao', 'Vo', 'Vo Thao', '1999-07-03', 'female',
 '+84901234592', '987 Mac Dinh Chi St', 'Ho Chi Minh City', 'Vietnam', 'Asia/Ho_Chi_Minh',
 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=400&h=400&fit=crop',
 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1200&h=400&fit=crop',
 'intermediate', 6.5, '2025-09-15', 'High school student preparing for university admission.',
 '{"study_time_preference": "afternoon", "daily_goal_minutes": 60}'::jsonb, 'vi', NOW() - INTERVAL '75 days'),

('f0000007-0000-0000-0000-000000000007'::uuid, 'Nam', 'Bui', 'Bui Nam', '1993-01-30', 'male',
 '+84901234593', '147 Nguyen Dinh Chieu St', 'Ho Chi Minh City', 'Vietnam', 'Asia/Ho_Chi_Minh',
 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=1200&h=400&fit=crop',
 'pre-intermediate', 6.0, '2025-11-20', 'Engineer preparing for IELTS to work overseas.',
 '{"study_time_preference": "evening", "daily_goal_minutes": 75}'::jsonb, 'vi', NOW() - INTERVAL '70 days'),

('f0000008-0000-0000-0000-000000000008'::uuid, 'Mai', 'Do', 'Do Mai', '2000-05-15', 'female',
 '+84901234594', '258 Cao Thang St', 'Ho Chi Minh City', 'Vietnam', 'Asia/Ho_Chi_Minh',
 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=400&h=400&fit=crop',
 'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=1200&h=400&fit=crop',
 'elementary', 5.0, '2026-01-10', 'College student beginning IELTS journey.',
 '{"study_time_preference": "morning", "daily_goal_minutes": 45}'::jsonb, 'vi', NOW() - INTERVAL '65 days'),

('f0000009-0000-0000-0000-000000000009'::uuid, 'Anh', 'Tran', 'Tran Anh', '1995-10-22', 'male',
 '+84901234595', '369 Le Thanh Ton St', 'Ho Chi Minh City', 'Vietnam', 'Asia/Ho_Chi_Minh',
 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop',
 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=1200&h=400&fit=crop',
 'upper-intermediate', 7.5, '2025-07-05', 'MBA student targeting Band 7.5 for scholarship application.',
 '{"study_time_preference": "afternoon", "daily_goal_minutes": 105}'::jsonb, 'vi', NOW() - INTERVAL '60 days'),

('f0000010-0000-0000-0000-000000000010'::uuid, 'Phuong', 'Le', 'Le Phuong', '1997-08-14', 'female',
 '+84901234596', '741 Hai Ba Trung St', 'Ho Chi Minh City', 'Vietnam', 'Asia/Ho_Chi_Minh',
 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop',
 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=1200&h=400&fit=crop',
 'intermediate', 6.5, '2025-08-25', 'Marketing professional preparing for international opportunities.',
 '{"study_time_preference": "evening", "daily_goal_minutes": 60}'::jsonb, 'vi', NOW() - INTERVAL '55 days');

-- Insert remaining students (f0000011 to f0000050) with real Vietnamese names
-- Using a CTE to ensure unique name combinations
WITH real_names AS (
    SELECT * FROM (VALUES
        -- Male names
        ('Nguyen', 'Quang', 'male'), ('Tran', 'Hung', 'male'), ('Le', 'Long', 'male'), ('Pham', 'Thanh', 'male'),
        ('Hoang', 'Dung', 'male'), ('Vo', 'Hai', 'male'), ('Bui', 'Tuan', 'male'), ('Do', 'Cuong', 'male'),
        ('Truong', 'Kien', 'male'), ('Dang', 'Tien', 'male'), ('Ngo', 'Binh', 'male'), ('Luu', 'Dat', 'male'),
        ('Ly', 'Hieu', 'male'), ('Vu', 'Khang', 'male'), ('Dinh', 'Huy', 'male'), ('Dao', 'Lam', 'male'),
        ('Ho', 'Loc', 'male'), ('Phan', 'Phuc', 'male'), ('Duong', 'Son', 'male'), ('Nguyen', 'Minh', 'male'),
        ('Tran', 'Duc', 'male'), ('Le', 'Hoang', 'male'), ('Pham', 'Khoa', 'male'), ('Hoang', 'Nam', 'male'),
        ('Vo', 'Anh', 'male'),
        -- Female names
        ('Nguyen', 'Hoa', 'female'), ('Tran', 'Huong', 'female'), ('Le', 'Ly', 'female'), ('Pham', 'Nga', 'female'),
        ('Hoang', 'Linh', 'female'), ('Vo', 'My', 'female'), ('Bui', 'Ngoc', 'female'), ('Do', 'Thu', 'female'),
        ('Truong', 'Trang', 'female'), ('Dang', 'Van', 'female'), ('Ngo', 'Yen', 'female'), ('Luu', 'Quynh', 'female'),
        ('Ly', 'Diem', 'female'), ('Vu', 'Giang', 'female'), ('Dinh', 'Khanh', 'female'), ('Dao', 'Ha', 'female'),
        ('Ho', 'Nhung', 'female'), ('Phan', 'Hong', 'female'), ('Duong', 'Bich', 'female'), ('Nguyen', 'Hanh', 'female'),
        ('Tran', 'Diep', 'female'), ('Le', 'Lan', 'female'), ('Pham', 'Huyen', 'female'), ('Hoang', 'Phuong', 'female'),
        ('Vo', 'Thao', 'female'), ('Bui', 'Mai', 'female')
    ) AS t(last_name, first_name, gender)
),
numbered_names AS (
    SELECT 
        last_name,
        first_name,
        last_name || ' ' || first_name as full_name,
        gender,
        row_number() OVER () as rn
    FROM real_names
)
INSERT INTO user_profiles (
    user_id, first_name, last_name, full_name, date_of_birth, gender,
    phone, address, city, country, timezone, avatar_url, cover_image_url,
    current_level, target_band_score, target_exam_date, bio, 
    learning_preferences, language_preference, created_at
)
SELECT 
    ('f' || LPAD((rn + 10)::text, 7, '0') || '-0000-0000-0000-000000000' || LPAD((rn + 10)::text, 3, '0'))::uuid,
    nn.first_name,
    nn.last_name,
    nn.full_name,
    (DATE '1990-01-01' + (random() * INTERVAL '15 years')::interval)::date,
    nn.gender,
    '+8490' || LPAD((123456 + rn * 10)::text, 7, '0'),
    (rn || ' Student St')::text,
    'Ho Chi Minh City',
    'Vietnam',
    'Asia/Ho_Chi_Minh',
    -- Real Unsplash avatar URLs based on gender
    CASE nn.gender
        WHEN 'male' THEN (ARRAY[
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop',
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop',
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop',
            'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=400&h=400&fit=crop'
        ])[1 + (rn % 5)]
        ELSE (ARRAY[
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop',
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop',
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&h=400&fit=crop',
            'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=400&h=400&fit=crop',
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop'
        ])[1 + (rn % 5)]
    END,
    -- Real Unsplash cover image URLs
    (ARRAY[
        'https://images.unsplash.com/photo-1497366216548-37526070297c?w=1200&h=400&fit=crop',
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1200&h=400&fit=crop',
        'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=1200&h=400&fit=crop',
        'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=1200&h=400&fit=crop'
    ])[1 + (rn % 4)],
    (ARRAY['beginner', 'elementary', 'pre-intermediate', 'intermediate', 'upper-intermediate', 'advanced'])[1 + (rn % 6)],
    4.5 + (rn % 41) * 0.1,
    CURRENT_DATE + (30 + (rn % 180))::integer,
    (ARRAY[
        'Sinh viên đại học chuẩn bị đi du học. Mong muốn đạt Band 7.0 để apply học bổng. Đang tập trung cải thiện Writing và Speaking.',
        'Nhân viên văn phòng muốn nâng cao trình độ tiếng Anh để thăng tiến. Mục tiêu Band 6.5 trong 6 tháng tới.',
        'Học sinh cấp 3 chuẩn bị thi IELTS để apply đại học. Đang luyện tập hàng ngày với mục tiêu Band 6.0.',
        'Kỹ sư muốn di cư sang Canada. Cần Band 7.0 để đủ điểm Express Entry. Đang học IELTS được 3 tháng.',
        'Giáo viên tiếng Anh muốn nâng cao chứng chỉ. Đã có nền tảng tốt, cần luyện thi để đạt Band 8.0.',
        'Sinh viên năm 4 chuẩn bị tốt nghiệp. Cần IELTS để apply cao học ở nước ngoài. Đang tập trung Reading và Writing.',
        'Nhân viên ngân hàng muốn làm việc ở chi nhánh quốc tế. Mục tiêu Band 7.5 trong 1 năm. Đã học được 6 tháng.',
        'Học viên mới bắt đầu học IELTS. Chưa có nền tảng, đang học từ cơ bản với mục tiêu Band 5.5.',
        'Freelancer muốn làm việc với khách hàng quốc tế. Cần IELTS để chứng minh khả năng giao tiếp. Mục tiêu Band 6.5.',
        'Học viên chăm chỉ, đã học IELTS được 1 năm. Đã đạt Band 6.0, đang cố gắng lên Band 7.0. Tập trung vào Listening và Speaking.',
        'Bác sĩ muốn làm việc tại bệnh viện quốc tế. Cần IELTS Academic Band 7.0 để đáp ứng yêu cầu nghề nghiệp. Đang cải thiện từng kỹ năng.',
        'Sinh viên kinh tế muốn học MBA ở Anh. Mục tiêu Band 7.5 để apply vào các trường top. Đã học được 8 tháng.',
        'Nhà thiết kế đồ họa muốn làm việc tại agency quốc tế. Cần IELTS để chứng minh khả năng giao tiếp với khách hàng.',
        'Nhân viên IT muốn relocate sang Singapore. Cần Band 7.0 để đủ điều kiện visa. Đang học IELTS được 4 tháng.',
        'Sinh viên y khoa chuẩn bị thi PLAB để hành nghề tại UK. Cần IELTS Academic Band 7.5. Đang tập trung vào Reading và Writing.',
        'Nhân viên marketing muốn làm việc tại công ty đa quốc gia. Mục tiêu Band 6.5 trong 3 tháng tới.',
        'Học sinh lớp 12 muốn apply vào đại học ở Úc. Cần Band 6.5 để đủ điều kiện nhập học. Đang luyện tập tích cực.',
        'Luật sư muốn làm việc tại văn phòng luật quốc tế. Cần IELTS để chứng minh trình độ tiếng Anh chuyên nghiệp.',
        'Giáo viên mầm non muốn làm việc tại trường quốc tế. Mục tiêu Band 7.0 để đáp ứng yêu cầu nghề nghiệp.',
        'Kế toán viên muốn thi ACCA. Cần IELTS để đáp ứng yêu cầu của chứng chỉ. Đang học song song cả hai.',
        'Sinh viên ngành du lịch muốn làm việc tại resort quốc tế. Cần IELTS để giao tiếp tốt với khách hàng.',
        'Nhân viên xuất nhập khẩu muốn làm việc với đối tác nước ngoài. Mục tiêu Band 6.5 để tự tin giao tiếp.',
        'Học viên đã thi IELTS 2 lần nhưng chưa đạt mục tiêu. Đang học lại từ đầu với phương pháp mới.',
        'Sinh viên kiến trúc muốn học thạc sĩ ở châu Âu. Cần Band 7.0 để apply học bổng. Đang tập trung Writing.',
        'Nhân viên bán hàng muốn làm việc tại showroom quốc tế. Cần IELTS để giao tiếp tốt với khách hàng nước ngoài.',
        'Sinh viên ngôn ngữ Anh muốn học sâu hơn về IELTS. Mục tiêu Band 8.0 để trở thành giáo viên IELTS.',
        'Nhân viên hàng không muốn apply vào hãng bay quốc tế. Cần IELTS để đáp ứng yêu cầu tuyển dụng.',
        'Kỹ sư phần mềm muốn làm việc tại startup ở Silicon Valley. Cần IELTS để đủ điều kiện visa.',
        'Sinh viên dược muốn làm việc tại nhà thuốc quốc tế. Mục tiêu Band 7.0 để đáp ứng yêu cầu nghề nghiệp.',
        'Nhân viên tư vấn tài chính muốn làm việc tại công ty đa quốc gia. Cần IELTS để giao tiếp với khách hàng.',
        'Học viên đã có bằng IELTS nhưng muốn nâng cao điểm số. Đang học lại để đạt Band 8.0.',
        'Sinh viên MBA muốn làm việc tại consulting firm quốc tế. Cần IELTS để chứng minh khả năng tiếng Anh.',
        'Nhân viên PR muốn làm việc tại agency quốc tế. Mục tiêu Band 7.5 để tự tin giao tiếp với media.',
        'Giáo viên Toán muốn làm việc tại trường quốc tế. Cần IELTS để đáp ứng yêu cầu giảng dạy bằng tiếng Anh.',
        'Sinh viên ngành thời trang muốn học thạc sĩ ở London. Cần Band 7.0 để apply vào các trường danh tiếng.',
        'Nhân viên nhân sự muốn làm việc tại công ty đa quốc gia. Cần IELTS để giao tiếp với nhân viên quốc tế.',
        'Học viên đã học IELTS tại nhiều trung tâm nhưng chưa đạt mục tiêu. Đang thử phương pháp học online.',
        'Sinh viên ngành môi trường muốn làm việc tại tổ chức quốc tế. Cần IELTS để tham gia các dự án quốc tế.',
        'Nhân viên logistics muốn làm việc tại công ty vận tải quốc tế. Mục tiêu Band 6.5 để giao tiếp tốt.',
        'Kỹ sư xây dựng muốn làm việc tại dự án quốc tế. Cần IELTS để đọc hiểu tài liệu kỹ thuật.',
        'Sinh viên ngành truyền thông muốn làm việc tại media quốc tế. Cần IELTS để viết bài và phỏng vấn.',
        'Nhân viên chăm sóc khách hàng muốn làm việc tại call center quốc tế. Cần IELTS để giao tiếp tốt.'
    ])[1 + (rn % 42)],
    jsonb_build_object(
        'study_time_preference', (ARRAY['morning', 'afternoon', 'evening'])[1 + (rn % 3)],
        'daily_goal_minutes', 30 + (rn % 91) * 5
    ),
    'vi',
    NOW() - (INTERVAL '1 day' * (100 - rn * 2))
FROM numbered_names nn
ORDER BY nn.rn;

-- ============================================
-- 2. LEARNING_PROGRESS
-- ============================================

INSERT INTO learning_progress (
    user_id, total_lessons_completed, total_exercises_completed,
    listening_progress, reading_progress, writing_progress, speaking_progress,
    listening_score, reading_score, writing_score, speaking_score, overall_score,
    current_streak_days, longest_streak_days, last_study_date, created_at, updated_at
)
SELECT 
    up.user_id,
    (random() * 100 + 5)::INTEGER, -- 5-105 lessons
    (random() * 150 + 10)::INTEGER, -- 10-160 exercises
    (random() * 100)::DECIMAL(5,2), -- 0-100%
    (random() * 100)::DECIMAL(5,2),
    (random() * 100)::DECIMAL(5,2),
    (random() * 100)::DECIMAL(5,2),
    CASE WHEN random() > 0.3 THEN 4.0 + (random() * 5.0)::DECIMAL(2,1) ELSE NULL END,
    CASE WHEN random() > 0.3 THEN 4.0 + (random() * 5.0)::DECIMAL(2,1) ELSE NULL END,
    CASE WHEN random() > 0.4 THEN 4.0 + (random() * 5.0)::DECIMAL(2,1) ELSE NULL END,
    CASE WHEN random() > 0.4 THEN 4.0 + (random() * 5.0)::DECIMAL(2,1) ELSE NULL END,
    CASE WHEN random() > 0.2 THEN 4.0 + (random() * 5.0)::DECIMAL(2,1) ELSE NULL END,
    (random() * 30)::INTEGER, -- 0-30 days streak
    (random() * 60 + 10)::INTEGER, -- 10-70 days longest streak
    CURRENT_DATE - (random() * 7)::INTEGER, -- Studied within last 7 days
    up.created_at,
    NOW()
FROM user_profiles up;

-- ============================================
-- 3. SKILL_STATISTICS
-- ============================================

-- Listening Statistics
INSERT INTO skill_statistics (
    user_id, skill_type, total_practices, completed_practices, average_score, best_score,
    total_time_minutes, last_practice_date, last_practice_score, score_trend, weak_areas
)
SELECT 
    user_id,
    'listening',
    total_practices_val,
    -- completed_practices: MUST be <= total_practices
    LEAST((random() * 45 + 3)::INTEGER, total_practices_val),
    -- average_score: MUST be <= best_score
    average_score_val,
    -- best_score: MUST be >= average_score
    GREATEST((random() * 40 + 60)::DECIMAL(5,2), average_score_val),
    (random() * 1200 + 60)::INTEGER, -- 60-1260 minutes
    CURRENT_TIMESTAMP - (random() * 30)::INTEGER * INTERVAL '1 day',
    (random() * 50 + 50)::DECIMAL(5,2),
    jsonb_build_array(
        jsonb_build_object('date', (CURRENT_DATE - 30)::text, 'score', (random() * 40 + 50)::DECIMAL(5,2)),
        jsonb_build_object('date', (CURRENT_DATE - 20)::text, 'score', (random() * 40 + 50)::DECIMAL(5,2)),
        jsonb_build_object('date', (CURRENT_DATE - 10)::text, 'score', (random() * 40 + 50)::DECIMAL(5,2)),
        jsonb_build_object('date', CURRENT_DATE::text, 'score', (random() * 40 + 50)::DECIMAL(5,2))
    ),
    jsonb_build_array(
        jsonb_build_object('topic', 'Multiple Choice', 'accuracy', (random() * 30 + 60)::DECIMAL(5,2)),
        jsonb_build_object('topic', 'Note Completion', 'accuracy', (random() * 30 + 60)::DECIMAL(5,2))
    )
FROM user_profiles
CROSS JOIN LATERAL (
    SELECT 
        (random() * 50 + 5)::INTEGER as total_practices_val,
        (random() * 50 + 50)::DECIMAL(5,2) as average_score_val
) AS stats_data
WHERE user_id::text LIKE 'f%' OR user_id::text LIKE 'b%' OR user_id::text LIKE 'a%'
LIMIT 60;

-- Reading Statistics
INSERT INTO skill_statistics (
    user_id, skill_type, total_practices, completed_practices, average_score, best_score,
    total_time_minutes, last_practice_date, last_practice_score, score_trend, weak_areas
)
SELECT 
    user_id,
    'reading',
    total_practices_val,
    -- completed_practices: MUST be <= total_practices
    LEAST((random() * 45 + 3)::INTEGER, total_practices_val),
    -- average_score: MUST be <= best_score
    average_score_val,
    -- best_score: MUST be >= average_score
    GREATEST((random() * 40 + 60)::DECIMAL(5,2), average_score_val),
    (random() * 1500 + 90)::INTEGER,
    CURRENT_TIMESTAMP - (random() * 30)::INTEGER * INTERVAL '1 day',
    (random() * 50 + 50)::DECIMAL(5,2),
    jsonb_build_array(
        jsonb_build_object('date', (CURRENT_DATE - 30)::text, 'score', (random() * 40 + 50)::DECIMAL(5,2)),
        jsonb_build_object('date', (CURRENT_DATE - 20)::text, 'score', (random() * 40 + 50)::DECIMAL(5,2)),
        jsonb_build_object('date', (CURRENT_DATE - 10)::text, 'score', (random() * 40 + 50)::DECIMAL(5,2)),
        jsonb_build_object('date', CURRENT_DATE::text, 'score', (random() * 40 + 50)::DECIMAL(5,2))
    ),
    jsonb_build_array(
        jsonb_build_object('topic', 'True/False/Not Given', 'accuracy', (random() * 30 + 60)::DECIMAL(5,2)),
        jsonb_build_object('topic', 'Matching Headings', 'accuracy', (random() * 30 + 60)::DECIMAL(5,2))
    )
FROM user_profiles
CROSS JOIN LATERAL (
    SELECT 
        (random() * 50 + 5)::INTEGER as total_practices_val,
        (random() * 50 + 50)::DECIMAL(5,2) as average_score_val
) AS stats_data
WHERE user_id::text LIKE 'f%' OR user_id::text LIKE 'b%' OR user_id::text LIKE 'a%'
LIMIT 55;

-- Writing Statistics
INSERT INTO skill_statistics (
    user_id, skill_type, total_practices, completed_practices, average_score, best_score,
    total_time_minutes, last_practice_date, last_practice_score, score_trend, weak_areas
)
SELECT 
    user_id,
    'writing',
    total_practices_val,
    -- completed_practices: MUST be <= total_practices
    LEAST((random() * 35 + 2)::INTEGER, total_practices_val),
    -- average_score: MUST be <= best_score
    average_score_val,
    -- best_score: MUST be >= average_score
    GREATEST((random() * 40 + 60)::DECIMAL(5,2), average_score_val),
    (random() * 800 + 120)::INTEGER,
    CURRENT_TIMESTAMP - (random() * 30)::INTEGER * INTERVAL '1 day',
    (random() * 50 + 50)::DECIMAL(5,2),
    jsonb_build_array(
        jsonb_build_object('date', (CURRENT_DATE - 30)::text, 'score', (random() * 40 + 50)::DECIMAL(5,2)),
        jsonb_build_object('date', (CURRENT_DATE - 20)::text, 'score', (random() * 40 + 50)::DECIMAL(5,2)),
        jsonb_build_object('date', (CURRENT_DATE - 10)::text, 'score', (random() * 40 + 50)::DECIMAL(5,2)),
        jsonb_build_object('date', CURRENT_DATE::text, 'score', (random() * 40 + 50)::DECIMAL(5,2))
    ),
    jsonb_build_array(
        jsonb_build_object('topic', 'Task Achievement', 'accuracy', (random() * 30 + 60)::DECIMAL(5,2)),
        jsonb_build_object('topic', 'Grammar', 'accuracy', (random() * 30 + 60)::DECIMAL(5,2))
    )
FROM user_profiles
CROSS JOIN LATERAL (
    SELECT 
        (random() * 40 + 3)::INTEGER as total_practices_val,
        (random() * 50 + 50)::DECIMAL(5,2) as average_score_val
) AS stats_data
WHERE user_id::text LIKE 'f%' OR user_id::text LIKE 'b%' OR user_id::text LIKE 'a%'
LIMIT 45;

-- Speaking Statistics
INSERT INTO skill_statistics (
    user_id, skill_type, total_practices, completed_practices, average_score, best_score,
    total_time_minutes, last_practice_date, last_practice_score, score_trend, weak_areas
)
SELECT 
    user_id,
    'speaking',
    total_practices_val,
    -- completed_practices: MUST be <= total_practices
    LEAST((random() * 30 + 2)::INTEGER, total_practices_val),
    -- average_score: MUST be <= best_score
    average_score_val,
    -- best_score: MUST be >= average_score
    GREATEST((random() * 40 + 60)::DECIMAL(5,2), average_score_val),
    (random() * 600 + 90)::INTEGER,
    CURRENT_TIMESTAMP - (random() * 30)::INTEGER * INTERVAL '1 day',
    (random() * 50 + 50)::DECIMAL(5,2),
    jsonb_build_array(
        jsonb_build_object('date', (CURRENT_DATE - 30)::text, 'score', (random() * 40 + 50)::DECIMAL(5,2)),
        jsonb_build_object('date', (CURRENT_DATE - 20)::text, 'score', (random() * 40 + 50)::DECIMAL(5,2)),
        jsonb_build_object('date', (CURRENT_DATE - 10)::text, 'score', (random() * 40 + 50)::DECIMAL(5,2)),
        jsonb_build_object('date', CURRENT_DATE::text, 'score', (random() * 40 + 50)::DECIMAL(5,2))
    ),
    jsonb_build_array(
        jsonb_build_object('topic', 'Pronunciation', 'accuracy', (random() * 30 + 60)::DECIMAL(5,2)),
        jsonb_build_object('topic', 'Fluency', 'accuracy', (random() * 30 + 60)::DECIMAL(5,2))
    )
FROM user_profiles
CROSS JOIN LATERAL (
    SELECT 
        (random() * 35 + 2)::INTEGER as total_practices_val,
        (random() * 50 + 50)::DECIMAL(5,2) as average_score_val
) AS stats_data
WHERE user_id::text LIKE 'f%' OR user_id::text LIKE 'b%' OR user_id::text LIKE 'a%'
LIMIT 40;

-- ============================================
-- 4. STUDY_SESSIONS
-- ============================================

INSERT INTO study_sessions (
    id, user_id, session_type, skill_type, resource_id, resource_type,
    started_at, ended_at, duration_minutes, is_completed, completion_percentage, score, device_type
)
SELECT 
    uuid_generate_v4(),
    user_id,
    CASE (random() * 3)::INTEGER
        WHEN 0 THEN 'lesson'
        WHEN 1 THEN 'exercise'
        ELSE 'practice_test'
    END,
    CASE (random() * 4)::INTEGER
        WHEN 0 THEN 'listening'
        WHEN 1 THEN 'reading'
        WHEN 2 THEN 'writing'
        ELSE 'speaking'
    END,
    uuid_generate_v4(),
    CASE (random() * 2)::INTEGER WHEN 0 THEN 'lesson' ELSE 'exercise' END,
    -- started_at: random time in the past
    started_at_val,
    -- ended_at: MUST be AFTER started_at, calculate duration from it
    started_at_val + duration_minutes_val * INTERVAL '1 minute',
    -- duration_minutes: MUST match (ended_at - started_at) / 60
    duration_minutes_val,
    CASE WHEN random() > 0.2 THEN true ELSE false END,
    CASE WHEN random() > 0.2 THEN (random() * 30 + 70)::DECIMAL(5,2) ELSE (random() * 60)::DECIMAL(5,2) END,
    CASE WHEN random() > 0.3 THEN (random() * 40 + 60)::DECIMAL(5,2) ELSE NULL END,
    CASE (random() * 3)::INTEGER WHEN 0 THEN 'web' WHEN 1 THEN 'android' ELSE 'ios' END
FROM user_profiles
CROSS JOIN LATERAL (
    SELECT 
        CURRENT_TIMESTAMP - (random() * 30)::INTEGER * INTERVAL '1 day' - (random() * 23)::INTEGER * INTERVAL '1 hour' as started_at_val,
        (random() * 120 + 15)::INTEGER as duration_minutes_val
) AS session_data
CROSS JOIN generate_series(1, 5) -- 5 sessions per user
WHERE user_id::text LIKE 'f%'
LIMIT 250;

-- ============================================
-- 5. STUDY_GOALS
-- ============================================

INSERT INTO study_goals (
    id, user_id, goal_type, title, description, target_value, target_unit,
    skill_type, start_date, end_date, status, reminder_enabled, reminder_time
)
SELECT 
    uuid_generate_v4(),
    user_id,
    CASE (random() * 3)::INTEGER
        WHEN 0 THEN 'daily'
        WHEN 1 THEN 'weekly'
        ELSE 'monthly'
    END,
    CASE (random() * 4)::INTEGER
        WHEN 0 THEN 'Complete ' || (random() * 5 + 1)::INTEGER || ' lessons this week'
        WHEN 1 THEN 'Study ' || (random() * 60 + 30)::INTEGER || ' minutes daily'
        WHEN 2 THEN 'Complete ' || (random() * 10 + 5)::INTEGER || ' exercises'
        ELSE 'Achieve Band ' || (random() * 4 + 5)::INTEGER || '.0 in ' || 
             CASE (random() * 4)::INTEGER
                 WHEN 0 THEN 'Listening'
                 WHEN 1 THEN 'Reading'
                 WHEN 2 THEN 'Writing'
                 ELSE 'Speaking'
             END
    END,
    'Personal study goal to improve IELTS skills',
    CASE (random() * 2)::INTEGER WHEN 0 THEN (random() * 60 + 30)::INTEGER ELSE (random() * 10 + 5)::INTEGER END,
    CASE (random() * 2)::INTEGER WHEN 0 THEN 'minutes' ELSE 'lessons' END,
    CASE WHEN random() > 0.5 THEN 
        CASE (random() * 4)::INTEGER
            WHEN 0 THEN 'listening'
            WHEN 1 THEN 'reading'
            WHEN 2 THEN 'writing'
            ELSE 'speaking'
        END
    ELSE NULL END,
    CURRENT_DATE - (random() * 30)::INTEGER,
    CURRENT_DATE + (random() * 60 + 30)::INTEGER,
    CASE (random() * 3)::INTEGER
        WHEN 0 THEN 'active'
        WHEN 1 THEN 'completed'
        ELSE 'expired'
    END,
    CASE WHEN random() > 0.3 THEN true ELSE false END,
    CASE WHEN random() > 0.3 THEN (TIME '08:00' + (random() * 12)::INTEGER * INTERVAL '1 hour') ELSE NULL END
FROM user_profiles
WHERE user_id::text LIKE 'f%'
LIMIT 150;

-- ============================================
-- 6. USER_ACHIEVEMENTS
-- ============================================

-- Assign achievements to users based on their progress
INSERT INTO user_achievements (user_id, achievement_id, earned_at)
SELECT 
    up.user_id,
    a.id,
    CURRENT_TIMESTAMP - (random() * 100)::INTEGER * INTERVAL '1 day'
FROM user_profiles up
CROSS JOIN achievements a
WHERE (a.code = 'first_lesson' AND up.user_id::text LIKE 'f%') -- All students get first lesson
   OR (a.code = 'streak_7' AND random() > 0.5)
   OR (a.code = 'streak_30' AND random() > 0.7)
   OR (a.code = 'band_6' AND random() > 0.4)
   OR (a.code = 'band_7' AND random() > 0.3)
   OR (a.code = 'listening_master' AND random() > 0.6)
ON CONFLICT (user_id, achievement_id) DO NOTHING;

-- ============================================
-- 7. USER_PREFERENCES
-- ============================================

INSERT INTO user_preferences (
    user_id, email_notifications, push_notifications, study_reminders, weekly_report,
    theme, font_size, auto_play_next_lesson, show_answer_explanation, playback_speed,
    profile_visibility, show_study_stats
)
SELECT 
    user_id,
    CASE WHEN random() > 0.2 THEN true ELSE false END,
    CASE WHEN random() > 0.15 THEN true ELSE false END,
    CASE WHEN random() > 0.25 THEN true ELSE false END,
    CASE WHEN random() > 0.3 THEN true ELSE false END,
    CASE (random() * 3)::INTEGER WHEN 0 THEN 'light' WHEN 1 THEN 'dark' ELSE 'auto' END,
    CASE (random() * 3)::INTEGER WHEN 0 THEN 'small' WHEN 1 THEN 'medium' ELSE 'large' END,
    CASE WHEN random() > 0.4 THEN true ELSE false END,
    CASE WHEN random() > 0.1 THEN true ELSE false END,
    (0.75 + (random() * 1.25))::DECIMAL(3,2), -- 0.75-2.0
    CASE (random() * 3)::INTEGER WHEN 0 THEN 'public' WHEN 1 THEN 'friends' ELSE 'private' END,
    CASE WHEN random() > 0.2 THEN true ELSE false END
FROM user_profiles
ON CONFLICT (user_id) DO NOTHING;

-- ============================================
-- 8. STUDY_REMINDERS
-- ============================================

INSERT INTO study_reminders (
    id, user_id, title, message, reminder_type, reminder_time, days_of_week,
    is_active, last_sent_at, next_send_at
)
SELECT 
    uuid_generate_v4(),
    user_id,
    'Daily Study Reminder',
    'Time to practice IELTS! Complete your daily goals.',
    CASE (random() * 2)::INTEGER WHEN 0 THEN 'daily' ELSE 'weekly' END,
    (TIME '07:00' + (random() * 14)::INTEGER * INTERVAL '1 hour'), -- 7 AM - 9 PM
    CASE WHEN random() > 0.5 THEN ARRAY[1,2,3,4,5] ELSE ARRAY[0,1,2,3,4,5,6] END,
    CASE WHEN random() > 0.3 THEN true ELSE false END,
    CASE WHEN random() > 0.5 THEN CURRENT_TIMESTAMP - (random() * 7)::INTEGER * INTERVAL '1 day' ELSE NULL END,
    CASE WHEN random() > 0.5 THEN CURRENT_TIMESTAMP + (random() * 24)::INTEGER * INTERVAL '1 hour' ELSE NULL END
FROM user_profiles
WHERE user_id::text LIKE 'f%'
LIMIT 100;

-- Summary
SELECT 
    '✅ Phase 2 Complete: User Profiles Created' as status,
    (SELECT COUNT(*) FROM user_profiles) as total_profiles,
    (SELECT COUNT(*) FROM learning_progress) as total_progress,
    (SELECT COUNT(*) FROM skill_statistics) as total_skill_stats,
    (SELECT COUNT(*) FROM study_sessions) as total_sessions,
    (SELECT COUNT(*) FROM study_goals) as total_goals,
    (SELECT COUNT(*) FROM user_achievements) as total_achievements;

