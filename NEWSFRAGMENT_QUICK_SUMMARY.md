# Tóm Tắt Nhanh - NewsFragment & Notification Service

## 📌 Overview

| Thành Phần | Chi Tiết |
|-----------|---------|
| **Frontend** | NewsFragment (Android) |
| **Backend** | Notification Service (Go, Port 8086) |
| **API Gateway** | Port 8080 (proxy requests) |
| **Database** | PostgreSQL (notification_db) |

---

## 🔌 API Endpoints Chính

### 1. Danh Sách Thông Báo
```
GET /api/v1/notifications?page=1&limit=20
Response: { notifications: [], pagination: { ... } }
```

### 2. Số Lượng Chưa Đọc
```
GET /api/v1/notifications/unread-count
Response: { unread_count: 5 }
```

### 3. Đánh Dấu Đã Đọc
```
PUT /api/v1/notifications/:id/read
```

### 4. Xóa Thông Báo
```
DELETE /api/v1/notifications/:id
```

### 5. Real-time Stream (Optional)
```
GET /api/v1/notifications/stream (SSE)
```

---

## 📦 Notification Data Model

```json
{
  "id": "uuid",
  "type": "achievement|reminder|course_update|exercise_graded|system|social",
  "category": "info|success|warning|alert",
  "title": "Tiêu đề",
  "message": "Nội dung chi tiết",
  "action_type": "navigate_to_course|navigate_to_exercise|external_link",
  "action_data": { "course_id": "...", "..." : "..." },
  "icon_url": "https://...",
  "image_url": "https://...",
  "is_read": false,
  "created_at": "2025-01-01T10:00:00Z"
}
```

---

## 🎯 Frontend Implementation Steps

### Phase 1: Models (20 mins)
- [ ] Notification.java
- [ ] NotificationResponse.java
- [ ] UnreadCountResponse.java

### Phase 2: Network (30 mins)
- [ ] NotificationApiService.java
- [ ] Update ApiClient.java

### Phase 3: UI (60 mins)
- [ ] fragment_news.xml
- [ ] item_notification.xml
- [ ] NotificationAdapter.java

### Phase 4: Fragment Logic (90 mins)
- [ ] NewsFragment.java
- [ ] Load, pagination, delete, mark read
- [ ] Error handling

### Phase 5: Polish (30 mins)
- [ ] Add strings
- [ ] Add drawables
- [ ] Error handling
- [ ] Loading states

---

## 🔐 Authentication

**Header**: `Authorization: Bearer <jwt-token>`

Token được tự động thêm vào bởi `AuthInterceptor` trong `ApiClient`

---

## ⚙️ Configuration

### Base URL Setup
```java
private static final String NOTIFICATION_SERVICE_URL = "http://" + baseIp + ":8086/api/v1/";

public static NotificationApiService getNotificationService() {
    return getClient(NOTIFICATION_SERVICE_URL).create(NotificationApiService.class);
}
```

### API Gateway Routes
```go
notificationGroup := v1.Group("/notifications")
notificationGroup.Use(authMiddleware.Authenticate())
{
    // GET, PUT, DELETE endpoints
}
```

---

## 📊 Database Tables

### notifications
```sql
- id (UUID)
- user_id (UUID)
- type (VARCHAR) - achievement, reminder, course_update, etc.
- category (VARCHAR) - info, success, warning, alert
- title (VARCHAR)
- message (TEXT)
- action_data (JSONB)
- is_read (BOOLEAN)
- created_at (TIMESTAMP)
- ...
```

---

## 🚀 Deployment

### Backend Running
```bash
# Notification Service
Port: 8086
Docker: ielts_notification_service
```

### Frontend Usage
```
1. Get token from Auth Service
2. Add to AuthInterceptor
3. Call NotificationApiService
4. Parse responses in NewsFragment
```

---

## 🔍 Key Files

### Backend
```
services/notification-service/
├── cmd/main.go
├── internal/
│   ├── handlers/notification_handler.go
│   ├── service/notification_service.go
│   ├── models/dto.go
│   ├── models/models.go
│   ├── routes/routes.go
│   └── repository/notification_repository.go
```

### Frontend
```
ieltsapp/app/src/main/java/com/example/ieltsapp/
├── model/
│   ├── Notification.java
│   ├── NotificationResponse.java
│   └── UnreadCountResponse.java
├── network/
│   ├── ApiClient.java
│   └── NotificationApiService.java
├── Adapter/
│   └── NotificationAdapter.java
└── ui/menu/
    └── NewsFragment.java

ieltsapp/app/src/main/res/
├── layout/
│   ├── fragment_news.xml
│   └── item_notification.xml
└── values/
    └── strings.xml
```

---

## 💡 Tips & Best Practices

1. **Pagination**: Sử dụng `page` & `limit` parameters cho infinite scroll
2. **Error Handling**: Always show user-friendly error messages
3. **Loading States**: Show loading indicator khi fetching data
4. **Empty States**: Display meaningful empty state message
5. **Timestamps**: Convert ISO 8601 to relative time (e.g., "1 hour ago")
6. **Icons**: Use appropriate icons dựa trên notification type
7. **Mark as Read**: Auto-mark khi user click notification
8. **Real-time**: (Optional) Sử dụng SSE stream cho live updates

---

## 🐛 Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| 401 Unauthorized | Kiểm tra JWT token, ensure AuthInterceptor đang work |
| 404 Not Found | Verify API Gateway routing |
| Connection Timeout | Check network, firewall, service port |
| JSON Parse Error | Verify response format matches model |
| Empty List | Check database, pagination settings |

---

## 📞 Support

### API Documentation
- See: [NOTIFICATION_REQUIREMENTS_FOR_NEWSFRAGMENT.md](NOTIFICATION_REQUIREMENTS_FOR_NEWSFRAGMENT.md)

### Implementation Guide
- See: [IMPLEMENTATION_GUIDE_NEWSFRAGMENT_NOTIFICATIONS.md](IMPLEMENTATION_GUIDE_NEWSFRAGMENT_NOTIFICATIONS.md)

### Backend API
- Notification Service: `services/notification-service/`
- API Gateway: `api-gateway/internal/routes/routes.go`

---

**Last Updated**: 28/12/2025
**Version**: 1.0

