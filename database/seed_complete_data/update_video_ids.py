#!/usr/bin/env python3
"""
Script tự động cập nhật video IDs từ url_yt.txt vào seed files
Sử dụng: python3 update_video_ids.py
"""

import re
import os
from typing import List

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
URL_FILE = os.path.join(SCRIPT_DIR, 'url_yt.txt')
COURSES_FILE = os.path.join(SCRIPT_DIR, '03_courses.sql')
EXERCISES_FILE = os.path.join(SCRIPT_DIR, '03_exercises.sql')

def extract_video_ids_from_file(file_path: str) -> List[str]:
    """Extract video IDs từ url_yt.txt"""
    video_ids = []
    
    if not os.path.exists(file_path):
        print(f"❌ File không tồn tại: {file_path}")
        return video_ids
    
    with open(file_path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            
            # Extract video ID from both formats
            match = re.search(r'(?:youtube\.com/watch\?v=|youtu\.be/)([a-zA-Z0-9_-]{11})', line)
            if match:
                video_id = match.group(1)
                if video_id not in video_ids:
                    video_ids.append(video_id)
    
    return video_ids

def update_courses_file(file_path: str, video_ids: List[str]) -> bool:
    """Cập nhật video_ids array trong 03_courses.sql"""
    if not os.path.exists(file_path):
        print(f"❌ File không tồn tại: {file_path}")
        return False
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find the CORRECT video_ids array - must be after "FROM lessons l" and "CROSS JOIN"
    # Pattern: FROM lessons l\nCROSS JOIN (\n    SELECT ARRAY[...] as video_ids\n) vid
    pattern = r"(FROM lessons l\s+CROSS JOIN\s*\(\s*SELECT ARRAY\[)(.*?)(\] as video_ids\s*\)\s*vid\s+WHERE l\.content_type = 'video')"
    
    def replace_array(match):
        prefix = match.group(1)
        suffix = match.group(3)
        
        # Format video IDs as SQL array
        # Split into lines of 5 IDs each for readability
        formatted_ids = []
        for i in range(0, len(video_ids), 5):
            batch = video_ids[i:i+5]
            formatted_ids.append("        " + ", ".join(f"'{vid}'" for vid in batch))
        
        array_content = ",\n".join(formatted_ids)
        
        return f"{prefix}\n{array_content}\n    {suffix}"
    
    new_content = re.sub(pattern, replace_array, content, flags=re.DOTALL)
    
    if new_content == content:
        print("⚠️  Không tìm thấy video_ids array cho lesson_videos")
        # Try alternative pattern
        pattern2 = r"(CROSS JOIN\s*\(\s*SELECT ARRAY\[)(.*?)(\] as video_ids\s*\)\s*vid)"
        new_content = re.sub(pattern2, replace_array, content, flags=re.DOTALL)
        if new_content == content:
            print("⚠️  Không tìm thấy pattern thay thế")
            return False
    
    # Backup original file
    backup_path = file_path + '.backup'
    if not os.path.exists(backup_path):
        with open(backup_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"   Backup: {backup_path}")
    
    # Write updated content
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    print(f"✅ Đã cập nhật {file_path}")
    return True

def update_exercises_file(file_path: str, video_ids: List[str]) -> bool:
    """Cập nhật video URLs trong hardcoded exercises nếu cần"""
    if not os.path.exists(file_path):
        return False
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find hardcoded YouTube URLs and replace with random selection from video_ids
    # Pattern: 'https://www.youtube.com/watch?v=VIDEO_ID'
    pattern = r"'https://www\.youtube\.com/watch\?v=([a-zA-Z0-9_-]{11})'"
    
    def replace_url(match):
        old_video_id = match.group(1)
        # Use first available video_id (or random, but for consistency use first)
        # Actually, keep the old one if it's in the list, otherwise use first
        if old_video_id in video_ids:
            return f"'https://www.youtube.com/watch?v={old_video_id}'"
        else:
            return f"'https://www.youtube.com/watch?v={video_ids[0]}'"
    
    new_content = re.sub(pattern, replace_url, content)
    
    if new_content == content:
        return True  # No changes needed
    
    # Backup original file
    backup_path = file_path + '.backup'
    with open(backup_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    # Write updated content
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    print(f"✅ Đã cập nhật {file_path}")
    return True

def generate_video_ids_array_sql(video_ids: List[str]) -> str:
    """Generate SQL array string từ video IDs"""
    formatted_ids = []
    for i in range(0, len(video_ids), 5):
        batch = video_ids[i:i+5]
        formatted_ids.append("        " + ", ".join(f"'{vid}'" for vid in batch))
    return ",\n".join(formatted_ids)

def main():
    print("🔄 Đang đọc video IDs từ url_yt.txt...")
    video_ids = extract_video_ids_from_file(URL_FILE)
    
    if not video_ids:
        print("❌ Không tìm thấy video IDs nào!")
        return 1
    
    print(f"✅ Tìm thấy {len(video_ids)} unique video IDs")
    print(f"   First 5: {video_ids[:5]}")
    print(f"   Last 5: {video_ids[-5:]}")
    print()
    
    # Update courses file
    print("📝 Đang cập nhật 03_courses.sql...")
    if update_courses_file(COURSES_FILE, video_ids):
        print("   ✓ Video IDs array đã được cập nhật")
    else:
        print("   ⚠️  Không có thay đổi nào")
    
    print()
    
    # Update exercises file (optional - chỉ update nếu URLs không có trong list)
    print("📝 Đang kiểm tra 03_exercises.sql...")
    update_exercises_file(EXERCISES_FILE, video_ids)
    
    print()
    print("✅ Hoàn thành!")
    print(f"   Total videos: {len(video_ids)}")
    print()
    print("💡 Để thêm video mới:")
    print("   1. Thêm link vào url_yt.txt")
    print("   2. Chạy: python3 update_video_ids.py")
    print("   3. Hoặc chạy: ./clean-and-seed.sh (tự động update)")
    
    return 0

if __name__ == '__main__':
    exit(main())

