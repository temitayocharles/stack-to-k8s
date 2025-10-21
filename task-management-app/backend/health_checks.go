package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"runtime"
	"sync"
	"time"

	"github.com/gorilla/mux"
)

// HealthCheckService manages comprehensive health checks
type HealthCheckService struct {
	db           *sql.DB
	redisClient  interface{} // We'll add Redis later
	checks       map[string]HealthChecker
	mutex        sync.RWMutex
	lastCheck    time.Time
	cache        map[string]HealthStatus
	cacheMutex   sync.RWMutex
	cacheExpiry  time.Duration
}

// HealthChecker interface for different health checks
type HealthChecker interface {
	Name() string
	Check(ctx context.Context) HealthStatus
}

// HealthStatus represents the status of a health check
type HealthStatus struct {
	Status    string                 `json:"status"`
	Message   string                 `json:"message,omitempty"`
	Timestamp time.Time              `json:"timestamp"`
	Duration  time.Duration          `json:"duration"`
	Details   map[string]interface{} `json:"details,omitempty"`
}

// HealthResponse represents the overall health check response
type HealthResponse struct {
	Status     string                    `json:"status"`
	Timestamp  time.Time                 `json:"timestamp"`
	Version    string                    `json:"version"`
	Service    string                    `json:"service"`
	Uptime     string                    `json:"uptime"`
	Checks     map[string]HealthStatus   `json:"checks"`
	Summary    HealthSummary             `json:"summary"`
}

// HealthSummary provides a summary of all health checks
type HealthSummary struct {
	Total     int `json:"total"`
	Healthy   int `json:"healthy"`
	Degraded  int `json:"degraded"`
	Unhealthy int `json:"unhealthy"`
}

// DatabaseHealthChecker checks database connectivity
type DatabaseHealthChecker struct {
	db *sql.DB
}

func (d *DatabaseHealthChecker) Name() string {
	return "database"
}

func (d *DatabaseHealthChecker) Check(ctx context.Context) HealthStatus {
	start := time.Now()

	if d.db == nil {
		return HealthStatus{
			Status:    "unhealthy",
			Message:   "Database not configured",
			Timestamp: time.Now(),
			Duration:  time.Since(start),
		}
	}

	// Test connection with timeout
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	err := d.db.PingContext(ctx)
	if err != nil {
		return HealthStatus{
			Status:    "unhealthy",
			Message:   fmt.Sprintf("Database ping failed: %v", err),
			Timestamp: time.Now(),
			Duration:  time.Since(start),
			Details: map[string]interface{}{
				"error": err.Error(),
			},
		}
	}

	// Test a simple query
	var result int
	err = d.db.QueryRowContext(ctx, "SELECT 1").Scan(&result)
	if err != nil {
		return HealthStatus{
			Status:    "degraded",
			Message:   fmt.Sprintf("Database query failed: %v", err),
			Timestamp: time.Now(),
			Duration:  time.Since(start),
			Details: map[string]interface{}{
				"error": err.Error(),
			},
		}
	}

	return HealthStatus{
		Status:    "healthy",
		Message:   "Database connection successful",
		Timestamp: time.Now(),
		Duration:  time.Since(start),
		Details: map[string]interface{}{
			"connection_pool": map[string]interface{}{
				"max_open":     getDBStats(d.db).MaxOpenConnections,
				"open":         getDBStats(d.db).OpenConnections,
				"in_use":       getDBStats(d.db).InUse,
				"idle":         getDBStats(d.db).Idle,
				"wait_count":   getDBStats(d.db).WaitCount,
				"wait_duration": getDBStats(d.db).WaitDuration.String(),
			},
		},
	}
}

// SystemHealthChecker checks system resources
type SystemHealthChecker struct{}

func (s *SystemHealthChecker) Name() string {
	return "system"
}

func (s *SystemHealthChecker) Check(ctx context.Context) HealthStatus {
	start := time.Now()

	var m runtime.MemStats
	runtime.ReadMemStats(&m)

	return HealthStatus{
		Status:    "healthy",
		Message:   "System resources normal",
		Timestamp: time.Now(),
		Duration:  time.Since(start),
		Details: map[string]interface{}{
			"goroutines": runtime.NumGoroutine(),
			"memory": map[string]interface{}{
				"alloc":        m.Alloc,
				"total_alloc":  m.TotalAlloc,
				"sys":          m.Sys,
				"lookups":      m.Lookups,
				"mallocs":      m.Mallocs,
				"frees":        m.Frees,
				"heap_alloc":   m.HeapAlloc,
				"heap_sys":     m.HeapSys,
				"heap_idle":    m.HeapIdle,
				"heap_inuse":   m.HeapInuse,
				"heap_released": m.HeapReleased,
				"heap_objects": m.HeapObjects,
				"stack_inuse":  m.StackInuse,
				"stack_sys":    m.StackSys,
				"mspan_inuse":  m.MSpanInuse,
				"mspan_sys":    m.MSpanSys,
				"mcache_inuse": m.MCacheInuse,
				"mcache_sys":   m.MCacheSys,
				"buck_hash_sys": m.BuckHashSys,
				"gc_sys":       m.GCSys,
				"other_sys":    m.OtherSys,
			},
			"gc": map[string]interface{}{
				"num_gc":        m.NumGC,
				"next_gc":       m.NextGC,
				"last_gc":       m.LastGC,
				"pause_total_ns": m.PauseTotalNs,
				"num_forced_gc": m.NumForcedGC,
			},
		},
	}
}

// AIHealthChecker checks AI engine status
type AIHealthChecker struct{}

func (a *AIHealthChecker) Name() string {
	return "ai_engine"
}

func (a *AIHealthChecker) Check(ctx context.Context) HealthStatus {
	start := time.Now()

	// Check if AI engine is initialized
	if aiEngine == nil {
		return HealthStatus{
			Status:    "unhealthy",
			Message:   "AI engine not initialized",
			Timestamp: time.Now(),
			Duration:  time.Since(start),
		}
	}

	return HealthStatus{
		Status:    "healthy",
		Message:   "AI engine operational",
		Timestamp: time.Now(),
		Duration:  time.Since(start),
		Details: map[string]interface{}{
			"status": "initialized",
			"type":   "intelligence_engine",
		},
	}
}

// CollaborationHealthChecker checks collaboration engine
type CollaborationHealthChecker struct{}

func (c *CollaborationHealthChecker) Name() string {
	return "collaboration_engine"
}

func (c *CollaborationHealthChecker) Check(ctx context.Context) HealthStatus {
	start := time.Now()

	if collaborationEngine == nil {
		return HealthStatus{
			Status:    "unhealthy",
			Message:   "Collaboration engine not initialized",
			Timestamp: time.Now(),
			Duration:  time.Since(start),
		}
	}

	return HealthStatus{
		Status:    "healthy",
		Message:   "Collaboration engine operational",
		Timestamp: time.Now(),
		Duration:  time.Since(start),
		Details: map[string]interface{}{
			"status": "initialized",
			"type":   "real_time_engine",
		},
	}
}

// WebSocketHealthChecker checks WebSocket hub
type WebSocketHealthChecker struct {
	hub *Hub
}

func (w *WebSocketHealthChecker) Name() string {
	return "websocket"
}

func (w *WebSocketHealthChecker) Check(ctx context.Context) HealthStatus {
	start := time.Now()

	if w.hub == nil {
		return HealthStatus{
			Status:    "unhealthy",
			Message:   "WebSocket hub not initialized",
			Timestamp: time.Now(),
			Duration:  time.Since(start),
		}
	}

	w.hub.mutex.RLock()
	clientCount := len(w.hub.clients)
	w.hub.mutex.RUnlock()

	return HealthStatus{
		Status:    "healthy",
		Message:   "WebSocket hub operational",
		Timestamp: time.Now(),
		Duration:  time.Since(start),
		Details: map[string]interface{}{
			"connected_clients": clientCount,
			"status":           "operational",
		},
	}
}

// NotificationHealthChecker checks notification system
type NotificationHealthChecker struct{}

func (n *NotificationHealthChecker) Name() string {
	return "notification_system"
}

func (n *NotificationHealthChecker) Check(ctx context.Context) HealthStatus {
	start := time.Now()

	if notificationSystem == nil {
		return HealthStatus{
			Status:    "unhealthy",
			Message:   "Notification system not initialized",
			Timestamp: time.Now(),
			Duration:  time.Since(start),
		}
	}

	return HealthStatus{
		Status:    "healthy",
		Message:   "Notification system operational",
		Timestamp: time.Now(),
		Duration:  time.Since(start),
		Details: map[string]interface{}{
			"status": "initialized",
			"type":   "multi_channel",
		},
	}
}

// NewHealthCheckService creates a new health check service
func NewHealthCheckService(db *sql.DB, hub *Hub) *HealthCheckService {
	hcs := &HealthCheckService{
		db:          db,
		checks:      make(map[string]HealthChecker),
		cache:       make(map[string]HealthStatus),
		cacheExpiry: 30 * time.Second,
	}

	// Register health checkers
	hcs.RegisterChecker(&DatabaseHealthChecker{db: db})
	hcs.RegisterChecker(&SystemHealthChecker{})
	hcs.RegisterChecker(&AIHealthChecker{})
	hcs.RegisterChecker(&CollaborationHealthChecker{})
	hcs.RegisterChecker(&WebSocketHealthChecker{hub: hub})
	hcs.RegisterChecker(&NotificationHealthChecker{})

	return hcs
}

// RegisterChecker registers a health checker
func (hcs *HealthCheckService) RegisterChecker(checker HealthChecker) {
	hcs.mutex.Lock()
	defer hcs.mutex.Unlock()
	hcs.checks[checker.Name()] = checker
}

// RunHealthChecks runs all health checks
func (hcs *HealthCheckService) RunHealthChecks(ctx context.Context) map[string]HealthStatus {
	hcs.mutex.RLock()
	defer hcs.mutex.RUnlock()

	results := make(map[string]HealthStatus)

	for name, checker := range hcs.checks {
		status := checker.Check(ctx)
		results[name] = status
	}

	return results
}

// GetHealthSummary returns a summary of health check results
func (hcs *HealthCheckService) GetHealthSummary(results map[string]HealthStatus) HealthSummary {
	summary := HealthSummary{
		Total: len(results),
	}

	for _, status := range results {
		switch status.Status {
		case "healthy":
			summary.Healthy++
		case "degraded":
			summary.Degraded++
		case "unhealthy":
			summary.Unhealthy++
		}
	}

	return summary
}

// DetermineOverallStatus determines the overall health status
func (hcs *HealthCheckService) DetermineOverallStatus(results map[string]HealthStatus) string {
	hasUnhealthy := false
	hasDegraded := false

	for _, status := range results {
		switch status.Status {
		case "unhealthy":
			hasUnhealthy = true
		case "degraded":
			hasDegraded = true
		}
	}

	if hasUnhealthy {
		return "unhealthy"
	}
	if hasDegraded {
		return "degraded"
	}
	return "healthy"
}

// ComprehensiveHealthCheckHandler handles comprehensive health checks
func (hcs *HealthCheckService) ComprehensiveHealthCheckHandler(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
	defer cancel()

	results := hcs.RunHealthChecks(ctx)
	summary := hcs.GetHealthSummary(results)
	overallStatus := hcs.DetermineOverallStatus(results)

	response := HealthResponse{
		Status:    overallStatus,
		Timestamp: time.Now(),
		Version:   "1.0.0",
		Service:   "Task Management API",
		Uptime:    time.Since(startTime).String(),
		Checks:    results,
		Summary:   summary,
	}

	w.Header().Set("Content-Type", "application/json")

	// Set HTTP status code based on overall health
	statusCode := http.StatusOK
	if overallStatus == "unhealthy" {
		statusCode = http.StatusServiceUnavailable
	}

	w.WriteHeader(statusCode)
	json.NewEncoder(w).Encode(response)
}

// ReadinessHealthCheckHandler handles readiness probes
func (hcs *HealthCheckService) ReadinessHealthCheckHandler(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
	defer cancel()

	// Check critical dependencies
	criticalChecks := []string{"database"}

	results := hcs.RunHealthChecks(ctx)

	// Check if all critical services are healthy
	ready := true
	for _, checkName := range criticalChecks {
		if status, exists := results[checkName]; exists {
			if status.Status == "unhealthy" {
				ready = false
				break
			}
		}
	}

	response := map[string]interface{}{
		"status":    "ready",
		"timestamp": time.Now(),
		"checks":    results,
	}

	if !ready {
		response["status"] = "not_ready"
		w.WriteHeader(http.StatusServiceUnavailable)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// LivenessHealthCheckHandler handles liveness probes
func (hcs *HealthCheckService) LivenessHealthCheckHandler(w http.ResponseWriter, r *http.Request) {
	// Liveness checks are simpler - just verify the service is running
	response := map[string]interface{}{
		"status":    "alive",
		"timestamp": time.Now(),
		"uptime":    time.Since(startTime).String(),
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// DependencyHealthCheckHandler checks external dependencies
func (hcs *HealthCheckService) DependencyHealthCheckHandler(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
	defer cancel()

	results := hcs.RunHealthChecks(ctx)

	// Focus on external dependencies
	dependencies := map[string]HealthStatus{
		"database": results["database"],
	}

	response := map[string]interface{}{
		"status":       "healthy",
		"timestamp":    time.Now(),
		"dependencies": dependencies,
	}

	// Check if any dependency is unhealthy
	for _, status := range dependencies {
		if status.Status == "unhealthy" {
			response["status"] = "unhealthy"
			w.WriteHeader(http.StatusServiceUnavailable)
			break
		}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// MetricsHealthCheckHandler provides health metrics
func (hcs *HealthCheckService) MetricsHealthCheckHandler(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
	defer cancel()

	results := hcs.RunHealthChecks(ctx)
	summary := hcs.GetHealthSummary(results)

	metrics := map[string]interface{}{
		"health_checks_total":     summary.Total,
		"health_checks_healthy":   summary.Healthy,
		"health_checks_degraded":  summary.Degraded,
		"health_checks_unhealthy": summary.Unhealthy,
		"overall_status":          hcs.DetermineOverallStatus(results),
		"timestamp":               time.Now().Unix(),
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(metrics)
}

// Helper function to get database stats
func getDBStats(db *sql.DB) sql.DBStats {
	return db.Stats()
}

// Global variables for health checks
var (
	healthCheckService *HealthCheckService
	startTime          = time.Now()
)

// Initialize health check service
func initHealthCheckService(db *sql.DB, hub *Hub) {
	healthCheckService = NewHealthCheckService(db, hub)
	log.Println("🏥 Comprehensive Health Check Service initialized")
}

// Register health check routes
func registerHealthCheckRoutes(r *mux.Router) {
	if healthCheckService == nil {
		log.Println("⚠️  Health check service not initialized")
		return
	}

	// Comprehensive health check
	r.HandleFunc("/health", healthCheckService.ComprehensiveHealthCheckHandler).Methods("GET")

	// Readiness probe
	r.HandleFunc("/health/ready", healthCheckService.ReadinessHealthCheckHandler).Methods("GET")

	// Liveness probe
	r.HandleFunc("/health/live", healthCheckService.LivenessHealthCheckHandler).Methods("GET")

	// Dependency health check
	r.HandleFunc("/health/dependencies", healthCheckService.DependencyHealthCheckHandler).Methods("GET")

	// Health metrics
	r.HandleFunc("/health/metrics", healthCheckService.MetricsHealthCheckHandler).Methods("GET")

	log.Println("🏥 Health check endpoints registered:")
	log.Println("   GET /api/v1/health - Comprehensive health check")
	log.Println("   GET /api/v1/health/ready - Readiness probe")
	log.Println("   GET /api/v1/health/live - Liveness probe")
	log.Println("   GET /api/v1/health/dependencies - Dependency check")
	log.Println("   GET /api/v1/health/metrics - Health metrics")
}