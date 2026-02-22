# 🧪 Admin Interface Fix - Quick Test Guide

## How to Test

### Test 1: Admin Login
```
1. Ensure admin account exists in database with role='admin'
2. Run app
3. Go to Login screen
4. Enter admin email/password
5. Expected: After login, should see [Admin] button next to avatar
6. Actual Result: _______________
```

### Test 2: Admin Button Click
```
1. (From Test 1) Admin is logged in with button visible
2. Click [Admin] button
3. Expected: AdminDashboardActivity opens showing:
   - Dashboard stats (users, courses, exercises)
   - System health (CPU, memory, disk)
   - Recent activities list
4. Actual Result: _______________
```

### Test 3: Student Login
```
1. Logout (if admin logged in)
2. Login with student account
3. Expected: [Admin] button should NOT appear
4. Only avatar should be visible
5. Actual Result: _______________
```

### Test 4: Session Persistence
```
1. (From Test 1) Admin logged in with admin button visible
2. Kill app completely (swipe from recent apps)
3. Re-open app
4. Expected: Still on home screen, admin button still visible
5. Logout then check → button gone
6. Actual Result: _______________
```

### Test 5: API Response Check
```
Verify in Logcat:
- Look for login response from API
- Should contain: "role": "ADMIN"
- User.java should capture this value
- SessionManager should store it

Logcat Search:
adb logcat | grep -i "role"
```

---

## Debugging Checklist

If admin button doesn't appear:

- [ ] Check API response contains "role": "ADMIN"
- [ ] Verify User model has role field
- [ ] Check User.getRole() returns non-null value
- [ ] Verify SessionManager.createLoginSession() called with role
- [ ] Confirm SessionManager.isAdmin() returns true
- [ ] Verify HomeFragment.showAdminInterface() is called
- [ ] Check binding.btnAdminDashboard exists in layout
- [ ] Verify AdminDashboardActivity exists and accessible

---

## Expected Behavior Changes

| Action | Before Fix | After Fix |
|--------|-----------|-----------|
| Admin logs in | See only avatar | See [Admin] button + avatar |
| Admin clicks avatar | Menu toast | Profile menu (todo) |
| Admin clicks [Admin] button | N/A | Opens admin dashboard |
| Student logs in | See avatar | See only avatar (no button) |
| Logout | Both disappear | Both disappear |

---

## Key Files to Monitor

1. **User.java** - Check role field exists
2. **SessionManager.java** - Check role methods work
3. **HomeFragment.java** - Check admin button click handler
4. **fragment_home.xml** - Check button visibility
5. **AndroidManifest.xml** - Check AdminDashboardActivity registered

---

## Common Issues & Solutions

### Issue: "Admin button not visible"
```
Solution:
1. Check User.getRole() returns "ADMIN"
2. Verify user.isAdmin() returns true
3. Check showAdminInterface() is called
4. Verify button has android:visibility="gone" in layout
```

### Issue: "Button visible but click does nothing"
```
Solution:
1. Check AdminDashboardActivity exists
2. Verify activity registered in AndroidManifest.xml
3. Check Intent is created correctly
4. Check for runtime permissions if needed
```

### Issue: "Role not being saved"
```
Solution:
1. Verify createLoginSession called with role parameter
2. Check SharedPreferences writing works
3. Verify USER_ROLE constant exists
4. Check editor.apply() is called
```

### Issue: "Role lost after app restart"
```
Solution:
1. Check user profile is loaded on app start
2. Verify getUserRole() from SharedPreferences
3. Ensure session persists in HomeFragment
4. Check isLoggedIn() works correctly
```

---

## Monitoring with Logcat

```bash
# Open Android Studio terminal

# Test 1: See login response
adb logcat | grep -i "authresponse\|role"

# Test 2: See session creation
adb logcat | grep -i "sessionmanager"

# Test 3: See fragment UI updates
adb logcat | grep -i "homefragment\|admin"

# Test 4: See all errors
adb logcat | grep -i "error\|exception"

# Clear logcat
adb logcat -c

# Save logcat to file
adb logcat > logcat.txt
```

---

## Quick Commands

```bash
# Build & test
./gradlew clean build
./gradlew connectedAndroidTest

# Install on device
adb install -r app/build/outputs/apk/debug/app-debug.apk

# Run specific activity
adb shell am start -n com.example.ieltsapp/.ui.admin.AdminDashboardActivity
```

---

## Expected Test Results

✅ **Passing Tests:**
- Admin login shows button
- Button clicks work
- Dashboard opens
- Student login hides button
- Logout removes button
- Session persists
- Role loads from SharedPreferences

❌ **Failing Tests:**
- (document any failures here)

---

**Note:** All changes are backward compatible. Student/Instructor users unaffected.
