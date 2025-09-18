package main

import (
	"database/sql"
	"encoding/json"
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

// WebSocket connection management
type Hub struct {
	clients    map[*websocket.Conn]bool
	broadcast  chan []byte
	register   chan *websocket.Conn
	unregister chan *websocket.Conn
	mutex      sync.RWMutex
}

type Client struct {
	hub      *Hub
	conn     *websocket.Conn
	send     chan []byte
	userID   string
	username string
	rooms    map[string]bool
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

	// Initialize Comprehensive Health Check Service
	initHealthCheckService(db, hub)
	log.Println("🏥 Comprehensive Health Check Service initialized")

	// Initialize WebSocket hub for basic real-time features
	hub = &Hub{
		clients:    make(chan *websocket.Conn, 256),
		broadcast:  make(chan []byte, 256),
		register:   make(chan *websocket.Conn, 256),
		unregister: make(chan *websocket.Conn, 256),
	}
	go hub.run()

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
		databaseURL = "postgres://taskuser:taskpass@localhost:5432/taskmanagement?sslmode=disable"
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

// WebSocket handler
func handleWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("WebSocket upgrade failed: %v", err)
		return
	}
	defer conn.Close()

	// Register client
	hub.register <- conn

	// Handle messages
	for {
		_, message, err := conn.ReadMessage()
		if err != nil {
			log.Printf("WebSocket read error: %v", err)
			hub.unregister <- conn
			break
		}

		// Broadcast message to all clients
		select {
		case hub.broadcast <- message:
		default:
			// Channel is full, skip this message
		}

		log.Printf("Received message: %s", message)
	}
}

// Hub run method
func (h *Hub) run() {
	for {
		select {
		case conn := <-h.register:
			h.mutex.Lock()
			h.clients[conn] = true
			h.mutex.Unlock()
			log.Printf("Client connected. Total clients: %d", len(h.clients))

		case conn := <-h.unregister:
			h.mutex.Lock()
			if _, ok := h.clients[conn]; ok {
				delete(h.clients, conn)
				conn.Close()
			}
			h.mutex.Unlock()
			log.Printf("Client disconnected. Total clients: %d", len(h.clients))

		case message := <-h.broadcast:
			h.mutex.RLock()
			for conn := range h.clients {
				select {
				case <-time.After(time.Millisecond * 100):
					// Timeout to prevent blocking
				default:
					if err := conn.WriteMessage(websocket.TextMessage, message); err != nil {
						log.Printf("WebSocket write error: %v", err)
						conn.Close()
						delete(h.clients, conn)
					}
				}
			}
			h.mutex.RUnlock()
		}
	}
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
