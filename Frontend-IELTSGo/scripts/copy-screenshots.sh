#!/bin/bash

# Script to copy screenshots from browser extension temp folder to project screenshots folder

SCREENSHOTS_DIR="/Users/bisosad/DATN/Frontend-IELTSGo/screenshots"
TEMP_BASE="/var/folders"

echo "🔍 Tìm ảnh screenshot trong temp folder..."

# Find all screenshots in temp folders
SCREENSHOTS=$(find $TEMP_BASE -name "*.png" -path "*/screenshots/*" -type f 2>/dev/null)

if [ -z "$SCREENSHOTS" ]; then
    echo "❌ Không tìm thấy ảnh nào trong temp folder"
    exit 1
fi

echo "✅ Tìm thấy $(echo "$SCREENSHOTS" | wc -l | tr -d ' ') ảnh"
echo ""

# Create screenshots directory if it doesn't exist
mkdir -p "$SCREENSHOTS_DIR"

# Copy each screenshot
echo "📋 Copying screenshots..."
echo "$SCREENSHOTS" | while read -r file; do
    # Extract relative path after "screenshots/"
    rel_path=$(echo "$file" | sed 's|.*/screenshots/||')
    
    # Create directory if needed
    target_dir="$SCREENSHOTS_DIR/$(dirname "$rel_path")"
    mkdir -p "$target_dir"
    
    # Copy file
    cp "$file" "$SCREENSHOTS_DIR/$rel_path"
    echo "  ✓ Copied: $rel_path"
done

echo ""
echo "✅ Hoàn thành! Tất cả ảnh đã được copy vào:"
echo "   $SCREENSHOTS_DIR"
echo ""
echo "📊 Danh sách ảnh đã copy:"
find "$SCREENSHOTS_DIR" -name "*.png" -type f | sort

