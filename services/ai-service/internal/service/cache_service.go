package service

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"log"
	"time"

	"github.com/bisosad1501/DATN/services/ai-service/internal/models"
	"github.com/bisosad1501/DATN/services/ai-service/internal/repository"
)

// CacheService handles evaluation result caching
type CacheService struct {
	repo *repository.AIRepository
}

// NewCacheService creates a new cache service
func NewCacheService(repo *repository.AIRepository) *CacheService {
	return &CacheService{
		repo: repo,
	}
}

// CacheEntry represents a cached evaluation result
type CacheEntry struct {
	Hash      string
	Content   string
	ExpiresAt time.Time
}

const (
	// CacheTTL defines how long cache entries are valid (7 days)
	CacheTTL = 7 * 24 * time.Hour
)

// generateContentHash creates SHA256 hash of content for cache key
func generateContentHash(content string) string {
	hasher := sha256.New()
	hasher.Write([]byte(content))
	return hex.EncodeToString(hasher.Sum(nil))
}

// CheckWritingCache checks if evaluation exists in cache
func (cs *CacheService) CheckWritingCache(essayText, taskType, promptText string) (*models.OpenAIWritingEvaluation, bool) {
	// Generate cache key from content
	cacheKey := fmt.Sprintf("writing:%s:%s:%s", taskType, promptText, essayText)
	hash := generateContentHash(cacheKey)

	// Try to get from database cache table
	cached, err := cs.repo.GetCachedEvaluation(hash)
	if err != nil {
		log.Printf("Cache miss (error): %v", err)
		return nil, false
	}

	if cached == nil {
		log.Printf("Cache miss: hash=%s", hash[:8])
		return nil, false
	}

	// Check if expired
	if cached.ExpiresAt.Valid && time.Now().After(cached.ExpiresAt.Time) {
		log.Printf("Cache expired: hash=%s", hash[:8])
		cs.repo.DeleteCachedEvaluation(hash) // Clean up
		return nil, false
	}

	// Parse cached result
	var result models.OpenAIWritingEvaluation
	if err := json.Unmarshal([]byte(cached.Content), &result); err != nil {
		log.Printf("Cache parse error: %v", err)
		return nil, false
	}

	log.Printf("✅ Cache hit: hash=%s", hash[:8])
	return &result, true
}

// SaveWritingCache saves evaluation result to cache
func (cs *CacheService) SaveWritingCache(essayText, taskType, promptText string, result *models.OpenAIWritingEvaluation) error {
	// Generate cache key
	cacheKey := fmt.Sprintf("writing:%s:%s:%s", taskType, promptText, essayText)
	hash := generateContentHash(cacheKey)

	// Serialize result
	content, err := json.Marshal(result)
	if err != nil {
		return fmt.Errorf("failed to serialize result: %w", err)
	}

	// Save to database cache table
	entry := &CacheEntry{
		Hash:      hash,
		Content:   string(content),
		ExpiresAt: time.Now().Add(CacheTTL),
	}

	if err := cs.repo.SaveCachedEvaluation(entry.Hash, entry.Content, entry.ExpiresAt); err != nil {
		log.Printf("⚠️ Failed to save cache: %v", err)
		return err
	}

	log.Printf("💾 Cached result: hash=%s, ttl=%v", hash[:8], CacheTTL)
	return nil
}

// CheckSpeakingCache checks if speaking evaluation exists in cache
func (cs *CacheService) CheckSpeakingCache(audioURL, transcriptText string, partNumber int) (*models.OpenAISpeakingEvaluation, bool) {
	// Generate cache key from transcript (audio URL may change but same audio = same transcript)
	cacheKey := fmt.Sprintf("speaking:%d:%s", partNumber, transcriptText)
	hash := generateContentHash(cacheKey)

	// Try to get from database cache table
	cached, err := cs.repo.GetCachedEvaluation(hash)
	if err != nil {
		log.Printf("Cache miss (error): %v", err)
		return nil, false
	}

	if cached == nil {
		log.Printf("Cache miss: hash=%s", hash[:8])
		return nil, false
	}

	// Check if expired
	if cached.ExpiresAt.Valid && time.Now().After(cached.ExpiresAt.Time) {
		log.Printf("Cache expired: hash=%s", hash[:8])
		cs.repo.DeleteCachedEvaluation(hash) // Clean up
		return nil, false
	}

	// Parse cached result
	var result models.OpenAISpeakingEvaluation
	if err := json.Unmarshal([]byte(cached.Content), &result); err != nil {
		log.Printf("Cache parse error: %v", err)
		return nil, false
	}

	log.Printf("✅ Cache hit: hash=%s", hash[:8])
	return &result, true
}

// SaveSpeakingCache saves speaking evaluation result to cache
func (cs *CacheService) SaveSpeakingCache(audioURL, transcriptText string, partNumber int, result *models.OpenAISpeakingEvaluation) error {
	// Generate cache key
	cacheKey := fmt.Sprintf("speaking:%d:%s", partNumber, transcriptText)
	hash := generateContentHash(cacheKey)

	// Serialize result
	content, err := json.Marshal(result)
	if err != nil {
		return fmt.Errorf("failed to serialize result: %w", err)
	}

	// Save to database cache table
	entry := &CacheEntry{
		Hash:      hash,
		Content:   string(content),
		ExpiresAt: time.Now().Add(CacheTTL),
	}

	if err := cs.repo.SaveCachedEvaluation(entry.Hash, entry.Content, entry.ExpiresAt); err != nil {
		log.Printf("⚠️ Failed to save cache: %v", err)
		return err
	}

	log.Printf("💾 Cached result: hash=%s, ttl=%v", hash[:8], CacheTTL)
	return nil
}

// GetCacheStatistics returns cache hit/miss statistics
func (cs *CacheService) GetCacheStatistics() (map[string]interface{}, error) {
	stats, err := cs.repo.GetCacheStatistics()
	if err != nil {
		return nil, err
	}

	return map[string]interface{}{
		"total_entries":   stats["total_entries"],
		"expired_entries": stats["expired_entries"],
		"valid_entries":   stats["valid_entries"],
		"cache_size_mb":   stats["cache_size_mb"],
	}, nil
}
