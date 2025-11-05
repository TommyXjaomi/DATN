#!/bin/bash

set -e

echo "🌱 Seeding Comprehensive Courses..."
echo "===================================="

if ! docker-compose ps | grep -q "postgres.*Up"; then
    echo "❌ Error: PostgreSQL container is not running"
    exit 1
fi

echo "📝 Inserting comprehensive courses into course_db..."
docker-compose exec -T postgres psql -U ielts_admin -d course_db < database/seed_comprehensive_courses.sql

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Comprehensive courses inserted successfully!"
    echo ""
    echo "📊 Summary:"
    echo "  - 20 diverse courses across all skill types"
    echo "  - Real YouTube videos"
    echo "  - Real Unsplash images"
    echo "  - Complete modules, lessons, and videos"
    echo "  - Mix of free and premium courses"
    echo "  - All levels: beginner, intermediate, advanced"
    echo ""
    echo "🎯 Courses include:"
    echo "  - Listening: Foundation, Advanced, Note-Taking"
    echo "  - Reading: Foundation, Academic, General Training, Speed"
    echo "  - Writing: Task 1, Task 2, Coherence & Cohesion"
    echo "  - Speaking: Foundation, Advanced, Part 2 Intensive"
    echo "  - General: Complete Prep, Academic, General Training, Vocabulary, Grammar, Mock Tests"
    echo ""
    echo "🌐 Access at: http://localhost:3000/courses"
else
    echo "❌ Error: Failed to insert courses"
    exit 1
fi




