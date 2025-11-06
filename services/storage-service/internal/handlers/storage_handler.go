package handlers

import (
	"fmt"
	"log"
	"net/http"
	"path/filepath"
	"strings"

	"github.com/bisosad1501/DATN/services/storage-service/internal/config"
	"github.com/bisosad1501/DATN/services/storage-service/internal/minio"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type StorageHandler struct {
	minioClient *minio.MinIOClient
	config      *config.Config
}

func NewStorageHandler(minioClient *minio.MinIOClient, cfg *config.Config) *StorageHandler {
	return &StorageHandler{
		minioClient: minioClient,
		config:      cfg,
	}
}

// HealthCheck endpoint
func (h *StorageHandler) HealthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status":  "healthy",
		"service": "storage-service",
		"bucket":  h.minioClient.GetBucketName(),
	})
}

// UploadAudio handles direct audio file upload (proxy to MinIO)
// POST /api/v1/storage/audio/upload
func (h *StorageHandler) UploadAudio(c *gin.Context) {
	// Get user_id from form or query
	userID := c.PostForm("user_id")
	if userID == "" {
		userID = c.Query("user_id")
	}
	if userID == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"error":   "user_id is required",
		})
		return
	}

	// Get uploaded file
	file, header, err := c.Request.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"error":   fmt.Sprintf("failed to get file: %v", err),
		})
		return
	}
	defer file.Close()

	// Validate file extension
	ext := filepath.Ext(header.Filename)
	validExtensions := []string{".mp3", ".wav", ".m4a", ".ogg", ".webm"}
	isValid := false
	for _, validExt := range validExtensions {
		if strings.ToLower(ext) == validExt {
			isValid = true
			break
		}
	}

	if !isValid {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"error":   fmt.Sprintf("invalid file extension. Allowed: %v", validExtensions),
		})
		return
	}

	// Generate unique object name
	objectID := uuid.New().String()
	objectName := fmt.Sprintf("audio/%s/%s%s", userID, objectID, ext)

	// Get content type
	contentType := header.Header.Get("Content-Type")
	if contentType == "" {
		contentType = getContentType(ext)
	}

	// Upload to MinIO
	err = h.minioClient.UploadObject(objectName, file, header.Size, contentType)
	if err != nil {
		log.Printf("❌ Failed to upload %s to MinIO: %v", objectName, err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"error":   "failed to upload file",
		})
		return
	}

	// Generate internal access URL (for AI service)
	internalURL := fmt.Sprintf("http://%s/%s/%s",
		h.config.MinIO.Endpoint,
		h.minioClient.GetBucketName(),
		objectName,
	)

	log.Printf("✅ Uploaded audio: %s (size: %d bytes)", objectName, header.Size)

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"audio_url":    internalURL,
			"object_name":  objectName,
			"content_type": contentType,
			"size":         header.Size,
		},
	})
}

// DeleteAudio deletes audio file
// DELETE /api/v1/storage/audio/:object_name
func (h *StorageHandler) DeleteAudio(c *gin.Context) {
	objectName := c.Param("object_name")
	if objectName == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"error":   "object_name is required",
		})
		return
	}

	// Delete object
	if err := h.minioClient.DeleteObject(objectName); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"error":   "failed to delete audio file",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "audio file deleted successfully",
	})
}

// GetAudioInfo gets audio file metadata
// GET /api/v1/storage/audio/info/:object_name
func (h *StorageHandler) GetAudioInfo(c *gin.Context) {
	objectName := c.Param("object_name")
	if objectName == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"error":   "object_name is required",
		})
		return
	}

	// Get object info
	info, err := h.minioClient.GetObjectInfo(objectName)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"error":   "audio file not found",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"object_name":   info.Key,
			"size":          info.Size,
			"content_type":  info.ContentType,
			"last_modified": info.LastModified.Unix(),
			"etag":          info.ETag,
		},
	})
}

// Helper function to get content type from extension
func getContentType(ext string) string {
	contentTypes := map[string]string{
		".mp3":  "audio/mpeg",
		".wav":  "audio/wav",
		".m4a":  "audio/mp4",
		".ogg":  "audio/ogg",
		".webm": "audio/webm",
	}

	if ct, ok := contentTypes[strings.ToLower(ext)]; ok {
		return ct
	}
	return "audio/mpeg" // default
}

// ValidateAudioExtension helper
func ValidateAudioExtension(filename string) bool {
	ext := strings.ToLower(filepath.Ext(filename))
	validExtensions := []string{".mp3", ".wav", ".m4a", ".ogg", ".webm"}

	for _, validExt := range validExtensions {
		if ext == validExt {
			return true
		}
	}
	return false
}
