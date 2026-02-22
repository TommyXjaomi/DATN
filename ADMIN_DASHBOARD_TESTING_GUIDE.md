# 🧪 Admin Dashboard Phase 1 - Testing Guide

## Quick Start

### To Access Admin Dashboard:
1. Login as admin user
2. Navigate to Admin Dashboard (button/menu item to be added to main navigation)
3. AdminDashboardActivity opens with AdminDashboardFragment

### Component Flow:
```
AdminDashboardActivity
    └─ AdminDashboardFragment
        ├─ AdminDashboardViewModel
        │   ├─ loadDashboardData()
        │   │   ├─ getDashboardStats() → API Gateway
        │   │   ├─ getSystemHealth() → API Gateway
        │   │   └─ getRecentActivities() → API Gateway
        │   └─ LiveData observations
        └─ UI Updates
            ├─ updateStatsUI(DashboardStats)
            ├─ updateHealthUI(SystemHealth)
            └─ setupActivityRecyclerView(AdminActivityAdapter)
```

---

## API Endpoints Being Called

### 1. Dashboard Overview Stats
**Endpoint:** `GET /api/v1/admin/analytics/overview`  
**Response Model:** DashboardStats

```json
{
  "total_users": 1234,
  "total_students": 890,
  "total_instructors": 45,
  "total_admins": 10,
  "user_growth": 12.5,
  "total_courses": 156,
  "active_courses": 142,
  "draft_courses": 14,
  "total_exercises": 2458,
  "submissions_today": 342,
  "average_completion_rate": 78.5
}
```

**Expected Field Mapping:**
- `total_users` → tvTotalUsers
- `total_students` → tvTotalStudents
- `total_instructors` → tvTotalInstructors
- `total_admins` → tvTotalAdmins
- `user_growth` → tvUserGrowth (with % symbol)
- `total_courses` → tvTotalCourses
- `active_courses` → tvActiveCourses
- `draft_courses` → tvDraftCourses
- `total_exercises` → tvTotalExercises
- `submissions_today` → tvSubmissionsToday
- `average_completion_rate` → tvCompletionRate (with % symbol)

---

### 2. System Health Monitoring
**Endpoint:** `GET /api/v1/admin/system/health`  
**Response Model:** SystemHealth

```json
{
  "status": "healthy",
  "cpu_usage": 45,
  "memory_usage": 62,
  "disk_usage": 78,
  "database_status": {
    "name": "PostgreSQL",
    "status": "online",
    "response_time": 5
  },
  "cache_status": {
    "name": "Redis",
    "status": "online",
    "response_time": 2
  }
}
```

**Expected UI Updates:**
- `status` → tvSystemStatus (badge color: green/yellow/red)
- `cpu_usage` → progressBarCpu.setProgress() + tvCpuUsage (with % symbol)
- `memory_usage` → progressBarMemory.setProgress() + tvMemoryUsage (with % symbol)
- `disk_usage` → progressBarDisk.setProgress() + tvDiskUsage (with % symbol)
- `database_status.status` → tvDatabaseStatus (color: green if online)
- `cache_status.status` → tvCacheStatus (color: green if online)

---

### 3. Recent Admin Activities
**Endpoint:** `GET /api/v1/admin/activities?limit=10&offset=0`  
**Response Model:** List<AdminActivity>

```json
[
  {
    "id": "act_001",
    "user_id": "user_123",
    "user_name": "Admin Name",
    "action": "created_course",
    "entity_type": "course",
    "entity_id": "course_456",
    "entity_name": "IELTS Writing Masterclass",
    "description": "Created new course",
    "timestamp": 1699564800000
  },
  {
    "id": "act_002",
    "user_id": "user_123",
    "user_name": "Admin Name",
    "action": "sent_notification",
    "entity_type": "notification",
    "entity_id": "notif_789",
    "entity_name": "Course Update",
    "description": "Sent notification to users",
    "timestamp": 1699564500000
  }
]
```

**Expected RecyclerView Display:**
```
Activity Row Layout:
[Icon] Admin Name                    5 min ago
       Created course: IELTS Writing Masterclass
       [COURSE]
```

---

## Testing Checklist

### UI Loading States
- [ ] Loading spinner appears while API calls in progress
- [ ] Loading spinner disappears after data loads
- [ ] Content ScrollView is visible after loading
- [ ] All TextViews display correct data from API

### Dashboard Stats Display
- [ ] tvTotalUsers shows correct number
- [ ] tvTotalStudents shows correct number
- [ ] tvTotalInstructors shows correct number
- [ ] tvTotalAdmins shows correct number
- [ ] tvUserGrowth shows percentage with % symbol
- [ ] tvTotalCourses shows correct count
- [ ] tvActiveCourses shows correct count
- [ ] tvDraftCourses shows correct count
- [ ] tvTotalExercises shows correct count
- [ ] tvSubmissionsToday shows correct count
- [ ] tvCompletionRate shows percentage with % symbol

### System Health Display
- [ ] tvSystemStatus badge displays health status
- [ ] progressBarCpu updates to correct percentage
- [ ] tvCpuUsage displays percentage with % symbol
- [ ] progressBarMemory updates to correct percentage
- [ ] tvMemoryUsage displays percentage with % symbol
- [ ] progressBarDisk updates to correct percentage
- [ ] tvDiskUsage displays percentage with % symbol
- [ ] tvDatabaseStatus shows service status
- [ ] tvCacheStatus shows service status

### Recent Activities Display
- [ ] RecyclerView displays list of activities
- [ ] Each activity shows icon based on action type
- [ ] User name displays correctly
- [ ] Action description formats properly
- [ ] Entity type badge displays with correct color
- [ ] Timestamp shows relative time (e.g., "5 min ago")
- [ ] Scrolling works correctly in activity list
- [ ] Maximum 10 items shown (pagination limit)

### Error Handling
- [ ] API failure displays error toast message
- [ ] Loading spinner hides on error
- [ ] Content remains accessible after error
- [ ] User can retry by navigating away and returning

### Icon Mapping
- [ ] created_course → ic_course (correct icon)
- [ ] deleted_course → ic_close (correct icon)
- [ ] created_exercise → ic_quiz (correct icon)
- [ ] created_user → ic_person (correct icon)
- [ ] sent_notification → ic_news (correct icon)
- [ ] updated_course → ic_course (correct icon)
- [ ] published_course → ic_trophy (correct icon)

### Color Coding
- [ ] course activities show green badge (#FF4CAF50)
- [ ] exercise activities show blue badge (#FF2196F3)
- [ ] user activities show amber badge (#FFFFC107)
- [ ] notification activities show orange badge (#xFFFF9800)
- [ ] System status shows green when healthy
- [ ] Service status shows green when online

---

## Manual Testing Steps

### 1. Launch Dashboard
```
1. Build and run the app
2. Login with admin credentials
3. Navigate to Admin Dashboard
4. Observe: Loading spinner appears briefly
5. Expected: Dashboard fully loads with all data within 2-3 seconds
```

### 2. Verify API Call Sequence
```
Expected network logs:
[AdminDashboardViewModel] Calling getAdminService().getDashboardStats()
[AdminDashboardViewModel] DashboardStats received: totalUsers=1234
[AdminDashboardViewModel] Calling getAdminService().getSystemHealth()
[AdminDashboardViewModel] SystemHealth received: status=healthy
[AdminDashboardViewModel] Calling getAdminService().getRecentActivities(10, 0)
[AdminDashboardViewModel] Activities received: 10 items
```

### 3. Test Data Updates
```
1. Change any data in backend
2. Navigate away from AdminDashboardActivity
3. Navigate back to AdminDashboardActivity
4. Observe: Fresh API calls are made
5. Expected: New data is displayed
```

### 4. Test Error Handling
```
1. Disable network connectivity
2. Navigate to AdminDashboardActivity
3. Observe: Error toast appears
4. Re-enable network
5. Navigate back to dashboard
6. Expected: Data loads successfully
```

### 5. Test RecyclerView Scrolling
```
1. View Recent Activities section
2. Scroll through activity list
3. Expected: Smooth scrolling without jank
4. Expected: No duplicate items or missing items
```

---

## Debugging Tips

### Enable Verbose Logging
Search for "AdminDashboardViewModel" in Logcat:
```
grep "AdminDashboardViewModel" logcat.log
```

### Check LiveData Values
- DashboardStats payload size: ~200 bytes
- SystemHealth payload size: ~150 bytes
- Activities list: 10 items × ~300 bytes = ~3KB

### Network Debugging
- API Gateway URL: `http://{baseIp}:8080/api/v1/`
- All requests include: `Authorization: Bearer {token}` header
- Expected response codes:
  - 200 OK - Success
  - 401 Unauthorized - Token expired, SessionManager.logout() called
  - 500 Internal Server Error - API error

### Common Issues & Solutions

**Issue:** "Cannot find symbol AdminActivityAdapter"
- Solution: Ensure AndroidActivityAdapter.java is in correct path: `app/src/main/java/com/example/ieltsapp/Adapter/AdminActivityAdapter.java`

**Issue:** "NullPointerException in updateStatsUI()"
- Solution: Check if DashboardStats object is null before accessing fields
- Add null checks: `if (stats != null && stats.getTotalUsers() != null)`

**Issue:** "RecyclerView shows empty list"
- Solution: Verify activities list is non-null and non-empty from API
- Check AdminActivityAdapter.submitList(activities) is called

**Issue:** "Progress bars not updating"
- Solution: Ensure `setProgress(int value)` is called before any other ProgressBar methods
- Progress values must be 0-100 to match max value

---

## Performance Metrics

**Expected Load Times:**
- Loading spinner duration: 1-2 seconds
- API calls: ~500ms each (3 parallel = ~500ms total)
- UI update: ~200ms
- Total: 1-2.5 seconds

**Expected Memory Usage:**
- AdminDashboardFragment: ~2-3 MB
- ViewModel: ~1 MB
- Adapter + RecyclerView: ~1-2 MB
- Total: ~4-6 MB

---

## Next Phase: User Management

Once Phase 1 is validated and working correctly, proceed to Phase 2 which adds:
- User list filtering and search
- User detail view
- User action buttons (edit, delete, change role)
- User statistics breakdown

**Estimated Timeline:** 3-4 hours of development
