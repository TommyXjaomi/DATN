#!/usr/bin/env python3
"""
Script seed data QUA API đầy đủ - Đảm bảo TẤT CẢ các field đều có giá trị
Tránh duplicate, đảm bảo liên kết chặt chẽ, validation đúng qua API

Usage:
    python scripts/seed-data-via-api.py --phase all
    python scripts/seed-data-via-api.py --phase courses
    python scripts/seed-data-via-api.py --phase exercises
"""

import json
import requests
import time
import sys
import argparse
from typing import Dict, List, Optional, Any
from urllib.parse import urljoin
from datetime import datetime, timedelta
import random

# Configuration
API_BASE = "http://localhost:8080/api/v1"
ADMIN_EMAIL = "test_admin@ielts.com"
ADMIN_PASSWORD = "Test@123"

# Instructor mapping: email -> name (từ courses hiện có)
INSTRUCTOR_MAPPING = {
    "sarah.mitchell@ieltsplatform.com": "Sarah Mitchell",
    "james.anderson@ieltsplatform.com": "James Anderson",
    "emma.thompson@ieltsplatform.com": "Emma Thompson",
    "michael.chen@ieltsplatform.com": "Michael Chen",
    "david.miller@ieltsplatform.com": "David Miller",
    "robert.chen@ieltsplatform.com": "Robert Chen",
    "jennifer.lee@ieltsplatform.com": "Jennifer Lee",
    "emma.wilson@ieltsplatform.com": "Emma Wilson",
    "sophie.brown@ieltsplatform.com": "Sophie Brown",
    "mark.johnson@ieltsplatform.com": "Mark Johnson",
    "patricia.williams@ieltsplatform.com": "Dr. Patricia Williams",
    "daniel.kim@ieltsplatform.com": "Daniel Kim",
    "alexandra.green@ieltsplatform.com": "Alexandra Green",
    "rachel.taylor@ieltsplatform.com": "Rachel Taylor",
    "thomas.wright@ieltsplatform.com": "Thomas Wright",
    "christopher.moore@ieltsplatform.com": "Christopher Moore",
    "dr.jonathan.white@ieltsplatform.com": "Dr. Jonathan White",
    "victoria.park@ieltsplatform.com": "Victoria Park",
    "lisa.wang@ieltsplatform.com": "Lisa Wang",
    "grace.liu@ieltsplatform.com": "Grace Liu",
}

# YouTube video IDs đã verify
YOUTUBE_VIDEOS = [
    "6QMu7-3DMi0",
    "ys-1LqlUNCk",
    "tml3fxV9w7g",
    "fX3qI4lQ6P0",
    "SeWt7IpZ0CA",
    "oV7qaHKPoK0",
    "9TH5JGYZB4o",
    "vVYONjT2b0Y",
    "kop8O3A-UGs",
    "btAiWvdIxm4",
    "G5orxWQWafI",
    "OZmK0YuSmXU",
]

# Unsplash images cho thumbnails
UNSPLASH_IMAGES = [
    "https://images.unsplash.com/photo-1590602847861-f357a9332bbc?w=1200&h=800&fit=crop",
    "https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=1200&h=800&fit=crop",
    "https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=1200&h=800&fit=crop",
    "https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=1200&h=800&fit=crop",
    "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&h=800&fit=crop",
    "https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=1200&h=800&fit=crop",
    "https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=1200&h=800&fit=crop",
]

class APISeeder:
    def __init__(self, base_url: str, email: str, password: str):
        self.base_url = base_url
        self.email = email
        self.password = password
        self.token: Optional[str] = None
        self.session = requests.Session()
        self.created_resources: Dict[str, List[str]] = {
            "courses": [],
            "modules": [],
            "lessons": [],
            "videos": [],
            "exercises": [],
            "sections": [],
            "questions": [],
        }
        self.errors: List[str] = []
        self.existing_courses: Dict[str, str] = {}  # slug -> id
        
    def log(self, message: str, level: str = "INFO"):
        """Log message với prefix"""
        prefix = {
            "INFO": "[INFO]",
            "ERROR": "[ERROR]",
            "SUCCESS": "[SUCCESS]",
            "WARNING": "[WARNING]"
        }.get(level, "[INFO]")
        print(f"{prefix} {message}")
        
    def login(self) -> bool:
        """Login và lấy token"""
        self.log(f"Đăng nhập với email: {self.email}")
        try:
            response = self.session.post(
                urljoin(self.base_url, "/auth/login"),
                json={"email": self.email, "password": self.password},
                timeout=10
            )
            response.raise_for_status()
            data = response.json()
            if data.get("success") and data.get("data", {}).get("token"):
                self.token = data["data"]["token"]
                self.session.headers.update({
                    "Authorization": f"Bearer {self.token}"
                })
                self.log("Đăng nhập thành công", "SUCCESS")
                return True
            else:
                self.log(f"Đăng nhập thất bại: {data.get('error', {}).get('message', 'Unknown error')}", "ERROR")
                return False
        except Exception as e:
            self.log(f"Lỗi khi đăng nhập: {str(e)}", "ERROR")
            return False
    
    def _make_request(self, method: str, endpoint: str, data: Optional[Dict] = None, 
                     retries: int = 3) -> Optional[Dict]:
        """Make API request với retry logic"""
        url = urljoin(self.base_url, endpoint)
        
        for attempt in range(retries):
            try:
                if method == "GET":
                    response = self.session.get(url, params=data, timeout=30)
                elif method == "POST":
                    response = self.session.post(url, json=data, timeout=30)
                elif method == "PUT":
                    response = self.session.put(url, json=data, timeout=30)
                elif method == "DELETE":
                    response = self.session.delete(url, timeout=30)
                else:
                    raise ValueError(f"Unsupported method: {method}")
                
                response.raise_for_status()
                return response.json()
                
            except requests.exceptions.HTTPError as e:
                if e.response.status_code == 409:  # Conflict - duplicate
                    self.log(f"Duplicate detected: {endpoint}", "WARNING")
                    return None
                elif e.response.status_code == 404:
                    self.log(f"Not found: {endpoint}", "WARNING")
                    return None
                elif attempt < retries - 1:
                    wait_time = 2 ** attempt
                    self.log(f"Retry {attempt + 1}/{retries} sau {wait_time}s...", "WARNING")
                    time.sleep(wait_time)
                    continue
                else:
                    error_msg = f"HTTP Error {e.response.status_code}: {e.response.text[:200]}"
                    self.log(error_msg, "ERROR")
                    self.errors.append(error_msg)
                    return None
            except Exception as e:
                if attempt < retries - 1:
                    wait_time = 2 ** attempt
                    self.log(f"Retry {attempt + 1}/{retries} sau {wait_time}s...", "WARNING")
                    time.sleep(wait_time)
                    continue
                else:
                    error_msg = f"Error: {str(e)}"
                    self.log(error_msg, "ERROR")
                    self.errors.append(error_msg)
                    return None
        
        return None
    
    def get_existing_courses(self) -> Dict[str, str]:
        """Lấy danh sách courses hiện có (slug -> id)"""
        if self.existing_courses:
            return self.existing_courses
            
        courses_map = {}
        page = 1
        limit = 50
        
        while True:
            result = self._make_request("GET", f"/courses?page={page}&limit={limit}")
            if not result or not result.get("success"):
                break
            
            data = result.get("data", {})
            courses = data.get("courses", [])
            if not courses:
                break
            
            for course in courses:
                courses_map[course.get("slug")] = course.get("id")
            
            total_pages = data.get("total_pages", 1)
            if page >= total_pages:
                break
            page += 1
        
        self.existing_courses = courses_map
        return courses_map
    
    def get_course_detail(self, course_id: str) -> Optional[Dict]:
        """Lấy chi tiết course"""
        result = self._make_request("GET", f"/courses/{course_id}")
        if result and result.get("success"):
            return result.get("data", {}).get("course")
        return None
    
    def get_course_modules(self, course_id: str) -> List[Dict]:
        """Lấy danh sách modules của course"""
        result = self._make_request("GET", f"/courses/{course_id}/modules")
        if result and result.get("success"):
            return result.get("data", {}).get("modules", [])
        return []
    
    def create_module(self, module_data: Dict) -> Optional[str]:
        """Tạo module qua API"""
        self.log(f"Tạo module: {module_data.get('title')}")
        result = self._make_request("POST", "/admin/modules", module_data)
        
        if result and result.get("success"):
            module_id = result.get("data", {}).get("id")
            if module_id:
                self.created_resources["modules"].append(module_id)
                self.log(f"Tạo module thành công: {module_id}", "SUCCESS")
                return module_id
        
        self.log(f"Tạo module thất bại: {module_data.get('title')}", "ERROR")
        return None
    
    def create_lesson(self, lesson_data: Dict) -> Optional[str]:
        """Tạo lesson qua API"""
        self.log(f"Tạo lesson: {lesson_data.get('title')}")
        result = self._make_request("POST", "/admin/lessons", lesson_data)
        
        if result and result.get("success"):
            lesson_id = result.get("data", {}).get("id")
            if lesson_id:
                self.created_resources["lessons"].append(lesson_id)
                self.log(f"Tạo lesson thành công: {lesson_id}", "SUCCESS")
                return lesson_id
        
        self.log(f"Tạo lesson thất bại: {lesson_data.get('title')}", "ERROR")
        return None
    
    def add_video_to_lesson(self, lesson_id: str, video_data: Dict) -> Optional[str]:
        """Thêm video vào lesson qua API"""
        self.log(f"Thêm video vào lesson: {lesson_id}")
        result = self._make_request("POST", f"/admin/lessons/{lesson_id}/videos", video_data)
        
        if result and result.get("success"):
            video_id = result.get("data", {}).get("id")
            if video_id:
                self.created_resources["videos"].append(video_id)
                self.log(f"Thêm video thành công: {video_id}", "SUCCESS")
                return video_id
        
        self.log(f"Thêm video thất bại", "ERROR")
        return None
    
    def ensure_course_structure(self, course_id: str, course_slug: str):
        """Đảm bảo course có đầy đủ modules và lessons"""
        # Lấy modules hiện có
        existing_modules = self.get_course_modules(course_id)
        
        if len(existing_modules) >= 4:
            self.log(f"Course {course_slug} đã có đủ modules ({len(existing_modules)})", "INFO")
            return
        
        # Tạo modules và lessons đầy đủ
        self.log(f"Tạo modules và lessons cho course: {course_slug}")
        
        course = self.get_course_detail(course_id)
        if not course:
            self.log(f"Không thể lấy chi tiết course: {course_id}", "ERROR")
            return
        
        skill_type = course.get("skill_type", "general")
        level = course.get("level", "beginner")
        
        # Module templates dựa trên skill type
        module_templates = self._get_module_templates(skill_type, level)
        
        for module_idx, module_template in enumerate(module_templates[:4], 1):
            module_data = {
                "course_id": course_id,
                "title": module_template["title"],
                "description": module_template["description"],
                "display_order": module_idx,
                "duration_hours": module_template.get("duration_hours", 2.0),
            }
            
            module_id = self.create_module(module_data)
            if not module_id:
                continue
            
            # Tạo lessons cho module
            for lesson_idx, lesson_template in enumerate(module_template["lessons"], 1):
                lesson_data = {
                    "module_id": module_id,
                    "title": lesson_template["title"],
                    "description": lesson_template.get("description"),
                    "content_type": lesson_template["content_type"],
                    "duration_minutes": lesson_template.get("duration_minutes", 20),
                    "display_order": lesson_idx,
                    "is_free": lesson_idx == 1,  # Lesson đầu tiên free
                }
                
                lesson_id = self.create_lesson(lesson_data)
                
                # Nếu là video lesson, thêm video
                if lesson_template["content_type"] == "video" and lesson_id:
                    video_id = random.choice(YOUTUBE_VIDEOS)
                    video_data = {
                        "title": lesson_template["title"],
                        "video_provider": "youtube",
                        "video_id": video_id,
                        "video_url": f"https://www.youtube.com/watch?v={video_id}",
                        "thumbnail_url": f"https://i.ytimg.com/vi/{video_id}/maxresdefault.jpg",
                        "duration_seconds": random.randint(600, 1800),  # 10-30 minutes
                        "display_order": 1,
                    }
                    self.add_video_to_lesson(lesson_id, video_data)
                
                time.sleep(0.2)  # Rate limiting
            
            time.sleep(0.3)  # Rate limiting
    
    def _get_module_templates(self, skill_type: str, level: str) -> List[Dict]:
        """Tạo module templates dựa trên skill type và level"""
        templates = {
            "listening": [
                {
                    "title": "Module 1: Introduction & Test Format",
                    "description": "Understand the IELTS Listening test structure and scoring system",
                    "duration_hours": 2.0,
                    "lessons": [
                        {"title": "Welcome to IELTS Listening", "content_type": "video", "duration_minutes": 15},
                        {"title": "Test Format Explained", "content_type": "video", "duration_minutes": 20},
                        {"title": "Scoring System & Band Descriptors", "content_type": "article", "duration_minutes": 18},
                        {"title": "Common Question Types", "content_type": "article", "duration_minutes": 22},
                    ]
                },
                {
                    "title": "Module 2: Part 1 - Social Conversation",
                    "description": "Master Part 1 which focuses on everyday social situations",
                    "duration_hours": 2.5,
                    "lessons": [
                        {"title": "Part 1 Overview & Strategies", "content_type": "video", "duration_minutes": 25},
                        {"title": "Common Topics in Part 1", "content_type": "article", "duration_minutes": 20},
                        {"title": "Practice: Part 1 Exercises", "content_type": "exercise", "duration_minutes": 30},
                    ]
                },
                {
                    "title": "Module 3: Part 2 - Monologue",
                    "description": "Master Part 2 which focuses on monologues",
                    "duration_hours": 2.5,
                    "lessons": [
                        {"title": "Part 2 Overview & Strategies", "content_type": "video", "duration_minutes": 25},
                        {"title": "Common Topics in Part 2", "content_type": "article", "duration_minutes": 20},
                        {"title": "Practice: Part 2 Exercises", "content_type": "exercise", "duration_minutes": 30},
                    ]
                },
                {
                    "title": "Module 4: Part 3 & 4 - Academic Content",
                    "description": "Master Parts 3 and 4 which focus on academic content",
                    "duration_hours": 3.0,
                    "lessons": [
                        {"title": "Part 3 Overview & Strategies", "content_type": "video", "duration_minutes": 25},
                        {"title": "Part 4 Overview & Strategies", "content_type": "video", "duration_minutes": 25},
                        {"title": "Practice: Part 3 & 4 Exercises", "content_type": "exercise", "duration_minutes": 35},
                    ]
                },
            ],
            "reading": [
                {
                    "title": "Module 1: Reading Fundamentals",
                    "description": "Essential reading skills and strategies",
                    "duration_hours": 3.0,
                    "lessons": [
                        {"title": "Introduction to IELTS Reading", "content_type": "video", "duration_minutes": 20},
                        {"title": "Reading Strategies", "content_type": "article", "duration_minutes": 25},
                        {"title": "Vocabulary Building", "content_type": "article", "duration_minutes": 20},
                    ]
                },
                {
                    "title": "Module 2: Question Types Mastery",
                    "description": "Master all IELTS Reading question types",
                    "duration_hours": 4.0,
                    "lessons": [
                        {"title": "Multiple Choice Questions", "content_type": "video", "duration_minutes": 25},
                        {"title": "True/False/Not Given", "content_type": "video", "duration_minutes": 30},
                        {"title": "Matching Headings", "content_type": "video", "duration_minutes": 25},
                        {"title": "Fill in the Blanks", "content_type": "video", "duration_minutes": 25},
                    ]
                },
                {
                    "title": "Module 3: Academic Vocabulary",
                    "description": "Build essential academic vocabulary",
                    "duration_hours": 3.0,
                    "lessons": [
                        {"title": "Common Academic Words", "content_type": "article", "duration_minutes": 20},
                        {"title": "Vocabulary Practice", "content_type": "exercise", "duration_minutes": 25},
                    ]
                },
                {
                    "title": "Module 4: Practice & Review",
                    "description": "Practice with real IELTS Reading passages",
                    "duration_hours": 3.0,
                    "lessons": [
                        {"title": "Practice Test 1", "content_type": "exercise", "duration_minutes": 60},
                        {"title": "Practice Test 2", "content_type": "exercise", "duration_minutes": 60},
                    ]
                },
            ],
            "writing": [
                {
                    "title": "Module 1: Writing Fundamentals",
                    "description": "Learn the basics of IELTS Writing",
                    "duration_hours": 2.5,
                    "lessons": [
                        {"title": "Introduction to IELTS Writing", "content_type": "video", "duration_minutes": 20},
                        {"title": "Task 1 Overview", "content_type": "video", "duration_minutes": 25},
                        {"title": "Task 2 Overview", "content_type": "video", "duration_minutes": 25},
                    ]
                },
                {
                    "title": "Module 2: Task 1 - Report Writing",
                    "description": "Master Task 1 report writing",
                    "duration_hours": 3.0,
                    "lessons": [
                        {"title": "Task 1 Structure", "content_type": "video", "duration_minutes": 25},
                        {"title": "Describing Graphs", "content_type": "video", "duration_minutes": 30},
                        {"title": "Describing Processes", "content_type": "video", "duration_minutes": 25},
                    ]
                },
                {
                    "title": "Module 3: Task 2 - Essay Writing",
                    "description": "Master Task 2 essay writing",
                    "duration_hours": 3.5,
                    "lessons": [
                        {"title": "Essay Structure", "content_type": "video", "duration_minutes": 30},
                        {"title": "Planning Your Essay", "content_type": "video", "duration_minutes": 25},
                        {"title": "Common Essay Types", "content_type": "article", "duration_minutes": 25},
                    ]
                },
                {
                    "title": "Module 4: Practice & Feedback",
                    "description": "Practice writing with feedback",
                    "duration_hours": 2.5,
                    "lessons": [
                        {"title": "Writing Practice 1", "content_type": "exercise", "duration_minutes": 60},
                        {"title": "Writing Practice 2", "content_type": "exercise", "duration_minutes": 60},
                    ]
                },
            ],
            "speaking": [
                {
                    "title": "Module 1: Speaking Fundamentals",
                    "description": "Build confidence in IELTS Speaking",
                    "duration_hours": 2.0,
                    "lessons": [
                        {"title": "Introduction to IELTS Speaking", "content_type": "video", "duration_minutes": 20},
                        {"title": "Speaking Test Format", "content_type": "video", "duration_minutes": 25},
                        {"title": "Band Descriptors", "content_type": "article", "duration_minutes": 20},
                    ]
                },
                {
                    "title": "Module 2: Part 1 - Introduction",
                    "description": "Master Part 1 introduction questions",
                    "duration_hours": 2.5,
                    "lessons": [
                        {"title": "Part 1 Strategies", "content_type": "video", "duration_minutes": 25},
                        {"title": "Common Topics", "content_type": "article", "duration_minutes": 20},
                        {"title": "Practice: Part 1", "content_type": "exercise", "duration_minutes": 25},
                    ]
                },
                {
                    "title": "Module 3: Part 2 - Long Turn",
                    "description": "Master Part 2 long turn speaking",
                    "duration_hours": 3.0,
                    "lessons": [
                        {"title": "Part 2 Strategies", "content_type": "video", "duration_minutes": 30},
                        {"title": "Planning Your Talk", "content_type": "video", "duration_minutes": 25},
                        {"title": "Practice: Part 2", "content_type": "exercise", "duration_minutes": 35},
                    ]
                },
                {
                    "title": "Module 4: Part 3 - Discussion",
                    "description": "Master Part 3 discussion",
                    "duration_hours": 2.5,
                    "lessons": [
                        {"title": "Part 3 Strategies", "content_type": "video", "duration_minutes": 25},
                        {"title": "Practice: Part 3", "content_type": "exercise", "duration_minutes": 30},
                    ]
                },
            ],
        }
        
        # Default template cho general hoặc không match
        default_template = templates.get("listening", [])
        return templates.get(skill_type, default_template)
    
    def seed_all_courses_structure(self):
        """Seed modules và lessons cho TẤT CẢ courses hiện có"""
        self.log("Bắt đầu seed modules và lessons cho tất cả courses...", "INFO")
        
        courses_map = self.get_existing_courses()
        
        if not courses_map:
            self.log("Không tìm thấy courses nào", "WARNING")
            return
        
        self.log(f"Tìm thấy {len(courses_map)} courses", "INFO")
        
        for slug, course_id in courses_map.items():
            self.log(f"\nXử lý course: {slug}", "INFO")
            self.ensure_course_structure(course_id, slug)
            time.sleep(0.5)  # Rate limiting
    
    def get_summary(self) -> Dict:
        """Lấy summary của các resources đã tạo"""
        return {
            "courses": len(self.created_resources["courses"]),
            "modules": len(self.created_resources["modules"]),
            "lessons": len(self.created_resources["lessons"]),
            "videos": len(self.created_resources["videos"]),
            "exercises": len(self.created_resources["exercises"]),
            "sections": len(self.created_resources["sections"]),
            "questions": len(self.created_resources["questions"]),
            "errors": len(self.errors),
        }


def main():
    """Main function"""
    parser = argparse.ArgumentParser(description="Seed data qua API - Đảm bảo đầy đủ field")
    parser.add_argument("--phase", choices=["all", "courses", "exercises"], 
                       default="all", help="Phase to seed")
    parser.add_argument("--base-url", default=API_BASE, help="API base URL")
    parser.add_argument("--email", default=ADMIN_EMAIL, help="Admin email")
    parser.add_argument("--password", default=ADMIN_PASSWORD, help="Admin password")
    
    args = parser.parse_args()
    
    print("=" * 60)
    print("SEED DATA QUA API - Đảm bảo đầy đủ field")
    print("=" * 60)
    
    seeder = APISeeder(args.base_url, args.email, args.password)
    
    if not seeder.login():
        print("Không thể đăng nhập. Kiểm tra lại credentials.")
        sys.exit(1)
    
    if args.phase in ["all", "courses"]:
        seeder.log("Bắt đầu seed courses structure...", "INFO")
        seeder.seed_all_courses_structure()
    
    if args.phase in ["all", "exercises"]:
        seeder.log("Bắt đầu seed exercises...", "INFO")
        # TODO: Implement exercise seeding
    
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    summary = seeder.get_summary()
    for resource_type, count in summary.items():
        print(f"{resource_type.capitalize()}: {count}")
    
    if seeder.errors:
        print(f"\nCó {len(seeder.errors)} lỗi:")
        for error in seeder.errors[:10]:  # Show first 10 errors
            print(f"  - {error}")
    
    print("\nHoàn thành!")


if __name__ == "__main__":
    main()
