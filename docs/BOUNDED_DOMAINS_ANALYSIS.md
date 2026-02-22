# Phân Rã Thành Các Miền Chức Năng (Bounded Domains)

## Tổng Quan
Hệ thống được phân rã thành 7 miền chức năng (Bounded Domains) độc lập, mỗi domain có dữ liệu riêng và chịu trách nhiệm cho một khía cạnh cụ thể của ứng dụng.

---

## 1. Auth Domain (Miền Xác Thực)

### Mục Đích
Quản lý xác thực người dùng, phân quyền và bảo mật.

### Entities Chính
- **AuthUser**: Tài khoản xác thực với email, mật khẩu, vai trò
- **Role**: Vai trò người dùng (Admin, User, Teacher, etc.)
- **Permission**: Quyền hạn của từng vai trò
- **RolePermission**: Ánh xạ quyền vào vai trò
- **EmailVerification**: Xác minh email người dùng
- **RefreshToken**: Token để làm mới phiên đăng nhập

### Ranh Giới Domain
Chỉ chịu trách nhiệm xác thực và cấp quyền. Không quản lý thông tin chi tiết hồ sơ người dùng (do User Domain quản lý).

### Tương Tác Với Domains Khác
- **→ User Domain**: Tạo UserProfile khi AuthUser được tạo (1:1)
- **← Tất cả Domains**: Validate JWT token từ AuthUser trước khi xử lý

---

## 2. User Domain (Miền Hồ Sơ Người Dùng)

### Mục Đích
Quản lý hồ sơ, tiến độ học tập, thành tích và các mục tiêu học của người dùng.

### Entities Chính
- **UserProfile**: Thông tin cá nhân, sở thích, cài đặt
- **LearningProgress**: Tiến độ học tập tổng quát (giờ học, bài đã hoàn thành, điểm)
- **StudySession**: Phiên học tập riêng lẻ
- **Achievement**: Các thành tích, huy hiệu có thể kiếm được
- **UserAchievement**: Thành tích đã kiếm được của người dùng
- **StudyGoal**: Mục tiêu học (e.g., "Đạt band 6.5 trong 3 tháng")
- **StudyReminder**: Nhắc nhở học tập cá nhân hóa
- **StudyStreak**: Chuỗi học liên tiếp

### Ranh Giới Domain
Chỉ quản lý dữ liệu cá nhân của người dùng. Không quản lý nội dung khóa học hay bài tập (do Course/Exercise Domains quản lý).

### Tương Tác Với Domains Khác
- **← Auth Domain**: Được tạo khi AuthUser được tạo
- **← Course Domain**: Cập nhật progress khi hoàn thành lesson
- **← Exercise Domain**: Cập nhật progress và achievement khi hoàn thành bài tập
- **→ Notification Domain**: Gửi dữ liệu để tạo notification
- **← Storage Domain**: Quản lý avatar và tài liệu cá nhân

---

## 3. Course Domain (Miền Khóa Học)

### Mục Đích
Quản lý nội dung khóa học, mô-đun, bài học, video và tài liệu.

### Entities Chính
- **Course**: Thông tin khóa học (tiêu đề, giá, khoá học tiên quyết)
- **Module**: Các mô-đun trong khóa học
- **Lesson**: Các bài học trong mô-đun
- **LessonVideo**: Video bài giảng
- **LessonMaterial**: Tài liệu hỗ trợ (PDF, hình ảnh, etc.)
- **LessonTranscript**: Bản phiên âm/phụ đề
- **CourseEnrollment**: Ghi danh của người dùng
- **LessonProgress**: Tiến độ học từng bài
- **CourseReview**: Đánh giá khóa học
- **CoursePrerequisite**: Khóa học tiên quyết

### Ranh Giới Domain
Chỉ quản lý nội dung khóa học và đăng ký. Không quản lý bài tập hay đánh giá bài (do Exercise Domain quản lý).

### Tương Tác Với Domains Khác
- **→ User Domain**: LessonProgress cập nhật UserProfile.learning_progress
- **← User Domain**: Nhận dữ liệu ghi danh từ UserProfile
- **→ Notification Domain**: Gửi thông báo hoàn thành bài học
- **→ Storage Domain**: Lưu trữ video, tài liệu, hình ảnh
- **← Exercise Domain**: Kiểm tra Exercise có phục vụ Lesson nào

---

## 4. Exercise Domain (Miền Bài Tập)

### Mục Đích
Quản lý bài tập, câu hỏi và xử lý câu trả lời của người dùng.

### Entities Chính
- **Exercise**: Thông tin bài tập (loại, kỹ năng, số câu hỏi)
- **ExerciseSection**: Phần của bài tập
- **Question**: Câu hỏi trong bài tập
- **QuestionOption**: Các lựa chọn trả lời
- **UserExerciseAttempt**: Lần làm bài của người dùng
- **SubmissionAnswer**: Câu trả lời của người dùng
- **ExerciseResult**: Kết quả bài tập

### Ranh Giới Domain
Chỉ quản lý bài tập và câu hỏi. Không quản lý AI evaluation (do AI Domain quản lý).

### Tương Tác Với Domains Khác
- **← User Domain**: Nhận user_id để tạo attempt
- **→ User Domain**: Gửi điểm, band score cập nhật progress
- **→ AI Domain**: Gửi writing/speaking answers để đánh giá
- **← AI Domain**: Nhận kết quả đánh giá từ AI
- **→ Notification Domain**: Gửi thông báo hoàn thành bài tập

---

## 5. Notification Domain (Miền Thông Báo)

### Mục Đích
Quản lý thông báo, mẫu thông báo, thiết bị người dùng và lịch sử gửi.

### Entities Chính
- **Notification**: Bản ghi thông báo gửi đi
- **NotificationEvent**: Loại sự kiện tích phát thông báo
- **NotificationTemplate**: Mẫu nội dung thông báo
- **DeviceToken**: Token thiết bị để gửi push notification
- **ScheduledNotification**: Thông báo theo lịch
- **NotificationPreference**: Tùy chọn thông báo của người dùng
- **NotificationLog**: Nhật ký gửi thông báo

### Ranh Giới Domain
Chỉ quản lý gửi thông báo. Không quyết định nên gửi thông báo khi nào (logic ở domains khác).

### Tương Tác Với Domains Khác
- **← User Domain**: Nhận dữ liệu để gửi thông báo
- **← Course Domain**: Nhận sự kiện (lesson completed)
- **← Exercise Domain**: Nhận sự kiện (exercise completed)
- **← Tất cả Domains**: Nhận sự kiện để phát thông báo

---

## 6. AI Domain (Miền Trí Tuệ Nhân Tạo)

### Mục Đích
Đánh giá kỹ năng Writing/Speaking và cung cấp phản hồi AI.

### Entities Chính
- **AIEvaluationRequest**: Yêu cầu đánh giá từ Exercise
- **AIEvaluationResult**: Kết quả đánh giá (fluency, accuracy, pronunciation)
- **AIEvaluationCache**: Cache kết quả để tối ưu chi phí
- **AIEvaluationLog**: Nhật ký gọi API AI
- **AIModel**: Cấu hình mô hình AI

### Ranh Giới Domain
Chỉ xử lý đánh giá. Không quản lý bài tập hay tiến độ người dùng.

### Tương Tác Với Domains Khác
- **← Exercise Domain**: Nhận yêu cầu đánh giá
- **→ Exercise Domain**: Gửi kết quả đánh giá (band score, feedback)
- **→ User Domain**: Dữ liệu để cập nhật speaking/writing progress

---

## 7. Storage Domain (Miền Lưu Trữ)

### Mục Đích
Quản lý tệp, hình ảnh, video, tài liệu trên MinIO/cloud storage.

### Entities Chính
- **StorageBucket**: Thùng lưu trữ
- **FileObject**: Đối tượng tệp (video, hình ảnh, PDF)
- **FileVersion**: Phiên bản tệp
- **FileAccess**: Lịch sử truy cập tệp
- **FileMetadata**: Siêu dữ liệu tệp
- **DeletedFile**: Bản ghi xóa tệp
- **FileQuota**: Giới hạn lưu trữ của người dùng

### Ranh Giới Domain
Chỉ quản lý lưu trữ vật lý. Không biết tệp được sử dụng cho mục đích gì.

### Tương Tác Với Domains Khác
- **← User Domain**: Lưu avatar, tài liệu cá nhân
- **← Course Domain**: Lưu video, tài liệu khóa học
- **← Exercise Domain**: Lưu tài nguyên bài tập
- **→ Tất cả Domains**: Cung cấp URL để truy cập tệp

---

## Bảng Tóm Tắt Tương Tác Giữa Domains

| Domain Nguồn | Domain Đích | Loại Tương Tác |
|---|---|---|
| Auth | User | Tạo UserProfile (1:1) |
| Auth | Tất cả | Xác thực JWT |
| User | Course | Ghi danh khóa học |
| User | Exercise | Làm bài tập |
| User | Notification | Nhận thông báo |
| User | Storage | Lưu avatar, tài liệu |
| Course | User | Cập nhật learning progress |
| Course | Notification | Gửi thông báo hoàn thành |
| Course | Storage | Lưu video, tài liệu |
| Exercise | User | Cập nhật scores, achievements |
| Exercise | AI | Gửi writing/speaking để đánh giá |
| Exercise | Notification | Gửi thông báo kết quả |
| AI | Exercise | Trả kết quả đánh giá |
| AI | User | Cập nhật speaking/writing skills |
| Notification | User | Gửi thông báo (1:*) |
| Storage | User | Lưu avatar |
| Storage | Course | Lưu video, tài liệu |
| Storage | Exercise | Lưu tài nguyên |

---

## Kiến Trúc Communication

### Synchronous (HTTP/REST)
- Auth → User (tạo profile)
- User → Course (ghi danh)
- User → Exercise (làm bài)
- Exercise → AI (đánh giá writing/speaking)
- Course → Storage (upload video)

### Asynchronous (RabbitMQ/Event-driven)
- Course → Notification (lesson completed event)
- Exercise → Notification (exercise completed event)
- Exercise → User (update progress event)
- AI → Exercise (evaluation completed event)

---

## Kết Luận
Các miền chức năng được thiết kế độc lập nhưng tương tác chặt chẽ qua các điểm tích hợp rõ ràng (integration points). Mỗi domain sở hữu dữ liệu riêng và chịu trách nhiệm cho một khía cạnh cụ thể của ứng dụng.
