# 🎓 BẢN THUYẾT TRÌNH BẢO VỆ ĐỒ ÁN
## Nền Tảng Học Tập IELTS Trực Tuyến với Kiến Trúc Microservices

---

## **I. GIỚI THIỆU ĐỀ TÀI**

### **1.1 Tên Đề Tài**
**"Thiết kế và xây dựng nền tảng học tập IELTS trực tuyến với kiến trúc Microservices"**

### **1.2 Mục Tiêu Chính**
Xây dựng một hệ thống học tập IELTS hiện đại với:
- ✅ Kiến trúc Microservices giải quyết bài toán mở rộng
- ✅ Hỗ trợ 4 kỹ năng: Listening, Reading, Writing, Speaking
- ✅ Đánh giá tự động bài Writing/Speaking bằng AI
- ✅ Hệ thống thông báo thông minh
- ✅ Dashboard admin toàn diện

### **1.3 Vấn Đề Cần Giải Quyết**
| Vấn Đề | Giải Pháp |
|--------|----------|
| Hệ thống nguyên khối khó mở rộng | Kiến trúc Microservices |
| Đánh giá Writing/Speaking thủ công, tốn thời gian | AI Service tự động |
| Khó quản lý người dùng, quyền hạn phức tạp | RBAC (Role-Based Access Control) |
| Khó theo dõi tiến độ học tập | Learning Progress Tracking |
| Thông báo không kịp thời | Notification Service + Push/Email |

---

## **II. KIẾN TRÚC HỆ THỐNG**

### **2.1 Sơ Đồ Kiến Trúc Tổng Quan**

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER (Web & Mobile)              │
│         Frontend (Next.js) | Mobile App (Android/iOS)           │
└────────────────────────────┬────────────────────────────────────┘
                              │
┌─────────────────────────────▼────────────────────────────────────┐
│                        API GATEWAY                               │
│                  (Port: 8080 - Single Entry)                     │
│    JWT Authentication | Request Routing | CORS | Rate Limiting  │
└────────┬────────┬──────────┬─────────┬──────────┬──────────┬─────┘
         │        │          │         │          │          │
    ┌────▼──┐ ┌──▼───┐ ┌───▼──┐ ┌───▼──┐ ┌──────▼┐ ┌──────▼┐
    │Auth   │ │User  │ │Course│ │Exer- │ │Notifi-│ │AI     │
    │Service│ │Serv. │ │Serv. │ │cise  │ │cation │ │Service│
    │:8081  │ │:8082 │ │:8083 │ │:8084 │ │:8085  │ │:8086  │
    └────┬──┘ └──┬───┘ └───┬──┘ └───┬──┘ └──────┬┘ └──────┬┘
         │       │         │        │           │         │
    ┌────▼───────▼─────────▼────────▼───────────▼─────────▼────┐
    │              PostgreSQL (6 Databases)                     │
    │  auth_db | user_db | course_db | exercise_db |           │
    │  ai_db | notification_db                                  │
    └────────────────────────────────────────────────────────────┘
    
    ┌────────────────┬──────────────┬─────────────┐
    │ Cache (Redis)  │Queue (Queue) │Storage (S3) │
    └────────────────┴──────────────┴─────────────┘
```

### **2.2 Mô Tả Chi Tiết 7 Microservices**

#### **1️⃣ Auth Service (Port 8081)**
**Chức năng:** Xác thực và phân quyền

| Tính Năng | Chi Tiết |
|-----------|---------|
| **Đăng Ký** | Email verification, password hashing (bcrypt) |
| **Đăng Nhập** | JWT generation, refresh token, OAuth (Google) |
| **Phân Quyền** | 3 roles: Student, Instructor, Admin |
| **Bảo Mật** | Token expiry, failed login protection, account locking |
| **Entities** | AuthUser, Role, EmailVerification, RefreshToken |

**Cơ Sở Dữ Liệu:** `auth_db` (9 bảng)

**API Endpoints Chính:**
- `POST /api/v1/auth/register` - Đăng ký
- `POST /api/v1/auth/login` - Đăng nhập
- `POST /api/v1/auth/refresh` - Làm mới token
- `GET /api/v1/auth/me` - Thông tin người dùng hiện tại
- `POST /api/v1/auth/logout` - Đăng xuất

---

#### **2️⃣ User Service (Port 8082)**
**Chức năng:** Quản lý hồ sơ và tiến trình học tập

| Tính Năng | Chi Tiết |
|-----------|---------|
| **Hồ Sơ Người Dùng** | Full name, avatar, phone, location, timezone |
| **Tiến Trình Học** | 4 skills (Listening, Reading, Writing, Speaking) |
| **Phiên Học** | Study sessions tracking, duration |
| **Thành Tích** | Badges, achievements, streak counting |
| **Mục Tiêu** | Study goals, progress tracking, reminders |

**Entities Chính:**
```
UserProfile
  ├─ BasicInfo (name, email, phone)
  ├─ LocationInfo (city, country, timezone)
  └─ Metadata (created_at, updated_at)

LearningProgress
  ├─ totalStudyHours
  ├─ totalLessonsCompleted
  ├─ totalExercisesCompleted
  └─ skillProgress (listening, reading, writing, speaking)

Achievement & Badges System
  ├─ UserAchievement (unlock tracking)
  ├─ StudyStreak (consistency tracking)
  ├─ StudyGoal (goal management)
  └─ StudyReminder (reminder system)
```

**Cơ Sở Dữ Liệu:** `user_db` (10 bảng)

---

#### **3️⃣ Course Service (Port 8083)**
**Chức Năng:** Quản lý khóa học, bài học, video

| Tính Năng | Chi Tiết |
|-----------|---------|
| **Khóa Học** | Tiêu đề, cấp độ (A1-C2), giá cả, publish |
| **Module & Lesson** | Cấu trúc phân cấp, thứ tự học |
| **Video Học** | YouTube/Vimeo integration, transcripts |
| **Tài Liệu** | PDF, docs, materials download |
| **Đăng Ký** | Enrollment tracking, progress, certificates |
| **Đánh Giá** | Course reviews, ratings |

**Entities Chính:**
```
Course
  ├─ BasicInfo (title, slug, description)
  ├─ Content (skill_type, level, price)
  └─ Metadata (published, ratings)

Course → Module → Lesson
           │
        Lesson → LessonVideo
             → LessonMaterial
             → LessonTranscript

CourseEnrollment
  ├─ Progress (%)
  ├─ Status (active, completed, dropped)
  └─ Certificate (issued_date)
```

**Cơ Sở Dữ Liệu:** `course_db` (12 bảng)

---

#### **4️⃣ Exercise Service (Port 8084)**
**Chức Năng:** Quản lý bài tập và ghi điểm tự động

| Tính Năng | Chi Tiết |
|-----------|---------|
| **Bài Tập** | 4 loại (Listening, Reading, Writing, Speaking) |
| **Câu Hỏi** | Multiple choice, fill-in-blank, essay, speaking |
| **Đáp Án** | Auto-grading cho trắc nghiệm |
| **Nộp Bài** | Tracking submissions, attempt history |
| **Chấm Điểm** | Band score calculation |

**Entities Chính:**
```
Exercise
  ├─ Properties (title, type, difficulty, passing_score)
  └─ Content

Exercise → ExerciseSection → Question → QuestionOption
                                   ├─ SubmissionAnswer
                                   └─ UserExerciseAttempt

ExerciseResult
  ├─ Score
  ├─ BandScore
  └─ Passed (boolean)
```

**Cơ Sở Dữ Liệu:** `exercise_db` (11 bảng)

---

#### **5️⃣ AI Service (Port 8085)**
**Chức Năng:** Đánh giá Writing & Speaking bằng AI

| Tính Năng | Chi Tiết |
|-----------|---------|
| **Writing Evaluation** | TOEFL iBT scoring rubric (Task Achievement, Coherence & Cohesion, Lexical Range & Accuracy, Grammatical Range & Accuracy) |
| **Speaking Evaluation** | Speech-to-Text (OpenAI), pronunciation analysis |
| **Caching** | Performance optimization, reduce API calls |
| **Feedback** | Detailed feedback generation |

**Entities Chính:**
```
AIEvaluationRequest
  ├─ userId, exerciseAttemptId
  ├─ Content (text/audio)
  └─ skillType, taskType

AIEvaluationResult
  ├─ overallBandScore (0-9)
  ├─ detailedScores (fluency, accuracy, etc.)
  └─ evaluatedAt

AIEvaluationCache
  ├─ contentHash
  ├─ cachedResult
  └─ hitCount
```

**Cơ Sở Dữ Liệu:** `ai_db` (10 bảng)

**Công Nghệ:** OpenAI API, NLP, caching strategy

---

#### **6️⃣ Notification Service (Port 8086)**
**Chức Năng:** Gửi thông báo đa kênh

| Tính Năng | Chi Tiết |
|-----------|---------|
| **Kênh** | Push (mobile), Email, In-app |
| **Templates** | Dynamic templates cho các sự kiện |
| **Lịch** | Scheduled notifications, frequency control |
| **Preferences** | User-specific notification settings |
| **Delivery Tracking** | Notification logs, delivery status |

**Entities Chính:**
```
Notification
  ├─ notificationType
  ├─ title, body
  └─ channel (push/email/in-app)

NotificationEvent
  ├─ eventType (enrollment, score, achievement, etc.)
  └─ configuration

DeviceToken
  ├─ token (FCM token)
  ├─ deviceType, OS
  └─ isActive

ScheduledNotification
  ├─ frequency (daily, weekly, etc.)
  ├─ nextScheduleTime
  └─ isActive
```

**Cơ Sở Dữ Liệu:** `notification_db` (8 bảng)

---

#### **7️⃣ Storage Service (Optional)**
**Chức Năng:** Lưu trữ file, audio, video

| Tính Năng | Chi Tiết |
|-----------|---------|
| **Cloud Storage** | AWS S3 / MinIO |
| **Audio Files** | Speaking submissions |
| **Video Upload** | Course video management |
| **URL Generation** | Pre-signed URLs |

---

### **2.3 Pattern & Công Nghệ**

| Aspekt | Chi Tiết |
|--------|---------|
| **Architecture Pattern** | Microservices + API Gateway |
| **Database Pattern** | Database per Service |
| **Communication** | REST API (synchronous) + Message Queue (async) |
| **Authentication** | JWT with OAuth2 support |
| **Caching** | Redis for performance |
| **Message Queue** | RabbitMQ for async operations |

---

## **III. BIỂU ĐỒ LỚP TOÀN HỆ THỐNG (Class Diagram)**

### **3.1 Cấu Trúc Lớp Chính**

```
┌─────────────────────────────────────────────────────────┐
│                    AUTH SERVICE                         │
├─────────────────────────────────────────────────────────┤
│ AuthUser                Role              RefreshToken  │
│ • id (UUID)            • id              • id            │
│ • email                • name            • userId        │
│ • passwordHash         • description     • tokenHash      │
│ • role                                   • expiresAt      │
│ • emailVerified        EmailVerification • isRevoked      │
│ • createdAt           • id                               │
│                       • userId                           │
│                       • code                             │
│                       • isVerified                        │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                    USER SERVICE                         │
├─────────────────────────────────────────────────────────┤
│ UserProfile          LearningProgress    Achievement    │
│ • userId             • id                • id            │
│ • fullName           • userId            • code          │
│ • avatarUrl          • totalStudyHours   • name          │
│ • email              • lessonsCompleted  • points        │
│ • phone              • skillProgress     • badgeUrl      │
│ • city, country      • (4 skills)        │               │
│ • timezone           •                   │ UserAchievement
│                      StudySession        │ • id
│                      • id                │ • userId
│                      • sessionType       │ • achievementId
│                      • skillType         │ • earnedAt
│                      • duration
│                      • isCompleted
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                   COURSE SERVICE                        │
├─────────────────────────────────────────────────────────┤
│ Course              Module           Lesson             │
│ • id                • id             • id               │
│ • title             • courseId       • moduleId         │
│ • skillType         • title          • title            │
│ • level (A1-C2)     • published      • contentType      │
│ • price             • totalLessons   • duration         │
│ • description       • totalExercises • isFree           │
│ • published         │                │                  │
│ • averageRating     │ CourseEnrollment                  │
│                     │ • id           LessonVideo        │
│ CoursePrerequisite  │ • userId       • id               │
│ • courseId          │ • courseId     • lessonId         │
│ • prereq_id         │ • progress%    • videoUrl         │
│                     │ • lessonsCompleted • duration     │
│                     │ • certificateIssued │              │
│                     │                  LessonMaterial    │
│                     │                  • id              │
│ CourseReview        │                  • fileType        │
│ • userId            │                  • fileUrl         │
│ • courseId          │                  • fileSize        │
│ • rating (1-5)      │                                    │
│ • reviewText        │ LessonProgress                     │
│                     │ • userId, lessonId                │
│                     │ • status, progress%               │
│                     │ • videoWatchedSeconds             │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                  EXERCISE SERVICE                       │
├─────────────────────────────────────────────────────────┤
│ Exercise           ExerciseSection    Question          │
│ • id               • id               • id              │
│ • title            • exerciseId       • sectionId       │
│ • skillType        • title            • questionText    │
│ • difficulty       • totalQuestions   • questionType    │
│ • totalQuestions   • durationMinutes  • points          │
│ • passingScore     │                  • difficulty      │
│ • published        │ QuestionOption    │                 │
│                    │ • id              │ UserExerciseAttempt
│                    │ • questionId      │ • id             
│                    │ • optionLabel     │ • userId         
│                    │ • optionText      │ • exerciseId     
│                    │ • isCorrect       │ • attemptNumber  
│                    │                   │ • totalQuestions 
│                    │ SubmissionAnswer  │ • correctAnswers 
│                    │ • id              │ • score          
│                    │ • attemptId       │ • bandScore      
│                    │ • questionId      │ • status         
│                    │ • answerText      │                  
│                    │ • isCorrect       │ ExerciseResult   
│                    │ • pointsEarned    │ • id             
│                    │                   │ • finalScore     
│                    │                   │ • bandScore      
│                    │                   │ • passed (bool)  
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                  AI SERVICE                             │
├─────────────────────────────────────────────────────────┤
│ AIEvaluationRequest     AIEvaluationResult               │
│ • id                    • id                            │
│ • userId                • requestId                     │
│ • exerciseAttemptId     • overallBandScore              │
│ • questionId            • fluencyScore                  │
│ • skillType             • accuracyScore                 │
│ • taskType              • detailedScores (map)          │
│ • content               • evaluatedAt                   │
│ • createdAt             │                               │
│                         │ AIEvaluationCache             │
│                         │ • contentHash                 │
│                         │ • skillType                   │
│                         │ • overallBandScore            │
│                         │ • hitCount                    │
│                         │ • createdAt                   │
│                         │                               │
│ AIModel                 AIEvaluationLog                 │
│ • id                    • id                            │
│ • name (GPT-4, etc.)    • requestId                     │
│ • version               • taskType                      │
│ • provider (OpenAI)     • cacheHit                      │
│ • isActive              • processingTimeMs              │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│               NOTIFICATION SERVICE                      │
├─────────────────────────────────────────────────────────┤
│ Notification        DeviceToken         NotificationEvent
│ • id                • id                • id             
│ • userId            • userId            • eventType      
│ • title             • token (FCM)       • description    
│ • body              • deviceType        • isActive       
│ • channel           • deviceOs          │                
│ • isRead            • isActive          │ NotificationTemplate
│ • sentAt            • createdAt         │ • id             
│ • readAt            │                   │ • name           
│                     │ ScheduledNotif.   │ • eventType      
│ NotificationPreference • id              │ • titleTemplate  
│ • userId            │ • userId          │ • bodyTemplate   
│ • eventId           │ • title           │                  
│ • emailEnabled      │ • frequency       │ NotificationLog  
│ • pushEnabled       │ • nextScheduleTime │ • id             
│                     │ • isActive         │ • notifId        
│                     │                    │ • deviceTokenId  
│                     │                    │ • channel        
│                     │                    │ • status         
│                     │                    │ • sentAt         
└─────────────────────────────────────────────────────────┘
```

### **3.2 Các Mối Quan Hệ Chính**

```
User (AuthService) ◄────────────────────────────► UserProfile (UserService)
     │                                                    │
     ├──────────► LearningProgress                       │
     │                                                    │
     └──────────► CourseEnrollment ◄──────────────────── Course (CourseService)
                       │                                       │
                       ├──────────► Lesson                    ├── Module
                       │                 │                    │
                       │                 ├── LessonVideo      └── Prerequisite
                       │                 │
                       └──────────► UserExerciseAttempt ◄──── Exercise (ExerciseService)
                                         │
                                         ├──────────────────► AIEvaluationRequest
                                         │                         │
                                         └──────────────────► AIEvaluationResult
                                                                  (AIService)

User ◄────────────────────────────► Notification (NotificationService)
     ├── DeviceToken
     ├── NotificationPreference
     └── ScheduledNotification
```

---

## **IV. LUỒNG DỮ LIỆU & QUY TRÌNH (Data Flows & Workflows)**

### **4.1 Quy Trình Đăng Nhập (Login Flow)**

```
┌─────────┐     1. Nhập email/password
│  User   │─────────────────────────────┐
└─────────┘                              │
                                        ▼
                          ┌──────────────────────┐
                          │  Frontend (Next.js)  │
                          │  Android/iOS         │
                          └──────────┬───────────┘
                                     │
                          2. POST /api/v1/auth/login
                          (email, password)
                                     │
                                    ▼
                          ┌──────────────────────┐
                          │   API Gateway        │
                          │   (Port 8080)        │
                          └──────────┬───────────┘
                                     │
                          3. Forward to Auth Service
                                     │
                                    ▼
                          ┌──────────────────────┐
                          │  Auth Service        │
                          │  (Port 8081)         │
                          └──────────┬───────────┘
                                     │
              ┌──────────────────────┼──────────────────────┐
              │                      │                      │
         4. Validate        5. Hash password      6. Check DB
         Email Format       Compare with stored
              │                      │
              └──────────────────────┼──────────────────────┘
                                     │
                        ┌────────────────────────┐
                        │  ✓ Valid: Generate JWT │
                        │  ✗ Invalid: Error      │
                        └────────────┬───────────┘
                                     │
                        7. Create JWT token
                        (userId, email, role,
                         expiresAt: 1 hour)
                                     │
                        8. Create Refresh Token
                        (expiresAt: 7 days)
                                     │
                                    ▼
                          ┌──────────────────────┐
                          │  Return Response     │
                          │  {                   │
                          │    token: "jwt...",  │
                          │    refreshToken: "...",
                          │    user: {           │
                          │      id,email,role   │
                          │    }                 │
                          │  }                   │
                          └──────────┬───────────┘
                                     │
                                    ▼
                          ┌──────────────────────┐
                          │  Frontend           │
                          │  Store Token        │
                          │  (SharedPreferences │
                          │   or localStorage)  │
                          └──────────┬───────────┘
                                     │
                                    ▼
                          ┌──────────────────────┐
                          │  🎉 Logged In!       │
                          │  Navigate to Home    │
                          └──────────────────────┘
```

### **4.2 Quy Trình Đăng Ký Khóa Học (Course Enrollment)**

```
┌─────────┐
│  User   │  Click "Enroll"
└────┬────┘
     │
     ▼
┌──────────────────────┐
│  Check if free/paid  │
└──────────┬───────────┘
           │
    ┌──────┴──────┐
    │             │
    ▼ Free        ▼ Paid
┌─────────┐  ┌──────────────┐
│ Skip    │  │ Payment      │
│ Payment │  │ Processing   │
└────┬────┘  │ (Stripe/     │
     │       │  VNPay)      │
     │       └──────┬───────┘
     │              │
     └──────┬───────┘
            │
            ▼
┌──────────────────────────┐
│ Create CourseEnrollment  │
│ record in course_db      │
└──────────┬───────────────┘
           │
           ▼
┌──────────────────────────┐
│ Send welcome             │
│ notification             │
└──────────┬───────────────┘
           │
           ▼
┌──────────────────────────┐
│ Update user progress     │
│ in user_db               │
└──────────┬───────────────┘
           │
           ▼
┌──────────────────────────┐
│ 🎉 Ready to start!       │
│ Access first lesson      │
└──────────────────────────┘
```

### **4.3 Quy Trình Nộp & Chấm Bài Writing (Writing Submission & Scoring)**

```
┌──────────────────────────────────────────────────────────────┐
│ 1. User làm bài Writing tập trung vào Task Achievement        │
└────────────────────┬─────────────────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────┐
        │ Submit essay (text)        │
        │ POST /exercises/:id/submit │
        └────────────┬───────────────┘
                     │
                     ▼ API Gateway routes to Exercise Service
        ┌────────────────────────────┐
        │ 2. Exercise Service:       │
        │ • Save to exercise_db      │
        │ • Create attempt record    │
        │ • Status: "submitted"      │
        └────────────┬───────────────┘
                     │
                     ▼ Call AI Service for evaluation
        ┌────────────────────────────────────────────┐
        │ 3. AI Service:                             │
        │ • Receive text                             │
        │ • Check cache (contentHash)                │
        │ • If cache hit: return cached result (fast)│
        │ • If miss: call OpenAI API                 │
        │   - Evaluate fluency (0-9)                 │
        │   - Evaluate accuracy (0-9)                │
        │   - Evaluate coherence (0-9)               │
        │   - Evaluate vocabulary (0-9)              │
        │   - Calculate band score                   │
        │ • Save to cache                            │
        │ • Return AIEvaluationResult                │
        └────────────┬───────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────────────┐
        │ 4. Exercise Service:                       │
        │ • Save AIEvaluationResult                  │
        │ • Update attempt status: "completed"       │
        │ • Create ExerciseResult                    │
        │ • Calculate overall band score             │
        └────────────┬───────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────────────┐
        │ 5. Notification Service:                   │
        │ • Send push: "Your essay scored X.0"       │
        │ • Send email: "Score details"              │
        └────────────┬───────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────────────┐
        │ 6. User Service:                           │
        │ • Update LearningProgress                  │
        │ • Update writing skill progress            │
        │ • Check achievements:                      │
        │   - 10 essays submitted?                   │
        │   - Score ≥ 7.0?                          │
        │   - Unlock badges                         │
        └────────────┬───────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────────────┐
        │ 7. Frontend Display:                       │
        │ • Show detailed feedback                   │
        │ • Score breakdown                         │
        │ • Recommendations                         │
        │ • Progress update                         │
        └────────────────────────────────────────────┘
```

### **4.4 Quy Trình Thông Báo Thông Minh (Smart Notification)**

```
┌─────────────────────────────────────────────────────────────┐
│ Trigger Events (từ các services)                            │
├──────────────────────────────┬──────────────────────────────┤
│ • User enrolls in course     │ • User unlocks achievement   │
│ • Score >7.0                 │ • Study streak reached       │
│ • Weekly reminder time       │ • Goal deadline approaching  │
└──────────────────────────────┴──────────────────────────────┘
                      │
                      ▼
        ┌────────────────────────────────────┐
        │ Notification Service receives      │
        │ event from Message Queue (RabbitMQ)│
        └────────────┬───────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────┐
        │ Look up NotificationTemplate       │
        │ by eventType                       │
        │ (e.g., "score_achievement")        │
        │ Template contains:                 │
        │ • titleTemplate                    │
        │ • bodyTemplate                     │
        │ • channels (push/email/in-app)     │
        └────────────┬───────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────┐
        │ Check user preferences             │
        │ (emailEnabled, pushEnabled)        │
        │ by userId + eventId                │
        └────────────┬───────────────────────┘
                     │
        ┌────────────┴──────────────────────┐
        │                                   │
        ▼ Push enabled              ▼ Email enabled
┌──────────────────────┐     ┌──────────────────────┐
│ 1. Get DeviceToken   │     │ 1. Get email address │
│ 2. Compose message   │     │ 2. Render email      │
│ 3. Send via FCM      │     │ 3. Send via SMTP     │
│ 4. Log delivery      │     │ 4. Log delivery      │
│ 5. Update status     │     │ 5. Update status     │
└──────────┬───────────┘     └──────────┬───────────┘
           │                             │
           └──────────────┬──────────────┘
                          │
                          ▼
                ┌──────────────────────────┐
                │ Create Notification      │
                │ record in notification_db│
                │ status: "delivered"      │
                └──────────┬───────────────┘
                           │
                           ▼
                ┌──────────────────────────┐
                │ 🔔 User receives         │
                │ notification on mobile   │
                │ or email                 │
                └──────────────────────────┘
```

---

## **V. CÔNG NGHỆ & STACK**

### **5.1 Backend Stack**

| Layer | Công Nghệ | Lý Do |
|-------|-----------|-------|
| **Language** | Go 1.21+ | Hiệu suất cao, concurrency tốt, compile nhanh |
| **Web Framework** | Gin | Lightweight, fast, perfect for microservices |
| **Database** | PostgreSQL 15 | ACID compliance, rich features, free |
| **Cache** | Redis | In-memory caching, fast operations |
| **Queue** | RabbitMQ | Async operations, message reliability |
| **ORM** | sql/database | Direct SQL control, flexibility |
| **Authentication** | JWT + OAuth2 | Stateless, scalable, industry standard |
| **API Documentation** | Swagger/OpenAPI | Auto-generated, interactive testing |
| **Containerization** | Docker & Docker Compose | Easy deployment, consistency |
| **External AI** | OpenAI API (GPT-4) | SOTA for NLP tasks |

### **5.2 Frontend Stack**

| Layer | Công Nghệ | Lý Do |
|-------|-----------|-------|
| **Framework** | Next.js 14 | Server-side rendering, routing, optimization |
| **Language** | TypeScript | Type safety, better DX |
| **Styling** | TailwindCSS | Utility-first, responsive design |
| **State** | React Context + Custom Hooks | Lightweight, no extra dependencies |
| **HTTP Client** | Axios | Promise-based, interceptor support |
| **UI Components** | shadcn/ui | Headless, customizable, accessible |
| **Mobile** | Android (Java/Kotlin) | Native experience, full access |
| **Mobile HTTP** | Retrofit 2 + OkHttp3 | Best-in-class for Android |
| **Mobile UI** | Material Design | Familiar, polished, responsive |

### **5.3 DevOps & Infrastructure**

| Layer | Công Nghệ | Lý Do |
|-------|-----------|-------|
| **Containerization** | Docker | Consistency across environments |
| **Orchestration** | Docker Compose | Development & small-scale deployment |
| **Monitoring** | ELK Stack (optional) | Log aggregation & analysis |
| **CI/CD** | GitHub Actions (optional) | Automated testing & deployment |
| **Storage** | MinIO / AWS S3 | File storage for audio/video |

---

## **VI. CÁC TÍNH NĂNG CHÍNH**

### **6.1 Cho Học Viên (Students)**

✅ **Khám Phá & Học Tập**
- Duyệt khóa học theo cấp độ (A1-C2)
- Học theo module cấu trúc
- Video bài giảng với transcript
- Tài liệu bổ sung (PDF, docs)
- Theo dõi tiến độ %

✅ **Thực Hành**
- Làm bài tập 4 kỹ năng
- Trắc nghiệm tự động chấm
- Writing/Speaking tự động đánh giá bằng AI
- Xem chi tiết feedback
- Lịch sử nộp bài

✅ **Theo Dõi Tiến Độ**
- Dashboard học tập
- Biểu đồ tiến trình 4 kỹ năng
- Thành tích & Badges
- Study streaks
- Learning goals

✅ **Thông Báo & Nhắc Nhở**
- Thông báo thành tích
- Nhắc nhở học tập
- Cập nhật điểm số
- Gợi ý tiếp theo

✅ **Cộng Đồng**
- Đánh giá khóa học
- Xem review người khác
- Bảng xếp hạng

### **6.2 Cho Giảng Viên (Instructors)**

✅ **Tạo & Quản Lý Khóa Học**
- Tạo khóa học mới
- Tổ chức modules & lessons
- Upload video bài giảng
- Quản lý tài liệu
- Publish/unpublish

✅ **Quản Lý Bài Tập**
- Tạo ngân hàng câu hỏi
- Thiết lập bài tập
- Xem submission
- Chấm điểm (nếu essay)
- Cho feedback

✅ **Theo Dõi Học Viên**
- Xem danh sách học viên
- Tracking tiến độ từng người
- Thống kê lớp
- Gửi announcement

✅ **Thống Kê & Báo Cáo**
- Số lượng học viên
- Completion rate
- Average scores
- Engagement metrics

### **6.3 Cho Quản Trị (Admins)**

✅ **Quản Lý Người Dùng**
- CRUD users
- Assign roles
- Lock/unlock accounts
- View user activity
- Export data

✅ **Quản Lý Nội Dung**
- Review courses
- Moderate submissions
- Quality assurance
- Content library management

✅ **Hệ Thống & Cấu Hình**
- System health monitoring
- Service status
- Error logs & debugging
- System settings
- Notification templates

✅ **Thống Kê & Báo Cáo**
- Tổng số users
- Active users (DAU/MAU)
- Courses & submissions
- Revenue (nếu có payment)
- System performance

---

## **VII. CÁC THÁCH THỨC & GIẢI PHÁP**

| Thách Thức | Giải Pháp |
|-----------|----------|
| **Scalability** | Microservices architecture cho phép scale từng service độc lập |
| **Data Consistency** | Database per service + eventual consistency pattern |
| **Network Latency** | API Gateway caching + Redis cache |
| **Real-time Updates** | WebSocket cho notifications + SSE |
| **AI Cost** | Content hashing + caching để giảm API calls |
| **Security** | JWT + RBAC + input validation |
| **Performance** | Indexing, caching, async processing |
| **Deployment** | Docker Compose for local, Kubernetes for production |

---

## **VIII. KẾT QUẢN**

### **8.1 Những Đạt Được**

✅ **Kiến Trúc Vững Chắc**
- Microservices pattern cho phép mở rộng
- Clear separation of concerns
- Độc lập deploy từng service

✅ **Tính Năng Toàn Diện**
- Hỗ trợ 4 kỹ năng IELTS
- AI-powered evaluation
- Comprehensive tracking & analytics

✅ **Trải Nghiệm Người Dùng**
- Responsive UI (web + mobile)
- Real-time notifications
- Personalized feedback

✅ **Dễ Bảo Trì & Mở Rộng**
- Clear API documentation
- Well-organized codebase
- Easy to add new services

### **8.2 Hướng Phát Triển Tương Lai**

🚀 **Phase 2**
- Payment integration (Stripe, VNPay)
- Live class support (video conferencing)
- Advanced analytics & ML-based recommendations
- Mobile app optimization

🚀 **Phase 3**
- Kubernetes deployment
- Global CDN for media
- Micro-learning (spaced repetition)
- Gamification features
- AI-powered course recommendation

🚀 **Phase 4**
- Blockchain for certificates
- Integration with IELTS official
- Multi-language support
- Enterprise features

---

## **IX. THAM KHẢO & TÀI LIỆU**

### **Tài Liệu Dự Án**
- `docs/class-system-design.puml` - Biểu đồ lớp toàn hệ thống
- `docs/architecture-system-communication.puml` - Sơ đồ kiến trúc
- `docs/sequence-*.puml` - Biểu đồ tuần tự cho các flows
- `database/schema-*.sql` - Cơ sở dữ liệu cho từng service
- API Gateway README - Tài liệu API Gateway

### **Công Nghệ Tham Khảo**
- Gin Framework Documentation
- PostgreSQL Best Practices
- Redis Caching Strategies
- OpenAI API Documentation
- Next.js Official Documentation
- Android Development Guide

### **Các Thực Hành Tốt Nhất**
- Clean Code principles
- SOLID principles
- API Documentation (OpenAPI/Swagger)
- Test-Driven Development
- Continuous Integration/Deployment

---

## **X. CẢM ƠN & KẾT THÚC**

**Cảm ơn quý thầy cô và các bạn đã lắng nghe!**

Dự án này đã:
- 📚 Nghiên cứu sâu về kiến trúc microservices
- 🏗️ Thiết kế hệ thống có độ mở rộng cao
- 💻 Triển khai 7 microservices
- 🤖 Tích hợp AI cho đánh giá tự động
- 📱 Xây dựng frontend web & mobile
- 🚀 Chuẩn bị cho production deployment

**Các câu hỏi?** 🤔

---

## **PHỤ LỤC: Biểu Đồ Tóm Tắt**

### **A. Quick Deployment Diagram**

```
┌─────────────────────────────────────────────────┐
│        docker-compose up -d                     │
└──────────────┬──────────────────────────────────┘
               │
    ┌──────────┼──────────┐
    │          │          │
    ▼          ▼          ▼
┌────────┐ ┌────────┐ ┌────────┐
│ Backend│ │Database│ │ Redis  │
│Services│ │ Postgres│ │Cache   │
└────────┘ └────────┘ └────────┘

Access:
- Frontend: http://localhost:3000
- API: http://localhost:8080
- PgAdmin: http://localhost:5050
```

### **B. Permission Matrix**

| Action | Student | Instructor | Admin |
|--------|---------|------------|-------|
| Enroll Course | ✅ | ✅ | ✅ |
| Submit Exercise | ✅ | ✅ | ✅ |
| Create Course | ❌ | ✅ | ✅ |
| View Analytics | ✅ (own) | ✅ (class) | ✅ (all) |
| Manage Users | ❌ | ❌ | ✅ |
| System Settings | ❌ | ❌ | ✅ |
| Send Notification | ❌ | ❌ | ✅ |
| View Logs | ❌ | ❌ | ✅ |

---

**Cám ơn bạn! 🙏**

