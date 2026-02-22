# 📊 Danh Sách Biểu Đồ Hoạt Động (Activity Diagrams)

## 📋 Tổng Quan

Các biểu đồ hoạt động này mô tả chi tiết flow của các chức năng chính trong hệ thống IELTS Platform, sử dụng PlantUML với swimlanes để thể hiện sự tương tác giữa các services.

---

## 🎯 4 Chức Năng Ưu Tiên Cao

### 1. 📚 Đăng Ký Khóa Học (Course Enrollment)
**File**: `docs/activity-enrollment.puml`

**Mô tả**: Flow đăng ký khóa học của học viên, bao gồm validation, tạo enrollment record, và gửi notification.

**Services liên quan**:
- API Gateway
- Course Service
- Notification Service (async)
- User Service (async)

**Các bước chính**:
1. Student chọn và submit enrollment request
2. Validate course tồn tại và enrollment type
3. Tạo enrollment record (với ON CONFLICT handling)
4. Gửi notification chào mừng (async)
5. Tạo initial progress records (async)

**Đặc điểm**:
- Xử lý duplicate enrollment (ON CONFLICT)
- Async notification không block response
- Support free và premium courses

---

### 2. 🎥 Học Bài - Xem Video Lesson
**File**: `docs/activity-learn-lesson.puml`

**Mô tả**: Flow học viên xem video lesson với real-time progress tracking và completion handling.

**Services liên quan**:
- API Gateway
- Course Service
- User Service (async)
- Notification Service (async)

**Các bước chính**:
1. Load lesson content và check enrollment
2. Student xem video với progress tracking
3. Real-time update lesson progress (UPSERT atomic)
4. Khi hoàn thành: Mark lesson as completed
5. Update user progress và statistics (async)
6. Gửi notification completion (async)
7. Check course completion

**Đặc điểm**:
- Real-time progress tracking
- Atomic UPSERT operations (tránh race condition)
- Auto-completion khi progress >= 100%
- Tích hợp với User Service để update statistics

---

### 3. ✍️ Nộp Bài Writing - AI Evaluation
**File**: `docs/activity-submit-writing.puml`

**Mô tả**: Flow nộp bài Writing với async AI evaluation, caching, và retry logic.

**Services liên quan**:
- API Gateway
- Exercise Service
- AI Service (async)
- User Service (async)
- Notification Service (async)

**Các bước chính**:
1. Student submit essay text
2. Validate word count (Task 1: 150+, Task 2: 250+)
3. Create submission với status "pending"
4. Async AI evaluation:
   - Check cache (content hash)
   - Nếu cache miss: Call OpenAI GPT-4o
   - Evaluate 4 criteria
   - Save to cache (async)
5. Update submission với results
6. Sync to User Service (async)
7. Gửi notification (async)
8. Student polling hoặc nhận notification

**Đặc điểm**:
- Async processing (non-blocking)
- Content-based caching (hash essay text)
- Retry mechanism (max 3 attempts)
- Real-time status updates (polling/SSE)

---

### 4. 🎤 Nộp Bài Speaking - Audio Upload & AI Evaluation
**File**: `docs/activity-submit-speaking.puml`

**Mô tả**: Flow nộp bài Speaking với audio upload, transcription, và AI evaluation.

**Services liên quan**:
- API Gateway
- Storage Service (MinIO)
- Exercise Service
- AI Service (async - 2 steps)
- User Service (async)
- Notification Service (async)

**Các bước chính**:
1. Student upload audio file
2. Storage Service validate và upload lên MinIO
3. Student submit với audio_url
4. Create submission với status "processing"
5. Async processing:
   - **Step 1**: Transcribe audio (Whisper API)
     - Download audio từ Storage
     - Call OpenAI Whisper
     - Save transcript
   - **Step 2**: Evaluate speaking (GPT-4o)
     - Check cache (audio_url + transcript + part)
     - Nếu cache miss: Call OpenAI GPT-4o
     - Evaluate 4 criteria
     - Save to cache (async)
6. Update submission với transcript và results
7. Sync to User Service (async)
8. Gửi notification (async)
9. Student polling hoặc nhận notification

**Đặc điểm**:
- 2-step async processing (transcribe → evaluate)
- File upload validation (size, format, duration)
- Retry mechanism cho cả transcription và evaluation
- Cache based on audio URL + transcript + part number
- Transcript được lưu trong submission

---

## 🎨 Cách Sử Dụng

### Xem Biểu Đồ

1. **Online**: Sử dụng PlantUML online editor
   - Truy cập: http://www.plantuml.com/plantuml/uml/
   - Copy nội dung file `.puml` và paste vào editor

2. **VS Code**: Cài extension "PlantUML"
   - Extension: `jebbs.plantuml`
   - Preview: `Alt + D` hoặc click "Preview"

3. **CLI**: Sử dụng PlantUML jar
   ```bash
   java -jar plantuml.jar docs/activity-enrollment.puml
   ```

4. **IntelliJ IDEA**: Cài plugin "PlantUML integration"
   - File → Settings → Plugins → Search "PlantUML"

### Export Hình Ảnh

```bash
# Export PNG
java -jar plantuml.jar -tpng docs/activity-*.puml

# Export SVG
java -jar plantuml.jar -tsvg docs/activity-*.puml

# Export PDF
java -jar plantuml.jar -tpdf docs/activity-*.puml
```

---

## 📝 Ghi Chú Kỹ Thuật

### Swimlanes
Mỗi biểu đồ sử dụng swimlanes để phân chia theo:
- **Actor**: Student, Instructor, Admin
- **Services**: API Gateway, Course Service, Exercise Service, AI Service, etc.

### Async Processing
- Sử dụng `fork` và `end fork` để thể hiện async operations
- Các operations không block main flow được đánh dấu rõ ràng

### Error Handling
- Tất cả validation steps đều có error handling
- Retry logic được ghi chú trong notes

### Database Operations
- UPSERT operations được sử dụng để tránh race conditions
- ON CONFLICT handling cho duplicate prevention

---

## 🔄 Cập Nhật

Khi có thay đổi trong flow, cần cập nhật:
1. File `.puml` tương ứng
2. File `activity-diagrams-index.md` này
3. Documentation liên quan

---

## 📚 Tài Liệu Liên Quan

- [Đề Xuất Chức Năng Chính](./activity-diagram-features.md)
- [Class Diagrams](./class-*-service-design.puml)
- [API Documentation](../README.md)

