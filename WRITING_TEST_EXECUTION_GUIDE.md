# Writing Submission - Test Execution Guide

## 🎯 Pre-Test Checklist

### Backend Requirements:
- [ ] Backend API running on `http://localhost:8080` (or your server)
- [ ] Database connected & migrated
- [ ] AI Service running on `http://localhost:8085`
- [ ] Authentication working (can login via app)

### Android App Setup:
- [ ] Code compiled without errors
- [ ] Android Emulator or Physical Device connected
- [ ] USB Debugging enabled (for physical device)
- [ ] Internet connection available

---

## 📱 Phase 1: Android App Testing

### Step 1: Install & Launch App

```bash
cd ieltsapp
./gradlew installDebug
adb shell am start -n com.example.ieltsapp/.ui.auth.LoginActivity
```

Or in Android Studio:
- Click "Run App" (Shift+F10)

### Step 2: Login

1. Use test account:
   - Email: `test@example.com`
   - Password: `password123`

2. Verify dashboard loads

---

### Step 3: Navigate to Writing Exercise

1. Tap "Study" tab (bottom navigation)
2. Look for "Writing" section or any exercise with skill_type = "writing"
3. Tap "Start Exercise" button

**Expected:** 
- Auto-redirect to `WritingSubmissionActivity`
- Prompt text displays
- No loading spinner

---

### Step 4: Test Word Count Validation

#### Test 4A: Type Less Than 150 Words

1. Focus on EditText field
2. Type ~100 words: 
   ```
   Technology changes our world. Communication is faster now.
   Email, chat apps, and video calls keep us connected.
   Families stay in touch across continents. Schools teach online.
   Doctors consult patients remotely. But technology has drawbacks.
   People spend too much time on screens. Face-to-face talks decrease.
   ```

3. Observe:
   - [ ] Word counter shows "~100 words"
   - [ ] Warning appears: "Minimum 150 words required (100/150)"
   - [ ] "Submit Essay" button is DISABLED (gray)
   - [ ] "Save Draft" button is still enabled

#### Test 4B: Reach 150+ Words

1. Continue typing until counter shows "150 words"
2. Observe:
   - [ ] Word counter updates: "150 words"
   - [ ] Warning message disappears
   - [ ] "Submit Essay" button is ENABLED (red)

---

### Step 5: Test Task Type Selection

1. Click Spinner (default: "Task 1")
2. Select "Task 2"
3. Observe:
   - [ ] Spinner shows "Task 2"
   - [ ] Selected value persists

---

### Step 6: Submit Essay

1. Clear essay & write new one (or keep existing 150+ words)
2. Click "Submit Essay" button
3. Observe:
   - [ ] Loading spinner appears: "AI is evaluating your essay..."
   - [ ] "Submit Essay" button disabled
   - [ ] Keyboard hides automatically

**Expected Response Time:** 2-5 seconds (might be longer for AI processing)

---

### Step 7: Verify AI Evaluation Result

After submission succeeds, page transitions to `WritingResultActivity`

Verify you see:
- [ ] **Overall Band Score**: Shows 0-9 (e.g., "7.5")
- [ ] **4 Criteria Scores** with progress bars:
  - [ ] Task Achievement: 0-9
  - [ ] Coherence & Cohesion: 0-9
  - [ ] Lexical Resource: 0-9
  - [ ] Grammatical Range: 0-9

- [ ] **Strengths Section** (green border):
  - [ ] Header: "✓ Strengths"
  - [ ] Bullet points with feedback

- [ ] **Areas for Improvement** (orange border):
  - [ ] Header: "⚠ Areas for Improvement"
  - [ ] Bullet points with suggestions

- [ ] **Action Buttons**:
  - [ ] "Try Again" button (red, clickable)
  - [ ] "Finish" button (outlined red, clickable)

---

### Step 8: Try Again Flow

1. Click "Try Again" button
2. Observe:
   - [ ] Return to WritingSubmissionActivity
   - [ ] Essay text cleared
   - [ ] Ready for new submission

---

### Step 9: Finish Flow

1. Click "Finish" button
2. Observe:
   - [ ] Navigate back to ExerciseDetailActivity
   - [ ] Exercise shows updated score/result

---

## 🔗 Phase 2: API Testing (Postman)

### Setup Postman

1. Import collection: `postman/Writing_Submission_Tests.postman_collection.json`
2. Set environment variables:
   ```
   baseUrl = http://localhost:8080
   token = <your-jwt-token>
   exerciseId = <writing-exercise-id>
   ```

### Run Tests

#### Test 1: Start Writing Submission
```
POST http://localhost:8080/api/v1/submissions
Body: {
  "exercise_id": "{{exerciseId}}",
  "is_practice": true
}
```
**Expected:** 200 OK, returns `submissionId`

---

#### Test 2: Submit Writing Essay
```
POST http://localhost:8080/api/v1/submissions/{{submissionId}}/submit
Body: {
  "writing_data": {
    "essay_text": "...(150+ words)...",
    "word_count": 250,
    "task_type": "task2",
    "prompt_text": "..."
  },
  "time_spent_seconds": 1200,
  "is_official_test": false
}
```
**Expected:** 200 OK

---

#### Test 3: Get Submission Result
```
GET http://localhost:8080/api/v1/submissions/{{submissionId}}/result
```
**Expected:** 200 OK, returns submission with AI evaluation

**Polling Strategy:**
- Call every 3 seconds
- Check if `ai_data.evaluation_status` = "completed"
- Max wait: 60 seconds

---

#### Test 4: Validation - Empty Essay
```
POST http://localhost:8080/api/v1/submissions/{{submissionId}}/submit
Body: {
  "writing_data": {
    "essay_text": "",
    "word_count": 0,
    "task_type": "task1"
  }
}
```
**Expected:** 400 Bad Request

---

#### Test 5: Validation - Short Essay
```
POST http://localhost:8080/api/v1/submissions/{{submissionId}}/submit
Body: {
  "writing_data": {
    "essay_text": "Short essay with less than 150 words.",
    "word_count": 8,
    "task_type": "task1"
  }
}
```
**Expected:** 200 OK (or 400 if backend enforces minimum)

---

## 📊 Test Results Template

```markdown
# Writing Submission Test Results

Date: ___________
Tester: ___________
Device: ___________
Android Version: ___________

## Android App Tests

### Scenario 1: Navigation
- Status: [ ] PASS [ ] FAIL [ ] SKIP
- Notes: _________________

### Scenario 2: Word Count Validation
- Status: [ ] PASS [ ] FAIL [ ] SKIP
- Notes: _________________

### Scenario 3: Task Type Selection
- Status: [ ] PASS [ ] FAIL [ ] SKIP
- Notes: _________________

### Scenario 4: Submit Essay
- Status: [ ] PASS [ ] FAIL [ ] SKIP
- Notes: _________________

### Scenario 5: AI Result Display
- Status: [ ] PASS [ ] FAIL [ ] SKIP
- Notes: _________________

### Scenario 6: Try Again
- Status: [ ] PASS [ ] FAIL [ ] SKIP
- Notes: _________________

### Scenario 7: Finish
- Status: [ ] PASS [ ] FAIL [ ] SKIP
- Notes: _________________

### Scenario 8: Error Handling
- Status: [ ] PASS [ ] FAIL [ ] SKIP
- Notes: _________________

## API Tests (Postman)

### Test 1: Start Submission
- Status: [ ] PASS [ ] FAIL
- Response Time: _____ ms
- Notes: _________________

### Test 2: Submit Essay
- Status: [ ] PASS [ ] FAIL
- Response Time: _____ ms
- Notes: _________________

### Test 3: Get Result
- Status: [ ] PASS [ ] FAIL
- AI Status: [ ] Pending [ ] Completed
- Response Time: _____ ms
- Notes: _________________

## Issues Found

1. **Issue**: _________________
   - **Severity**: [ ] Critical [ ] High [ ] Medium [ ] Low
   - **Steps to Reproduce**: _________________
   - **Expected**: _________________
   - **Actual**: _________________

2. (Add more as needed)

## Summary

- Total Tests: ___
- Passed: ___
- Failed: ___
- Skipped: ___

Overall Status: [ ] READY FOR PRODUCTION [ ] NEEDS FIXES
```

---

## 🐛 Troubleshooting

### App Crashes on WritingSubmissionActivity
**Solution:** Check logcat for errors
```bash
adb logcat | grep WritingSubmissionActivity
```

### EditText not showing keyboard
**Solution:** Add focus on resume:
```java
@Override
protected void onResume() {
    super.onResume();
    binding.etEssayText.requestFocus();
}
```

### Word count not updating
**Solution:** Check TextWatcher is attached:
```java
binding.etEssayText.addTextChangedListener(new TextWatcher() {
    // Implementation
});
```

### Loading spinner never disappears
**Solution:** Check API timeout and retry logic in ViewModel

### AI Result not displaying
**Solution:** 
1. Verify `DetailedSubmissionResult` parsing
2. Check if `ai_data` field exists in response
3. Add debugging: `Log.d(TAG, "AI Data: " + result.getAiData());`

---

## ✅ Success Criteria

Writing submission is **READY** when:
- [ ] All 8 Android scenarios PASS
- [ ] All 5 API tests PASS
- [ ] UI displays correctly with red brand colors
- [ ] Word count validation works
- [ ] AI evaluation displays with all 4 criteria scores
- [ ] No critical errors in logcat
- [ ] Response times < 5 seconds (API only)

---

## 📝 Next Steps (After Passing Tests)

1. ✅ Writing submission complete
2. 📱 Implement Speaking submission (Phase 2)
3. 🎤 Add audio recording functionality
4. 🔧 Implement profile management
5. 📊 Add analytics & reporting

---

**Questions?** Check the test plan: `WRITING_TEST_PLAN.md`
