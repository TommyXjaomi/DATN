#!/usr/bin/env python3
"""
Script to fetch YouTube video durations from YouTube API
and generate a mapping file for seed data.
"""
import os
import sys
import json
import re
import subprocess
from typing import Dict, Optional

# Try to import requests, fallback to curl if not available
try:
    import requests
    HAS_REQUESTS = True
except ImportError:
    HAS_REQUESTS = False

# Try to load .env file if exists
def load_env_file():
    """Load environment variables from .env file"""
    env_path = os.path.join(os.path.dirname(__file__), '../../.env')
    if os.path.exists(env_path):
        with open(env_path, 'r') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, value = line.split('=', 1)
                    os.environ[key.strip()] = value.strip().strip('"').strip("'")

# Load .env file if exists
load_env_file()

# YouTube API v3 endpoint
YOUTUBE_API_URL = "https://www.googleapis.com/youtube/v3/videos"

def extract_video_id(url: str) -> Optional[str]:
    """Extract video ID from YouTube URL"""
    if not url:
        return None
    
    # If it's already just an ID (11 characters)
    if len(url) == 11 and url.isalnum():
        return url
    
    # Extract from URL
    if 'watch?v=' in url:
        return url.split('watch?v=')[1].split('&')[0]
    elif 'youtu.be/' in url:
        return url.split('youtu.be/')[1].split('?')[0]
    elif '/embed/' in url:
        return url.split('/embed/')[1].split('?')[0]
    
    return None

def parse_duration(iso_duration: str) -> int:
    """Parse ISO 8601 duration (PT1H2M3S) to seconds"""
    if not iso_duration or not iso_duration.startswith('PT'):
        return 0
    
    duration = iso_duration[2:]  # Remove 'PT' prefix
    hours = 0
    minutes = 0
    seconds = 0
    
    # Parse hours
    if 'H' in duration:
        parts = duration.split('H')
        hours = int(parts[0])
        duration = parts[1]
    
    # Parse minutes
    if 'M' in duration:
        parts = duration.split('M')
        minutes = int(parts[0])
        duration = parts[1]
    
    # Parse seconds
    if 'S' in duration:
        seconds = int(duration.replace('S', ''))
    
    return hours * 3600 + minutes * 60 + seconds

def fetch_video_duration(api_key: str, video_id: str) -> Optional[int]:
    """Fetch video duration from YouTube API"""
    try:
        url = f"{YOUTUBE_API_URL}?part=contentDetails&id={video_id}&key={api_key}"
        
        if HAS_REQUESTS:
            # Use requests library if available
            response = requests.get(url, timeout=10)
            response.raise_for_status()
            data = response.json()
        else:
            # Fallback to curl
            try:
                result = subprocess.run(
                    ['curl', '-s', url],
                    capture_output=True,
                    text=True,
                    timeout=10
                )
                if result.returncode != 0:
                    raise Exception(f"curl failed: {result.stderr}")
                data = json.loads(result.stdout)
            except FileNotFoundError:
                print(f"❌ Error: Neither 'requests' module nor 'curl' command available")
                return None
            except json.JSONDecodeError as e:
                print(f"❌ Error parsing JSON for {video_id}: {e}")
                return None
        
        if not data.get('items'):
            print(f"⚠️  Video not found: {video_id}")
            return None
        
        video = data['items'][0]
        iso_duration = video.get('contentDetails', {}).get('duration', '')
        
        if not iso_duration:
            print(f"⚠️  No duration found for: {video_id}")
            return None
        
        duration_seconds = parse_duration(iso_duration)
        return duration_seconds
        
    except Exception as e:
        print(f"❌ Error fetching {video_id}: {e}")
        return None

def collect_video_ids_from_seed() -> list:
    """Collect all unique video IDs from seed files"""
    video_ids = set()
    
    seed_files = [
        '03_courses.sql',
        '03_exercises.sql'
    ]
    
    for seed_file in seed_files:
        filepath = os.path.join(os.path.dirname(__file__), seed_file)
        if not os.path.exists(filepath):
            continue
        
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
            # Find all YouTube URLs
            import re
            youtube_urls = re.findall(r'https://www\.youtube\.com/watch\?v=([a-zA-Z0-9_-]{11})', content)
            video_ids.update(youtube_urls)
            
            # Find video IDs in arrays (for lesson_videos) - chỉ match 11 ký tự hợp lệ
            video_id_arrays = re.findall(r"'([a-zA-Z0-9_-]{11})'", content)
            # Filter để chỉ lấy video IDs hợp lệ:
            # - Đúng 11 ký tự
            # - Chứa ít nhất 1 số hoặc ký tự đặc biệt (-, _)
            # - Không phải từ khóa SQL thông thường
            valid_video_ids = []
            sql_keywords = {'immediately', 'unfurnished', 'in_progress', 'not_started', 'completed'}
            for vid in video_id_arrays:
                vid_lower = vid.lower()
                # Bỏ qua nếu là từ khóa SQL hoặc không có số/ký tự đặc biệt
                if vid_lower not in sql_keywords and (any(c.isdigit() for c in vid) or '-' in vid or '_' in vid):
                    valid_video_ids.append(vid)
            video_ids.update(valid_video_ids)
    
    return sorted(list(video_ids))

def load_existing_durations() -> Dict[str, int]:
    """Load existing durations from cache file if exists"""
    script_dir = os.path.dirname(__file__)
    json_file = os.path.join(script_dir, 'youtube_durations.json')
    
    if os.path.exists(json_file):
        try:
            with open(json_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        except:
            return {}
    return {}

def main():
    # Get API key from environment
    api_key = os.getenv('YOUTUBE_API_KEY')
    if not api_key:
        print("❌ Error: YOUTUBE_API_KEY environment variable not set")
        print("   Set it with: export YOUTUBE_API_KEY=your_api_key")
        sys.exit(1)
    
    print("🔍 Collecting video IDs from seed files...")
    video_ids = collect_video_ids_from_seed()
    
    print(f"📹 Found {len(video_ids)} unique video IDs")
    
    # Load existing durations from cache
    existing_durations = load_existing_durations()
    print(f"💾 Found {len(existing_durations)} cached durations")
    
    # Find videos that need to be fetched
    videos_to_fetch = [vid for vid in video_ids if vid not in existing_durations]
    
    if videos_to_fetch:
        print(f"🔄 Need to fetch {len(videos_to_fetch)} new videos...")
        print(f"   Skipping {len(video_ids) - len(videos_to_fetch)} cached videos (saving API quota)")
    else:
        print(f"✅ All {len(video_ids)} videos already cached! No API calls needed.")
    
    # Start with existing durations
    duration_map = existing_durations.copy()
    
    # Fetch only new videos
    failed_ids = []
    
    if videos_to_fetch:
        print("\n🔄 Fetching durations from YouTube API...")
        for i, video_id in enumerate(videos_to_fetch, 1):
            print(f"[{i}/{len(videos_to_fetch)}] Fetching {video_id}...", end=' ')
            
            duration = fetch_video_duration(api_key, video_id)
            
            if duration:
                duration_map[video_id] = duration
                minutes = duration // 60
                seconds = duration % 60
                print(f"✅ {minutes}m{seconds}s ({duration}s)")
            else:
                failed_ids.append(video_id)
                print("❌ Failed")
            
            # Rate limiting: sleep 100ms to avoid quota issues
            import time
            time.sleep(0.1)
    
    # Save updated mapping to JSON file
    output_file = os.path.join(os.path.dirname(__file__), 'youtube_durations.json')
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(duration_map, f, indent=2)
    
    if videos_to_fetch:
        print(f"\n✅ Saved {len(duration_map)} durations to {output_file}")
        if len(videos_to_fetch) > 0:
            print(f"   New videos fetched: {len(videos_to_fetch) - len(failed_ids)}")
            print(f"   Cached videos reused: {len(existing_durations)}")
    else:
        print(f"\n✅ Using cached durations ({len(duration_map)} videos)")
    
    if failed_ids:
        print(f"\n⚠️  Failed to fetch {len(failed_ids)} videos: {', '.join(failed_ids)}")
    
    # Print summary
    print("\n📊 Summary:")
    print(f"   Total videos: {len(video_ids)}")
    print(f"   Successfully fetched: {len(duration_map)}")
    print(f"   Failed: {len(failed_ids)}")
    if existing_durations:
        print(f"   Cached reused: {len(existing_durations)}")
        print(f"   New fetched: {len(videos_to_fetch) - len(failed_ids) if videos_to_fetch else 0}")
    
    if duration_map:
        durations = list(duration_map.values())
        avg_duration = sum(durations) / len(durations)
        min_duration = min(durations)
        max_duration = max(durations)
        print(f"\n   Duration stats:")
        print(f"   - Average: {avg_duration:.1f}s ({avg_duration/60:.1f}m)")
        print(f"   - Min: {min_duration}s ({min_duration/60:.1f}m)")
        print(f"   - Max: {max_duration}s ({max_duration/60:.1f}m)")
    
    if not videos_to_fetch and existing_durations:
        print(f"\n💰 Saved API quota: {len(video_ids)} API calls (using cache)")

if __name__ == '__main__':
    main()

