package minio

import (
	"context"
	"fmt"
	"io"
	"log"

	"github.com/bisosad1501/DATN/services/storage-service/internal/config"
	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
)

type MinIOClient struct {
	client     *minio.Client
	bucketName string
}

func NewMinIOClient(cfg *config.Config) (*MinIOClient, error) {
	// Initialize MinIO client
	client, err := minio.New(cfg.MinIO.Endpoint, &minio.Options{
		Creds:  credentials.NewStaticV4(cfg.MinIO.AccessKey, cfg.MinIO.SecretKey, ""),
		Secure: cfg.MinIO.UseSSL,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to create MinIO client: %w", err)
	}

	return &MinIOClient{
		client:     client,
		bucketName: cfg.MinIO.BucketName,
	}, nil
}

// EnsureBucket creates bucket if it doesn't exist
func (m *MinIOClient) EnsureBucket() error {
	ctx := context.Background()

	exists, err := m.client.BucketExists(ctx, m.bucketName)
	if err != nil {
		return fmt.Errorf("error checking bucket: %w", err)
	}

	if !exists {
		err = m.client.MakeBucket(ctx, m.bucketName, minio.MakeBucketOptions{})
		if err != nil {
			return fmt.Errorf("error creating bucket: %w", err)
		}
		log.Printf("✅ Created bucket: %s", m.bucketName)
	}

	return nil
}

// GetObjectInfo gets information about an object
func (m *MinIOClient) GetObjectInfo(objectName string) (minio.ObjectInfo, error) {
	ctx := context.Background()
	return m.client.StatObject(ctx, m.bucketName, objectName, minio.StatObjectOptions{})
}

// DeleteObject deletes an object from bucket
func (m *MinIOClient) DeleteObject(objectName string) error {
	ctx := context.Background()
	return m.client.RemoveObject(ctx, m.bucketName, objectName, minio.RemoveObjectOptions{})
}

// UploadObject uploads an object to MinIO
func (m *MinIOClient) UploadObject(objectName string, reader io.Reader, objectSize int64, contentType string) error {
	ctx := context.Background()

	_, err := m.client.PutObject(ctx, m.bucketName, objectName, reader, objectSize, minio.PutObjectOptions{
		ContentType: contentType,
	})

	return err
}

// GetBucketName returns the bucket name
func (m *MinIOClient) GetBucketName() string {
	return m.bucketName
}
