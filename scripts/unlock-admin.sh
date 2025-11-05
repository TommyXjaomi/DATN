#!/bin/bash
# Quick script để unlock admin account và test login

echo "=== Unlocking Admin Account ==="

docker-compose exec -T postgres psql -U ielts_admin -d auth_db <<'EOF'
UPDATE users 
SET failed_login_attempts = 0, 
    locked_until = NULL 
WHERE email = 'test_admin@ielts.com';
EOF

echo ""
echo "=== Testing Login ==="
curl -s -X POST "http://localhost:8080/api/v1/auth/login" \
  -H 'Content-Type: application/json' \
  -d '{"email":"test_admin@ielts.com","password":"Test@123"}' | jq -r '.success, .data.token[:30]'

echo ""
echo "Done!"




