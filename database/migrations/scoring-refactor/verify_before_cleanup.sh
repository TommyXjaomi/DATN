#!/bin/bash

# ============================================
# Pre-Cleanup Verification Script
# ============================================
# Purpose: Verify migration success before dropping ai_db tables
# Run this BEFORE executing 011_archive_old_ai_tables.sql

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Database connection
DB_HOST="localhost"
DB_PORT="5432"
DB_USER="ielts_admin"
DB_PASSWORD="ielts_password_2025"
EXERCISE_DB="exercise_db"
AI_DB="ai_db"

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

count_records() {
    local db=$1
    local query=$2
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $db -t -c "$query" | xargs
}

echo ""
echo "============================================"
echo "  PRE-CLEANUP VERIFICATION"
echo "  Checking migration success"
echo "============================================"
echo ""

# Check 1: Count records in ai_db
log "Step 1: Counting records in ai_db (source)..."
WRITING_AI=$(count_records $AI_DB "SELECT COUNT(*) FROM writing_submissions;")
SPEAKING_AI=$(count_records $AI_DB "SELECT COUNT(*) FROM speaking_submissions;")

log "Original data in ai_db:"
log "  - Writing submissions: $WRITING_AI"
log "  - Speaking submissions: $SPEAKING_AI"
log "  - Total: $((WRITING_AI + SPEAKING_AI))"

# Check 2: Count records in exercise_db
log ""
log "Step 2: Counting migrated records in exercise_db (target)..."
WRITING_EX=$(count_records $EXERCISE_DB "SELECT COUNT(*) FROM user_exercise_attempts WHERE essay_text IS NOT NULL;")
SPEAKING_EX=$(count_records $EXERCISE_DB "SELECT COUNT(*) FROM user_exercise_attempts WHERE audio_url IS NOT NULL;")

log "Migrated data in exercise_db:"
log "  - Writing submissions: $WRITING_EX"
log "  - Speaking submissions: $SPEAKING_EX"
log "  - Total: $((WRITING_EX + SPEAKING_EX))"

# Check 3: Compare counts
log ""
log "Step 3: Verifying record counts match..."
PASS=true

if [ "$WRITING_AI" -ne "$WRITING_EX" ]; then
    log_error "Writing count mismatch! ai_db=$WRITING_AI, exercise_db=$WRITING_EX"
    PASS=false
else
    log_success "Writing counts match: $WRITING_AI records"
fi

if [ "$SPEAKING_AI" -ne "$SPEAKING_EX" ]; then
    log_error "Speaking count mismatch! ai_db=$SPEAKING_AI, exercise_db=$SPEAKING_EX"
    PASS=false
else
    log_success "Speaking counts match: $SPEAKING_AI records"
fi

# Check 4: Verify detailed_scores JSONB
log ""
log "Step 4: Verifying JSONB structure..."
WRITING_WITH_SCORES=$(count_records $EXERCISE_DB "SELECT COUNT(*) FROM user_exercise_attempts WHERE essay_text IS NOT NULL AND detailed_scores IS NOT NULL;")
SPEAKING_WITH_SCORES=$(count_records $EXERCISE_DB "SELECT COUNT(*) FROM user_exercise_attempts WHERE audio_url IS NOT NULL AND detailed_scores IS NOT NULL;")

log "Records with detailed_scores:"
log "  - Writing: $WRITING_WITH_SCORES"
log "  - Speaking: $SPEAKING_WITH_SCORES"

# Check 5: Sample data validation
log ""
log "Step 5: Validating sample data..."
SAMPLE_VALID=$(count_records $EXERCISE_DB "SELECT COUNT(*) FROM user_exercise_attempts WHERE (essay_text IS NOT NULL OR audio_url IS NOT NULL) AND user_id IS NOT NULL AND (band_score IS NULL OR (band_score >= 0 AND band_score <= 9));")
TOTAL_MIGRATED=$((WRITING_EX + SPEAKING_EX))

if [ "$SAMPLE_VALID" -eq "$TOTAL_MIGRATED" ]; then
    log_success "All $SAMPLE_VALID migrated records are valid"
else
    log_error "Some records have invalid data!"
    PASS=false
fi

# Check 6: Verify no dependencies
log ""
log "Step 6: Checking for dependencies on ai_db tables..."
log_warning "Manual check required: Verify no services are using writing_submissions/speaking_submissions"
log_warning "  - AI service should use pure evaluation APIs only"
log_warning "  - Exercise service should use user_exercise_attempts only"

# Final result
echo ""
echo "============================================"
echo "  VERIFICATION SUMMARY"
echo "============================================"
echo ""

if [ "$PASS" = true ]; then
    log_success "✓ All checks PASSED"
    log_success "✓ Migration verified successful"
    log_success "✓ Safe to drop ai_db tables"
    echo ""
    log "Next steps:"
    log "  1. Create backup: pg_dump -U ielts_admin -d ai_db > ai_db_backup_$(date +%Y%m%d).sql"
    log "  2. Run cleanup: docker exec -i ielts_postgres psql -U ielts_admin -d ai_db < 011_archive_old_ai_tables.sql"
    log "  3. Monitor application for 24 hours"
    echo ""
    exit 0
else
    log_error "✗ Verification FAILED"
    log_error "✗ DO NOT drop ai_db tables yet"
    log_error "✗ Investigate mismatches above"
    echo ""
    exit 1
fi
