#!/bin/bash

# Rollback Script for Phase 1 Migrations
# WARNING: This will revert all Phase 1 database changes
# Usage: ./rollback_phase1_migrations.sh

set -e  # Exit on error

SCRIPT_DIR="/Users/bisosad/DATN/database/migrations/scoring-refactor"
POSTGRES_CONTAINER="ielts_postgres"
POSTGRES_USER="ielts_admin"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo -e "${RED}⚠️  PHASE 1 ROLLBACK WARNING ⚠️${NC}"
echo "=========================================="
echo ""
echo "This will REVERT all Phase 1 database changes:"
echo "  - Drop official_test_results table"
echo "  - Drop practice_activities table"
echo "  - Revert learning_progress updates"
echo "  - Revert skill_statistics updates"
echo "  - Revert exercises table updates"
echo "  - Revert user_exercise_attempts updates"
echo "  - Drop ai_evaluation_cache table"
echo ""
read -p "Are you SURE you want to rollback? (type 'yes' to confirm): " -r
if [[ ! $REPLY == "yes" ]]; then
    echo "Rollback cancelled."
    exit 0
fi

echo ""
echo "🔄 Starting rollback..."
echo ""

# Function to run rollback
run_rollback() {
    local db_name=$1
    local rollback_file=$2
    local description=$3
    
    echo -e "${YELLOW}➜${NC} Rolling back: $description"
    echo "  Database: $db_name"
    echo "  File: $rollback_file"
    
    if docker exec -i $POSTGRES_CONTAINER psql -U $POSTGRES_USER -d $db_name < "$SCRIPT_DIR/$rollback_file"; then
        echo -e "${GREEN}✅ Rolled back successfully${NC}"
    else
        echo -e "${RED}❌ Rollback failed${NC}"
        echo "Rollback failed! Please check errors above."
        exit 1
    fi
    echo ""
}

# Run rollbacks in REVERSE order

# ========================================
# AI_DB ROLLBACKS
# ========================================
echo "📊 DATABASE: ai_db (rollback)"
echo "=========================================="

run_rollback "ai_db" "007_create_ai_evaluation_cache.rollback.sql" \
    "Drop AI evaluation cache table"

echo ""

# ========================================
# EXERCISE_DB ROLLBACKS
# ========================================
echo "📊 DATABASE: exercise_db (rollback)"
echo "=========================================="

run_rollback "exercise_db" "006_update_user_exercise_attempts.rollback.sql" \
    "Revert user_exercise_attempts updates"

run_rollback "exercise_db" "005_update_exercises_table.rollback.sql" \
    "Revert exercises table updates"

echo ""

# ========================================
# USER_DB ROLLBACKS
# ========================================
echo "📊 DATABASE: user_db (rollback)"
echo "=========================================="

run_rollback "user_db" "004_update_skill_statistics.rollback.sql" \
    "Revert skill_statistics updates"

run_rollback "user_db" "003_update_learning_progress.rollback.sql" \
    "Revert learning_progress updates"

run_rollback "user_db" "002_create_practice_activities.rollback.sql" \
    "Drop practice_activities table"

run_rollback "user_db" "001_create_official_test_results.rollback.sql" \
    "Drop official_test_results table"

echo ""
echo "=========================================="
echo -e "${GREEN}✅ ALL ROLLBACKS COMPLETED!${NC}"
echo "=========================================="
echo ""
echo "Database schemas have been reverted to pre-Phase 1 state."
echo ""
