#!/bin/bash

# Apply all scoring refactor migrations to user_db
# Usage: ./apply-scoring-migrations.sh

MIGRATIONS_DIR="/Users/bisosad/DATN/database/migrations/scoring-refactor"
DB_CONTAINER="ielts_postgres"
DB_USER="ielts_admin"
DB_NAME="user_db"

echo "🚀 Applying Scoring System Refactoring Migrations"
echo "=================================================="
echo ""

# Array of migration files in order
MIGRATIONS=(
    "001_create_official_test_results.sql"
    "002_create_practice_activities.sql"
    "003_update_learning_progress.sql"
    "004_update_skill_statistics.sql"
)

# Function to apply a single migration
apply_migration() {
    local migration_file=$1
    local migration_path="$MIGRATIONS_DIR/$migration_file"
    
    echo "📝 Applying: $migration_file"
    
    if [ ! -f "$migration_path" ]; then
        echo "❌ Migration file not found: $migration_path"
        return 1
    fi
    
    # Apply migration
    docker exec -i $DB_CONTAINER psql -U $DB_USER -d $DB_NAME < "$migration_path"
    
    if [ $? -eq 0 ]; then
        echo "✅ Successfully applied: $migration_file"
        echo ""
        return 0
    else
        echo "❌ Failed to apply: $migration_file"
        echo ""
        return 1
    fi
}

# Apply each migration
FAILED=0
for migration in "${MIGRATIONS[@]}"; do
    apply_migration "$migration"
    if [ $? -ne 0 ]; then
        FAILED=1
        echo "⚠️  Migration failed: $migration"
        echo "⚠️  Stopping migration process"
        echo ""
        echo "To rollback, run: ./rollback-scoring-migrations.sh"
        exit 1
    fi
done

if [ $FAILED -eq 0 ]; then
    echo "=================================================="
    echo "✅ All migrations applied successfully!"
    echo ""
    echo "Verification queries:"
    echo "  docker exec -i $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c '\d official_test_results'"
    echo "  docker exec -i $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c '\d practice_activities'"
    echo "  docker exec -i $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c '\d learning_progress'"
    echo "  docker exec -i $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c '\d skill_statistics'"
    echo ""
    echo "Next steps:"
    echo "  1. Verify schema changes"
    echo "  2. Begin Phase 2: Shared Library Implementation"
else
    echo "=================================================="
    echo "❌ Some migrations failed"
    echo "Please check the error messages above"
fi
