#!/bin/bash

# Test Unified Submission Endpoint (Phase 4)
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiYTAwMDAwMDEtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDAxIiwiZW1haWwiOiJhZG1pbkBpZWx0c3BsYXRmb3JtLmNvbSIsInJvbGUiOiJhZG1pbiIsImV4cCI6MTc2MjQ2MDcwOSwibmJmIjoxNzYyMzc0MzA5LCJpYXQiOjE3NjIzNzQzMDl9.LmpsLkAIMHGZa-T5yHYPxb8PJ44WE1PE8-gM_-Lyavk"
SUBMISSION_ID="4765395b-a086-4e29-ad3c-b50213017939"

echo "=== Testing Unified Submission Endpoint (Listening) ==="
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

echo -e "\n=== Getting Submission Result ==="
curl -s -X GET "http://localhost:8080/api/v1/submissions/${SUBMISSION_ID}/result" \
  -H "Authorization: Bearer $TOKEN" | jq .
