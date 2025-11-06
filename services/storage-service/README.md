# Storage Service

**FREE** MinIO-based audio storage service for IELTS platform.

## 🎯 Features

- ✅ **Presigned Upload URLs** - Secure direct upload to MinIO
- ✅ **Audio Validation** - MP3, WAV, M4A, OGG, WebM support
- ✅ **Internal URLs** - AI Service can download via Docker network
- ✅ **100% FREE** - Self-hosted MinIO (S3-compatible)

## 🚀 Quick Start

```bash
# Build and run with Docker Compose
docker-compose up -d minio storage-service

# Access MinIO Console
open http://localhost:9001
# Login: ielts_admin / ielts_minio_password_2025
```

## 📡 API Endpoints

### 1. Generate Upload URL

```bash
POST /api/v1/storage/audio/upload-url

Request:
{
  "user_id": "user-uuid",
  "file_extension": ".mp3",
  "content_type": "audio/mpeg"
}

Response:
{
  "success": true,
  "data": {
    "upload_url": "http://localhost:9000/ielts-audio/audio/user-uuid/audio-uuid.mp3?X-Amz-...",
    "audio_url": "http://minio:9000/ielts-audio/audio/user-uuid/audio-uuid.mp3",
    "object_name": "audio/user-uuid/audio-uuid.mp3",
    "expires_at": 1699999999,
    "content_type": "audio/mpeg"
  }
}
```

### 2. Get Audio Info

```bash
GET /api/v1/storage/audio/info/:object_name

Response:
{
  "success": true,
  "data": {
    "object_name": "audio/user-uuid/audio-uuid.mp3",
    "size": 2048576,
    "content_type": "audio/mpeg",
    "last_modified": 1699999999
  }
}
```

### 3. Delete Audio

```bash
DELETE /api/v1/storage/audio/:object_name

Response:
{
  "success": true,
  "message": "audio file deleted successfully"
}
```

## 🔧 Environment Variables

```env
PORT=8087
MINIO_ENDPOINT=minio:9000
MINIO_ACCESS_KEY=ielts_admin
MINIO_SECRET_KEY=ielts_minio_password_2025
MINIO_BUCKET_NAME=ielts-audio
MINIO_USE_SSL=false
```

## 📦 Supported Audio Formats

- ✅ MP3 (audio/mpeg)
- ✅ WAV (audio/wav)
- ✅ M4A (audio/mp4)
- ✅ OGG (audio/ogg)
- ✅ WebM (audio/webm)

## 🌐 Integration with Frontend

```typescript
// 1. Get upload URL
const { upload_url, audio_url } = await fetch('/api/v1/storage/audio/upload-url', {
  method: 'POST',
  body: JSON.stringify({
    user_id: userId,
    file_extension: '.mp3',
    content_type: 'audio/mpeg'
  })
});

// 2. Upload audio directly to MinIO
await fetch(upload_url, {
  method: 'PUT',
  body: audioBlob,
  headers: { 'Content-Type': 'audio/mpeg' }
});

// 3. Submit exercise with audio_url
await fetch(`/api/v1/submissions/${submissionId}/submit`, {
  body: JSON.stringify({ 
    speaking_data: { audio_url } 
  })
});
```

## 🏗️ Architecture

```
Frontend → Storage Service → MinIO
                ↓
         audio_url (internal)
                ↓
    Exercise Service → AI Service
                        ↓
                   Download from MinIO
```

## 💰 Cost

**100% FREE** - Self-hosted MinIO, no cloud costs!
