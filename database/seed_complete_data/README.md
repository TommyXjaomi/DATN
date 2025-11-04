# Seed Data - Hướng Dẫn Sử Dụng

## 🚀 Quick Start

Chỉ cần chạy **1 script duy nhất** để seed toàn bộ database:

```bash
cd /Users/bisosad/DATN
./database/seed_complete_data/clean-and-seed.sh
```

Script sẽ tự động:
1. 🧹 **Clean** - Xóa tất cả data cũ
2. 🔍 **Fetch YouTube Durations** - Lấy durations chính xác từ YouTube API
3. 📝 **Update Seed Files** - Cập nhật seed files với durations
4. 🌱 **Seed Data** - Seed tất cả databases theo đúng thứ tự

## 📋 Flow Tự Động

### Phase 1: Auth DB - Users & Roles
- `01_auth_users.sql`: Tạo users, roles, permissions, user_roles
- 70 users: 5 admins, 15 instructors, 50 students
- Passwords đã hash bằng `crypt()` và `gen_salt('bf', 10)`

### Phase 2.5: Course DB - Courses Structure
- `03_courses.sql`: Courses, modules, lessons, lesson_videos
- 29 courses với đầy đủ modules, lessons, videos
- Durations tự động fetch từ YouTube API

### Phase 2: User DB - Profiles & Progress
- `02_user_profiles.sql`: User profiles, learning progress, skill statistics
- 67 user profiles với progress và statistics đầy đủ
- Study sessions, goals, achievements

### Phase 3: Course DB - User Activities
- `04_course_activities.sql`: Enrollments, lesson progress, watch history, reviews
- Course enrollments với progress tracking
- Video watch history và course reviews

### Phase 4: Exercise DB - Exercises
- `03_exercises.sql`: Exercises, sections, questions, options, attempts
- `03_exercises_enhanced.sql`: Enhanced realistic questions
- Listening và Reading exercises với questions đa dạng
- User attempts và answers

### Phase 5: AI DB - Writing & Speaking
- `05_ai_submissions.sql`: Writing và Speaking submissions
- Evaluations và feedback từ AI service
- Cross-database linking với users và courses

### Phase 6: Notification DB
- `06_notifications.sql`: Notifications và preferences
- Email và push notifications
- Notification preferences

### Phase 7-8: Additional Tables
- `07_missing_tables.sql`: Question bank
- `07b_evaluation_feedback.sql`: Evaluation feedback ratings
- `08a_course_additional.sql`: Video subtitles, lesson materials
- `08b_exercise_additional.sql`: Exercise tag mapping, analytics
- `08c_notification_additional.sql`: Scheduled notifications

## 🔧 Cấu Hình

### YouTube API Key

Script tự động tìm `YOUTUBE_API_KEY` từ:
1. Environment variable
2. File `.env` trong project root
3. Docker-compose.yml

**Setup:**
```bash
# Thêm vào .env file
YOUTUBE_API_KEY=your_api_key_here
```

**Lấy API key:**
- Xem hướng dẫn trong `docs/YOUTUBE_API_SETUP.md`
- Hoặc truy cập: https://console.cloud.google.com/apis/credentials

### Durations Mapping

Script tự động tạo và sử dụng `youtube_durations.json` với mapping:
- Video ID → Duration (seconds)
- **Cache thông minh**: Chỉ fetch videos mới, reuse cache để tiết kiệm quota
- Tự động cập nhật seed files với durations chính xác
- **Tiết kiệm quota**: Lần chạy đầu fetch tất cả, lần sau chỉ fetch videos mới

## 📁 File Structure

### Seed Files (SQL)
- `01_auth_users.sql` - Auth database
- `02_user_profiles.sql` - User database
- `03_courses.sql` - Courses structure
- `03_exercises.sql` - Exercises
- `03_exercises_enhanced.sql` - Enhanced exercises
- `04_course_activities.sql` - Course activities
- `05_ai_submissions.sql` - AI submissions
- `06_notifications.sql` - Notifications
- `07_missing_tables.sql` - Missing tables
- `07b_evaluation_feedback.sql` - Evaluation feedback
- `08a_course_additional.sql` - Course additional
- `08b_exercise_additional.sql` - Exercise additional
- `08c_notification_additional.sql` - Notification additional

### Scripts
- `clean-and-seed.sh` - **Script chính** - Chạy toàn bộ flow
- `fetch_youtube_durations.py` - Fetch durations từ YouTube API
- `update_seed_with_durations.py` - Cập nhật seed files với durations

### Generated Files (Auto-generated, không cần edit)
- `youtube_durations.json` - **Cache durations mapping** (tiết kiệm API quota)
  - Lần đầu: Fetch tất cả videos từ API
  - Lần sau: Chỉ fetch videos mới, reuse cache
  - File này nên được commit vào Git để team share

## 🎯 Data Features

### ✅ Đa Dạng & Thực Tế
- 50 students với tên Việt Nam thực tế
- 29 courses đầy đủ nội dung
- 60+ exercises với questions chi tiết
- Durations chính xác từ YouTube API
- Images từ Unsplash
- Videos từ YouTube

### ✅ Tight Coupling
- User enrollments → Course reviews
- Exercise attempts → User answers
- Lesson progress → Video watch history
- AI submissions → Course/Exercise linking

### ✅ Logical Consistency
- Timestamps theo thứ tự logic
- Progress percentages hợp lý
- Scores và statistics nhất quán
- Relationships đúng foreign keys

## 🔍 Troubleshooting

### Không tìm thấy YouTube API key
```
⚠ YOUTUBE_API_KEY not found - using default durations
```
**Giải pháp:** Thêm `YOUTUBE_API_KEY` vào `.env` file

### Docker container không chạy
```
✗ Docker container ielts_postgres is not running
```
**Giải pháp:** 
```bash
docker-compose up -d postgres
```

### Lỗi khi fetch durations
- Script sẽ tiếp tục với default durations
- Check log trong `/tmp/youtube_fetch.log`
- Rate limiting: 100ms delay giữa requests

## 📊 Data Statistics

Sau khi seed thành công:
- **70 users** (5 admins, 15 instructors, 50 students)
- **29 courses** với đầy đủ modules và lessons
- **60+ exercises** với questions đa dạng
- **1000+ questions** với options và answers
- **500+ user attempts** với answers
- **300+ enrollments** với progress tracking
- **200+ reviews** và ratings

## 💡 Cách Hoạt Động

### Cache Thông Minh

Script tự động cache durations vào `youtube_durations.json`:
- **Lần đầu chạy**: Fetch tất cả videos từ YouTube API (129 videos)
- **Lần sau chạy**: Chỉ fetch videos mới (nếu có), reuse cache cho videos đã có
- **Tiết kiệm quota**: ~97.7% API calls được tiết kiệm (126/129 videos)

**Ví dụ:**
- Lần 1: Fetch 129 videos → Tốn 129 API calls
- Lần 2: Reuse cache → Tiết kiệm 129 API calls
- Lần 3 (có video mới): Chỉ fetch 3 videos mới → Tiết kiệm 126 API calls

### File JSON Cache

File `youtube_durations.json` được giữ lại để:
- ✅ Cache durations và tiết kiệm quota
- ✅ Share với team (commit vào Git)
- ✅ Dễ maintain khi có video mới
- ✅ Seed files tự động sử dụng cache này

## 📝 Quản Lý Video URLs

### Tự Động Cập Nhật Video IDs

Để thêm/sửa video URLs:

1. **Chỉnh sửa file `url_yt.txt`**:
   ```bash
   # Thêm link YouTube mới vào cuối file
   https://www.youtube.com/watch?v=VIDEO_ID
   # Hoặc
   https://youtu.be/VIDEO_ID
   ```

2. **Chạy script cập nhật**:
   ```bash
   python3 database/seed_complete_data/update_video_ids.py
   ```

3. **Hoặc chạy clean-and-seed.sh** (tự động cập nhật):
   ```bash
   ./database/seed_complete_data/clean-and-seed.sh
   ```

Script sẽ tự động:
- ✅ Đọc tất cả video IDs từ `url_yt.txt`
- ✅ Cập nhật array `video_ids` trong `03_courses.sql`
- ✅ Backup file gốc (`.backup`)
- ✅ Hỗ trợ cả 2 format: `youtube.com/watch?v=` và `youtu.be/`

### File Structure

- `url_yt.txt` - **Danh sách video URLs** (source of truth)
- `update_video_ids.py` - Script tự động cập nhật seed files
- `03_courses.sql` - Seed file chứa `video_ids` array

## 🎓 Login Credentials

### Admin
- Email: `admin1@example.com`
- Password: `password123`

### Instructor  
- Email: `instructor1@example.com`
- Password: `password123`

### Student
- Email: `minh.tran@example.com` (hoặc `student1@example.com`)
- Password: `password123`

*Note: Tất cả passwords đã được hash, có thể login qua API hoặc frontend.*

