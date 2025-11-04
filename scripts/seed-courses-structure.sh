#!/usr/bin/env bash
set -euo pipefail

# Script seed data QUA API - Đảm bảo TẤT CẢ các field đều có giá trị
# Tránh duplicate, đảm bảo liên kết chặt chẽ, validation đúng qua API

API_BASE="${API_BASE:-http://localhost:8080/api/v1}"
ADMIN_EMAIL="${ADMIN_EMAIL:-test_admin@ielts.com}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-Test@123}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

# Check dependencies
command -v jq >/dev/null 2>&1 || { error "jq is required but not installed. Aborting."; exit 1; }
command -v curl >/dev/null 2>&1 || { error "curl is required but not installed. Aborting."; exit 1; }

# Login and get token
TOKEN=""
login() {
    log "Đăng nhập với email: $ADMIN_EMAIL"
    local resp
    resp=$(curl -s -X POST "$API_BASE/auth/login" \
        -H 'Content-Type: application/json' \
        -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASSWORD\"}") || {
        error "Login failed"
        return 1
    }
    
    TOKEN=$(echo "$resp" | jq -r '.data.token // empty')
    if [[ -z "$TOKEN" ]]; then
        error "Không thể lấy token. Response: $resp"
        return 1
    fi
    
    success "Đăng nhập thành công"
    return 0
}

# Make API request
api_request() {
    local method=$1
    local endpoint=$2
    local data="${3:-}"
    local retries=3
    local attempt=0
    
    while [ $attempt -lt $retries ]; do
        if [ "$method" = "GET" ]; then
            resp=$(curl -s -w "\n%{http_code}" -X GET "$API_BASE$endpoint" \
                -H "Authorization: Bearer $TOKEN" \
                -H 'Content-Type: application/json') || {
                attempt=$((attempt + 1))
                [ $attempt -lt $retries ] && sleep $((2 ** attempt))
                continue
            }
        elif [ "$method" = "POST" ]; then
            resp=$(curl -s -w "\n%{http_code}" -X POST "$API_BASE$endpoint" \
                -H "Authorization: Bearer $TOKEN" \
                -H 'Content-Type: application/json' \
                -d "$data") || {
                attempt=$((attempt + 1))
                [ $attempt -lt $retries ] && sleep $((2 ** attempt))
                continue
            }
        else
            error "Unsupported method: $method"
            return 1
        fi
        
        http_code=$(echo "$resp" | tail -n1)
        body=$(echo "$resp" | sed '$d')
        
        if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 201 ]; then
            echo "$body"
            return 0
        elif [ "$http_code" -eq 409 ]; then
            warning "Duplicate detected: $endpoint"
            return 1
        elif [ "$http_code" -eq 404 ]; then
            warning "Not found: $endpoint"
            return 1
        elif [ $attempt -lt $((retries - 1)) ]; then
            attempt=$((attempt + 1))
            warning "Retry $attempt/$retries sau $((2 ** attempt))s..."
            sleep $((2 ** attempt))
            continue
        else
            error "HTTP Error $http_code: $(echo "$body" | jq -r '.error.message // .error // "Unknown error"' 2>/dev/null || echo "$body")"
            return 1
        fi
    done
    
    return 1
}

# Get existing courses
get_existing_courses() {
    log "Lấy danh sách courses hiện có..."
    local page=1
    local courses=""
    
    while true; do
        resp=$(api_request "GET" "/courses?page=$page&limit=50") || break
        
        local courses_page=$(echo "$resp" | jq -r '.data.courses[]? | "\(.slug)|\(.id)"' 2>/dev/null || echo "")
        if [ -z "$courses_page" ]; then
            break
        fi
        
        courses="${courses}${courses_page}"$'\n'
        
        local total_pages=$(echo "$resp" | jq -r '.data.total_pages // 1')
        if [ "$page" -ge "$total_pages" ]; then
            break
        fi
        page=$((page + 1))
    done
    
    echo "$courses"
}

# Get course modules
get_course_modules() {
    local course_id=$1
    api_request "GET" "/courses/$course_id/modules" | jq -r '.data.modules[]?.id // empty' 2>/dev/null || echo ""
}

# Create module
create_module() {
    local course_id=$1
    local title=$2
    local description=$3
    local display_order=$4
    local duration_hours=${5:-2.0}
    
    local data=$(jq -n \
        --arg course_id "$course_id" \
        --arg title "$title" \
        --arg description "$description" \
        --argjson display_order "$display_order" \
        --argjson duration_hours "$duration_hours" \
        '{
            course_id: $course_id,
            title: $title,
            description: $description,
            display_order: $display_order,
            duration_hours: $duration_hours
        }')
    
    log "Tạo module: $title"
    api_request "POST" "/admin/modules" "$data" | jq -r '.data.id // empty' 2>/dev/null || echo ""
}

# Create lesson
create_lesson() {
    local module_id=$1
    local title=$2
    local description=$3
    local content_type=$4
    local duration_minutes=$5
    local display_order=$6
    local is_free=${7:-false}
    
    local data=$(jq -n \
        --arg module_id "$module_id" \
        --arg title "$title" \
        --arg description "$description" \
        --arg content_type "$content_type" \
        --argjson duration_minutes "$duration_minutes" \
        --argjson display_order "$display_order" \
        --argjson is_free "$is_free" \
        '{
            module_id: $module_id,
            title: $title,
            description: $description,
            content_type: $content_type,
            duration_minutes: $duration_minutes,
            display_order: $display_order,
            is_free: $is_free
        }')
    
    log "Tạo lesson: $title"
    api_request "POST" "/admin/lessons" "$data" | jq -r '.data.id // empty' 2>/dev/null || echo ""
}

# Add video to lesson
add_video_to_lesson() {
    local lesson_id=$1
    local title=$2
    local video_id=$3
    local duration_seconds=$4
    
    local video_url="https://www.youtube.com/watch?v=$video_id"
    local thumbnail_url="https://i.ytimg.com/vi/$video_id/maxresdefault.jpg"
    
    local data=$(jq -n \
        --arg title "$title" \
        --arg video_provider "youtube" \
        --arg video_id "$video_id" \
        --arg video_url "$video_url" \
        --arg thumbnail_url "$thumbnail_url" \
        --argjson duration_seconds "$duration_seconds" \
        --argjson display_order 1 \
        '{
            title: $title,
            video_provider: $video_provider,
            video_id: $video_id,
            video_url: $video_url,
            thumbnail_url: $thumbnail_url,
            duration_seconds: $duration_seconds,
            display_order: $display_order
        }')
    
    log "Thêm video vào lesson: $lesson_id"
    api_request "POST" "/admin/lessons/$lesson_id/videos" "$data" | jq -r '.data.id // empty' 2>/dev/null || echo ""
}

# Ensure course has full structure
ensure_course_structure() {
    local course_slug=$1
    local course_id=$2
    
    log "Xử lý course: $course_slug"
    
    # Check existing modules
    local existing_modules=$(get_course_modules "$course_id")
    local module_count=$(echo "$existing_modules" | grep -c . || echo "0")
    
    if [ "$module_count" -ge 4 ]; then
        log "Course $course_slug đã có đủ modules ($module_count)"
        return 0
    fi
    
    # Create modules based on skill type
    # For now, create 4 standard modules
    local module_titles=(
        "Module 1: Introduction & Fundamentals"
        "Module 2: Core Concepts & Strategies"
        "Module 3: Advanced Techniques"
        "Module 4: Practice & Review"
    )
    
    local module_descriptions=(
        "Learn the fundamentals and get started"
        "Master core concepts and strategies"
        "Advanced techniques for higher scores"
        "Practice with real exercises and review"
    )
    
    for i in "${!module_titles[@]}"; do
        local module_id=$(create_module "$course_id" "${module_titles[$i]}" "${module_descriptions[$i]}" $((i + 1)) 2.0)
        
        if [ -z "$module_id" ]; then
            warning "Không thể tạo module: ${module_titles[$i]}"
            continue
        fi
        
        success "Tạo module thành công: $module_id"
        
        # Create 3-4 lessons per module
        local lesson_types=("video" "article" "exercise")
        for j in {1..3}; do
            local lesson_type="${lesson_types[$((j % 3))]}"
            local lesson_title="Lesson $j: ${lesson_type^} Content"
            local lesson_description="Practice ${lesson_type} content"
            local duration=$((15 + j * 5))
            
            local lesson_id=$(create_lesson "$module_id" "$lesson_title" "$lesson_description" \
                "$lesson_type" "$duration" "$j" "$([ $j -eq 1 ] && echo true || echo false)")
            
            if [ -z "$lesson_id" ]; then
                warning "Không thể tạo lesson: $lesson_title"
                continue
            fi
            
            success "Tạo lesson thành công: $lesson_id"
            
            # Add video if lesson type is video
            if [ "$lesson_type" = "video" ]; then
                local video_ids=("6QMu7-3DMi0" "ys-1LqlUNCk" "tml3fxV9w7g" "fX3qI4lQ6P0")
                local video_id="${video_ids[$((RANDOM % ${#video_ids[@]}))]}"
                local video_duration=$((600 + RANDOM % 1200))  # 10-30 minutes
                
                add_video_to_lesson "$lesson_id" "$lesson_title" "$video_id" "$video_duration" >/dev/null || true
            fi
            
            sleep 0.2  # Rate limiting
        done
        
        sleep 0.3  # Rate limiting
    done
}

# Main function
main() {
    echo "============================================================"
    echo "SEED DATA QUA API - Đảm bảo đầy đủ field"
    echo "============================================================"
    
    # Login
    if ! login; then
        error "Không thể đăng nhập"
        exit 1
    fi
    
    # Get existing courses
    log "Lấy danh sách courses..."
    local courses=$(get_existing_courses)
    local course_count=$(echo "$courses" | grep -c . || echo "0")
    
    if [ "$course_count" -eq 0 ]; then
        warning "Không tìm thấy courses nào"
        exit 0
    fi
    
    log "Tìm thấy $course_count courses"
    
    # Process each course
    local processed=0
    local skipped=0
    
    while IFS='|' read -r slug id; do
        [ -z "$slug" ] && continue
        
        ensure_course_structure "$slug" "$id"
        processed=$((processed + 1))
        
        sleep 0.5  # Rate limiting
    done <<< "$courses"
    
    echo ""
    echo "============================================================"
    echo "SUMMARY"
    echo "============================================================"
    echo "Courses processed: $processed"
    echo "Courses skipped: $skipped"
    echo ""
    success "Hoàn thành!"
}

main "$@"

