#!/bin/bash

# Test OFFICIAL Writing Test submission

# Get fresh token
TOKEN=$(curl -s -X POST http://localhost:8081/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@ieltsplatform.com","password":"password123"}' | jq -r '.data.access_token')

OFFICIAL_WRITING_TEST_ID="e2000002-0000-0000-0000-000000000001"
USER_ID="a0000001-0000-0000-0000-000000000001"

echo "=== Testing OFFICIAL Writing Test Submission ==="
echo "Token: ${TOKEN:0:50}..."
echo ""

# Check current scores BEFORE test
echo "📊 Current scores BEFORE test:"
docker exec ielts_postgres sh -c "psql -U \$POSTGRES_USER -d user_db -c \"SELECT user_id, listening_score, reading_score, writing_score, speaking_score, overall_score FROM learning_progress WHERE user_id = '$USER_ID';\" -t"
echo ""

echo "1. Starting OFFICIAL Writing Test..."
SUBMISSION_RESPONSE=$(curl -s -X POST "http://localhost:8080/api/v1/exercises/${OFFICIAL_WRITING_TEST_ID}/start" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{}')

echo "$SUBMISSION_RESPONSE" | jq .

SUBMISSION_ID=$(echo "$SUBMISSION_RESPONSE" | jq -r '.data.id')
echo ""
echo "Submission ID: $SUBMISSION_ID"
echo ""

echo "2. Submitting Essay for OFFICIAL Test..."
SUBMIT_RESPONSE=$(curl -s -X POST "http://localhost:8080/api/v1/submissions/${SUBMISSION_ID}/submit" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "writing_data": {
      "essay_text": "Education plays a crucial role in shaping children into responsible members of society. While some believe parents are the primary teachers of social values, others argue that schools should bear this responsibility. This essay will discuss both perspectives before presenting my own view.\n\nProponents of parental teaching argue that parents have the earliest and most consistent influence on their children. From birth, children observe and imitate their parents behavior, learning fundamental social skills like sharing, empathy, and respect. Moreover, parents can tailor their teaching to their child specific needs and cultural values, providing personalized guidance that generic school curricula cannot match. Research shows that children from homes with strong parental involvement tend to demonstrate better social skills and emotional intelligence.\n\nOn the other hand, advocates for school-based social education emphasize the unique advantages of formal educational settings. Schools provide structured environments where children interact with diverse peers, learning to navigate different personalities and perspectives. Teachers trained in child development can implement proven pedagogical methods to teach cooperation, conflict resolution, and civic responsibility. Additionally, schools offer consistency in social education, ensuring all children receive fundamental lessons regardless of their home environment variations.\n\nIn my opinion, optimal social development requires collaboration between parents and schools. Parents lay the foundation through modeling behavior and instilling core values, while schools build upon this foundation through structured social learning and peer interaction. Neither institution alone can adequately prepare children for complex modern society. Therefore, I believe both parents and schools share equal responsibility, with effective communication between them being crucial for raising well-adjusted, socially competent individuals.",
      "word_count": 285,
      "task_type": "task2",
      "prompt_text": "Some people think that parents should teach children how to be good members of society. Others, however, believe that school is the place to learn this. Discuss both these views and give your own opinion."
    },
    "time_spent_seconds": 2100,
    "is_official_test": true
  }')

echo "$SUBMIT_RESPONSE" | jq .
echo ""

echo "3. Waiting for AI evaluation (async)..."
sleep 3
echo ""

echo "4. Checking evaluation status..."
for i in {1..10}; do
  RESULT=$(curl -s -X GET "http://localhost:8080/api/v1/submissions/${SUBMISSION_ID}/result" \
    -H "Authorization: Bearer $TOKEN")
  
  STATUS=$(echo "$RESULT" | jq -r '.data.submission.evaluation_status // "pending"')
  BAND_SCORE=$(echo "$RESULT" | jq -r '.data.submission.band_score // "null"')
  
  echo "  Attempt $i: Status=$STATUS, Band Score=$BAND_SCORE"
  
  if [ "$STATUS" = "completed" ]; then
    echo ""
    echo "✅ Evaluation completed!"
    echo "$RESULT" | jq '.data.submission | {status, evaluation_status, band_score, essay_text: (.essay_text[:100] + "..."), ai_feedback: (.ai_feedback[:200] + "...")}'
    break
  fi
  
  sleep 5
done

echo ""
echo "5. Checking User Service - Official Test Result (should be recorded):"
docker exec ielts_postgres sh -c "psql -U \$POSTGRES_USER -d user_db -c \"SELECT test_type, overall_band_score, listening_score, reading_score, writing_score, speaking_score, test_date FROM official_test_results WHERE user_id = '$USER_ID' ORDER BY test_date DESC LIMIT 1;\" -t"

echo ""
echo "6. Checking learning_progress AFTER test (writing_score should be updated):"
docker exec ielts_postgres sh -c "psql -U \$POSTGRES_USER -d user_db -c \"SELECT user_id, listening_score, reading_score, writing_score, speaking_score, overall_score FROM learning_progress WHERE user_id = '$USER_ID';\" -t"
