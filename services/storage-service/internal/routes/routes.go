package routes

import (
	"github.com/bisosad1501/DATN/services/storage-service/internal/handlers"
	"github.com/gin-gonic/gin"
)

func SetupRoutes(router *gin.Engine, handler *handlers.StorageHandler) {
	// Health check
	router.GET("/health", handler.HealthCheck)

	// API v1 routes
	v1 := router.Group("/api/v1")
	{
		storage := v1.Group("/storage")
		{
			audio := storage.Group("/audio")
			{
				// Direct upload (proxy to MinIO)
				audio.POST("/upload", handler.UploadAudio)

				// Get audio info
				audio.GET("/info/:object_name", handler.GetAudioInfo)

				// Delete audio
				audio.DELETE("/:object_name", handler.DeleteAudio)
			}
		}
	}
}
