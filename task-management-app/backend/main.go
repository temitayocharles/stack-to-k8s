/*
 * ===============================================================
 * PROPRIETARY TASK MANAGEMENT PLATFORM - GO BACKEND
 * ===============================================================
 * 
 * COPYRIGHT (c) 2025 Temitayo Charles Akinniranye
 * All Rights Reserved. Patent Pending.=============================================================
 * PROPRIETARY TASK MANAGEMENT PLATFORM - GO BACKEND
 * ===============================================================
 * 
 * COPYRIGHT (c) 2025 [Your Full Legal Name]. All Rights Reserved.
 * PATENT PENDING - Commercial Use Strictly Prohibited
 * 
 * This Go backend server for task management is protected 
 * intellectual property. Unauthorized commercial use will 
 * result in legal action.
 * 
 * For licensing inquiries: [your-email@domain.com]
 * ===============================================================
 */

package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"sync"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/mux"
	"github.com/gorilla/websocket"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"github.com/rs/cors"
	_ "github.com/lib/pq"
)

// Global variables
var (
	db                *sql.DB
	hub               *Hub
	collaborationEngine *CollaborationEngine
	aiEngine          *AIEngine
	aiHandler         *SimpleAIHandler
	notificationSystem *NotificationSystem
	prioritizationEngine *SimplePrioritizationEngine
	timeTrackingEngine *SimpleTimeTrackingEngine
	analyticsEngine   *SimpleAnalyticsEngine
	upgrader          = websocket.Upgrader{
		CheckOrigin: func(r *http.Request) bool {
			return true // Allow all origins in development
		},
	}
)

// Task represents a task in the system
type Task struct {
	ID          string     `json:"id"`
	Title       string     `json:"title"`
	Description string     `json:"description"`
	Status      string     `json:"status"`
	Priority    string     `json:"priority"`
	AssigneeID  string     `json:"assignee_id"`
	ProjectID   string     `json:"project_id"`
	DueDate     *time.Time `json:"due_date,omitempty"`
	CreatedAt   time.Time  `json:"created_at"`
	UpdatedAt   time.Time  `json:"updated_at"`
	Type        string     `json:"type"`
	Dependencies []string  `json:"dependencies,omitempty"`
	Tags        []string   `json:"tags,omitempty"`
}

// User represents a user in the system
type User struct {
	ID        string    `json:"id"`
	Username  string    `json:"username"`
	Email     string    `json:"email"`
	Role      string    `json:"role"`
	CreatedAt time.Time `json:"created_at"`
}

// Project represents a project in the system
type Project struct {
	ID          string    `json:"id"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	Status      string    `json:"status"`
	OwnerID     string    `json:"owner_id"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
	Type        string    `json:"type"`
}

// Comment represents a comment on a task
type Comment struct {
	ID        string    `json:"id"`
	TaskID    string    `json:"task_id"`
	UserID    string    `json:"user_id"`
	Content   string    `json:"content"`
	CreatedAt time.Time `json:"created_at"`
	Type      string    `json:"type"`
}

// Enhanced WebSocket message structures
type WSMessageType string

const (
	// Task related messages
	WSMsgTaskCreated  WSMessageType = "task_created"
	WSMsgTaskUpdated  WSMessageType = "task_updated"
	WSMsgTaskDeleted  WSMessageType = "task_deleted"
	WSMsgTaskAssigned WSMessageType = "task_assigned"
	
	// Collaboration messages
	WSMsgUserTyping     WSMessageType = "user_typing"
	WSMsgUserPresence   WSMessageType = "user_presence"
	WSMsgCursorPosition WSMessageType = "cursor_position"
	WSMsgDocumentEdit   WSMessageType = "document_edit"
	
	// System messages
	WSMsgUserJoined    WSMessageType = "user_joined"
	WSMsgUserLeft      WSMessageType = "user_left"
	WSMsgRoomJoined    WSMessageType = "room_joined"
	WSMsgRoomLeft      WSMessageType = "room_left"
	WSMsgNotification  WSMessageType = "notification"
	WSMsgHeartbeat     WSMessageType = "heartbeat"
	WSMsgError         WSMessageType = "error"
	WSMsgAcknowledgment WSMessageType = "acknowledgment"
)

type WSMessage struct {
	ID        string        `json:"id"`
	Type      WSMessageType `json:"type"`
	Data      interface{}   `json:"data"`
	UserID    string        `json:"user_id"`
	Username  string        `json:"username"`
	Room      string        `json:"room,omitempty"`
	Timestamp int64         `json:"timestamp"`
	RequiresAck bool         `json:"requires_ack,omitempty"`
}

type TypingIndicator struct {
	UserID   string `json:"user_id"`
	Username string `json:"username"`
	TaskID   string `json:"task_id"`
	IsTyping bool   `json:"is_typing"`
}

// Enhanced WebSocket connection management
type Hub struct {
	clients         map[*websocket.Conn]*Client
	rooms           map[string]map[*Client]bool
	broadcast       chan WSMessage
	register        chan *Client
	unregister      chan *Client
	userPresence    map[string]*UserPresence
	pendingAcks     map[string]WSMessage
	mutex           sync.RWMutex
	presenceMutex   sync.RWMutex
}

type Client struct {
	hub        *Hub
	conn       *websocket.Conn
	send       chan WSMessage
	userID     string
	username   string
	rooms      map[string]bool
	isActive   bool
	lastPing   time.Time
	mutex      sync.RWMutex
}

// Analytics Engine for monitoring
type AnalyticsEngine struct{}

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

	// Initialize database connection
	initDB()

	// Initialize CouchDB connection
	initCouchDB()

	// Initialize AI Intelligence Engine
	aiEngine = NewAIEngine()
	aiHandler = NewSimpleAIHandler()
	log.Println("🧠 AI Intelligence Engine initialized")

	// Initialize Notification System
	notificationSystem = NewNotificationSystem()
	log.Println("📢 Notification System initialized")

	// Initialize Real-time Collaboration Engine
	collaborationEngine = NewCollaborationEngine()
	log.Println("🤝 Real-time Collaboration Engine initialized")

	// Initialize Enhanced AI Prioritization Engine
	prioritizationEngine = NewSimplePrioritizationEngine()
	log.Println("🎯 Enhanced AI Prioritization Engine initialized")

	// Initialize Time Tracking Engine
	timeTrackingEngine = NewSimpleTimeTrackingEngine()
	log.Println("⏱️ Time Tracking Engine initialized")

	// Initialize Project Analytics Engine
	analyticsEngine = NewSimpleAnalyticsEngine()
	log.Println("📊 Project Analytics Engine initialized")

	// Initialize Enhanced WebSocket hub for real-time collaboration
	hub = &Hub{
		clients:      make(map[*websocket.Conn]*Client),
		rooms:        make(map[string]map[*Client]bool),
		broadcast:    make(chan WSMessage, 256),
		register:     make(chan *Client, 256),
		unregister:   make(chan *Client, 256),
		userPresence: make(map[string]*UserPresence),
		pendingAcks:  make(map[string]WSMessage),
	}
	go hub.run()
	log.Println("🔗 Enhanced WebSocket Hub initialized")

	// Initialize Comprehensive Health Check Service
	initHealthCheckService(db, hub)
	log.Println("🏥 Comprehensive Health Check Service initialized")

	// Create router
	r := mux.NewRouter()

	// API routes
	api := r.PathPrefix("/api/v1").Subrouter()

	// Task routes
	api.HandleFunc("/tasks", getTasks).Methods("GET")
	api.HandleFunc("/tasks", createTask).Methods("POST")
	api.HandleFunc("/tasks/{id}", getTask).Methods("GET")
	api.HandleFunc("/tasks/{id}", updateTask).Methods("PUT")
	api.HandleFunc("/tasks/{id}", deleteTask).Methods("DELETE")

	// User routes
	api.HandleFunc("/users", getUsers).Methods("GET")
	api.HandleFunc("/users", createUser).Methods("POST")
	api.HandleFunc("/users/{id}", getUser).Methods("GET")

	// Project routes
	api.HandleFunc("/projects", getProjects).Methods("GET")
	api.HandleFunc("/projects", createProject).Methods("POST")
	api.HandleFunc("/projects/{id}", getProject).Methods("GET")
	api.HandleFunc("/projects/{id}", updateProject).Methods("PUT")

	// Comment routes
	api.HandleFunc("/tasks/{id}/comments", getTaskComments).Methods("GET")
	api.HandleFunc("/tasks/{id}/comments", createComment).Methods("POST")

	// AI-powered routes
	api.HandleFunc("/ai/tasks", aiHandler.CreateTaskWithBasicAI()).Methods("POST")
	api.HandleFunc("/ai/tasks/{id}/suggestions", aiHandler.GetTaskSuggestions()).Methods("GET")
	api.HandleFunc("/ai/users/{id}/tips", aiHandler.GetProductivityTips()).Methods("GET")

	// Enhanced AI Prioritization routes
	api.HandleFunc("/ai/prioritize", prioritizeTasksHandler).Methods("POST")
	api.HandleFunc("/ai/prioritize/user/{userID}", prioritizeUserTasksHandler).Methods("GET")
	api.HandleFunc("/ai/prioritize/context", getPrioritizationContextHandler).Methods("GET")

	// Time Tracking routes
	api.HandleFunc("/time/start", startTimeTrackingHandler).Methods("POST")
	api.HandleFunc("/time/stop", stopTimeTrackingHandler).Methods("POST")
	api.HandleFunc("/time/entries", getTimeEntriesHandler).Methods("GET")
	api.HandleFunc("/time/entries/{userID}", getUserTimeEntriesHandler).Methods("GET")
	api.HandleFunc("/time/analytics", getTimeAnalyticsHandler).Methods("GET")
	api.HandleFunc("/time/productivity/{userID}", getProductivityAnalysisHandler).Methods("GET")
	api.HandleFunc("/time/detect/{userID}", detectActivityHandler).Methods("POST")

	// Project Analytics routes
	api.HandleFunc("/analytics/project/{projectID}", getProjectAnalyticsHandler).Methods("GET")
	api.HandleFunc("/analytics/dashboard/{userID}", getAnalyticsDashboardHandler).Methods("GET")
	api.HandleFunc("/analytics/metrics", getProjectMetricsHandler).Methods("GET")
	api.HandleFunc("/analytics/reports", generateAnalyticsReportHandler).Methods("POST")
	api.HandleFunc("/analytics/realtime/{projectID}", getRealtimeMetricsHandler).Methods("GET")

	// Notification routes
	api.HandleFunc("/notifications", sendNotification).Methods("POST")

	// Dashboard
	api.HandleFunc("/dashboard/stats", getDashboardStats).Methods("GET")

	// WebSocket endpoints
	api.HandleFunc("/ws", handleWebSocket).Methods("GET")

	// Register comprehensive health check routes
	registerHealthCheckRoutes(api)

	// Prometheus metrics
	api.Handle("/metrics", promhttp.Handler())

	// CORS middleware
	c := cors.New(cors.Options{
		AllowedOrigins:   []string{"http://localhost:3000", "http://localhost:5173"},
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
	log.Printf("📊 Dashboard available at http://localhost:%s/api/v1/dashboard/stats", port)
	log.Printf("🔗 WebSocket: ws://localhost:%s/api/v1/ws", port)
	log.Fatal(http.ListenAndServe(":"+port, handler))
}

func initConfig() {
	// Initialize CouchDB config
	couchConfig = CouchDBConfig{
		Host:     getEnv("COUCHDB_HOST", "localhost"),
		Port:     getEnv("COUCHDB_PORT", "5984"),
		Username: getEnv("COUCHDB_USER", "admin"),
		Password: getEnv("COUCHDB_PASS", "password"),
		Database: getEnv("COUCHDB_DB", "taskmanagement"),
	}
}

func initCouchDB() {
	log.Println("✅ CouchDB configuration initialized")
}

func initDB() {
	databaseURL := os.Getenv("DATABASE_URL")
	if databaseURL == "" {
		// Use environment variables for container compatibility
		dbHost := os.Getenv("DB_HOST")
		if dbHost == "" {
			dbHost = "localhost"
		}
		dbPort := os.Getenv("DB_PORT")
		if dbPort == "" {
			dbPort = "5432"
		}
		dbUser := os.Getenv("DB_USER")
		if dbUser == "" {
			dbUser = "taskuser"
		}
		dbPassword := os.Getenv("DB_PASSWORD")
		if dbPassword == "" {
			dbPassword = "taskpass"
		}
		dbName := os.Getenv("DB_NAME")
		if dbName == "" {
			dbName = "taskmanagement"
		}
		databaseURL = fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable", dbUser, dbPassword, dbHost, dbPort, dbName)
	}

	var err error
	db, err = sql.Open("postgres", databaseURL)
	if err != nil {
		log.Printf("⚠️  Warning: Failed to connect to database: %v", err)
		log.Println("📝 Database functionality will be limited. Some endpoints may not work.")
		return
	}

	if err = db.Ping(); err != nil {
		log.Printf("⚠️  Warning: Failed to ping database: %v", err)
		log.Println("📝 Database functionality will be limited. Some endpoints may not work.")
		return
	}

	log.Println("✅ Connected to PostgreSQL database")
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
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

	task.ID = uuid.New().String()
	task.CreatedAt = time.Now()
	task.UpdatedAt = time.Now()

	_, err := db.Exec(
		"INSERT INTO tasks (id, title, description, status, priority, assignee_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)",
		task.ID, task.Title, task.Description, task.Status, task.Priority, task.AssigneeID, task.CreatedAt, task.UpdatedAt,
	)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// Send WebSocket notification for task creation
	wsMessage := WSMessage{
		ID:        generateID(),
		Type:      WSMsgTaskCreated,
		Data:      task,
		UserID:    "system", // Could be extracted from auth context
		Username:  "System",
		Room:      "general", // Could be project-specific
		Timestamp: time.Now().Unix(),
	}
	
	select {
	case hub.broadcast <- wsMessage:
	default:
		// Channel full, notification not sent
		log.Printf("WebSocket channel full, task creation notification not sent")
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(task)
}

func getTask(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	var task Task
	err := db.QueryRow(
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

func updateTask(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	var task Task
	if err := json.NewDecoder(r.Body).Decode(&task); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	task.UpdatedAt = time.Now()

	_, err := db.Exec(
		"UPDATE tasks SET title = $1, description = $2, status = $3, priority = $4, assignee_id = $5, updated_at = $6 WHERE id = $7",
		task.Title, task.Description, task.Status, task.Priority, task.AssigneeID, task.UpdatedAt, id,
	)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	task.ID = id

	// Send WebSocket notification for task update
	wsMessage := WSMessage{
		ID:        generateID(),
		Type:      WSMsgTaskUpdated,
		Data:      task,
		UserID:    "system", // Could be extracted from auth context
		Username:  "System",
		Room:      "general", // Could be project-specific
		Timestamp: time.Now().Unix(),
	}
	
	select {
	case hub.broadcast <- wsMessage:
	default:
		log.Printf("WebSocket channel full, task update notification not sent")
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(task)
}

func deleteTask(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	_, err := db.Exec("DELETE FROM tasks WHERE id = $1", id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// Send WebSocket notification for task deletion
	wsMessage := WSMessage{
		ID:        generateID(),
		Type:      WSMsgTaskDeleted,
		Data:      map[string]string{"id": id},
		UserID:    "system", // Could be extracted from auth context
		Username:  "System",
		Room:      "general", // Could be project-specific
		Timestamp: time.Now().Unix(),
	}
	
	select {
	case hub.broadcast <- wsMessage:
	default:
		log.Printf("WebSocket channel full, task deletion notification not sent")
	}

	w.WriteHeader(http.StatusNoContent)
}

// User handlers
func getUsers(w http.ResponseWriter, r *http.Request) {
	rows, err := db.Query("SELECT id, username, email, role, created_at FROM users ORDER BY username")
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var users []User
	for rows.Next() {
		var user User
		err := rows.Scan(&user.ID, &user.Username, &user.Email, &user.Role, &user.CreatedAt)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		users = append(users, user)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(users)
}

func createUser(w http.ResponseWriter, r *http.Request) {
	var user User
	if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	user.ID = uuid.New().String()
	user.CreatedAt = time.Now()

	_, err := db.Exec(
		"INSERT INTO users (id, username, email, role, created_at) VALUES ($1, $2, $3, $4, $5)",
		user.ID, user.Username, user.Email, user.Role, user.CreatedAt,
	)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(user)
}

func getUser(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	var user User
	err := db.QueryRow(
		"SELECT id, username, email, role, created_at FROM users WHERE id = $1",
		id,
	).Scan(&user.ID, &user.Username, &user.Email, &user.Role, &user.CreatedAt)

	if err != nil {
		if err == sql.ErrNoRows {
			http.Error(w, "User not found", http.StatusNotFound)
		} else {
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(user)
}

// Project handlers
func getProjects(w http.ResponseWriter, r *http.Request) {
	rows, err := db.Query("SELECT id, name, description, status, owner_id, created_at, updated_at FROM projects ORDER BY created_at DESC")
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var projects []Project
	for rows.Next() {
		var project Project
		err := rows.Scan(&project.ID, &project.Name, &project.Description, &project.Status, &project.OwnerID, &project.CreatedAt, &project.UpdatedAt)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		projects = append(projects, project)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(projects)
}

func createProject(w http.ResponseWriter, r *http.Request) {
	var project Project
	if err := json.NewDecoder(r.Body).Decode(&project); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	project.ID = uuid.New().String()
	project.CreatedAt = time.Now()
	project.UpdatedAt = time.Now()

	_, err := db.Exec(
		"INSERT INTO projects (id, name, description, status, owner_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7)",
		project.ID, project.Name, project.Description, project.Status, project.OwnerID, project.CreatedAt, project.UpdatedAt,
	)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(project)
}

func getProject(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	var project Project
	err := db.QueryRow(
		"SELECT id, name, description, status, owner_id, created_at, updated_at FROM projects WHERE id = $1",
		id,
	).Scan(&project.ID, &project.Name, &project.Description, &project.Status, &project.OwnerID, &project.CreatedAt, &project.UpdatedAt)

	if err != nil {
		if err == sql.ErrNoRows {
			http.Error(w, "Project not found", http.StatusNotFound)
		} else {
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(project)
}

func updateProject(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	var project Project
	if err := json.NewDecoder(r.Body).Decode(&project); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	project.UpdatedAt = time.Now()

	_, err := db.Exec(
		"UPDATE projects SET name = $1, description = $2, status = $3, owner_id = $4, updated_at = $5 WHERE id = $6",
		project.Name, project.Description, project.Status, project.OwnerID, project.UpdatedAt, id,
	)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	project.ID = id
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(project)
}

// Comment handlers
func getTaskComments(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	taskID := vars["id"]

	rows, err := db.Query("SELECT id, task_id, user_id, content, created_at FROM comments WHERE task_id = $1 ORDER BY created_at DESC", taskID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var comments []Comment
	for rows.Next() {
		var comment Comment
		err := rows.Scan(&comment.ID, &comment.TaskID, &comment.UserID, &comment.Content, &comment.CreatedAt)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		comments = append(comments, comment)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(comments)
}

func createComment(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	taskID := vars["id"]

	var comment Comment
	if err := json.NewDecoder(r.Body).Decode(&comment); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	comment.ID = uuid.New().String()
	comment.TaskID = taskID
	comment.CreatedAt = time.Now()

	_, err := db.Exec(
		"INSERT INTO comments (id, task_id, user_id, content, created_at) VALUES ($1, $2, $3, $4, $5)",
		comment.ID, comment.TaskID, comment.UserID, comment.Content, comment.CreatedAt,
	)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(comment)
}

// Dashboard
func getDashboardStats(w http.ResponseWriter, r *http.Request) {
	var totalTasks, completedTasks, activeUsers, totalProjects int

	// Get task counts
	err := db.QueryRow("SELECT COUNT(*) FROM tasks").Scan(&totalTasks)
	if err != nil {
		log.Printf("Error getting total tasks: %v", err)
	}

	err = db.QueryRow("SELECT COUNT(*) FROM tasks WHERE status = 'completed'").Scan(&completedTasks)
	if err != nil {
		log.Printf("Error getting completed tasks: %v", err)
	}

	// Get user count
	err = db.QueryRow("SELECT COUNT(*) FROM users").Scan(&activeUsers)
	if err != nil {
		log.Printf("Error getting active users: %v", err)
	}

	// Get project count
	err = db.QueryRow("SELECT COUNT(*) FROM projects").Scan(&totalProjects)
	if err != nil {
		log.Printf("Error getting total projects: %v", err)
	}

	stats := map[string]interface{}{
		"total_tasks":     totalTasks,
		"completed_tasks": completedTasks,
		"active_users":    activeUsers,
		"total_projects":  totalProjects,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(stats)
}

// Enhanced WebSocket handler with authentication and structured messaging
func handleWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("WebSocket upgrade failed: %v", err)
		return
	}

	// Extract user info from query parameters or headers
	userID := r.URL.Query().Get("user_id")
	username := r.URL.Query().Get("username")
	
	// Use defaults if not provided
	if userID == "" {
		userID = "anonymous_" + generateID()
	}
	if username == "" {
		username = "Anonymous User"
	}

	// Create client
	client := &Client{
		hub:      hub,
		conn:     conn,
		send:     make(chan WSMessage, 256),
		userID:   userID,
		username: username,
		rooms:    make(map[string]bool),
		isActive: true,
		lastPing: time.Now(),
	}

	// Register client
	hub.register <- client

	// Join general room by default
	hub.addToRoom(client, "general")

	// Start goroutines for reading and writing
	go client.writePump()
	go client.readPump()
}

// Client read pump - handles incoming messages
func (c *Client) readPump() {
	defer func() {
		c.hub.unregister <- c
		c.conn.Close()
	}()

	// Set read deadline and pong handler
	c.conn.SetReadDeadline(time.Now().Add(60 * time.Second))
	c.conn.SetPongHandler(func(string) error {
		c.conn.SetReadDeadline(time.Now().Add(60 * time.Second))
		c.lastPing = time.Now()
		return nil
	})

	for {
		_, messageBytes, err := c.conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("WebSocket error: %v", err)
			}
			break
		}

		// Parse incoming message
		var incomingMsg WSMessage
		if err := json.Unmarshal(messageBytes, &incomingMsg); err != nil {
			log.Printf("Error parsing WebSocket message: %v", err)
			// Send error response
			errorMsg := WSMessage{
				ID:        generateID(),
				Type:      WSMsgError,
				Data:      map[string]string{"error": "Invalid message format"},
				Timestamp: time.Now().Unix(),
			}
			select {
			case c.send <- errorMsg:
			default:
				close(c.send)
				return
			}
			continue
		}

		// Set user info and timestamp
		incomingMsg.UserID = c.userID
		incomingMsg.Username = c.username
		incomingMsg.Timestamp = time.Now().Unix()

		// Handle different message types
		c.handleMessage(incomingMsg)
	}
}

// Client write pump - handles outgoing messages
func (c *Client) writePump() {
	ticker := time.NewTicker(54 * time.Second)
	defer func() {
		ticker.Stop()
		c.conn.Close()
	}()

	for {
		select {
		case message, ok := <-c.send:
			c.conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
			if !ok {
				c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			messageBytes, err := json.Marshal(message)
			if err != nil {
				log.Printf("Error marshaling message: %v", err)
				continue
			}

			if err := c.conn.WriteMessage(websocket.TextMessage, messageBytes); err != nil {
				log.Printf("WebSocket write error: %v", err)
				return
			}

		case <-ticker.C:
			c.conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
			if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}

// Handle different types of WebSocket messages
func (c *Client) handleMessage(message WSMessage) {
	switch message.Type {
	case WSMsgUserTyping:
		// Handle typing indicator
		c.handleTypingIndicator(message)
	case WSMsgCursorPosition:
		// Handle cursor position update
		c.handleCursorPosition(message)
	case WSMsgRoomJoined:
		// Handle room join request
		c.handleRoomJoin(message)
	case WSMsgRoomLeft:
		// Handle room leave request
		c.handleRoomLeave(message)
	case WSMsgUserPresence:
		// Handle presence update
		c.handlePresenceUpdate(message)
	default:
		// Default: broadcast to all in same rooms
		c.hub.broadcast <- message
	}
}

// Handle typing indicator
func (c *Client) handleTypingIndicator(message WSMessage) {
	// Broadcast typing indicator to room members
	if message.Room != "" {
		c.hub.broadcastToRoom(message.Room, message)
	} else {
		c.hub.broadcastToRoom("general", message)
	}
}

// Handle cursor position update
func (c *Client) handleCursorPosition(message WSMessage) {
	// Broadcast cursor position to room members
	if message.Room != "" {
		c.hub.broadcastToRoom(message.Room, message)
	} else {
		c.hub.broadcastToRoom("general", message)
	}
}

// Handle room join request
func (c *Client) handleRoomJoin(message WSMessage) {
	if roomData, ok := message.Data.(map[string]interface{}); ok {
		if roomID, exists := roomData["room_id"].(string); exists {
			c.hub.addToRoom(c, roomID)
			
			// Send confirmation
			confirmMsg := WSMessage{
				ID:        generateID(),
				Type:      WSMsgRoomJoined,
				Data:      map[string]string{"room_id": roomID, "status": "joined"},
				UserID:    c.userID,
				Username:  c.username,
				Room:      roomID,
				Timestamp: time.Now().Unix(),
			}
			
			select {
			case c.send <- confirmMsg:
			default:
			}
		}
	}
}

// Handle room leave request
func (c *Client) handleRoomLeave(message WSMessage) {
	if roomData, ok := message.Data.(map[string]interface{}); ok {
		if roomID, exists := roomData["room_id"].(string); exists {
			c.hub.removeFromRoom(c, roomID)
			
			// Send confirmation
			confirmMsg := WSMessage{
				ID:        generateID(),
				Type:      WSMsgRoomLeft,
				Data:      map[string]string{"room_id": roomID, "status": "left"},
				UserID:    c.userID,
				Username:  c.username,
				Timestamp: time.Now().Unix(),
			}
			
			select {
			case c.send <- confirmMsg:
			default:
			}
		}
	}
}

// Handle presence update
func (c *Client) handlePresenceUpdate(message WSMessage) {
	c.hub.presenceMutex.Lock()
	if presence, exists := c.hub.userPresence[c.userID]; exists {
		if presenceData, ok := message.Data.(map[string]interface{}); ok {
			if status, ok := presenceData["status"].(string); ok {
				presence.Status = PresenceStatus(status)
			}
			if activity, ok := presenceData["activity"].(string); ok {
				presence.Activity = activity
			}
			presence.LastSeen = time.Now()
		}
	}
	c.hub.presenceMutex.Unlock()
	
	// Broadcast presence update
	c.hub.broadcastToRoom("general", message)
}

// Enhanced Hub run method with room and presence management
func (h *Hub) run() {
	ticker := time.NewTicker(30 * time.Second) // Heartbeat ticker
	defer ticker.Stop()

	for {
		select {
		case client := <-h.register:
			h.mutex.Lock()
			h.clients[client.conn] = client
			h.mutex.Unlock()
			
			// Update user presence with simplified structure
			h.presenceMutex.Lock()
			h.userPresence[client.userID] = &UserPresence{
				Status:   PresenceOnline,
				Activity: "Connected",
				LastSeen: time.Now(),
			}
			h.presenceMutex.Unlock()
			
			log.Printf("Client connected: %s (%s). Total clients: %d", client.username, client.userID, len(h.clients))
			
			// Notify others of user joining
			h.broadcastToRoom("general", WSMessage{
				ID:        generateID(),
				Type:      WSMsgUserJoined,
				Data:      h.userPresence[client.userID],
				UserID:    client.userID,
				Username:  client.username,
				Timestamp: time.Now().Unix(),
			})

		case client := <-h.unregister:
			h.mutex.Lock()
			if existingClient, ok := h.clients[client.conn]; ok {
				delete(h.clients, client.conn)
				close(existingClient.send)
				
				// Remove from all rooms
				for room := range existingClient.rooms {
					h.removeFromRoom(existingClient, room)
				}
			}
			h.mutex.Unlock()
			
			// Update user presence to offline
			h.presenceMutex.Lock()
			if presence, ok := h.userPresence[client.userID]; ok {
				presence.Status = PresenceOffline
				presence.LastSeen = time.Now()
			}
			h.presenceMutex.Unlock()
			
			log.Printf("Client disconnected: %s (%s). Total clients: %d", client.username, client.userID, len(h.clients))
			
			// Notify others of user leaving
			h.broadcastToRoom("general", WSMessage{
				ID:        generateID(),
				Type:      WSMsgUserLeft,
				Data:      map[string]string{"user_id": client.userID, "username": client.username},
				UserID:    client.userID,
				Username:  client.username,
				Timestamp: time.Now().Unix(),
			})

		case message := <-h.broadcast:
			if message.Room != "" {
				h.broadcastToRoom(message.Room, message)
			} else {
				h.broadcastToAll(message)
			}

		case <-ticker.C:
			// Send heartbeat to all connected clients
			heartbeat := WSMessage{
				ID:        generateID(),
				Type:      WSMsgHeartbeat,
				Data:      map[string]interface{}{"timestamp": time.Now().Unix()},
				Timestamp: time.Now().Unix(),
			}
			h.broadcastToAll(heartbeat)
		}
	}
}

// Broadcast message to all clients
func (h *Hub) broadcastToAll(message WSMessage) {
	h.mutex.RLock()
	defer h.mutex.RUnlock()

	for conn, client := range h.clients {
		select {
		case client.send <- message:
		default:
			close(client.send)
			delete(h.clients, conn)
		}
	}
}

// Broadcast message to specific room
func (h *Hub) broadcastToRoom(roomID string, message WSMessage) {
	h.mutex.RLock()
	defer h.mutex.RUnlock()
	
	if room, exists := h.rooms[roomID]; exists {
		for client := range room {
			select {
			case client.send <- message:
			default:
				close(client.send)
				delete(h.clients, client.conn)
				delete(room, client)
			}
		}
	}
}

// Add client to room
func (h *Hub) addToRoom(client *Client, roomID string) {
	h.mutex.Lock()
	defer h.mutex.Unlock()
	
	if h.rooms[roomID] == nil {
		h.rooms[roomID] = make(map[*Client]bool)
	}
	
	h.rooms[roomID][client] = true
	client.mutex.Lock()
	client.rooms[roomID] = true
	client.mutex.Unlock()
	
	log.Printf("Client %s joined room %s", client.username, roomID)
}

// Remove client from room
func (h *Hub) removeFromRoom(client *Client, roomID string) {
	if room, exists := h.rooms[roomID]; exists {
		delete(room, client)
		if len(room) == 0 {
			delete(h.rooms, roomID)
		}
	}
	
	client.mutex.Lock()
	delete(client.rooms, roomID)
	client.mutex.Unlock()
	
	log.Printf("Client %s left room %s", client.username, roomID)
}

// Notification system
type NotificationSystem struct {
	slackWebhookURL string
	emailServer     string
	mutex           sync.RWMutex
}

// Notification represents a notification
type Notification struct {
	ID        string    `json:"id"`
	Type      string    `json:"type"`
	Title     string    `json:"title"`
	Message   string    `json:"message"`
	Priority  string    `json:"priority"`
	Recipient string    `json:"recipient"`
	CreatedAt time.Time `json:"created_at"`
}

// NewNotificationSystem creates a new notification system
func NewNotificationSystem() *NotificationSystem {
	return &NotificationSystem{}
}

// SendNotification sends a notification
func (ns *NotificationSystem) SendNotification(notification Notification) error {
	log.Printf("📢 Sending %s notification: %s", notification.Type, notification.Title)

	// For now, just log the notification
	// In production, this would integrate with actual notification services
	switch notification.Type {
	case "slack":
		return ns.sendSlackNotification(notification)
	case "email":
		return ns.sendEmailNotification(notification)
	case "webhook":
		return ns.sendWebhookNotification(notification)
	default:
		log.Printf("Unknown notification type: %s", notification.Type)
		return nil
	}
}

// sendSlackNotification sends a notification to Slack
func (ns *NotificationSystem) sendSlackNotification(notification Notification) error {
	if ns.slackWebhookURL == "" {
		log.Printf("Slack webhook not configured, skipping notification")
		return nil
	}

	// This would implement actual Slack webhook call
	log.Printf("Would send Slack notification: %s", notification.Message)
	return nil
}

// sendEmailNotification sends an email notification
func (ns *NotificationSystem) sendEmailNotification(notification Notification) error {
	if ns.emailServer == "" {
		log.Printf("Email server not configured, skipping notification")
		return nil
	}

	// This would implement actual email sending
	log.Printf("Would send email notification to %s: %s", notification.Recipient, notification.Message)
	return nil
}

// sendWebhookNotification sends a webhook notification
func (ns *NotificationSystem) sendWebhookNotification(notification Notification) error {
	// This would implement actual webhook call
	log.Printf("Would send webhook notification: %s", notification.Message)
	return nil
}

func healthCheck(w http.ResponseWriter, r *http.Request) {
	// This function is deprecated - using comprehensive health check system instead
	// Redirect to the new comprehensive health check
	http.Redirect(w, r, "/api/v1/health", http.StatusMovedPermanently)
}

// Notification handler
func sendNotification(w http.ResponseWriter, r *http.Request) {
	var notification Notification
	if err := json.NewDecoder(r.Body).Decode(&notification); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	notification.ID = uuid.New().String()
	notification.CreatedAt = time.Now()

	if err := notificationSystem.SendNotification(notification); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]interface{}{
		"message": "Notification sent successfully",
		"id":      notification.ID,
	})
}

// ========================================
// ENHANCED AI PRIORITIZATION HANDLERS
// ========================================

// prioritizeTasksHandler - Prioritize a list of tasks using AI
func prioritizeTasksHandler(w http.ResponseWriter, r *http.Request) {
	var request struct {
		Tasks  []*Task      `json:"tasks"`
		UserID string       `json:"user_id"`
		Context *SimpleTaskContext `json:"context,omitempty"`
	}

	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// Use default context if none provided
	if request.Context == nil {
		request.Context = &SimpleTaskContext{
			TemporalContext: &SimpleTemporalContext{
				CurrentTime: time.Now(),
				TimeOfDay:   getCurrentTimeOfDay(),
			},
		}
	}

	prioritizedTasks, err := prioritizationEngine.PrioritizeTasks(request.Tasks, request.UserID, request.Context)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"prioritized_tasks": prioritizedTasks,
		"total_tasks":      len(prioritizedTasks),
		"timestamp":        time.Now(),
	})
}

// prioritizeUserTasksHandler - Get prioritized tasks for a specific user
func prioritizeUserTasksHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userID := vars["userID"]

	// Get user's tasks from database
	tasks, err := getUserTasks(userID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// Create default context
	context := &SimpleTaskContext{
		TemporalContext: &SimpleTemporalContext{
			CurrentTime: time.Now(),
			TimeOfDay:   getCurrentTimeOfDay(),
		},
	}

	prioritizedTasks, err := prioritizationEngine.PrioritizeTasks(tasks, userID, context)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"user_id":          userID,
		"prioritized_tasks": prioritizedTasks,
		"total_tasks":      len(prioritizedTasks),
		"timestamp":        time.Now(),
	})
}

// getPrioritizationContextHandler - Get current prioritization context
func getPrioritizationContextHandler(w http.ResponseWriter, r *http.Request) {
	userID := r.URL.Query().Get("user_id")
	
	// Build comprehensive context
	context := &SimpleTaskContext{
		TemporalContext: &SimpleTemporalContext{
			CurrentTime: time.Now(),
			TimeOfDay:   getCurrentTimeOfDay(),
		},
		UserContext: &SimpleUserContext{
			CurrentWorkload: 0.7, // Default
			EnergyLevel:     0.8, // Default
			StressLevel:     0.3, // Default
		},
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"context":    context,
		"user_id":    userID,
		"timestamp":  time.Now(),
	})
}

// ========================================
// TIME TRACKING HANDLERS
// ========================================

// startTimeTrackingHandler - Start time tracking for a task
func startTimeTrackingHandler(w http.ResponseWriter, r *http.Request) {
	var request struct {
		UserID      string `json:"user_id"`
		TaskID      string `json:"task_id"`
		ActivityType string `json:"activity_type"`
		Description string `json:"description,omitempty"`
	}

	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	entry, err := timeTrackingEngine.StartTimeEntry(request.UserID, request.TaskID, request.ActivityType, request.Description)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"message":    "Time tracking started",
		"entry":      entry,
		"timestamp":  time.Now(),
	})
}

// stopTimeTrackingHandler - Stop time tracking
func stopTimeTrackingHandler(w http.ResponseWriter, r *http.Request) {
	var request struct {
		UserID  string `json:"user_id"`
		EntryID string `json:"entry_id"`
		Notes   string `json:"notes,omitempty"`
	}

	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	entry, err := timeTrackingEngine.StopTimeEntry(request.UserID, request.EntryID, request.Notes)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"message":    "Time tracking stopped",
		"entry":      entry,
		"duration":   entry.Duration,
		"timestamp":  time.Now(),
	})
}

// getTimeEntriesHandler - Get time entries
func getTimeEntriesHandler(w http.ResponseWriter, r *http.Request) {
	userID := r.URL.Query().Get("user_id")
	taskID := r.URL.Query().Get("task_id")
	
	entries, err := timeTrackingEngine.GetTimeEntries(userID, taskID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"entries":     entries,
		"total_count": len(entries),
		"timestamp":   time.Now(),
	})
}

// getUserTimeEntriesHandler - Get time entries for a specific user
func getUserTimeEntriesHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userID := vars["userID"]

	entries, err := timeTrackingEngine.GetTimeEntries(userID, "")
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"user_id":     userID,
		"entries":     entries,
		"total_count": len(entries),
		"timestamp":   time.Now(),
	})
}

// getTimeAnalyticsHandler - Get time analytics
func getTimeAnalyticsHandler(w http.ResponseWriter, r *http.Request) {
	userID := r.URL.Query().Get("user_id")
	period := r.URL.Query().Get("period") // "day", "week", "month"
	
	if period == "" {
		period = "week"
	}

	analytics, err := timeTrackingEngine.GetTimeAnalytics(userID, period)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"analytics":  analytics,
		"period":     period,
		"user_id":    userID,
		"timestamp":  time.Now(),
	})
}

// getProductivityAnalysisHandler - Get productivity analysis for a user
func getProductivityAnalysisHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userID := vars["userID"]

	analysis, err := timeTrackingEngine.GetProductivityAnalysis(userID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"user_id":     userID,
		"analysis":    analysis,
		"timestamp":   time.Now(),
	})
}

// detectActivityHandler - Detect current activity for a user
func detectActivityHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userID := vars["userID"]

	var request struct {
		Context map[string]interface{} `json:"context"`
	}

	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	activity, err := timeTrackingEngine.DetectActivity(userID, request.Context)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"user_id":    userID,
		"activity":   activity,
		"timestamp":  time.Now(),
	})
}

// ========================================
// PROJECT ANALYTICS HANDLERS
// ========================================

// getProjectAnalyticsHandler - Get analytics for a specific project
func getProjectAnalyticsHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	projectID := vars["projectID"]

	metrics, err := analyticsEngine.GetProjectMetrics(projectID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"project_id": projectID,
		"metrics":    metrics,
		"timestamp":  time.Now(),
	})
}

// getAnalyticsDashboardHandler - Get analytics dashboard for a user
func getAnalyticsDashboardHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userID := vars["userID"]

	dashboard, err := analyticsEngine.GetDashboard(userID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"user_id":    userID,
		"dashboard":  dashboard,
		"timestamp":  time.Now(),
	})
}

// getProjectMetricsHandler - Get comprehensive project metrics
func getProjectMetricsHandler(w http.ResponseWriter, r *http.Request) {
	projectID := r.URL.Query().Get("project_id")
	userID := r.URL.Query().Get("user_id")

	var metrics interface{}
	var err error

	if projectID != "" {
		metrics, err = analyticsEngine.GetProjectMetrics(projectID)
	} else if userID != "" {
		metrics, err = analyticsEngine.GetDashboard(userID)
	} else {
		// Get overall metrics
		metrics = map[string]interface{}{
			"message": "Please specify project_id or user_id parameter",
		}
	}

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"metrics":    metrics,
		"project_id": projectID,
		"user_id":    userID,
		"timestamp":  time.Now(),
	})
}

// generateAnalyticsReportHandler - Generate comprehensive analytics report
func generateAnalyticsReportHandler(w http.ResponseWriter, r *http.Request) {
	var request struct {
		ProjectID   string `json:"project_id"`
		UserID      string `json:"user_id"`
		ReportType  string `json:"report_type"`  // "summary", "detailed", "executive"
		Period      string `json:"period"`       // "week", "month", "quarter"
		Format      string `json:"format"`       // "json", "pdf", "csv"
	}

	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	report, err := analyticsEngine.GenerateReport(request.ProjectID, request.UserID, request.ReportType, request.Period)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"report":      report,
		"report_type": request.ReportType,
		"period":      request.Period,
		"format":      request.Format,
		"generated_at": time.Now(),
	})
}

// getRealtimeMetricsHandler - Get real-time metrics for a project
func getRealtimeMetricsHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	projectID := vars["projectID"]

	metrics, err := analyticsEngine.GetRealtimeMetrics(projectID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"project_id":       projectID,
		"realtime_metrics": metrics,
		"timestamp":        time.Now(),
		"refresh_interval": "30s",
	})
}

// ========================================
// HELPER FUNCTIONS
// ========================================

// getUserTasks - Helper function to get tasks for a user (placeholder implementation)
func getUserTasks(userID string) ([]*Task, error) {
	// This would typically query the database
	// For now, return empty slice
	return []*Task{}, nil
}

// getCurrentTimeOfDay - Helper function to get current time of day
func getCurrentTimeOfDay() string {
	hour := time.Now().Hour()
	if hour < 12 {
		return "morning"
	} else if hour < 18 {
		return "afternoon"
	} else {
		return "evening"
	}
}
