# 🎤 Complete Audio Recording & Evaluation System - Setup Guide

## 🎯 Overview

**100% FREE** solution để ghi âm, upload, và chấm điểm Speaking IELTS:

- ✅ **MediaRecorder API** - Browser built-in (FREE)
- ✅ **MinIO** - Self-hosted S3-compatible storage (FREE)
- ✅ **OpenAI Whisper** - Transcription ($0.006/min)
- ✅ **OpenAI GPT-4** - Evaluation ($0.03/1K tokens)

---

## 🚀 Quick Start

### 1. Build & Start Services

```bash
# Build all services (including storage-service)
docker-compose build storage-service exercise-service ai-service

# Start everything
docker-compose up -d

# Check logs
docker-compose logs -f storage-service
docker-compose logs -f exercise-service
docker-compose logs -f ai-service
```

### 2. Access MinIO Console

```bash
# Open browser
open http://localhost:9001

# Login credentials
Username: ielts_admin
Password: ielts_minio_password_2025

# Bucket created automatically: ielts-audio
```

### 3. Test Storage Service

```bash
# Health check
curl http://localhost:8087/health

# Generate upload URL (requires auth token)
curl -X POST http://localhost:8087/api/v1/storage/audio/upload-url \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "file_extension": ".mp3",
    "content_type": "audio/mpeg"
  }'

# Response:
{
  "success": true,
  "data": {
    "upload_url": "http://localhost:9000/ielts-audio/audio/user-id/audio-uuid.mp3?...",
    "audio_url": "http://minio:9000/ielts-audio/audio/user-id/audio-uuid.mp3",
    "object_name": "audio/user-id/audio-uuid.mp3",
    "expires_at": 1699999999
  }
}
```

---

## 🎙️ Frontend Setup

### 1. Install Dependencies (if needed)

```bash
cd Frontend-IELTSGo
pnpm install
```

### 2. Test Audio Recorder Hook

```tsx
import { useAudioRecorder } from '@/hooks/useAudioRecorder';

function MyComponent() {
  const {
    isRecording,
    audioBlob,
    startRecording,
    stopRecording,
    uploadAudio
  } = useAudioRecorder();

  return (
    <div>
      <button onClick={startRecording}>Record</button>
      <button onClick={stopRecording}>Stop</button>
      <button onClick={() => uploadAudio(userId, token)}>Upload</button>
    </div>
  );
}
```

### 3. Use Complete Component

```tsx
import { AudioRecorder } from '@/components/speaking/AudioRecorder';

function SpeakingPage() {
  const handleAudioReady = (audioUrl: string) => {
    console.log('Audio uploaded:', audioUrl);
    // Submit to Exercise Service
  };

  return (
    <AudioRecorder 
      onAudioReady={handleAudioReady}
      maxDuration={180}
      userId={currentUser.id}
      token={authToken}
    />
  );
}
```

### 4. Access Test Page

```
http://localhost:3000/speaking/test
```

---

## 🧪 Complete End-to-End Test

### Step 1: Login

```bash
TOKEN=$(curl -X POST http://localhost:8081/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"bi@gmail.com","password":"12345678"}' | jq -r '.data.access_token')

echo "Token: $TOKEN"
```

### Step 2: Start Exercise

```bash
SUBMISSION_ID=$(curl -X POST "http://localhost:8084/api/v1/exercises/dd3abb5b-e1ae-482e-b798-1ee686ce7ecd/start" \
  -H "Authorization: Bearer $TOKEN" | jq -r '.data.id')

echo "Submission ID: $SUBMISSION_ID"
```

### Step 3: Get Upload URL

```bash
UPLOAD_RESPONSE=$(curl -X POST "http://localhost:8084/api/v1/storage/audio/upload-url" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"file_extension":".mp3","content_type":"audio/mpeg"}')

UPLOAD_URL=$(echo $UPLOAD_RESPONSE | jq -r '.data.upload_url')
AUDIO_URL=$(echo $UPLOAD_RESPONSE | jq -r '.data.audio_url')

echo "Upload URL: $UPLOAD_URL"
echo "Audio URL: $AUDIO_URL"
```

### Step 4: Upload Audio

```bash
# Upload a test audio file (replace with your audio file)
curl -X PUT "$UPLOAD_URL" \
  -H "Content-Type: audio/mpeg" \
  --data-binary "@test-audio.mp3"

# Verify in MinIO Console:
open http://localhost:9001
```

### Step 5: Submit Exercise

```bash
curl -X POST "http://localhost:8084/api/v1/submissions/$SUBMISSION_ID/submit" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"speaking_data\": {
      \"audio_url\": \"$AUDIO_URL\",
      \"audio_duration_seconds\": 120,
      \"speaking_part_number\": 2
    }
  }"
```

### Step 6: Check Result (Wait 10-15s)

```bash
# Poll for result
for i in {1..20}; do
  echo "Checking result (attempt $i)..."
  
  RESULT=$(curl -s "http://localhost:8084/api/v1/submissions/$SUBMISSION_ID/result" \
    -H "Authorization: Bearer $TOKEN")
  
  STATUS=$(echo $RESULT | jq -r '.data.submission.evaluation_status')
  
  echo "Status: $STATUS"
  
  if [ "$STATUS" = "completed" ]; then
    echo "✅ Evaluation complete!"
    echo $RESULT | jq .
    break
  elif [ "$STATUS" = "failed" ]; then
    echo "❌ Evaluation failed!"
    echo $RESULT | jq .
    break
  fi
  
  sleep 2
done
```

---

## 📊 Expected Results

### Success Response

```json
{
  "success": true,
  "data": {
    "submission": {
      "id": "uuid",
      "status": "in_progress",
      "evaluation_status": "completed",
      "band_score": 7.5,
      "detailed_scores": {
        "fluency": 7.5,
        "lexical_resource": 7.5,
        "grammar": 7.5,
        "pronunciation": 7.5,
        "overall_band": 7.5
      },
      "feedback": "Excellent response with good fluency...",
      "transcript": "Full transcript of the audio..."
    }
  }
}
```

---

## 🐛 Troubleshooting

### Issue 1: MinIO Container Not Starting

```bash
# Check logs
docker logs ielts_minio

# Ensure port 9000 and 9001 are free
lsof -i :9000
lsof -i :9001

# Restart
docker-compose restart minio
```

### Issue 2: Storage Service Can't Connect to MinIO

```bash
# Check MinIO is healthy
curl http://localhost:9000/minio/health/live

# Check storage service logs
docker logs ielts_storage_service

# Verify internal network
docker exec ielts_storage_service ping minio
```

### Issue 3: AI Service Can't Download Audio

```bash
# Test internal URL from AI service container
docker exec ielts_ai_service curl -I http://minio:9000/ielts-audio/audio/test.mp3

# Check audio exists in MinIO
# Open MinIO Console → ielts-audio bucket → verify file
```

### Issue 4: Frontend Can't Access Storage API

```bash
# Check Exercise Service proxy
curl http://localhost:8084/api/v1/storage/audio/upload-url \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"file_extension":".mp3"}'

# Check API Gateway routing (if using)
```

### Issue 5: Browser MediaRecorder Not Working

```javascript
// Check browser support
if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
  alert('Your browser does not support audio recording');
}

// Check HTTPS (required for production)
// MediaRecorder requires HTTPS except on localhost
```

---

## 💰 Cost Analysis

### Self-Hosted (Current Setup)

| Component | Cost |
|-----------|------|
| MinIO | **FREE** (self-hosted) |
| Storage (100GB) | **FREE** (local disk) |
| Bandwidth | **FREE** (internal network) |
| **Total** | **$0/month** |

### OpenAI API Costs

| Service | Cost | Example |
|---------|------|---------|
| Whisper Transcription | $0.006/minute | 100 mins = $0.60 |
| GPT-4 Evaluation | $0.03/1K tokens | 100 evals = $3.00 |
| **Total for 100 users** | | **~$3.60** |

### Cloud Alternative (AWS)

| Component | Cost |
|-----------|------|
| S3 Storage (100GB) | $2.30/month |
| S3 PUT Requests (10K) | $0.05 |
| CloudFront Transfer (100GB) | $8.50 |
| **Total** | **$10.85/month** |

**→ Self-hosted MinIO saves $10/month + scales easily!**

---

## 🔒 Security Checklist

### Production Deployment

- [ ] **Change MinIO credentials** in docker-compose.yml
- [ ] **Enable HTTPS** for MinIO (use Traefik/nginx)
- [ ] **Implement rate limiting** on upload endpoints
- [ ] **Add file size validation** (max 10MB per audio)
- [ ] **Set bucket lifecycle policy** (auto-delete old files)
- [ ] **Enable MinIO audit logging**
- [ ] **Restrict bucket access** (private by default)
- [ ] **Monitor storage usage** with Prometheus

---

## 📚 Additional Resources

- [MinIO Documentation](https://min.io/docs/minio/linux/index.html)
- [MediaRecorder API](https://developer.mozilla.org/en-US/docs/Web/API/MediaRecorder)
- [OpenAI Whisper API](https://platform.openai.com/docs/guides/speech-to-text)
- [IELTS Speaking Criteria](https://www.ielts.org/for-organisations/ielts-scoring-in-detail)

---

## ✅ Summary

Bạn đã có:

1. ✅ **MinIO Storage** - FREE S3-compatible storage
2. ✅ **Storage Service** - Presigned URL generator
3. ✅ **Exercise Service** - Proxy to storage
4. ✅ **AI Service** - Download & evaluate audio
5. ✅ **Frontend Components** - Record & upload UI
6. ✅ **Complete Flow** - Record → Upload → Evaluate → Results

**Next Steps:**

1. Build services: `docker-compose build`
2. Start services: `docker-compose up -d`
3. Test frontend: Open `http://localhost:3000/speaking/test`
4. Deploy to production with HTTPS + monitoring

**🎉 Congratulations! You have a complete FREE audio recording & evaluation system!**
