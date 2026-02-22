# Frontend-Backend Integration Mapping - Notification Service

## 📋 Overview

Tài liệu này mô tả cách Frontend (Android) kết nối với Backend (Notification Service) để hiển thị thông báo trong NewsFragment.

---

## 🔀 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    NewsFragment (Android)                        │
│  - Hiển thị danh sách thông báo                                  │
│  - Handle user interactions                                      │
│  - Show loading/error/empty states                               │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
        ┌────────────────────────────────────┐
        │    NotificationApiService          │
        │  - Define API endpoints            │
        │  - Handle HTTP calls               │
        └────────────┬───────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────┐
        │       ApiClient (Retrofit)         │
        │  - Configure base URL              │
        │  - Handle authentication           │
        │  - Manage HTTP client              │
        └────────────┬───────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────────┐
        │    AuthInterceptor (OkHttp)        │
        │  - Add JWT token to header         │
        │  - Handle token refresh            │
        └────────────┬───────────────────────┘
                     │
        ┌────────────┴───────────────────┐
        │                                 │
        ▼                                 ▼
   ┌─────────────┐             ┌──────────────────┐
   │  API Gateway│             │  Auth Service    │
   │  (Port 8080)│             │  (Port 8081)     │
   └─────┬───────┘             └──────────────────┘
         │
         ▼
┌──────────────────────────────┐
│  Notification Service        │
│  (Port 8086)                 │
│  - Handle API requests       │
│  - Query database            │
│  - Return notifications      │
└──────────────────────────────┘
         │
         ▼
    ┌─────────────┐
    │ PostgreSQL  │
    │ (DB)        │
    └─────────────┘
```

---

## 📱 Frontend Components

### 1. NewsFragment
**File**: `ieltsapp/app/src/main/java/com/example/ieltsapp/ui/menu/NewsFragment.java`

**Responsibilities**:
- Khởi tạo RecyclerView để hiển thị danh sách
- Gọi API để lấy thông báo
- Xử lý user interactions (click, delete)
- Hiển thị loading/error/empty states
- Quản lý pagination

**API Calls**:
```java
// 1. Load notifications (initial)
apiService.getNotifications(page, limit)

// 2. Load more notifications (pagination)
apiService.getNotifications(page++, limit)

// 3. Get unread count
apiService.getUnreadCount()

// 4. Mark as read
apiService.markAsRead(notificationId)

// 5. Delete notification
apiService.deleteNotification(notificationId)
```

### 2. NotificationAdapter
**File**: `ieltsapp/app/src/main/java/com/example/ieltsapp/Adapter/NotificationAdapter.java`

**Responsibilities**:
- Bind notification data to RecyclerView items
- Handle item clicks and deletes
- Format timestamps
- Set notification icons
- Load images via Glide

**Data from Backend**:
```json
{
  "id": "...",
  "title": "...",
  "message": "...",
  "created_at": "2025-01-28T10:30:00Z",
  "is_read": false,
  "type": "achievement",
  "icon_url": "...",
  "image_url": "..."
}
```

### 3. Models
**Files**: 
- `Notification.java`
- `NotificationResponse.java`
- `UnreadCountResponse.java`

**Purpose**: 
- Deserialize JSON responses from backend
- Store notification data
- Provide getters/setters

**Serialization/Deserialization**:
```java
// Backend JSON
{
  "notifications": [...],
  "pagination": {...}
}

// Frontend Object
NotificationResponse {
  List<Notification> notifications
  PaginationInfo pagination
}
```

---

## 🔗 Network Layer

### NotificationApiService Interface
**File**: `ieltsapp/app/src/main/java/com/example/ieltsapp/network/NotificationApiService.java`

**Endpoint Mapping**:

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/notifications` | Danh sách thông báo |
| GET | `/notifications/unread-count` | Số chưa đọc |
| GET | `/notifications/{id}` | Chi tiết thông báo |
| PUT | `/notifications/{id}/read` | Đánh dấu đã đọc |
| PUT | `/notifications/mark-all-read` | Đánh dấu tất cả đã đọc |
| DELETE | `/notifications/{id}` | Xóa thông báo |
| GET | `/notifications/stream` | Real-time stream (SSE) |

### ApiClient Configuration
**File**: `ieltsapp/app/src/main/java/com/example/ieltsapp/network/ApiClient.java`

**Base URL Setup**:
```java
// Configuration
private static final String baseIp = BuildConfig.API_BASE_IP;
private static final String NOTIFICATION_SERVICE_URL = 
    "http://" + baseIp + ":8086/api/v1/";

// Getter method
public static NotificationApiService getNotificationService() {
    return getClient(NOTIFICATION_SERVICE_URL)
        .create(NotificationApiService.class);
}
```

### AuthInterceptor
**File**: `ieltsapp/app/src/main/java/com/example/ieltsapp/network/AuthInterceptor.java`

**Responsibilities**:
- Lấy JWT token từ SharedPreferences
- Thêm token vào Authorization header
- Handle token refresh (if needed)
- Forward user_id nếu cần thiết

**Header Addition**:
```java
// Before API call
request.newBuilder()
    .addHeader("Authorization", "Bearer " + token)
    .build()

// Header sent to backend
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

---

## 🔐 Authentication Flow

```
1. User logs in (Auth Service)
   └─ Get JWT token
   
2. Token stored in SharedPreferences
   └─ Via AuthService or LoginActivity
   
3. NewsFragment calls API
   └─ NotificationApiService.getNotifications()
   
4. Retrofit prepares request
   └─ AuthInterceptor intercepts
   
5. AuthInterceptor adds token
   └─ Authorization: Bearer <token>
   
6. Request sent to API Gateway
   └─ API Gateway forwards to Notification Service
   
7. Notification Service validates token
   └─ AuthMiddleware.Authenticate()
   
8. If valid: Process request
   └─ Return notifications
   
9. If invalid: Return 401
   └─ Handle in NewsFragment
```

---

## 📊 Data Model Mapping

### Backend Model (Go)
```go
// services/notification-service/internal/models/dto.go

type NotificationResponse struct {
    ID         uuid.UUID              `json:"id"`
    Type       string                 `json:"type"`
    Category   string                 `json:"category"`
    Title      string                 `json:"title"`
    Message    string                 `json:"message"`
    ActionType *string                `json:"action_type,omitempty"`
    ActionData map[string]interface{} `json:"action_data,omitempty"`
    IconURL    *string                `json:"icon_url,omitempty"`
    ImageURL   *string                `json:"image_url,omitempty"`
    IsRead     bool                   `json:"is_read"`
    ReadAt     *string                `json:"read_at,omitempty"`
    CreatedAt  string                 `json:"created_at"`
}
```

### Frontend Model (Java)
```java
// ieltsapp/app/src/main/java/com/example/ieltsapp/model/Notification.java

public class Notification {
    @SerializedName("id")
    private String id;
    
    @SerializedName("type")
    private String type;
    
    @SerializedName("category")
    private String category;
    
    @SerializedName("title")
    private String title;
    
    @SerializedName("message")
    private String message;
    
    @SerializedName("action_type")
    private String actionType;
    
    @SerializedName("action_data")
    private Map<String, Object> actionData;
    
    @SerializedName("icon_url")
    private String iconUrl;
    
    @SerializedName("image_url")
    private String imageUrl;
    
    @SerializedName("is_read")
    private boolean isRead;
    
    @SerializedName("read_at")
    private String readAt;
    
    @SerializedName("created_at")
    private String createdAt;
    
    // Getters & Setters
}
```

### JSON Serialization
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "type": "achievement",
  "category": "success",
  "title": "Chúc mừng!",
  "message": "Bạn hoàn thành bài tập",
  "action_type": "navigate_to_exercise",
  "action_data": {
    "exercise_id": "...",
    "section": "reading"
  },
  "icon_url": "https://...",
  "image_url": null,
  "is_read": false,
  "read_at": null,
  "created_at": "2025-01-28T10:30:00Z"
}
```

---

## 🔄 API Call Workflows

### 1️⃣ Initial Load Workflow

```
NewsFragment.onViewCreated()
    ├─ initializeUI()
    ├─ setupRecyclerView()
    ├─ setupSwipeRefresh()
    └─ loadNotifications()
          │
          ├─ Show loading indicator
          ├─ Call apiService.getNotifications(page=1, limit=20)
          │   │
          │   ├─ AuthInterceptor adds Authorization header
          │   ├─ Retrofit converts to HTTP request
          │   ├─ OkHttp sends request to API Gateway (8080)
          │   ├─ API Gateway routes to Notification Service (8086)
          │   ├─ Notification Service validates token
          │   └─ Notification Service queries database
          │
          └─ onResponse(response)
                ├─ Parse NotificationResponse
                ├─ Update notifications list
                ├─ notificationAdapter.addAll(notifications)
                ├─ Update pagination info
                └─ Show notification list
```

### 2️⃣ Pagination Workflow

```
User scrolls near end of list
    │
    ├─ RecyclerView.OnScrollListener.onScrolled()
    │   └─ Check if lastVisiblePosition >= totalItems - 5
    │
    ├─ loadMoreNotifications()
    │   ├─ currentPage++
    │   ├─ Call apiService.getNotifications(page=2, limit=20)
    │   └─ onResponse()
    │       ├─ Get new notifications
    │       ├─ notificationAdapter.notifyItemRangeInserted()
    │       └─ Update pagination info
    │
    └─ Repeat for page 3, 4, etc.
```

### 3️⃣ Mark as Read Workflow

```
User clicks notification
    │
    ├─ NotificationAdapter.onBindViewHolder()
    │   └─ itemView.setOnClickListener()
    │
    ├─ handleNotificationClick(notification)
    │   │
    │   ├─ Check if !notification.isRead()
    │   │   └─ Call apiService.markAsRead(notificationId)
    │   │       │
    │   │       ├─ Send PUT request
    │   │       ├─ Backend updates notification
    │   │       └─ onResponse()
    │   │           ├─ loadUnreadCount()
    │   │           └─ Update badge
    │   │
    │   └─ handleNotificationAction(notification)
    │       ├─ Get action_type from notification
    │       ├─ If "navigate_to_course": navigate to course
    │       ├─ If "navigate_to_exercise": navigate to exercise
    │       └─ If "external_link": open URL
    │
    └─ UI updated
```

### 4️⃣ Delete Workflow

```
User clicks delete button
    │
    ├─ NotificationAdapter.deleteBtn.setOnClickListener()
    │
    ├─ handleNotificationDelete(notificationId, position)
    │   │
    │   ├─ Call apiService.deleteNotification(notificationId)
    │   │   │
    │   │   ├─ Send DELETE request
    │   │   ├─ Backend deletes from database
    │   │   └─ onResponse()
    │   │       ├─ notificationAdapter.removeNotification(position)
    │   │       ├─ notifyItemRemoved(position)
    │   │       └─ Show toast "Đã xóa"
    │   │
    │   └─ onFailure()
    │       └─ Show error toast
    │
    └─ UI updated
```

### 5️⃣ Unread Count Workflow

```
NewsFragment.onViewCreated()
    │
    ├─ loadUnreadCount()
    │   │
    │   ├─ Call apiService.getUnreadCount()
    │   │   │
    │   │   ├─ Send GET request
    │   │   ├─ Backend queries unread count
    │   │   └─ onResponse()
    │   │       ├─ if unreadCount > 0:
    │   │       │   ├─ unreadBadge.setText(unreadCount)
    │   │       │   └─ unreadBadge.setVisibility(VISIBLE)
    │   │       └─ else:
    │   │           └─ unreadBadge.setVisibility(GONE)
    │   │
    │   └─ onFailure()
    │       └─ Silent fail (log only)
    │
    └─ Badge updated
```

---

## 🛠️ Configuration Required

### Frontend Side

1. **ApiClient.java**
   - Add base URL: `http://{baseIp}:8086/api/v1/`
   - Add getter method: `getNotificationService()`

2. **NotificationApiService.java**
   - Define all endpoints
   - Add proper annotations (@GET, @PUT, @DELETE)
   - Add query parameters

3. **Models**
   - Add @SerializedName annotations
   - Match JSON field names exactly
   - Handle nullable fields with @SerializedName(alternate=...)

4. **AuthInterceptor.java**
   - Must add Authorization header
   - Token format: `Bearer <jwt-token>`

### Backend Side

1. **API Gateway** (`api-gateway/internal/routes/routes.go`)
   - Route `/api/v1/notifications/*` to Notification Service
   - Add auth middleware for protected routes

2. **Notification Service** (`services/notification-service/`)
   - All routes must use AuthMiddleware.Authenticate()
   - Validate JWT tokens
   - Return proper error codes

3. **Database** (`database/schemas/`)
   - Ensure notifications table exists
   - Create proper indexes
   - Support pagination

---

## 📊 Status Code Handling

### Frontend Error Handling

```java
// In NewsFragment

if (response.isSuccessful()) {
    // 200-299: Success
    // Parse response and update UI
} else {
    // 4xx-5xx: Error
    switch (response.code()) {
        case 400:
            showErrorLayout("Yêu cầu không hợp lệ");
            break;
        case 401:
            // Token expired or invalid
            // Redirect to login
            break;
        case 404:
            showErrorLayout("Không tìm thấy");
            break;
        case 500:
            showErrorLayout("Lỗi server");
            break;
        default:
            showErrorLayout("Lỗi: " + response.code());
    }
}

// Network failure
call.enqueue(new Callback<>() {
    @Override
    public void onFailure(Call<> call, Throwable t) {
        showErrorLayout("Lỗi kết nối: " + t.getMessage());
    }
});
```

---

## 🔒 Security Considerations

1. **Token Management**
   - Store JWT in secure SharedPreferences
   - Add token to all authenticated requests
   - Handle token refresh/expiration

2. **HTTPS (Optional for Production)**
   - Use HTTPS for API Gateway
   - Validate SSL certificates
   - Add certificate pinning if needed

3. **Input Validation**
   - Validate pagination parameters
   - Validate UUID format for IDs
   - Sanitize displayed data

4. **Error Messages**
   - Don't expose sensitive information
   - Show user-friendly error messages
   - Log detailed errors for debugging

---

## 📝 Common Integration Issues

| Issue | Solution |
|-------|----------|
| 401 Unauthorized | Check JWT token, ensure AuthInterceptor adds header |
| 404 Not Found | Verify API Gateway routing, check service port |
| JSON Parse Error | Check @SerializedName annotations match JSON field names |
| Connection Timeout | Check network, service status, firewall rules |
| Empty List | Check database, pagination parameters, filters |
| CORS Error | Should be handled by API Gateway, not frontend |

---

## 🚀 Testing Checklist

### Unit Tests
- [ ] Test Notification model deserialization
- [ ] Test NotificationResponse parsing
- [ ] Test pagination calculations

### Integration Tests
- [ ] Test API calls with mock server
- [ ] Test error handling
- [ ] Test token addition via interceptor

### UI Tests
- [ ] Test RecyclerView display
- [ ] Test click handlers
- [ ] Test delete functionality
- [ ] Test empty/error states
- [ ] Test pagination scroll
- [ ] Test refresh functionality

### End-to-End Tests
- [ ] Real backend connection
- [ ] Real database queries
- [ ] Token validation
- [ ] Error scenarios

---

**Last Updated**: 28/12/2025
**Version**: 1.0

