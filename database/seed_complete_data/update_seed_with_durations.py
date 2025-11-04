#!/usr/bin/env python3
"""
Helper script to update seed SQL files with YouTube video durations from mapping.
This script reads youtube_durations.json and updates seed files with accurate durations.
"""
import os
import sys
import json
import re
from typing import Dict

def load_durations_mapping() -> Dict[str, int]:
    """Load durations from JSON mapping file"""
    script_dir = os.path.dirname(__file__)
    json_file = os.path.join(script_dir, 'youtube_durations.json')
    
    if not os.path.exists(json_file):
        print(f"⚠️  Mapping file not found: {json_file}")
        print("   Run fetch_youtube_durations.py first to generate mapping")
        return {}
    
    with open(json_file, 'r', encoding='utf-8') as f:
        return json.load(f)

def update_seed_file(file_path: str, durations: Dict[str, int]) -> bool:
    """Update seed file with durations from mapping"""
    if not os.path.exists(file_path):
        print(f"⚠️  File not found: {file_path}")
        return False
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # Find all video IDs in the file
    video_id_pattern = r"'([a-zA-Z0-9_-]{11})'"
    video_ids = set(re.findall(video_id_pattern, content))
    
    if not video_ids:
        return False
    
    # Build CASE statement for all video IDs found
    case_statements = []
    for video_id in sorted(video_ids):
        if video_id in durations:
            duration = durations[video_id]
            case_statements.append(f"            WHEN '{video_id}' THEN {duration}")
    
    if not case_statements:
        return False
    
    # Pattern to match duration calculation in lesson_videos
    duration_pattern = r"(CASE WHEN l\.content_type = 'video' THEN\s+-- Use duration from YouTube API.*?)(CASE\s+.*?ELSE l\.duration_minutes \* 60.*?END)(.*?ELSE NULL END)"
    
    replacement = f"""\\1
        CASE 
{chr(10).join(case_statements)}
            ELSE l.duration_minutes * 60 -- Fallback: use calculated duration
        END\\3"""
    
    content = re.sub(duration_pattern, replacement, content, flags=re.DOTALL)
    
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    
    return False

def main():
    print("🔄 Loading YouTube durations mapping...")
    durations = load_durations_mapping()
    
    if not durations:
        print("❌ No durations found. Run fetch_youtube_durations.py first.")
        sys.exit(1)
    
    print(f"✓ Loaded {len(durations)} video durations")
    
    script_dir = os.path.dirname(__file__)
    
    # Update seed files
    seed_files = [
        '03_courses.sql',
        '03_exercises.sql'
    ]
    
    updated_count = 0
    for seed_file in seed_files:
        file_path = os.path.join(script_dir, seed_file)
        print(f"\n📝 Updating {seed_file}...")
        
        if update_seed_file(file_path, durations):
            print(f"✓ Updated {seed_file}")
            updated_count += 1
        else:
            print(f"⚠ No changes needed for {seed_file}")
    
    print(f"\n✅ Updated {updated_count} seed file(s)")
    print("   You can now run clean-and-seed.sh with accurate durations")

if __name__ == '__main__':
    main()

