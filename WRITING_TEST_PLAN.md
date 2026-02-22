# Writing Submission Test Plan

## 📋 Test Scenarios

### Scenario 1: Navigate to Writing Exercise
**Steps:**
1. Launch app & login
2. Go to "Study" section
3. Find any "Writing" exercise (skill_type = "writing")
4. Click "Start Exercise"

**Expected Result:**
- App detects writing skill type
- Auto-redirects to `WritingSubmissionActivity`
- Shows writing prompt on screen
- NO Loading indicator

---

### Scenario 2: Word Count Validation
**Steps:**
1. On WritingSubmissionActivity
2. Type essay with < 150 words (e.g., 100 words)

**Expected Result:**
- Word counter updates in real-time: "100 words"
- Warning message appears: "Minimum 150 words required (100/150)"
- "Submit Essay" button is **DISABLED** (grayed out)

**Steps:**
3. Continue typing to reach 150+ words

**Expected Result:**
- Word counter updates: "150 words"
- Warning message disappears
- "Submit Essay" button is **ENABLED**

---

### Scenario 3: Task Type Selection
**Steps:**
1. From WritingSubmissionActivity, check Spinner
2. Default should be "Task 1"
3. Click Spinner → Select "Task 2"

**Expected Result:**
- Spinner shows "Task 2" selected
- Task type should be saved for submission

---

### Scenario 4: Submit Writing Essay
**Steps:**
1. Type essay (150+ words)
2. Click "Submit Essay" button

**Expected Result:**
- Loading indicator appears
- "Submit Essay" button becomes disabled
- POST request sent: `/api/v1/submissions/{submissionId}/submit`
- Request payload:
  ```json
  {
    "writing_data": {
      "essay_text": "...",
      "word_count": 250,
      "task_type": "task2",
      "prompt_text": "..."
    },
    "time_spent_seconds": 1200
  }
  ```

---

### Scenario 5: AI Evaluation Result Display
**Steps:**
1. After successful submission (previous scenario)
2. Wait for AI evaluation (may take 5-30 seconds)

**Expected Result:**
- Page transitions to WritingResultActivity
- Shows:
  - ✅ Overall Band Score (e.g., "7.5")
  - 4 Criteria Scores with progress bars:
    - Task Achievement: 7.0
    - Coherence & Cohesion: 7.5
    - Lexical Resource: 7.5
    - Grammatical Range: 8.0
  - Strengths section (green border) with bullet points
  - Areas for Improvement section (orange border) with bullet points
  - "Try Again" button (red)
  - "Finish" button (outline red)

---

### Scenario 6: Try Again Flow
**Steps:**
1. On WritingResultActivity
2. Click "Try Again" button

**Expected Result:**
- Return to WritingSubmissionActivity
- Clear essay text (or keep it for editing)
- Ready for another submission

---

### Scenario 7: Finish Flow
**Steps:**
1. On WritingResultActivity
2. Click "Finish" button

**Expected Result:**
- Navigate back to ExerciseDetailActivity
- Show previous exercise with updated score/result

---

### Scenario 8: Error Handling
**Test Cases:**

#### 8.1: Empty Essay Submit
**Steps:**
1. On WritingSubmissionActivity
2. Click "Submit Essay" without typing

**Expected Result:**
- Toast message: "Essay text is empty"
- Submit doesn't proceed

#### 8.2: Network Error
**Steps:**
1. Disable internet connection
2. Try to submit essay

**Expected Result:**
- Toast message: "Network error"
- Error message displayed
- Submit button re-enabled

#### 8.3: Server Error
**Steps:**
1. Submit valid essay
2. Server returns 500 error

**Expected Result:**
- Toast message showing error
- Option to retry

---

## 🎨 UI Verification Checklist

### WritingSubmissionActivity Layout:
- [ ] Red toolbar with white text
- [ ] Prompt displayed in gray background
- [ ] Task Type spinner visible
- [ ] EditText with light input field background
- [ ] Word counter shows real-time count
- [ ] Warning message in red when < 150 words
- [ ] Tips card with blue header
- [ ] "Submit Essay" button (red, rounded)
- [ ] "Save Draft" button (outlined red)

### WritingResultActivity Layout:
- [ ] Red toolbar with white text
- [ ] Loading spinner while evaluating
- [ ] Overall band score in large font
- [ ] 4 criteria scores with progress bars
- [ ] Green border for Strengths section
- [ ] Orange border for Improvements section
- [ ] "Try Again" button (red)
- [ ] "Finish" button (outlined red)

---

## 🔗 API Integration Verification

### Check Network Traffic:
Use Android Studio's Network Profiler to verify:

1. **POST Request to `/api/v1/submissions/{id}/submit`**
   - Method: POST
   - Status: 200 OK
   - Body: SubmitExerciseRequest with WritingSubmissionData
   - Headers: Auth token included

2. **Polling for Result**
   - GET `/api/v1/submissions/{id}/result` (every 2-3 seconds)
   - Response: DetailedSubmissionResult with AI evaluation

---

## ⚠️ Known Limitations

1. **Draft Saving**: "Save Draft" button shows toast but doesn't save (future feature)
2. **AI Evaluation Time**: May take 5-30 seconds depending on essay length
3. **Audio**: Speaking is phase 2 (not in this release)

---

## 📝 Test Log Template

```
Date: ___________
Device: ___________
Android Version: ___________

Test Case: ___________
Status: [PASS / FAIL / SKIP]
Notes: ___________

Issue Found: ___________
Severity: [Critical / High / Medium / Low]
```

---

## 🚀 How to Run Test

### Option 1: Local Android Emulator
```bash
cd ieltsapp
./gradlew installDebug
adb shell am start -n com.example.ieltsapp/.ui.menu.MenuActivity
```

### Option 2: Physical Device
1. Connect Android device via USB
2. Enable USB debugging
3. Run: `./gradlew installDebug`

### Option 3: Android Studio
1. Open project in Android Studio
2. Click "Run App" (or Shift+F10)
3. Select emulator/device

---

## 🐛 Debug Tips

### Enable Logging:
Add this in WritingSubmissionActivity:
```java
Log.d("WritingSubmission", "Essay text: " + essayText);
Log.d("WritingSubmission", "Word count: " + wordCount);
Log.d("WritingSubmission", "Submitting to: " + submissionId);
```

### Check Network:
- Android Studio → Profiler → Network
- Monitor API calls in real-time
- Check request/response payloads

### Check Database:
- Android Studio → App Inspection → Database
- Verify submission data saved locally

---

## ✅ Test Success Criteria

All scenarios pass without critical errors and UI displays correctly with brand colors (red theme).
