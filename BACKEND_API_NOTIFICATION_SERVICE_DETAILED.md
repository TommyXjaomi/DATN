# Backend API Chi Tiết - Notification Service

## 📌 Thông Tin Service

| Thông Số | Giá Trị |
|---------|--------|
| Service Name | Notification Service |
| Port | 8086 |
| Technology | Go + Gin Framework |
| Database | PostgreSQL |
| Container Name | ielts_notification_service |
| Health Check | GET /health |

---

## 🔐 Authentication

### Required Header
```
Authorization: Bearer <jwt-token>
```

### Token Source
- Từ Auth Service (Port 8081)
- Format: JWT (JSON Web Token)
- Validation: Handled by AuthMiddleware

### Note
- API Gateway sẽ forward request với user_id trong context
- Một số endpoints có requirements khác (Admin, Internal)

---

## 📡 API Endpoints

### 1️⃣ GET /api/v1/notifications
**Lấy danh sách thông báo của user hiện tại**

**Authentication**: Required (Student role)

**Query Parameters**:
```
page       (int)    - Trang hiện tại (default: 1)
limit      (int)    - Số item per page (default: 20, max: 100)
is_read    (bool)   - Lọc: true/false/null (tất cả)
type       (string) - achievement|reminder|course_update|exercise_graded|system|social
category   (string) - info|success|warning|alert
sort_by    (string) - date (mặc định)
sort_order (string) - asc|desc (mặc định: desc)
date_from  (string) - ISO 8601: YYYY-MM-DD
date_to    (string) - ISO 8601: YYYY-MM-DD
```

**Example Request**:
```bash
GET /api/v1/notifications?page=1&limit=20&is_read=false
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**Success Response (200)**:
```json
{
  "notifications": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "type": "achievement",
      "category": "success",
      "title": "Chúc mừng bạn!",
      "message": "Bạn đã hoàn thành bài tập Reading Section 1",
      "action_type": "navigate_to_exercise",
      "action_data": {
        "exercise_id": "e29b-41d4-a716-446655440000",
        "section": "reading"
      },
      "icon_url": "https://api.example.com/icons/achievement.png",
      "image_url": null,
      "is_read": false,
      "read_at": null,
      "created_at": "2025-01-28T10:30:00Z"
    },
    {
      "id": "660e8400-e29b-41d4-a716-446655440001",
      "type": "reminder",
      "category": "info",
      "title": "Nhắc nhở",
      "message": "Bạn còn 2 ngày nữa để hoàn thành khóa học IELTS Preparation",
      "action_type": "navigate_to_course",
      "action_data": {
        "course_id": "a29b-41d4-a716-446655440001"
      },
      "icon_url": null,
      "image_url": null,
      "is_read": true,
      "read_at": "2025-01-27T15:45:00Z",
      "created_at": "2025-01-26T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "total_pages": 3
  }
}
```

**Error Response (400)**:
```json
{
  "error": "invalid_request",
  "message": "Invalid page or limit parameter"
}
```

**Error Response (401)**:
```json
{
  "error": "unauthorized",
  "message": "Missing or invalid token"
}
```

**Error Response (500)**:
```json
{
  "error": "server_error",
  "message": "Failed to fetch notifications"
}
```

---

### 2️⃣ GET /api/v1/notifications/unread-count
**Lấy số lượng thông báo chưa đọc**

**Authentication**: Required (Student role)

**Example Request**:
```bash
GET /api/v1/notifications/unread-count
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**Success Response (200)**:
```json
{
  "unread_count": 5
}
```

**Error Response (401)**:
```json
{
  "error": "unauthorized",
  "message": "Missing or invalid token"
}
```

---

### 3️⃣ GET /api/v1/notifications/:id
**Lấy chi tiết một thông báo cụ thể**

**Authentication**: Required (Student role)

**Path Parameters**:
```
id (string, UUID) - Notification ID
```

**Example Request**:
```bash
GET /api/v1/notifications/550e8400-e29b-41d4-a716-446655440000
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**Success Response (200)**:
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "type": "achievement",
  "category": "success",
  "title": "Chúc mừng bạn!",
  "message": "Bạn đã hoàn thành bài tập Reading Section 1",
  "action_type": "navigate_to_exercise",
  "action_data": {
    "exercise_id": "e29b-41d4-a716-446655440000",
    "section": "reading"
  },
  "icon_url": "https://api.example.com/icons/achievement.png",
  "image_url": null,
  "is_read": false,
  "read_at": null,
  "created_at": "2025-01-28T10:30:00Z"
}
```

**Error Response (404)**:
```json
{
  "error": "not_found",
  "message": "Notification not found"
}
```

**Error Response (401)**:
```json
{
  "error": "unauthorized",
  "message": "Missing or invalid token"
}
```

---

### 4️⃣ PUT /api/v1/notifications/:id/read
**Đánh dấu thông báo là đã đọc**

**Authentication**: Required (Student role)

**Path Parameters**:
```
id (string, UUID) - Notification ID
```

**Example Request**:
```bash
PUT /api/v1/notifications/550e8400-e29b-41d4-a716-446655440000/read
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**Success Response (200)**:
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "type": "achievement",
  "category": "success",
  "title": "Chúc mừng bạn!",
  "message": "Bạn đã hoàn thành bài tập Reading Section 1",
  "action_type": "navigate_to_exercise",
  "action_data": {
    "exercise_id": "e29b-41d4-a716-446655440000"
  },
  "icon_url": "https://api.example.com/icons/achievement.png",
  "image_url": null,
  "is_read": true,
  "read_at": "2025-01-28T11:45:30Z",
  "created_at": "2025-01-28T10:30:00Z"
}
```

**Error Response (404)**:
```json
{
  "error": "not_found",
  "message": "Notification not found"
}
```

**Error Response (401)**:
```json
{
  "error": "unauthorized",
  "message": "Missing or invalid token"
}
```

---

### 5️⃣ PUT /api/v1/notifications/mark-all-read
**Đánh dấu tất cả thông báo là đã đọc**

**Authentication**: Required (Student role)

**Example Request**:
```bash
PUT /api/v1/notifications/mark-all-read
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**Success Response (200)**:
```json
{
  "marked_count": 5
}
```

**Error Response (401)**:
```json
{
  "error": "unauthorized",
  "message": "Missing or invalid token"
}
```

---

### 6️⃣ DELETE /api/v1/notifications/:id
**Xóa một thông báo**

**Authentication**: Required (Student role)

**Path Parameters**:
```
id (string, UUID) - Notification ID
```

**Example Request**:
```bash
DELETE /api/v1/notifications/550e8400-e29b-41d4-a716-446655440000
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**Success Response (204)**:
```
(No content)
```

**Error Response (404)**:
```json
{
  "error": "not_found",
  "message": "Notification not found"
}
```

**Error Response (401)**:
```json
{
  "error": "unauthorized",
  "message": "Missing or invalid token"
}
```

---

### 7️⃣ GET /api/v1/notifications/stream
**Real-time Notification Stream (Server-Sent Events)**

**Authentication**: Required (Student role)

**Features**:
- Kết nối SSE để nhận thông báo real-time
- Heartbeat mỗi 30 giây để giữ kết nối
- Auto-reconnect support

**Example Request**:
```bash
GET /api/v1/notifications/stream
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**Event Types**:

#### Notification Event
```
event: notification
data: {
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "type": "achievement",
  "category": "success",
  "title": "Chúc mừng!",
  "message": "Bài tập hoàn thành",
  "is_read": false,
  "created_at": "2025-01-28T11:45:00Z"
}
```

#### Heartbeat Event
```
event: heartbeat
data: {"timestamp": 1640234400000}
```

#### Closed Event
```
event: closed
data: {"message": "Connection closed"}
```

---

### 8️⃣ POST /api/v1/notifications/preferences
**Lấy notification preferences của user**

**Authentication**: Required (Student role)

**Example Request**:
```bash
GET /api/v1/notifications/preferences
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**Success Response (200)**:
```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "push_enabled": true,
  "push_achievements": true,
  "push_reminders": true,
  "push_course_updates": true,
  "push_exercise_graded": true,
  "email_enabled": true,
  "email_weekly_report": true,
  "email_course_updates": false,
  "email_marketing": false,
  "in_app_enabled": true,
  "quiet_hours_enabled": true,
  "quiet_hours_start": "22:00:00",
  "quiet_hours_end": "08:00:00",
  "timezone": "Asia/Ho_Chi_Minh"
}
```

---

### 9️⃣ PUT /api/v1/notifications/preferences
**Cập nhật notification preferences**

**Authentication**: Required (Student role)

**Request Body**:
```json
{
  "push_enabled": true,
  "push_achievements": true,
  "push_reminders": true,
  "push_course_updates": true,
  "push_exercise_graded": true,
  "email_enabled": true,
  "email_weekly_report": true,
  "email_course_updates": false,
  "email_marketing": false,
  "in_app_enabled": true,
  "quiet_hours_enabled": true,
  "quiet_hours_start": "22:00:00",
  "quiet_hours_end": "08:00:00",
  "timezone": "Asia/Ho_Chi_Minh"
}
```

**Success Response (200)**:
```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "push_enabled": true,
  "...": "..."
}
```

---

## 🔒 Admin Endpoints

### POST /api/v1/admin/notifications
**Tạo notification cho user (Admin only)**

**Authentication**: Required (Admin or Instructor role)

**Request Body**:
```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "type": "achievement",
  "category": "success",
  "title": "Tiêu đề",
  "message": "Nội dung chi tiết",
  "action_type": "navigate_to_course",
  "action_data": {
    "course_id": "..."
  },
  "icon_url": "https://...",
  "image_url": "https://...",
  "scheduled_for": "2025-02-01T10:00:00Z",
  "expires_at": "2025-02-28T23:59:59Z"
}
```

### POST /api/v1/admin/notifications/bulk
**Tạo notification cho nhiều users (Admin only)**

---

## 🔗 Internal Service Endpoints

### POST /api/v1/notifications/internal/send
**Gửi notification từ service khác (Internal only)**

**Header**: `X-API-Key: <internal-api-key>`

**Request Body**:
```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Bài tập được chấm",
  "message": "Bài Writing của bạn đã được chấm",
  "type": "exercise_graded",
  "category": "success",
  "action_type": "navigate_to_exercise",
  "action_data": {
    "exercise_id": "..."
  }
}
```

### POST /api/v1/notifications/internal/bulk
**Gửi notification cho nhiều users (Internal only)**

---

## 🌐 Public Endpoints

### GET /health
**Health check endpoint (No auth required)**

**Example Request**:
```bash
GET /health
```

**Success Response (200)**:
```json
{
  "status": "healthy",
  "service": "notification-service"
}
```

---

## 📊 Response Status Codes

| Code | Meaning | Example |
|------|---------|---------|
| 200 | OK | GET, PUT, POST success |
| 204 | No Content | DELETE success |
| 400 | Bad Request | Invalid parameters |
| 401 | Unauthorized | Missing/invalid token |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource doesn't exist |
| 500 | Server Error | Internal error |
| 503 | Service Unavailable | Database connection error |

---

## 🚀 Usage Examples

### cURL Examples

**Get Notifications**:
```bash
curl -X GET "http://localhost:8080/api/v1/notifications?page=1&limit=20" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..."
```

**Mark as Read**:
```bash
curl -X PUT "http://localhost:8080/api/v1/notifications/550e8400-e29b-41d4-a716-446655440000/read" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..."
```

**Delete Notification**:
```bash
curl -X DELETE "http://localhost:8080/api/v1/notifications/550e8400-e29b-41d4-a716-446655440000" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..."
```

**Get Unread Count**:
```bash
curl -X GET "http://localhost:8080/api/v1/notifications/unread-count" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..."
```

---

## 📝 Notes

1. **Pagination**: Default limit is 20, maximum 100
2. **Timestamps**: All timestamps are in ISO 8601 format (UTC)
3. **UUID Format**: Standard UUID v4 format
4. **Error Messages**: Always contain error code and message
5. **CORS**: Handled by API Gateway, no need to configure here
6. **Rate Limiting**: Check API Gateway for rate limit policies

---

## 🔗 Related Services

- **Auth Service** (Port 8081): JWT token generation and validation
- **API Gateway** (Port 8080): Request routing and authentication
- **Database**: PostgreSQL with notification_db
- **User Service** (Port 8082): User information
- **Course Service** (Port 8083): Course information
- **Exercise Service** (Port 8084): Exercise information

---

**Last Updated**: 28/12/2025
**Version**: 1.0

