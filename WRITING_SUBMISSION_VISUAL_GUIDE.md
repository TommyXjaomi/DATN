# 📱 Writing Submission - Visual Testing Guide

## 🎬 Screen Flow (What User Sees)

### Screen 1: Study Section → Find Writing Exercise
```
┌─────────────────────────────────┐
│  🔴 IELTSGo                     │
├─────────────────────────────────┤
│  Study Exercises                │
│                                 │
│  📖 Reading (10 exercises)      │
│  🎧 Listening (15 exercises)    │
│  ✏️  WRITING (5 exercises)      │◄─── TAP HERE
│  🎤 Speaking (8 exercises)      │
│                                 │
└─────────────────────────────────┘
```

### Screen 2: Writing Exercise Detail
```
┌─────────────────────────────────┐
│  🔴 IELTS Writing Task 2        │
├─────────────────────────────────┤
│  Difficulty: Advanced          │
│  Estimated time: 40 min        │
│  Success rate: 65%             │
│                                 │
│  📝 Write about technology      │
│  and its impact on society...   │
│                                 │
│  ┌─────────────────────────────┐│
│  │ START EXERCISE              ││◄─── TAP
│  └─────────────────────────────┘│
│                                 │
└─────────────────────────────────┘
```

### Screen 3: Writing Submission Form [NEW]
```
┌─────────────────────────────────┐
│  🔴 Writing Submission          │
├─────────────────────────────────┤
│  Task Type: [Task 1 ▼]          │
│                                 │
│  Prompt:                        │
│  ┌─────────────────────────────┐│
│  │ Technology has changed our  ││
│  │ communication methods...    ││
│  └─────────────────────────────┘│
│                                 │
│  Your Essay:              ┌──────┤
│  ┌─────────────────────────┐   ││
│  │ Type your essay here... │   ││ 245 words ◄─ Updates live
│  │                         │   ││
│  │ Technology has changed  │   ││
│  │ our world significantly.│   ││
│  │ Email, instant messaging,  ││
│  │ and video calls enable  │   ││
│  │ people to communicate... │   ││
│  │                         │   ││
│  │ [MORE TEXT...]          │   ││
│  └─────────────────────────┘   ││
│                                 │
│  ┌─────────────────────────────┐│
│  │ 💡 Writing Tips             ││
│  │ • Min 150 words             ││
│  │ • Clear structure           ││
│  │ • Check grammar             ││
│  │ • Use varied vocabulary     ││
│  └─────────────────────────────┘│
│                                 │
│  ┌──────────────────┐ ┌────────┐│
│  │ SUBMIT ESSAY 🔴  │ │ Draft  ││
│  └──────────────────┘ └────────┘│
│                                 │
└─────────────────────────────────┘
```

### Screen 4: During Submission (Loading State)
```
┌─────────────────────────────────┐
│  🔴 Writing Submission          │
├─────────────────────────────────┤
│                                 │
│          ⟳⟳⟳ (spinner)         │
│                                 │
│   AI is evaluating your essay...│
│                                 │
│        Please wait...           │
│                                 │
│       (Response time: 5-30s)    │
│                                 │
└─────────────────────────────────┘
```

### Screen 5: AI Evaluation Result [NEW]
```
┌─────────────────────────────────┐
│  🔴 AI Evaluation Result        │
├─────────────────────────────────┤
│  ┌─────────────────────────────┐│
│  │  OVERALL BAND SCORE        ││
│  │      7.5                   ││ ◄─ Out of 9.0
│  │  Completed                 ││
│  └─────────────────────────────┘│
│                                 │
│  Detailed Criteria Scores       │
│  ────────────────────────────   │
│                                 │
│  Task Achievement ───── 7.0 🔴  │
│  ████████░░ 70%                 │
│                                 │
│  Coherence & Cohesion ── 7.5 🔴 │
│  ████████░░ 75%                 │
│                                 │
│  Lexical Resource ────── 7.5 🔴 │
│  ████████░░ 75%                 │
│                                 │
│  Grammatical Range ───── 8.0 🔴 │
│  █████████░ 80%                 │
│                                 │
│  ┌─────────────────────────────┐│
│  │ ✓ Strengths                 ││
│  │ • Well-structured essay     ││
│  │ • Good vocabulary usage     ││
│  │ • Clear arguments           ││
│  └─────────────────────────────┘│
│                                 │
│  ┌─────────────────────────────┐│
│  │ ⚠ Areas for Improvement    ││
│  │ • More diverse transitions  ││
│  │ • Watch out for spelling    ││
│  │ • Expand on examples        ││
│  └─────────────────────────────┘│
│                                 │
│  ┌──────────────────┐ ┌────────┐│
│  │ TRY AGAIN 🔴    │ │ FINISH ││
│  └──────────────────┘ └────────┘│
│                                 │
└─────────────────────────────────┘
```

---

## 🎨 Color Scheme Used

```
Primary Red (Buttons)      #E52E2E  🔴
Dark Red (Active)          #C81E1E  🔴
Text Color                 #111827  ⬛
Secondary Text             #6B7280  ⬜
Input Background           #F1F2F5  ⬜
Success (Strengths)        #22C55E  🟢
Warning (Improvements)     #F59E0B  🟠
Error                      #EF4444  🔴
```

---

## 📊 Data Flow Diagram

```
User Input Essay
    │
    ▼
Client Validation
(min 150 words)
    │
    ├─ Invalid → Show Error
    │
    └─ Valid
        │
        ▼
    POST /api/v1/submissions/{id}/submit
    {
      writing_data: {
        essay_text: "...",
        word_count: 250,
        task_type: "task2",
        prompt_text: "..."
      },
      time_spent_seconds: 1200
    }
        │
        ▼
    Backend Processing
        │
        ├─ Save submission
        │
        └─ Call AI Service (async)
            │
            ├─ Transcribe (if speaking)
            │
            └─ Evaluate with GPT-4
                │
                ├─ Task Achievement score
                ├─ Coherence & Cohesion score
                ├─ Lexical Resource score
                ├─ Grammatical Range score
                ├─ Overall band
                ├─ Strengths
                └─ Areas for improvement
        │
        ▼
    GET /api/v1/submissions/{id}/result
    (poll every 3 seconds)
        │
        ▼
    Response received
        │
        ▼
    Display Results
        │
        ├─ Overall band score
        ├─ 4 criteria scores
        ├─ Strengths
        └─ Improvements
```

---

## ⌨️ User Interactions

### Keyboard Interactions
```
EditText focused
│
├─ Typing → Word counter updates (real-time)
├─ Backspace → Counter decreases
├─ Pasting → Counter updates
│
└─ When unfocused → Keyboard hides
```

### Button States
```
Submit Button State:
├─ Enabled (Red)  → word_count >= 150
└─ Disabled (Gray)→ word_count < 150

Spinner:
└─ Click → Show options [Task 1, Task 2]

Try Again:
└─ Click → Back to WritingSubmissionActivity

Finish:
└─ Click → Back to ExerciseDetailActivity
```

---

## 🔔 Toast Messages

| Scenario | Message |
|----------|---------|
| Empty essay | "Essay text is empty" |
| Too short | "Essay must have at least 150 words" |
| Successful submit | (transition to result screen) |
| Network error | "Network error" |
| Server error | "Submission failed: [error message]" |
| Draft saved | "Draft saved" |

---

## 📱 Responsive Layout Notes

- Works on portrait orientation (default)
- ScrollView for long essays
- Buttons at bottom (always visible)
- EditText expands based on content

---

## 🎯 Key Testing Checkpoints

### Visual Checkpoints
- [ ] Red theme consistent throughout
- [ ] All text readable (font sizes appropriate)
- [ ] Buttons clickable and responsive
- [ ] Progress bars animate smoothly
- [ ] No UI overlaps or cutoffs

### Functional Checkpoints
- [ ] Word counter updates in real-time
- [ ] Submit button enable/disable logic works
- [ ] Task type persists during session
- [ ] Results display all 4 criteria scores
- [ ] Strength/improvement bullets display correctly
- [ ] Navigation flows work (Try Again, Finish)

### Performance Checkpoints
- [ ] Form loads in < 2 seconds
- [ ] Word count updates responsive (no lag)
- [ ] Submission completes in < 5 seconds
- [ ] Result display smooth without flicker

---

## 💡 Pro Testing Tips

1. **Test Edge Cases:**
   - Exactly 150 words
   - Very long essay (5000+ words)
   - Essay with special characters
   - Rapid typing

2. **Test Network Scenarios:**
   - Slow network (emulate 3G)
   - Network timeout during submission
   - Offline mode after submission started

3. **Test Device Scenarios:**
   - Small screen (400x600)
   - Large screen (1080x1920)
   - Landscape orientation
   - Low RAM device

---

## 📞 Quick Help

**Word count not updating?**
→ Check TextWatcher attached to EditText

**Submit button always disabled?**
→ Verify word count calculation logic

**Loading spinner stuck?**
→ Check API timeout settings

**Results not showing?**
→ Verify AI Service running and responding

**Wrong colors?**
→ Check `colors.xml` matches brand colors

---

**Ready to test? Start with WRITING_TEST_PLAN.md** ✅
