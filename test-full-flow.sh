#!/bin/bash

# Get fresh token
TOKEN=$(curl -s -X POST http://localhost:8081/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@ieltsplatform.com","password":"password123"}' | jq -r '.data.access_token')

SUBMISSION_ID="2d357a30-76b6-407e-9c92-299b53777769"

echo "=== Testing Full Unified Submission Flow ==="
echo "Token: ${TOKEN:0:50}..."
echo "Submission ID: $SUBMISSION_ID"
echo ""

echo "1. Submitting Listening Exercise..."
curl -s -X POST "http://localhost:8080/api/v1/submissions/${SUBMISSION_ID}/submit" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "answers": [
      {"question_id": "ca0d9b4e-9f09-4694-bb95-06ef8c3a8e78", "text_answer": "A"},
      {"question_id": "2459a951-e8ea-4964-a53a-837fcf735f50", "text_answer": "C"},
      {"question_id": "cc4a5d25-3438-42e2-ae16-e87620504bc7", "text_answer": "library"},
      {"question_id": "069e96f8-90d8-405e-a294-f8e7fd8f6401", "text_answer": "Tuesday"},
      {"question_id": "bd2c2430-1ac6-4b6c-8b5c-50c13fd82dea", "text_answer": "Dr. Smith"},
      {"question_id": "61770218-b568-4323-aba1-02c0f22db844", "text_answer": "C"},
      {"question_id": "4b960269-baec-4aa9-a0d9-33d65eca588b", "text_answer": "research project"},
      {"question_id": "4639cb29-dfc4-4db8-b7a1-d0db0aa13e2d", "text_answer": "A"},
      {"question_id": "1be96566-ec89-487e-b270-b1e6e619beb0", "text_answer": "presentation"},
      {"question_id": "325e3616-9637-4a06-b993-29bb7de9ae69", "text_answer": "B"}
    ],
    "time_spent_seconds": 1200,
    "is_official_test": false
  }' | jq .

echo ""
echo "2. Waiting for async processing..."
sleep 5

echo ""
echo "3. Getting Submission Result..."
curl -s -X GET "http://localhost:8080/api/v1/submissions/${SUBMISSION_ID}/result" \
  -H "Authorization: Bearer $TOKEN" | jq '.data.submission | {status, band_score, correct_answers, total_questions, time_spent_seconds}'

echo ""
echo "4. Checking User Service Practice Activity..."
docker exec ielts_postgres psql -U ielts_admin -d user_db -c "SELECT user_id, exercise_id, band_score, created_at FROM practice_activities ORDER BY created_at DESC LIMIT 1;" -t
