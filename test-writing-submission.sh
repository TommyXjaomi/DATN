#!/bin/bash

# Get fresh token
TOKEN=$(curl -s -X POST http://localhost:8081/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@ieltsplatform.com","password":"password123"}' | jq -r '.data.access_token')

WRITING_EXERCISE_ID="e2000001-0000-0000-0000-000000000001"

echo "=== Testing Writing Submission (Async AI Evaluation) ==="
echo "Token: ${TOKEN:0:50}..."
echo ""

echo "1. Starting Writing Exercise..."
SUBMISSION_RESPONSE=$(curl -s -X POST "http://localhost:8080/api/v1/exercises/${WRITING_EXERCISE_ID}/start" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{}')

echo "$SUBMISSION_RESPONSE" | jq .

SUBMISSION_ID=$(echo "$SUBMISSION_RESPONSE" | jq -r '.data.id')
echo ""
echo "Submission ID: $SUBMISSION_ID"
echo ""

echo "2. Submitting Writing Essay..."
SUBMIT_RESPONSE=$(curl -s -X POST "http://localhost:8080/api/v1/submissions/${SUBMISSION_ID}/submit" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "writing_data": {
      "essay_text": "Environmental protection has become a pressing global issue in recent years. While some people argue that governments should take primary responsibility for protecting the environment, others believe individuals should also play an active role. In my opinion, both parties need to work together to address this challenge effectively.\n\nThose who advocate for government responsibility argue that environmental problems require large-scale solutions that only governments can implement. For instance, governments have the power to enforce strict environmental regulations, invest in renewable energy infrastructure, and negotiate international climate agreements. The Paris Agreement is a prime example of how governmental cooperation can lead to meaningful environmental protection measures on a global scale.\n\nOn the other hand, individual actions are equally important in the fight against environmental degradation. Every person can contribute by adopting sustainable practices such as reducing plastic use, conserving energy, and choosing eco-friendly transportation options. When millions of individuals make these small changes, the cumulative effect can be substantial. Moreover, consumer demand for sustainable products can pressure companies to adopt more environmentally friendly practices.\n\nIn conclusion, I believe that environmental protection requires a collaborative approach involving both governments and individuals. Governments must create the regulatory framework and infrastructure, while individuals need to take personal responsibility for their environmental impact. Only through this combined effort can we hope to preserve our planet for future generations.",
      "word_count": 253,
      "task_type": "task2",
      "prompt_text": "Some people believe that protecting the environment is the government'\''s responsibility, while others think individuals should take action. Discuss both views and give your opinion."
    },
    "time_spent_seconds": 2400,
    "is_official_test": false
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
echo "5. Checking User Service Practice Activity..."
docker exec ielts_postgres psql -U ielts_admin -d user_db -c "SELECT user_id, exercise_id, skill, band_score, created_at FROM practice_activities WHERE exercise_id = '${WRITING_EXERCISE_ID}' ORDER BY created_at DESC LIMIT 1;" -t
