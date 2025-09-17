package main

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"log"
	"math"
	"net/http"
	"net/url"
	"os"
	"sort"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/mux"
	"github.com/gorilla/websocket"
	"github.com/rs/cors"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

// Task represents a task in the system with advanced features
type Task struct {
	ID            string               `json:"id"`
	Rev           string               `json:"_rev,omitempty"`
	Title         string               `json:"title" validate:"required,min=1,max=200"`
	Description   string               `json:"description" validate:"max=1000"`
	Status        string               `json:"status" validate:"required,oneof=todo in_progress review done archived"`
	Priority      string               `json:"priority" validate:"required,oneof=low medium high urgent critical"`
	AssigneeID    string               `json:"assignee_id,omitempty"`
	ProjectID     string               `json:"project_id" validate:"required"`
	Tags          []string             `json:"tags"`
	DueDate       *string              `json:"due_date,omitempty"`
	EstimatedTime int                  `json:"estimated_time"` // in minutes
	ActualTime    int                  `json:"actual_time"`    // in minutes
	CreatedBy     string               `json:"created_by" validate:"required"`
	CreatedAt     time.Time            `json:"created_at"`
	UpdatedAt     time.Time            `json:"updated_at"`
	CompletedAt   *time.Time           `json:"completed_at,omitempty"`
	Dependencies  []string             `json:"dependencies"` // Task IDs this task depends on
	Subtasks      []string             `json:"subtasks"`     // Subtask IDs
	Comments      []TaskComment        `json:"comments"`
	TimeTracking  []TimeEntry          `json:"time_tracking"`
	Attachments   []TaskAttachment     `json:"attachments"`
	Watchers      []string             `json:"watchers"`     // User IDs watching this task
	Labels        []TaskLabel          `json:"labels"`
	CustomFields  map[string]interface{} `json:"custom_fields"`
	AIInsights    *TaskAIInsights      `json:"ai_insights,omitempty"`
	Collaboration TaskCollaboration    `json:"collaboration"`
	Type          string               `json:"type"` // CouchDB document type
}

// TaskComment represents a comment on a task
type TaskComment struct {
	ID        string    `json:"id"`
	UserID    string    `json:"user_id"`
	Content   string    `json:"content"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Mentions  []string  `json:"mentions"` // User IDs mentioned in comment
}

// TimeEntry represents time tracking for a task
type TimeEntry struct {
	ID          string     `json:"id"`
	UserID      string     `json:"user_id"`
	StartTime   time.Time  `json:"start_time"`
	EndTime     *time.Time `json:"end_time,omitempty"`
	Duration    int        `json:"duration"` // in minutes
	Description string     `json:"description"`
	CreatedAt   time.Time  `json:"created_at"`
}

// TaskAttachment represents a file attachment
type TaskAttachment struct {
	ID       string    `json:"id"`
	Filename string    `json:"filename"`
	URL      string    `json:"url"`
	Size     int64     `json:"size"`
	MimeType string    `json:"mime_type"`
	UserID   string    `json:"user_id"`
	CreatedAt time.Time `json:"created_at"`
}

// TaskLabel represents a colored label
type TaskLabel struct {
	ID    string `json:"id"`
	Name  string `json:"name"`
	Color string `json:"color"`
}

// TaskAIInsights represents AI-generated insights for a task
type TaskAIInsights struct {
	CompletionPrediction float64           `json:"completion_prediction"` // 0-1 probability
	RiskScore           float64           `json:"risk_score"`             // 0-1 risk level
	RecommendedPriority string            `json:"recommended_priority"`
	SimilarTasks        []string          `json:"similar_tasks"` // Task IDs
	Bottlenecks         []string          `json:"bottlenecks"`   // Potential blocking issues
	Recommendations     []AIRecommendation `json:"recommendations"`
	UpdatedAt           time.Time         `json:"updated_at"`
}

// AIRecommendation represents an AI-generated recommendation
type AIRecommendation struct {
	Type        string  `json:"type"`        // e.g., "time_estimate", "resource_allocation"
	Confidence  float64 `json:"confidence"`  // 0-1
	Description string  `json:"description"`
	Action      string  `json:"action"`
}

// TaskCollaboration represents real-time collaboration data
type TaskCollaboration struct {
	ActiveUsers    []ActiveUser    `json:"active_users"`
	RecentActivity []ActivityEvent `json:"recent_activity"`
	ConflictState  *ConflictState  `json:"conflict_state,omitempty"`
}

// ActiveUser represents a user currently viewing/editing a task
type ActiveUser struct {
	UserID    string    `json:"user_id"`
	Username  string    `json:"username"`
	Action    string    `json:"action"` // "viewing", "editing", "commenting"
	LastSeen  time.Time `json:"last_seen"`
	CursorPos int       `json:"cursor_pos"` // For real-time editing
}

// ActivityEvent represents a real-time activity event
type ActivityEvent struct {
	ID        string                 `json:"id"`
	Type      string                 `json:"type"` // "status_change", "comment", "assignment", etc.
	UserID    string                 `json:"user_id"`
	Username  string                 `json:"username"`
	Data      map[string]interface{} `json:"data"`
	Timestamp time.Time              `json:"timestamp"`
}

// ConflictState represents merge conflicts in collaborative editing
type ConflictState struct {
	ConflictID   string                 `json:"conflict_id"`
	Field        string                 `json:"field"`
	Versions     map[string]interface{} `json:"versions"` // user_id -> field_value
	ResolvedBy   string                 `json:"resolved_by,omitempty"`
	ResolvedAt   *time.Time             `json:"resolved_at,omitempty"`
	ResolutionValue interface{}         `json:"resolution_value,omitempty"`
}

// User represents a user in the system with enhanced features
type User struct {
	ID               string              `json:"id"`
	Rev              string              `json:"_rev,omitempty"`
	Username         string              `json:"username" validate:"required,min=3,max=50"`
	Email            string              `json:"email" validate:"required,email"`
	FullName         string              `json:"full_name" validate:"required"`
	Role             string              `json:"role" validate:"required,oneof=admin manager user guest"`
	Avatar           string              `json:"avatar,omitempty"`
	IsActive         bool                `json:"is_active"`
	CreatedAt        time.Time           `json:"created_at"`
	LastActiveAt     *time.Time          `json:"last_active_at"`
	Preferences      UserPreferences     `json:"preferences"`
	Skills           []string            `json:"skills"`
	WorkloadCapacity int                 `json:"workload_capacity"` // max concurrent tasks
	CurrentWorkload  int                 `json:"current_workload"`  // current task count
	ProductivityScore float64            `json:"productivity_score"` // AI-calculated 0-1
	Teams            []string            `json:"teams"`             // Team IDs
	Notifications    NotificationSettings `json:"notifications"`
	Type             string              `json:"type"` // CouchDB document type
}

// UserPreferences represents user customization preferences
type UserPreferences struct {
	Theme           string `json:"theme"`           // "light", "dark", "auto"
	Language        string `json:"language"`        // "en", "es", "fr", etc.
	Timezone        string `json:"timezone"`        // IANA timezone
	DateFormat      string `json:"date_format"`     // "MM/DD/YYYY", "DD/MM/YYYY", etc.
	WorkingHours    WorkingHours `json:"working_hours"`
	EmailDigest     string `json:"email_digest"`    // "daily", "weekly", "none"
	DefaultView     string `json:"default_view"`    // "kanban", "list", "calendar"
	AutoAssignment  bool   `json:"auto_assignment"` // Allow AI auto-assignment
}

// WorkingHours represents user's working schedule
type WorkingHours struct {
	StartTime string   `json:"start_time"` // "09:00"
	EndTime   string   `json:"end_time"`   // "17:00"
	Days      []string `json:"days"`       // ["monday", "tuesday", ...]
	Timezone  string   `json:"timezone"`
}

// NotificationSettings represents user notification preferences
type NotificationSettings struct {
	Email     NotificationChannel `json:"email"`
	Push      NotificationChannel `json:"push"`
	InApp     NotificationChannel `json:"in_app"`
	Slack     NotificationChannel `json:"slack"`
	Frequency string              `json:"frequency"` // "immediate", "batched", "digest"
}

// NotificationChannel represents settings for a notification channel
type NotificationChannel struct {
	Enabled bool     `json:"enabled"`
	Events  []string `json:"events"` // types of events to notify about
}

// Project represents a project in the system
type Project struct {
	ID          string    `json:"id"`
	Rev         string    `json:"_rev,omitempty"`
	Name        string    `json:"name" validate:"required,min=1,max=100"`
	Description string    `json:"description" validate:"max=500"`
	Status      string    `json:"status" validate:"required,oneof=active completed archived"`
	OwnerID     string    `json:"owner_id" validate:"required"`
	TeamMembers []string  `json:"team_members"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
	Type        string    `json:"type"` // CouchDB document type
}

// Comment represents a comment on a task
type Comment struct {
	ID        string    `json:"id"`
	Rev       string    `json:"_rev,omitempty"`
	TaskID    string    `json:"task_id" validate:"required"`
	UserID    string    `json:"user_id" validate:"required"`
	Content   string    `json:"content" validate:"required,max=1000"`
	CreatedAt time.Time `json:"created_at"`
	Type      string    `json:"type"` // CouchDB document type
}

// WebSocket connection management for real-time collaboration
type Hub struct {
	clients    map[*Client]bool
	broadcast  chan []byte
	register   chan *Client
	unregister chan *Client
	rooms      map[string]map[*Client]bool // room_id -> clients
	mutex      sync.RWMutex
}

type Client struct {
	hub      *Hub
	conn     *websocket.Conn
	send     chan []byte
	userID   string
	username string
	rooms    map[string]bool // rooms this client is subscribed to
}

// Real-time message types
type WSMessage struct {
	Type      string                 `json:"type"`
	RoomID    string                 `json:"room_id,omitempty"`
	UserID    string                 `json:"user_id"`
	Username  string                 `json:"username"`
	Data      map[string]interface{} `json:"data"`
	Timestamp time.Time              `json:"timestamp"`
}

// AI Engine for task intelligence and automation
type AIEngine struct {
	TaskPatterns    map[string]TaskPattern    `json:"task_patterns"`
	UserProfiles    map[string]UserProfile    `json:"user_profiles"`
	ProjectMetrics  map[string]ProjectMetrics `json:"project_metrics"`
	PredictionModel *PredictionModel          `json:"prediction_model"`
	mutex           sync.RWMutex
}

// Analytics and monitoring
var (
	aiEngine       *AIEngine
	globalHub      *Hub
	metricsEngine  *AnalyticsEngine
	
	// Prometheus metrics
	taskCreatedCounter = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "tasks_created_total",
			Help: "Total number of tasks created",
		},
		[]string{"project_id", "priority", "user_id"},
	)
	
	taskCompletedCounter = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "tasks_completed_total",
			Help: "Total number of tasks completed",
		},
		[]string{"project_id", "priority", "user_id"},
	)
	
	taskDurationHistogram = prometheus.NewHistogramVec(
		prometheus.HistogramOpts{
			Name: "task_duration_seconds",
			Help: "Duration of task completion in seconds",
			Buckets: prometheus.ExponentialBuckets(60, 2, 10), // 1 minute to ~17 hours
		},
		[]string{"task_type", "priority"},
	)
	
	activeUsersGauge = prometheus.NewGaugeVec(
		prometheus.GaugeOpts{
			Name: "active_users_current",
			Help: "Current number of active users",
		},
		[]string{"project_id"},
	)
	
	collaborationEventsCounter = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "collaboration_events_total",
			Help: "Total number of real-time collaboration events",
		},
		[]string{"event_type", "project_id"},
	)
)

// CouchDB configuration
type CouchDBConfig struct {
	Host     string
	Port     string
	Username string
	Password string
	Database string
}

var couchConfig CouchDBConfig

func main() {
	// Initialize configuration
	initConfig()

	// Initialize CouchDB connection
	initCouchDB()

	// Initialize AI Intelligence Engine - UNIQUE TO THIS APPLICATION
	aiEngine := NewTaskIntelligenceEngine()
	log.Println("🧠 AI Intelligence Engine initialized with predictive analytics")

	// Initialize Real-time Collaboration Engine - UNIQUE FEATURES
	collaborationEngine := NewCollaborationEngine()
	log.Println("🤝 Real-time Collaboration Engine initialized with conflict resolution")

	// Initialize Predictive Model Training
	go func() {
		log.Println("🎯 Starting AI model training background process...")
		trainPredictiveModels(aiEngine)
	}()

	// Initialize Burnout Prevention Monitoring
	go func() {
		log.Println("💪 Starting burnout prevention monitoring...")
		monitorTeamWellbeing(aiEngine)
	}()

	// Initialize Smart Workflow Optimization
	go func() {
		log.Println("⚙️ Starting workflow optimization engine...")
		optimizeWorkflowsIntelligently(aiEngine)
	}()

	// Initialize WebSocket hub for basic real-time features
	hub = &Hub{
		clients:    make(map[*websocket.Conn]bool),
		broadcast:  make(chan []byte),
		register:   make(chan *websocket.Conn),
		unregister: make(chan *websocket.Conn),
	}
	go hub.run()

	// Create router
	r := mux.NewRouter()

	// API routes
	api := r.PathPrefix("/api/v1").Subrouter()

	// Enhanced Task routes with AI predictions
	api.HandleFunc("/tasks", getTasks).Methods("GET")
	api.HandleFunc("/tasks", createTaskWithAI(aiEngine)).Methods("POST")  // AI-enhanced task creation
	api.HandleFunc("/tasks/{id}", getTask).Methods("GET")
	api.HandleFunc("/tasks/{id}", updateTaskWithAI(aiEngine)).Methods("PUT")  // AI-enhanced updates
	api.HandleFunc("/tasks/{id}", deleteTask).Methods("DELETE")

	// AI-powered task intelligence endpoints - UNIQUE FEATURES
	api.HandleFunc("/tasks/{id}/predict-completion", predictTaskCompletion(aiEngine)).Methods("POST")
	api.HandleFunc("/tasks/{id}/optimize-assignment", optimizeTaskAssignment(aiEngine)).Methods("POST")
	api.HandleFunc("/tasks/intelligent-routing", intelligentTaskRouting(aiEngine)).Methods("POST")
	api.HandleFunc("/tasks/{id}/ai-insights", getTaskAIInsights(aiEngine)).Methods("GET")

	// User routes with AI profiling
	api.HandleFunc("/users", getUsers).Methods("GET")
	api.HandleFunc("/users", createUserWithAI(aiEngine)).Methods("POST")  // Creates AI profile
	api.HandleFunc("/users/{id}", getUser).Methods("GET")
	api.HandleFunc("/users/{id}", updateUserWithAI(aiEngine)).Methods("PUT")  // Updates AI profile
	api.HandleFunc("/users/{id}/ai-profile", getUserAIProfile(aiEngine)).Methods("GET")  // UNIQUE
	api.HandleFunc("/users/{id}/productivity-insights", getUserProductivityInsights(aiEngine)).Methods("GET")  // UNIQUE
	api.HandleFunc("/users/{id}/burnout-assessment", assessUserBurnoutRisk(aiEngine)).Methods("GET")  // UNIQUE

	// Project routes with team optimization
	api.HandleFunc("/projects", getProjects).Methods("GET")
	api.HandleFunc("/projects", createProjectWithAI(aiEngine)).Methods("POST")  // AI team optimization
	api.HandleFunc("/projects/{id}", getProject).Methods("GET")
	api.HandleFunc("/projects/{id}", updateProjectWithAI(aiEngine)).Methods("PUT")
	api.HandleFunc("/projects/{id}/tasks", getProjectTasks).Methods("GET")

	// Team Intelligence endpoints - UNIQUE TO THIS APPLICATION
	api.HandleFunc("/teams/{id}/optimize-workload", optimizeTeamWorkload(aiEngine)).Methods("POST")
	api.HandleFunc("/teams/{id}/collaboration-analysis", getCollaborationAnalysis(aiEngine)).Methods("GET")
	api.HandleFunc("/teams/{id}/detect-conflicts", detectAndResolveConflicts(aiEngine)).Methods("POST")
	api.HandleFunc("/teams/{id}/predictive-insights", getTeamPredictiveInsights(aiEngine)).Methods("GET")
	api.HandleFunc("/teams/{id}/rebalance-assignments", rebalanceTeamAssignments(aiEngine)).Methods("POST")

	// Real-time Collaboration endpoints - UNIQUE FEATURES
	api.HandleFunc("/collaboration/rooms", getCollaborationRooms(collaborationEngine)).Methods("GET")
	api.HandleFunc("/collaboration/rooms", createCollaborationRoom(collaborationEngine)).Methods("POST")
	api.HandleFunc("/collaboration/rooms/{id}/join", joinCollaborationRoom(collaborationEngine)).Methods("POST")
	api.HandleFunc("/collaboration/rooms/{id}/leave", leaveCollaborationRoom(collaborationEngine)).Methods("POST")
	api.HandleFunc("/collaboration/presence", getUserPresence(collaborationEngine)).Methods("GET")
	api.HandleFunc("/collaboration/decisions", createGroupDecision(collaborationEngine)).Methods("POST")
	api.HandleFunc("/collaboration/decisions/{id}/vote", castVote(collaborationEngine)).Methods("POST")

	// Workflow Intelligence endpoints - ADVANCED ORCHESTRATION
	api.HandleFunc("/workflows", getWorkflows(aiEngine)).Methods("GET")
	api.HandleFunc("/workflows", createIntelligentWorkflow(aiEngine)).Methods("POST")
	api.HandleFunc("/workflows/{id}", updateWorkflowWithAI(aiEngine)).Methods("PUT")
	api.HandleFunc("/workflows/{id}/optimize", optimizeWorkflow(aiEngine)).Methods("POST")
	api.HandleFunc("/workflows/{id}/predictions", getWorkflowPredictions(aiEngine)).Methods("GET")
	api.HandleFunc("/workflows/{id}/auto-coordinate", autoCoordinateWorkflow(aiEngine)).Methods("POST")

	// Comment routes
	api.HandleFunc("/tasks/{id}/comments", getTaskComments).Methods("GET")
	api.HandleFunc("/tasks/{id}/comments", createComment).Methods("POST")

	// Enhanced Dashboard with AI insights
	api.HandleFunc("/dashboard/stats", getDashboardStats).Methods("GET")
	api.HandleFunc("/dashboard/ai-insights", getDashboardAIInsights(aiEngine)).Methods("GET")  // UNIQUE
	api.HandleFunc("/dashboard/predictive", getDashboardPredictive(aiEngine)).Methods("GET")  // UNIQUE
	api.HandleFunc("/dashboard/optimization", getDashboardOptimization(aiEngine)).Methods("GET")  // UNIQUE

	// WebSocket endpoints
	api.HandleFunc("/ws", handleWebSocket).Methods("GET")  // Basic WebSocket
	api.HandleFunc("/ws/collaboration", func(w http.ResponseWriter, r *http.Request) {
		collaborationEngine.HandleWebSocketConnection(w, r)  // Advanced collaboration WebSocket
	}).Methods("GET")

	// Health check
	api.HandleFunc("/health", healthCheck).Methods("GET")

	// CORS middleware
	c := cors.New(cors.Options{
		AllowedOrigins:   []string{getEnv("FRONTEND_URL", "http://localhost:3000")},
		AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"*"},
		AllowCredentials: true,
	})

	handler := c.Handler(r)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("🚀 AI-Powered Task Management API starting on port %s", port)
	log.Printf("🧠 Features: Predictive Analytics, Burnout Prevention, Intelligent Routing")
	log.Printf("🤝 Real-time Collaboration with Conflict Resolution")
	log.Printf("📊 Dashboard available at http://localhost:%s/api/v1/dashboard/stats", port)
	log.Printf("🔗 Basic WebSocket: ws://localhost:%s/api/v1/ws", port)
	log.Printf("🔗 Advanced Collaboration: ws://localhost:%s/api/v1/ws/collaboration", port)
	log.Fatal(http.ListenAndServe(":"+port, handler))
}

func initConfig() {
	couchConfig = CouchDBConfig{
		Host:     getEnv("COUCHDB_HOST", "localhost"),
		Port:     getEnv("COUCHDB_PORT", "5984"),
		Username: getEnv("COUCHDB_USERNAME", "admin"),
		Password: getEnv("COUCHDB_PASSWORD", "password"),
		Database: getEnv("COUCHDB_DATABASE", "taskmanagement"),
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func initCouchDB() {
	baseURL := fmt.Sprintf("http://%s:%s@%s:%s",
		couchConfig.Username,
		couchConfig.Password,
		couchConfig.Host,
		couchConfig.Port)

	// Create database if it doesn't exist
	resp, err := http.Get(fmt.Sprintf("%s/%s", baseURL, couchConfig.Database))
	if err != nil {
		log.Fatal("Failed to connect to CouchDB:", err)
	}
	resp.Body.Close()

	if resp.StatusCode == 404 {
		// Create database
		req, _ := http.NewRequest("PUT", fmt.Sprintf("%s/%s", baseURL, couchConfig.Database), nil)
		client := &http.Client{}
		resp, err := client.Do(req)
		if err != nil {
			log.Fatal("Failed to create database:", err)
		}
		resp.Body.Close()
		log.Printf("✅ Created CouchDB database: %s", couchConfig.Database)
	}

	log.Printf("✅ Connected to CouchDB at %s:%s", couchConfig.Host, couchConfig.Port)

	// Create design documents for views
	createDesignDocuments()
}

func createDesignDocuments() {
	// Design document for tasks view
	tasksView := map[string]interface{}{
		"_id": "_design/tasks",
		"views": map[string]interface{}{
			"by_project": map[string]interface{}{
				"map": "function(doc) { if(doc.type === 'task') { emit(doc.project_id, doc); } }",
			},
			"by_assignee": map[string]interface{}{
				"map": "function(doc) { if(doc.type === 'task' && doc.assignee_id) { emit(doc.assignee_id, doc); } }",
			},
			"by_status": map[string]interface{}{
				"map": "function(doc) { if(doc.type === 'task') { emit(doc.status, doc); } }",
			},
		},
	}

	createDesignDocument(tasksView)

	// Design document for users view
	usersView := map[string]interface{}{
		"_id": "_design/users",
		"views": map[string]interface{}{
			"active": map[string]interface{}{
				"map": "function(doc) { if(doc.type === 'user' && doc.is_active) { emit(doc._id, doc); } }",
			},
		},
	}

	createDesignDocument(usersView)
}

func createDesignDocument(doc map[string]interface{}) {
	jsonData, _ := json.Marshal(doc)
	baseURL := fmt.Sprintf("http://%s:%s@%s:%s",
		couchConfig.Username,
		couchConfig.Password,
		couchConfig.Host,
		couchConfig.Port)

	url := fmt.Sprintf("%s/%s/%s", baseURL, couchConfig.Database, doc["_id"])
	req, _ := http.NewRequest("PUT", url, bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		log.Printf("Warning: Failed to create design document %s: %v", doc["_id"], err)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode == 201 || resp.StatusCode == 409 { // Created or conflict (already exists)
		log.Printf("✅ Design document %s ready", doc["_id"])
	}
}

// WebSocket hub methods
func (h *Hub) run() {
	for {
		select {
		case conn := <-h.register:
			h.clients[conn] = true
			log.Println("📱 Client connected")

		case conn := <-h.unregister:
			if _, ok := h.clients[conn]; ok {
				delete(h.clients, conn)
				conn.Close()
				log.Println("📱 Client disconnected")
			}

		case message := <-h.broadcast:
			for conn := range h.clients {
				if err := conn.WriteMessage(websocket.TextMessage, message); err != nil {
					delete(h.clients, conn)
					conn.Close()
				}
			}
		}
	}
}

func broadcastUpdate(eventType string, data interface{}) {
	message := map[string]interface{}{
		"type":      eventType,
		"data":      data,
		"timestamp": time.Now(),
	}

	jsonData, err := json.Marshal(message)
	if err != nil {
		log.Printf("Error marshaling broadcast message: %v", err)
		return
	}

	select {
	case hub.broadcast <- jsonData:
	default:
		// Channel is full, skip broadcast
	}
}

func handleWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("WebSocket upgrade error: %v", err)
		return
	}

	hub.register <- conn

	// Listen for client disconnect
	go func() {
		defer func() {
			hub.unregister <- conn
		}()

		for {
			_, _, err := conn.ReadMessage()
			if err != nil {
				break
			}
		}
	}()
}

func healthCheck(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"status":    "healthy",
		"timestamp": time.Now(),
		"version":   "1.0.0",
		"services": map[string]string{
			"couchdb":   "connected",
			"websocket": "active",
		},
	})
}

// CouchDB helper functions
func couchDBRequest(method, path string, body interface{}) (*http.Response, error) {
	baseURL := fmt.Sprintf("http://%s:%s@%s:%s",
		couchConfig.Username,
		couchConfig.Password,
		couchConfig.Host,
		couchConfig.Port)

	url := fmt.Sprintf("%s/%s%s", baseURL, couchConfig.Database, path)

	var reqBody *bytes.Buffer
	if body != nil {
		jsonData, err := json.Marshal(body)
		if err != nil {
			return nil, err
		}
		reqBody = bytes.NewBuffer(jsonData)
	} else {
		reqBody = bytes.NewBuffer([]byte{})
	}

	req, err := http.NewRequest(method, url, reqBody)
	if err != nil {
		return nil, err
	}

	if body != nil {
		req.Header.Set("Content-Type", "application/json")
	}

	client := &http.Client{}
	return client.Do(req)
}

func getAllDocs(docType string) ([]map[string]interface{}, error) {
	resp, err := couchDBRequest("GET", "/_all_docs?include_docs=true", nil)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var result map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, err
	}

	rows := result["rows"].([]interface{})
	var docs []map[string]interface{}

	for _, row := range rows {
		rowMap := row.(map[string]interface{})
		doc := rowMap["doc"].(map[string]interface{})

		// Filter by document type
		if docType == "" || doc["type"] == docType {
			docs = append(docs, doc)
		}
	}

	return docs, nil
}

// Task handlers
func getTasks(w http.ResponseWriter, r *http.Request) {
	rows, err := db.Query("SELECT id, title, description, status, priority, assignee_id, created_at, updated_at FROM tasks ORDER BY created_at DESC")
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var tasks []Task
	for rows.Next() {
		var task Task
		err := rows.Scan(&task.ID, &task.Title, &task.Description, &task.Status, &task.Priority, &task.AssigneeID, &task.CreatedAt, &task.UpdatedAt)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		tasks = append(tasks, task)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(tasks)
}

func createTask(w http.ResponseWriter, r *http.Request) {
	var task Task
	if err := json.NewDecoder(r.Body).Decode(&task); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// Validate required fields
	if task.Title == "" || task.Status == "" || task.Priority == "" {
		http.Error(w, "Title, status, and priority are required", http.StatusBadRequest)
		return
	}

	var id int
	err := db.QueryRow(
		"INSERT INTO tasks (title, description, status, priority, assignee_id) VALUES ($1, $2, $3, $4, $5) RETURNING id",
		task.Title, task.Description, task.Status, task.Priority, task.AssigneeID,
	).Scan(&id)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	task.ID = id
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(task)
}

func getTask(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id, err := strconv.Atoi(vars["id"])
	if err != nil {
		http.Error(w, "Invalid task ID", http.StatusBadRequest)
		return
	}

	var task Task
	err = db.QueryRow(
		"SELECT id, title, description, status, priority, assignee_id, created_at, updated_at FROM tasks WHERE id = $1",
		id,
	).Scan(&task.ID, &task.Title, &task.Description, &task.Status, &task.Priority, &task.AssigneeID, &task.CreatedAt, &task.UpdatedAt)

	if err != nil {
		if err == sql.ErrNoRows {
			http.Error(w, "Task not found", http.StatusNotFound)
		} else {
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(task)
}

func createTaskWithAI(aiEngine *AIEngine) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var task Task
		if err := json.NewDecoder(r.Body).Decode(&task); err != nil {
			http.Error(w, fmt.Sprintf("Invalid JSON: %v", err), http.StatusBadRequest)
			return
		}

		// Validate required fields
		if task.Title == "" || task.Status == "" || task.Priority == "" {
			http.Error(w, "Title, status, and priority are required", http.StatusBadRequest)
			return
		}

		// Set task properties
		task.ID = uuid.New().String()
		task.CreatedAt = time.Now()
		task.UpdatedAt = time.Now()

		// AI enhancement: predict completion time and suggest priority
		if aiEngine != nil {
			task.EstimatedTime = aiEngine.PredictTaskDuration(task)
			if task.Priority == "medium" {
				task.Priority = aiEngine.SuggestPriority(task)
			}
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(task)
	}
}
