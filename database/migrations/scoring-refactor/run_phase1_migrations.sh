#!/bin/bash

# Master Migration Script for Scoring System Refactoring
# Phase 1: Database Schema Updates
# Run date: $(date +"%Y-%m-%d %H:%M:%S")

set -e  # Exit on error

SCRIPT_DIR="/Users/bisosad/DATN/database/migrations/scoring-refactor"
POSTGRES_CONTAINER="ielts_postgres"
POSTGRES_USER="ielts_admin"

echo "=========================================="
echo "PHASE 1: DATABASE SCHEMA UPDATES"
echo "=========================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to run migration
run_migration() {
    local db_name=$1
    local migration_file=$2
    local description=$3
    
    echo -e "${YELLOW}➜${NC} Running: $description"
    echo "  Database: $db_name"
    echo "  File: $migration_file"
    
    if docker exec -i $POSTGRES_CONTAINER psql -U $POSTGRES_USER -d $db_name < "$SCRIPT_DIR/$migration_file"; then
        echo -e "${GREEN}✅ Success${NC}"
    else
        echo -e "${RED}❌ Failed${NC}"
        echo "Migration failed! Please check errors above."
        exit 1
    fi
    echo ""
}

echo "🔄 Starting migrations..."
echo ""

# ========================================
# USER_DB MIGRATIONS
# ========================================
echo "📊 DATABASE: user_db"
echo "=========================================="

run_migration "user_db" "001_create_official_test_results.sql" \
    "Create official_test_results table"

run_migration "user_db" "002_create_practice_activities.sql" \
    "Create practice_activities table"

run_migration "user_db" "003_update_learning_progress.sql" \
    "Update learning_progress table"

run_migration "user_db" "004_update_skill_statistics.sql" \
    "Update skill_statistics table"

echo ""

# ========================================
# EXERCISE_DB MIGRATIONS
# ========================================
echo "📊 DATABASE: exercise_db"
echo "=========================================="

run_migration "exercise_db" "005_update_exercises_table.sql" \
    "Update exercises table (add test categorization)"

run_migration "exercise_db" "006_update_user_exercise_attempts.sql" \
    "Update user_exercise_attempts (support all 4 skills)"

echo ""

# ========================================
# AI_DB MIGRATIONS
# ========================================
echo "📊 DATABASE: ai_db"
echo "=========================================="

run_migration "ai_db" "007_create_ai_evaluation_cache.sql" \
    "Create AI evaluation cache table"

echo ""
echo "=========================================="
echo -e "${GREEN}✅ ALL MIGRATIONS COMPLETED SUCCESSFULLY!${NC}"
echo "=========================================="
echo ""

# Verification queries
echo "🔍 Running verification queries..."
echo ""

echo "user_db tables:"
docker exec $POSTGRES_CONTAINER psql -U $POSTGRES_USER -d user_db -c "\dt official_test_results"
docker exec $POSTGRES_CONTAINER psql -U $POSTGRES_USER -d user_db -c "\dt practice_activities"

echo ""
echo "exercise_db columns (user_exercise_attempts):"
docker exec $POSTGRES_CONTAINER psql -U $POSTGRES_USER -d exercise_db -c "\d user_exercise_attempts" | grep -E "(essay_text|audio_url|evaluation_status|is_official_test)"

echo ""
echo "ai_db tables:"
docker exec $POSTGRES_CONTAINER psql -U $POSTGRES_USER -d ai_db -c "\dt ai_evaluation_cache"

echo ""
echo -e "${GREEN}✅ Phase 1 migrations complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Review verification output above"
echo "  2. Test migrations in development"
echo "  3. Proceed to Phase 2: Shared Library Implementation"
echo ""
