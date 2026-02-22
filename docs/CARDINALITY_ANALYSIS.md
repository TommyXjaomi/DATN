## b. Xác định quan hệ số lượng giữa các thực thể

### Quan hệ từ Auth Service

- Một người dùng (AuthUser) tương ứng với một hồ sơ người dùng (UserProfile) => Quan hệ AuthUser – UserProfile là 1 – 1.
- Một người dùng (AuthUser) tương ứng với một hoặc nhiều vai trò (Role) => Quan hệ AuthUser – Role là * – 1.
- Một người dùng (AuthUser) có thể có một hoặc nhiều xác minh email (EmailVerification) => Quan hệ AuthUser – EmailVerification là 1 – *.
- Một người dùng (AuthUser) có thể có một hoặc nhiều token làm mới (RefreshToken) => Quan hệ AuthUser – RefreshToken là 1 – *.

### Quan hệ từ User Service

- Một hồ sơ người dùng (UserProfile) tương ứng với một tiến độ học tập (LearningProgress) => Quan hệ UserProfile – LearningProgress là 1 – 1.
- Một hồ sơ người dùng (UserProfile) có thể có một hoặc nhiều phiên học (StudySession) => Quan hệ UserProfile – StudySession là 1 – *.
- Một hồ sơ người dùng (UserProfile) có thể có một hoặc nhiều thành tích (UserAchievement) => Quan hệ UserProfile – UserAchievement là 1 – *.
- Một hồ sơ người dùng (UserProfile) có thể có một hoặc nhiều mục tiêu học (StudyGoal) => Quan hệ UserProfile – StudyGoal là 1 – *.
- Một hồ sơ người dùng (UserProfile) có thể có một hoặc nhiều nhắc nhở học (StudyReminder) => Quan hệ UserProfile – StudyReminder là 1 – *.
- Một hồ sơ người dùng (UserProfile) tương ứng với một chuỗi học liên tiếp (StudyStreak) => Quan hệ UserProfile – StudyStreak là 1 – 1.
- Một thành tích (Achievement) có thể được nhiều người dùng kiếm được => Quan hệ Achievement – UserAchievement là 1 – *.

### Quan hệ từ Course Service

- Một khóa học (Course) chứa một hoặc nhiều mô-đun (Module) => Quan hệ Course – Module là 1 – *.
- Một mô-đun (Module) chứa một hoặc nhiều bài học (Lesson) => Quan hệ Module – Lesson là 1 – *.
- Một bài học (Lesson) có thể có một hoặc nhiều video (LessonVideo) => Quan hệ Lesson – LessonVideo là 1 – *.
- Một bài học (Lesson) có thể có một hoặc nhiều tài liệu (LessonMaterial) => Quan hệ Lesson – LessonMaterial là 1 – *.
- Một video (LessonVideo) có thể có một hoặc nhiều bảng phiên dịch (LessonTranscript) => Quan hệ LessonVideo – LessonTranscript là 1 – *.
- Một khóa học (Course) có thể có một hoặc nhiều ghi danh (CourseEnrollment) => Quan hệ Course – CourseEnrollment là 1 – *.
- Một người dùng (UserProfile) có thể ghi danh vào một hoặc nhiều khóa học => Quan hệ UserProfile – CourseEnrollment là 1 – *.
- Một bài học (Lesson) có thể có một hoặc nhiều bản ghi tiến độ (LessonProgress) => Quan hệ Lesson – LessonProgress là 1 – *.
- Một khóa học (Course) có thể nhận được một hoặc nhiều đánh giá (CourseReview) => Quan hệ Course – CourseReview là 1 – *.
- Một người dùng (UserProfile) có thể viết một hoặc nhiều đánh giá => Quan hệ UserProfile – CourseReview là 1 – *.
- Một khóa học (Course) có thể yêu cầu một hoặc nhiều khóa học tiên quyết => Quan hệ Course – CoursePrerequisite là 1 – *.

### Quan hệ từ Exercise Service

- Một bài tập (Exercise) chứa một hoặc nhiều phần (ExerciseSection) => Quan hệ Exercise – ExerciseSection là 1 – *.
- Một phần (ExerciseSection) chứa một hoặc nhiều câu hỏi (Question) => Quan hệ ExerciseSection – Question là 1 – *.
- Một câu hỏi (Question) có thể có một hoặc nhiều lựa chọn (QuestionOption) => Quan hệ Question – QuestionOption là 1 – *.
- Một người dùng (UserProfile) có thể làm một hoặc nhiều lần thi (UserExerciseAttempt) => Quan hệ UserProfile – UserExerciseAttempt là 1 – *.
- Một lần thi (UserExerciseAttempt) tương ứng với một bài tập => Quan hệ UserExerciseAttempt – Exercise là * – 1.
- Một lần thi (UserExerciseAttempt) chứa một hoặc nhiều câu trả lời (SubmissionAnswer) => Quan hệ UserExerciseAttempt – SubmissionAnswer là 1 – *.
- Một lần thi (UserExerciseAttempt) tương ứng với một kết quả bài tập (ExerciseResult) => Quan hệ UserExerciseAttempt – ExerciseResult là 1 – 1.

### Quan hệ từ Notification Service

- Một người dùng (UserProfile) có thể nhận được một hoặc nhiều thông báo (Notification) => Quan hệ UserProfile – Notification là 1 – *.
- Một người dùng (UserProfile) có thể đăng ký một hoặc nhiều thiết bị (DeviceToken) => Quan hệ UserProfile – DeviceToken là 1 – *.
- Một người dùng (UserProfile) có thể lên lịch một hoặc nhiều thông báo (ScheduledNotification) => Quan hệ UserProfile – ScheduledNotification là 1 – *.
- Một thiết bị (DeviceToken) có thể có một hoặc nhiều bản ghi nhật ký thông báo (NotificationLog) => Quan hệ DeviceToken – NotificationLog là 1 – *.
- Một thông báo (Notification) có thể có một hoặc nhiều bản ghi nhật ký => Quan hệ Notification – NotificationLog là 1 – *.
- Một sự kiện thông báo (NotificationEvent) có thể có một hoặc nhiều mẫu (NotificationTemplate) => Quan hệ NotificationEvent – NotificationTemplate là 1 – *.
- Một sự kiện thông báo (NotificationEvent) có thể có một hoặc nhiều tùy chọn cấu hình (NotificationPreference) => Quan hệ NotificationEvent – NotificationPreference là 1 – *.

### Quan hệ từ AI Service

- Một lần thi (UserExerciseAttempt) có thể kích hoạt một hoặc nhiều yêu cầu đánh giá AI (AIEvaluationRequest) => Quan hệ UserExerciseAttempt – AIEvaluationRequest là 1 – *.
- Một yêu cầu đánh giá (AIEvaluationRequest) tương ứng với một kết quả đánh giá (AIEvaluationResult) => Quan hệ AIEvaluationRequest – AIEvaluationResult là 1 – 1.
- Một yêu cầu đánh giá (AIEvaluationRequest) tương ứng với một mô hình AI (AIModel) => Quan hệ AIEvaluationRequest – AIModel là * – 1.
- Một yêu cầu đánh giá (AIEvaluationRequest) có thể có một hoặc nhiều bản ghi nhật ký (AIEvaluationLog) => Quan hệ AIEvaluationRequest – AIEvaluationLog là 1 – *.

### Quan hệ từ Storage Service

- Một người dùng (UserProfile) tương ứng với một bộ nhớ (FileQuota) => Quan hệ UserProfile – FileQuota là 1 – 1.
- Một bộ nhớ (StorageBucket) chứa một hoặc nhiều tệp (FileObject) => Quan hệ StorageBucket – FileObject là 1 – *.
- Một tệp (FileObject) có thể có một hoặc nhiều phiên bản (FileVersion) => Quan hệ FileObject – FileVersion là 1 – *.
- Một tệp (FileObject) có thể được một hoặc nhiều người truy cập => Quan hệ FileObject – FileAccess là 1 – *.
- Một tệp (FileObject) tương ứng với một bản ghi siêu dữ liệu (FileMetadata) => Quan hệ FileObject – FileMetadata là 1 – 1.
- Một tệp (FileObject) có thể được lưu theo dõi khi xóa (DeletedFile) => Quan hệ FileObject – DeletedFile là * – 1.
- Một tệp (FileObject) sử dụng bộ nhớ của một người dùng => Quan hệ FileObject – FileQuota là * – 1.
