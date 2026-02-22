# Yêu Cầu Xử Lý NewsFragment - Hiển Thị Thông Báo

## 📋 Mô Tả Chung
Tài liệu này cung cấp các yêu cầu cần thiết để xử lý NewsFragment hiển thị thông báo từ Notification Service.

---

## 🏗️ Kiến Trúc Hệ Thống

### Backend (Notification Service)
- **Port**: 8086
- **Technology**: Go, PostgreSQL
- **Location**: `services/notification-service/`

### Frontend (Android)
- **Component**: NewsFragment
- **Location**: `ieltsapp/app/src/main/java/com/example/ieltsapp/ui/menu/`
- **Network Client**: ApiClient (Base URL configuration)

---

## 📡 API Endpoints từ Notification Service

### 1. **Lấy Danh Sách Thông Báo**
```
GET /api/v1/notifications
```

**Query Parameters:**
- `page` (int, default: 1) - Trang hiện tại
- `limit` (int, default: 20) - Số lượng thông báo mỗi trang
- `is_read` (bool, optional) - Lọc theo trạng thái đã đọc/chưa đọc
- `type` (string, optional) - Loại thông báo
  - `achievement` - Thành tích
  - `reminder` - Nhắc nhở
  - `course_update` - Cập nhật khóa học
  - `exercise_graded` - Bài tập được chấm
  - `system` - Thông báo hệ thống
  - `social` - Thông báo xã hội
- `category` (string, optional) - Danh mục
  - `info` - Thông tin
  - `success` - Thành công
  - `warning` - Cảnh báo
  - `alert` - Cảnh báo khẩn
- `sort_by` (string, optional) - Sắp xếp theo: `date`
- `sort_order` (string, optional) - Thứ tự: `asc` hoặc `desc` (mặc định: `desc`)
- `date_from` (string, optional) - Ngày bắt đầu (ISO 8601: YYYY-MM-DD)
- `date_to` (string, optional) - Ngày kết thúc (ISO 8601: YYYY-MM-DD)

**Response:**
```json
{
  "notifications": [
    {
      "id": "uuid-string",
      "type": "achievement|reminder|course_update|exercise_graded|system|social",
      "category": "info|success|warning|alert",
      "title": "Tiêu đề thông báo",
      "message": "Nội dung chi tiết thông báo",
      "action_type": "navigate_to_course|navigate_to_exercise|external_link",
      "action_data": {
        "course_id": "...",
        "exercise_id": "...",
        "url": "..."
      },
      "icon_url": "https://...",
      "image_url": "https://...",
      "is_read": false,
      "read_at": "2025-01-01T10:30:00Z",
      "created_at": "2025-01-01T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "total_pages": 5
  }
}
```

**Status Code:**
- `200` - Thành công
- `400` - Yêu cầu không hợp lệ
- `401` - Chưa xác thực
- `500` - Lỗi server

---

### 2. **Lấy Số Lượng Thông Báo Chưa Đọc**
```
GET /api/v1/notifications/unread-count
```

**Response:**
```json
{
  "unread_count": 5
}
```

**Status Code:**
- `200` - Thành công
- `401` - Chưa xác thực

---

### 3. **Đánh Dấu Thông Báo Là Đã Đọc**
```
PUT /api/v1/notifications/:id/read
```

**Path Parameters:**
- `id` (string, UUID) - ID của thông báo

**Response:**
```json
{
  "id": "uuid-string",
  "is_read": true,
  "read_at": "2025-01-01T10:30:00Z"
}
```

**Status Code:**
- `200` - Thành công
- `400` - ID không hợp lệ
- `401` - Chưa xác thực
- `404` - Không tìm thấy thông báo

---

### 4. **Đánh Dấu Tất Cả Thông Báo Là Đã Đọc**
```
PUT /api/v1/notifications/mark-all-read
```

**Response:**
```json
{
  "marked_count": 5
}
```

**Status Code:**
- `200` - Thành công
- `401` - Chưa xác thực

---

### 5. **Xóa Thông Báo**
```
DELETE /api/v1/notifications/:id
```

**Path Parameters:**
- `id` (string, UUID) - ID của thông báo

**Response:**
```json
{
  "message": "Notification deleted successfully"
}
```

**Status Code:**
- `204` - Xóa thành công
- `401` - Chưa xác thực
- `404` - Không tìm thấy

---

### 6. **Streaming Notifications (Real-time - Server-Sent Events)**
```
GET /api/v1/notifications/stream
```

**Description:** Kết nối SSE để nhận thông báo real-time

**Response Events:**
- `notification` - Thông báo mới
- `heartbeat` - Tín hiệu sống (mỗi 30 giây)
- `closed` - Kết nối bị đóng

**Event Data:**
```json
{
  "id": "uuid-string",
  "type": "achievement",
  "category": "success",
  "title": "Chúc mừng!",
  "message": "Bạn đã hoàn thành bài tập",
  "is_read": false,
  "created_at": "2025-01-01T10:00:00Z"
}
```

---

## 🔐 Xác Thực (Authentication)

Tất cả các API endpoints (ngoại trừ `/health`) đều yêu cầu:
- **Header**: `Authorization: Bearer <jwt-token>`
- **Token Source**: Từ AuthService (Port 8081)
- **Token Format**: JWT (JSON Web Token)

**Note**: API Gateway (Port 8080) sẽ xử lý forwarding request và authentication middleware.

---

## 📦 Data Models cần thiết cho Frontend

### 1. **Notification Model**
```java
public class Notification {
    private String id;
    private String type;           // achievement, reminder, course_update, exercise_graded, system, social
    private String category;       // info, success, warning, alert
    private String title;
    private String message;
    private String actionType;     // navigate_to_course, navigate_to_exercise, external_link
    private Map<String, Object> actionData;
    private String iconUrl;
    private String imageUrl;
    private boolean isRead;
    private String readAt;
    private String createdAt;
    
    // Getters và Setters
}
```

### 2. **NotificationResponse Model**
```java
public class NotificationResponse {
    private List<Notification> notifications;
    private PaginationInfo pagination;
    
    // Getters và Setters
}
```

### 3. **PaginationInfo Model**
```java
public class PaginationInfo {
    private int page;
    private int limit;
    private int total;
    private int totalPages;
    
    // Getters và Setters
}
```

### 4. **UnreadCountResponse Model**
```java
public class UnreadCountResponse {
    private int unreadCount;
    
    // Getters và Setters
}
```

---

## 🔗 Network Service Implementation

### 1. **Tạo NotificationApiService Interface**

```java
public interface NotificationApiService {
    
    @GET("notifications")
    Call<NotificationResponse> getNotifications(
        @Query("page") int page,
        @Query("limit") int limit,
        @Query("is_read") Boolean isRead,
        @Query("type") String type,
        @Query("category") String category,
        @Query("sort_by") String sortBy,
        @Query("sort_order") String sortOrder,
        @Query("date_from") String dateFrom,
        @Query("date_to") String dateTo
    );
    
    @GET("notifications/unread-count")
    Call<UnreadCountResponse> getUnreadCount();
    
    @GET("notifications/{id}")
    Call<Notification> getNotificationById(@Path("id") String id);
    
    @PUT("notifications/{id}/read")
    Call<Notification> markAsRead(@Path("id") String id);
    
    @PUT("notifications/mark-all-read")
    Call<MarkAllReadResponse> markAllAsRead();
    
    @DELETE("notifications/{id}")
    Call<Void> deleteNotification(@Path("id") String id);
}
```

### 2. **Cấu Hình Base URL trong ApiClient**

```java
// Thêm vào ApiClient.java
private static final String NOTIFICATION_SERVICE_URL = "http://" + baseIp + ":8086/api/v1/";

// Tạo method để lấy Notification Service client
public static NotificationApiService getNotificationService() {
    return getClient(NOTIFICATION_SERVICE_URL).create(NotificationApiService.class);
}
```

---

## 📝 Workflow cho NewsFragment

### 1. **Khởi Tạo (onCreateView)**
```
- Tải danh sách thông báo (page 1, limit 20)
- Hiển thị loading indicator
- Xử lý lỗi nếu có
```

### 2. **Hiển Thị Dữ Liệu**
```
- Sử dụng RecyclerView để hiển thị danh sách thông báo
- Sắp xếp theo ngày mới nhất trước
- Hiển thị biểu tượng "unread" cho thông báo chưa đọc
```

### 3. **Tương Tác Người Dùng**
```
- Click vào thông báo -> Đánh dấu là đã đọc + Thực hiện action
- Swipe xóa -> Gọi API xóa thông báo
- Pagination -> Load thêm thông báo khi scroll tới cuối
- Pull-to-refresh -> Tải lại danh sách
```

### 4. **Real-time Updates (Optional - Advanced)**
```
- Kết nối SSE stream để nhận thông báo mới
- Thêm thông báo vào danh sách khi có event mới
- Cập nhật unread count
```

---

## 🎨 UI Components cần thiết

### 1. **RecyclerView Adapter**
```
- Hiển thị danh sách thông báo
- Item layout: title, message, icon, timestamp, read status
- Support swipe-to-delete
```

### 2. **Filter & Sort Options**
```
- Filter: Tất cả, Chưa đọc, Đã đọc
- Filter: Loại thông báo
- Sort: Mới nhất trước (default), Cũ nhất trước
```

### 3. **Empty State**
```
- Hiển thị khi không có thông báo
- Icon + Text: "Không có thông báo"
```

### 4. **Error Handling**
```
- Network error message
- Retry button
- Toast notification cho action success/failure
```

---

## ⚙️ Technical Requirements

### Frontend (Android)
- **Min SDK**: Theo project requirement
- **Libraries**:
  - Retrofit 2 (HTTP client)
  - GSON (JSON parsing)
  - RecyclerView (list display)
  - LiveData / ViewModel (state management)
  - OkHttp (network interceptor cho auth)

### Backend (Notification Service)
- **API Gateway**: Port 8080 (proxy requests)
- **Notification Service**: Port 8086
- **Database**: PostgreSQL
- **Auth**: JWT token validation
- **Real-time**: Server-Sent Events (SSE) support

---

## 🔄 API Gateway Configuration

Đảm bảo API Gateway đã cấu hình routes cho Notification Service:

```go
// api-gateway/internal/routes/routes.go
notificationGroup := v1.Group("/notifications")
notificationGroup.Use(authMiddleware.Authenticate())
{
    notificationGroup.GET("", proxy.ReverseProxy(cfg.Services.NotificationService))
    notificationGroup.GET("/unread-count", proxy.ReverseProxy(cfg.Services.NotificationService))
    notificationGroup.GET("/stream", proxy.ReverseProxy(cfg.Services.NotificationService))
    notificationGroup.GET("/:id", proxy.ReverseProxy(cfg.Services.NotificationService))
    notificationGroup.PUT("/:id/read", proxy.ReverseProxy(cfg.Services.NotificationService))
    notificationGroup.PUT("/mark-all-read", proxy.ReverseProxy(cfg.Services.NotificationService))
    notificationGroup.DELETE("/:id", proxy.ReverseProxy(cfg.Services.NotificationService))
}
```

---

## 📊 Database Schema (Reference)

```sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    type VARCHAR(50) NOT NULL,        -- achievement, reminder, course_update, etc.
    category VARCHAR(50) NOT NULL,    -- info, success, warning, alert
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    action_type VARCHAR(50),
    action_data JSONB,
    icon_url TEXT,
    image_url TEXT,
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_sent BOOLEAN DEFAULT true,
    is_deleted BOOLEAN DEFAULT false
);

CREATE INDEX idx_notifications_user_id_created_at 
ON notifications(user_id, created_at DESC);
CREATE INDEX idx_notifications_is_read 
ON notifications(is_read);
```

---

## 🚀 Implementation Checklist

### Phase 1: Backend Verification
- [x] Kiểm tra Notification Service endpoints
- [x] Xác nhận data models
- [x] Xác nhận authentication mechanism
- [x] Xác nhận API Gateway routing

### Phase 2: Frontend Models
- [ ] Tạo Notification model class
- [ ] Tạo NotificationResponse model class
- [ ] Tạo PaginationInfo model class
- [ ] Tạo UnreadCountResponse model class

### Phase 3: Network Layer
- [ ] Tạo NotificationApiService interface
- [ ] Thêm base URL cho Notification Service vào ApiClient
- [ ] Implement error handling
- [ ] Test API endpoints

### Phase 4: UI Implementation
- [ ] Cập nhật fragment_news.xml layout
- [ ] Tạo notification item layout
- [ ] Tạo RecyclerView adapter
- [ ] Tạo NewsFragment logic

### Phase 5: Features
- [ ] Danh sách thông báo
- [ ] Mark as read
- [ ] Delete notification
- [ ] Filter & sort
- [ ] Pagination
- [ ] Real-time updates (SSE - optional)

### Phase 6: Testing
- [ ] Unit tests
- [ ] Integration tests
- [ ] UI tests
- [ ] Network error handling tests

---

## 📚 References

### Backend Notification Service
- Location: `services/notification-service/`
- Handler: `internal/handlers/notification_handler.go`
- Service: `internal/service/notification_service.go`
- Routes: `internal/routes/routes.go`
- Models: `internal/models/dto.go`, `internal/models/models.go`

### Frontend
- NewsFragment: `ieltsapp/app/src/main/java/com/example/ieltsapp/ui/menu/NewsFragment.java`
- Layout: `ieltsapp/app/src/main/res/layout/fragment_news.xml`
- ApiClient: `ieltsapp/app/src/main/java/com/example/ieltsapp/network/ApiClient.java`

### Configuration
- API Gateway routes: `api-gateway/internal/routes/routes.go` (line 293+)
- Docker config: `docker-compose.yml` (notification-service service)
- Database schema: `database/schemas/06_notification_service.sql`

---

## 🔍 Lưu Ý Quan Trọng

1. **Authentication**: Tất cả requests phải bao gồm JWT token trong header
2. **Base URL**: Notification Service chạy trên port 8086
3. **CORS**: API Gateway xử lý CORS, không cần cấu hình ở service
4. **Error Handling**: Cần handle các lỗi network, timeout, invalid responses
5. **Pagination**: Mặc định limit 20, page 1
6. **Real-time**: SSE stream tùy chọn, hữu ích cho real-time notifications
7. **Token Refresh**: Sử dụng AuthInterceptor trong ApiClient để tự động thêm token

---

**Cập nhật**: 28/12/2025
**Version**: 1.0

