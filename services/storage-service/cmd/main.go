package main

import (
	"log"
	"os"

	"github.com/bisosad1501/DATN/services/storage-service/internal/config"
	"github.com/bisosad1501/DATN/services/storage-service/internal/handlers"
	"github.com/bisosad1501/DATN/services/storage-service/internal/minio"
	"github.com/bisosad1501/DATN/services/storage-service/internal/routes"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	_ = godotenv.Load()

	// Load configuration
	cfg := config.LoadConfig()

	// Initialize MinIO client
	minioClient, err := minio.NewMinIOClient(cfg)
	if err != nil {
		log.Fatalf("Failed to initialize MinIO client: %v", err)
	}

	// Ensure bucket exists
	if err := minioClient.EnsureBucket(); err != nil {
		log.Fatalf("Failed to ensure bucket exists: %v", err)
	}

	log.Printf("✅ Connected to MinIO - Bucket: %s", cfg.MinIO.BucketName)

	// Initialize handlers
	storageHandler := handlers.NewStorageHandler(minioClient, cfg)

	// Setup Gin router
	if os.Getenv("GIN_MODE") == "release" {
		gin.SetMode(gin.ReleaseMode)
	}

	router := gin.Default()
	routes.SetupRoutes(router, storageHandler)

	// Start server
	port := cfg.Server.Port
	log.Printf("🚀 Storage Service starting on port %s", port)
	log.Printf("📦 MinIO Console: http://localhost:9001")
	log.Printf("💾 Bucket: %s", cfg.MinIO.BucketName)

	if err := router.Run(":" + port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
