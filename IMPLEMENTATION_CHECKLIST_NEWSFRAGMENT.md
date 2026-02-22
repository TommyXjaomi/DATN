# Implementation Checklist - NewsFragment Notification Integration

## 📋 Project Overview

**Goal**: Integrate Notification Service vào NewsFragment để hiển thị thông báo  
**Timeline**: ~6-8 giờ  
**Frontend**: Android (NewsFragment)  
**Backend**: Notification Service (Go, Port 8086)  

---

## ✅ Phase 1: Backend Verification (30 mins)

- [x] Notification Service running on port 8086
- [x] Database schema created (notifications table)
- [x] API endpoints implemented
- [x] Authentication middleware enabled
- [x] API Gateway configured
- [ ] Health check passing: `curl http://localhost:8086/health`
- [ ] Sample data in database (if needed for testing)

**Verification Commands**:
```bash
# Check service running
curl http://localhost:8086/health

# Check API Gateway routing
curl -H "Authorization: Bearer <token>" \
  http://localhost:8080/api/v1/notifications

# Check database
psql -U postgres -d notification_db -c "SELECT COUNT(*) FROM notifications;"
```

---

## ✅ Phase 2: Frontend Models (1-2 hours)

### 2.1 Create Model Classes
- [ ] `ieltsapp/app/src/main/java/com/example/ieltsapp/model/Notification.java`
  - [ ] Add all fields with @SerializedName
  - [ ] Add constructors
  - [ ] Add getters/setters
  - [ ] Add equals() & hashCode()
  - [ ] Add toString()

- [ ] `ieltsapp/app/src/main/java/com/example/ieltsapp/model/NotificationResponse.java`
  - [ ] notifications: List<Notification>
  - [ ] pagination: PaginationInfo
  - [ ] Add constructors
  - [ ] Add getters/setters

- [ ] `ieltsapp/app/src/main/java/com/example/ieltsapp/model/UnreadCountResponse.java`
  - [ ] unreadCount: int
  - [ ] Add constructor
  - [ ] Add getters/setters

### 2.2 Add String Resources
- [ ] Add strings to `strings.xml`:
  - [ ] `no_notifications`
  - [ ] `no_notifications_desc`
  - [ ] `error_loading_notifications`
  - [ ] `error`
  - [ ] `retry`
  - [ ] `notification_icon`
  - [ ] `delete_notification`

---

## ✅ Phase 3: Network Layer (1-2 hours)

### 3.1 Create API Service
- [ ] Create `NotificationApiService.java` interface
  - [ ] `getNotifications(page, limit)` - GET /notifications
  - [ ] `getNotifications(page, limit, isRead, type, category, sortBy, sortOrder, dateFrom, dateTo)`
  - [ ] `getUnreadCount()` - GET /notifications/unread-count
  - [ ] `getNotificationById(id)` - GET /notifications/:id
  - [ ] `markAsRead(id)` - PUT /notifications/:id/read
  - [ ] `markAllAsRead()` - PUT /notifications/mark-all-read
  - [ ] `deleteNotification(id)` - DELETE /notifications/:id
  - [ ] Add MarkAllReadResponse inner class

### 3.2 Update API Client
- [ ] Open `ApiClient.java`
- [ ] Add Notification Service base URL:
  ```java
  private static final String NOTIFICATION_SERVICE_URL = 
      "http://" + baseIp + ":8086/api/v1/";
  ```
- [ ] Add getter method:
  ```java
  public static NotificationApiService getNotificationService() {
      return getClient(NOTIFICATION_SERVICE_URL).create(NotificationApiService.class);
  }
  ```

### 3.3 Verify Authentication
- [ ] Check AuthInterceptor adds Authorization header
- [ ] Verify token is retrieved from SharedPreferences
- [ ] Test with actual token

---

## ✅ Phase 4: UI Design (1-2 hours)

### 4.1 Update Layouts
- [ ] Update `fragment_news.xml`
  - [ ] Add RecyclerView
  - [ ] Add SwipeRefreshLayout
  - [ ] Add loading layout
  - [ ] Add empty state layout
  - [ ] Add error layout
  - [ ] Add header with unread badge
  - [ ] Add filter buttons (optional)

- [ ] Create `item_notification.xml`
  - [ ] Add icon ImageView
  - [ ] Add title TextView
  - [ ] Add message TextView
  - [ ] Add timestamp TextView
  - [ ] Add unread indicator dot
  - [ ] Add delete button
  - [ ] Add click handlers

### 4.2 Create Drawable Resources
- [ ] `circle_unread.xml` - Unread indicator dot
- [ ] `badge_background.xml` - Unread badge background
- [ ] Ensure icons exist:
  - [ ] `ic_notifications`
  - [ ] `ic_achievement`
  - [ ] `ic_reminder`
  - [ ] `ic_course`
  - [ ] `ic_check`
  - [ ] `ic_system`
  - [ ] `ic_social`
  - [ ] `ic_delete`
  - [ ] `ic_error`
  - [ ] `placeholder`
  - [ ] `error_placeholder`

---

## ✅ Phase 5: Adapter Implementation (1 hour)

### 5.1 Create NotificationAdapter
- [ ] Create `NotificationAdapter.java`
  - [ ] Extend RecyclerView.Adapter<NotificationViewHolder>
  - [ ] Add OnNotificationClickListener interface
  - [ ] Add OnNotificationDeleteListener interface
  - [ ] Implement onCreateViewHolder()
  - [ ] Implement onBindViewHolder()
  - [ ] Implement getItemCount()
  - [ ] Add helper methods:
    - [ ] addNotification()
    - [ ] removeNotification()
    - [ ] updateNotification()
    - [ ] addAll()
    - [ ] clear()
    - [ ] getRelativeTime() - Convert ISO 8601 to relative time
    - [ ] setIconByType() - Set icon based on notification type

### 5.2 Create ViewHolder
- [ ] NotificationViewHolder inner class
  - [ ] Bind UI elements
  - [ ] Icon, title, message, timestamp, unread dot, delete button

---

## ✅ Phase 6: Fragment Implementation (2-3 hours)

### 6.1 Initialize UI
- [ ] Override onCreateView()
  - [ ] Inflate fragment_news.xml
  - [ ] Return root view

- [ ] Override onViewCreated()
  - [ ] Initialize all UI elements
  - [ ] Setup API service
  - [ ] Setup RecyclerView
  - [ ] Setup SwipeRefreshLayout
  - [ ] Setup retry button
  - [ ] Load initial data

### 6.2 Setup RecyclerView
- [ ] Create LinearLayoutManager
- [ ] Create NotificationAdapter with listeners
- [ ] Set adapter to RecyclerView
- [ ] Add OnScrollListener for pagination

### 6.3 Setup SwipeRefreshLayout
- [ ] Set OnRefreshListener
- [ ] Reset pagination on refresh
- [ ] Clear adapter data
- [ ] Reload notifications

### 6.4 Implement API Calls
- [ ] `loadNotifications()`
  - [ ] Show loading indicator
  - [ ] Call apiService.getNotifications(page, limit)
  - [ ] Handle response
  - [ ] Update notifications list
  - [ ] Update pagination info
  - [ ] Show notification list

- [ ] `loadMoreNotifications()`
  - [ ] Increment page
  - [ ] Call apiService.getNotifications(page, limit)
  - [ ] Append results to list
  - [ ] Update adapter

- [ ] `loadUnreadCount()`
  - [ ] Call apiService.getUnreadCount()
  - [ ] Update badge visibility/text
  - [ ] Handle errors silently

### 6.5 Implement User Interactions
- [ ] `handleNotificationClick(notification)`
  - [ ] Check if unread
  - [ ] Call markAsRead() if needed
  - [ ] Handle action (navigate, open link)

- [ ] `handleNotificationDelete(notificationId, position)`
  - [ ] Call apiService.deleteNotification()
  - [ ] Remove from adapter
  - [ ] Show success/error toast

- [ ] `markAsRead(notificationId)`
  - [ ] Call apiService.markAsRead()
  - [ ] Reload unread count
  - [ ] Update adapter item (hide unread dot)

- [ ] `handleNotificationAction(notification)`
  - [ ] Check action_type
  - [ ] Navigate to course/exercise
  - [ ] Open external link
  - [ ] Pass action_data to destination

### 6.6 Implement State Management
- [ ] `showLoadingLayout()`
  - [ ] Hide RecyclerView, empty, error
  - [ ] Show loading indicator

- [ ] `showNotificationLayout()`
  - [ ] Show RecyclerView
  - [ ] Hide loading, empty, error

- [ ] `showEmptyStateLayout()`
  - [ ] Hide RecyclerView, loading, error
  - [ ] Show empty state message

- [ ] `showErrorLayout(message)`
  - [ ] Hide RecyclerView, loading, empty
  - [ ] Show error message and retry button

---

## ✅ Phase 7: Testing (1-2 hours)

### 7.1 Unit Tests
- [ ] Test Notification model serialization/deserialization
- [ ] Test NotificationResponse parsing
- [ ] Test PaginationInfo calculations
- [ ] Test relative time formatting

### 7.2 Integration Tests
- [ ] Test API calls with mock responses
- [ ] Test error handling (400, 401, 404, 500)
- [ ] Test pagination logic
- [ ] Test token addition via interceptor

### 7.3 UI Tests
- [ ] Test RecyclerView displays items correctly
- [ ] Test click handlers trigger callbacks
- [ ] Test delete button removes item
- [ ] Test empty state displays when no notifications
- [ ] Test error state displays on API failure
- [ ] Test pagination loads more items on scroll
- [ ] Test refresh clears list and reloads
- [ ] Test unread badge displays/hides correctly

### 7.4 End-to-End Tests
- [ ] Login with valid credentials
- [ ] Open News tab
- [ ] Wait for notifications to load
- [ ] Click notification and verify mark as read
- [ ] Delete notification and verify removal
- [ ] Scroll to end and verify pagination
- [ ] Pull refresh and verify data reloads
- [ ] Logout and verify access denied

### 7.5 Error Scenarios
- [ ] Network error (turn off wifi)
- [ ] Invalid token (clear auth)
- [ ] Server error (stop service)
- [ ] Timeout (slow connection)
- [ ] Empty list (no notifications)
- [ ] Large list (100+ items)

---

## ✅ Phase 8: Debugging & Optimization (30 mins - 1 hour)

### 8.1 Logging
- [ ] Add Log.d() calls for API calls
- [ ] Log response data
- [ ] Log error messages
- [ ] Use Android Studio Logcat to debug

### 8.2 Performance
- [ ] Check memory usage with Profiler
- [ ] Optimize image loading with Glide
- [ ] Use ViewBinding instead of findViewById
- [ ] Implement DiffUtil for adapter updates (optional)

### 8.3 Bug Fixes
- [ ] Fix any failing tests
- [ ] Handle edge cases
- [ ] Fix UI layout issues
- [ ] Handle null/empty data

### 8.4 Code Quality
- [ ] Remove unused imports
- [ ] Format code consistently
- [ ] Add JavaDoc comments
- [ ] Follow Android naming conventions

---

## ✅ Phase 9: Features & Enhancements (Optional)

### 9.1 Core Features
- [ ] Notification filtering by type
- [ ] Notification filtering by read status
- [ ] Sort by date (ascending/descending)
- [ ] Search functionality (optional)

### 9.2 Advanced Features
- [ ] Real-time notifications via SSE stream
- [ ] Local caching (Room database)
- [ ] Offline mode
- [ ] Notification preferences
- [ ] Mark all as read

### 9.3 UI Enhancements
- [ ] Swipe to delete with undo
- [ ] Notification grouping
- [ ] Custom notification icons per type
- [ ] Animations on item add/remove
- [ ] Dark mode support

---

## 🔍 Code Review Checklist

- [ ] No hardcoded strings (use strings.xml)
- [ ] No hardcoded IP addresses (use BuildConfig)
- [ ] No deprecated APIs
- [ ] Proper null checking
- [ ] Proper exception handling
- [ ] No memory leaks (check Profiler)
- [ ] Proper resource cleanup in onDestroy()
- [ ] Consistent naming conventions
- [ ] Comments for complex logic
- [ ] No unused variables/imports

---

## 📦 Deliverables

### Code Files
- [ ] Notification.java
- [ ] NotificationResponse.java
- [ ] UnreadCountResponse.java
- [ ] NotificationApiService.java
- [ ] NotificationAdapter.java
- [ ] NewsFragment.java (updated)
- [ ] ApiClient.java (updated)
- [ ] fragment_news.xml (updated)
- [ ] item_notification.xml
- [ ] Drawable resources

### Documentation
- [ ] API documentation
- [ ] Integration guide
- [ ] Implementation guide
- [ ] Architecture diagram
- [ ] Testing report

### Tests
- [ ] Unit tests
- [ ] Integration tests
- [ ] UI tests
- [ ] Test coverage report

---

## 🚀 Deployment Checklist

### Pre-deployment
- [ ] All tests passing
- [ ] No compilation errors/warnings
- [ ] Code reviewed and approved
- [ ] Documentation complete
- [ ] Release notes prepared

### Deployment
- [ ] Build APK/AAB
- [ ] Test on real device
- [ ] Verify in staging environment
- [ ] Create release branch
- [ ] Tag version

### Post-deployment
- [ ] Monitor for errors (Crashlytics)
- [ ] Check performance metrics
- [ ] User feedback collection
- [ ] Bug fixes if needed

---

## 📋 File Structure Reference

```
ieltsapp/app/src/main/
├── java/com/example/ieltsapp/
│   ├── model/
│   │   ├── Notification.java (NEW)
│   │   ├── NotificationResponse.java (NEW)
│   │   └── UnreadCountResponse.java (NEW)
│   ├── network/
│   │   ├── ApiClient.java (UPDATED)
│   │   ├── NotificationApiService.java (NEW)
│   │   └── AuthInterceptor.java (verify)
│   ├── Adapter/
│   │   └── NotificationAdapter.java (NEW)
│   └── ui/menu/
│       └── NewsFragment.java (UPDATED)
└── res/
    ├── layout/
    │   ├── fragment_news.xml (UPDATED)
    │   └── item_notification.xml (NEW)
    ├── drawable/
    │   ├── circle_unread.xml (NEW)
    │   ├── badge_background.xml (NEW)
    │   └── ic_*.xml (verify)
    └── values/
        └── strings.xml (UPDATED)
```

---

## 🎯 Success Criteria

- [x] Backend: Notification Service running and accessible
- [ ] Frontend: Models created and tested
- [ ] Frontend: API service integrated
- [ ] Frontend: NewsFragment displays notifications
- [ ] Frontend: Can mark notifications as read
- [ ] Frontend: Can delete notifications
- [ ] Frontend: Pagination works correctly
- [ ] Frontend: Error handling works
- [ ] Frontend: Empty state displays
- [ ] Frontend: All tests passing
- [ ] Documentation: Complete and accurate
- [ ] Code: Clean, well-commented, follows conventions

---

## 📞 Support & References

### Key Files
- Backend: `services/notification-service/`
- Frontend: `ieltsapp/app/src/main/`
- API Gateway: `api-gateway/internal/routes/routes.go`
- Database: `database/schemas/`

### Documentation Files
1. `NOTIFICATION_REQUIREMENTS_FOR_NEWSFRAGMENT.md` - Requirements
2. `IMPLEMENTATION_GUIDE_NEWSFRAGMENT_NOTIFICATIONS.md` - Step-by-step guide
3. `BACKEND_API_NOTIFICATION_SERVICE_DETAILED.md` - API details
4. `FRONTEND_BACKEND_INTEGRATION_MAPPING.md` - Integration mapping
5. `NEWSFRAGMENT_QUICK_SUMMARY.md` - Quick reference

### Related Services
- Auth Service (8081) - Token management
- User Service (8082) - User information
- Course Service (8083) - Course information
- Exercise Service (8084) - Exercise information

---

**Checklist Version**: 1.0  
**Last Updated**: 28/12/2025  
**Estimated Time**: 6-8 hours  
**Difficulty**: Medium  

---

## 📊 Progress Tracking

| Phase | Status | Time | Notes |
|-------|--------|------|-------|
| 1. Backend Verification | ✅ | 30m | Service ready |
| 2. Frontend Models | ⬜ | 1-2h | Not started |
| 3. Network Layer | ⬜ | 1-2h | Not started |
| 4. UI Design | ⬜ | 1-2h | Not started |
| 5. Adapter | ⬜ | 1h | Not started |
| 6. Fragment Logic | ⬜ | 2-3h | Not started |
| 7. Testing | ⬜ | 1-2h | Not started |
| 8. Debugging | ⬜ | 30m-1h | Not started |
| 9. Enhancements | ⬜ | Optional | Not started |

---

**Start implementing from Phase 2 onwards!** 🚀

