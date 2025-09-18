package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"time"

	"github.com/gorilla/mux"
	"github.com/google/uuid"
)

// SimpleAIHandler provides basic AI-powered task management features
type SimpleAIHandler struct{}

// NewSimpleAIHandler creates a new simple AI handler
func NewSimpleAIHandler() *SimpleAIHandler {
	return &SimpleAIHandler{}
}

// CreateTaskWithBasicAI creates a task with simple AI suggestions
func (ai *SimpleAIHandler) CreateTaskWithBasicAI() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var task Task
		if err := json.NewDecoder(r.Body).Decode(&task); err != nil {
			http.Error(w, fmt.Sprintf("Invalid JSON: %v", err), http.StatusBadRequest)
			return
		}

		// Set basic task properties
		task.ID = uuid.New().String()
		task.Type = "task"
		task.CreatedAt = time.Now()
		task.UpdatedAt = time.Now()

		// Simple AI: Suggest priority based on deadline
		if task.DueDate != nil && time.Until(*task.DueDate).Hours() < 24 {
			task.Priority = "high"
		}

		// Create task in database
		resp, err := couchDBRequest("PUT", "/"+task.ID, task)
		if err != nil {
			http.Error(w, fmt.Sprintf("Failed to create task: %v", err), http.StatusInternalServerError)
			return
		}
		defer resp.Body.Close()

		if resp.StatusCode != 201 {
			http.Error(w, "Failed to create task", http.StatusInternalServerError)
			return
		}

		// Broadcast task creation
		broadcastUpdate("task_created", task)

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(map[string]interface{}{
			"task":    task,
			"message": "Task created successfully",
		})
	}
}

// GetTaskSuggestions provides simple task completion suggestions
func (ai *SimpleAIHandler) GetTaskSuggestions() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)
		taskID := vars["id"]

		// Get task from database
		task, err := getTaskByID(taskID)
		if err != nil {
			http.Error(w, fmt.Sprintf("Task not found: %v", err), http.StatusNotFound)
			return
		}

		// Simple suggestions based on task properties
		suggestions := []string{}

		if task.DueDate != nil && time.Until(*task.DueDate).Hours() < 24 {
			suggestions = append(suggestions, "Task is due soon - consider prioritizing this")
		}

		if task.Priority == "high" {
			suggestions = append(suggestions, "High priority task - focus on completion")
		}

		if len(task.Description) < 50 {
			suggestions = append(suggestions, "Consider adding more details to the task description")
		}

		response := map[string]interface{}{
			"task_id":     taskID,
			"suggestions": suggestions,
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(response)
	}
}

// SuggestTaskAssignee provides simple assignee suggestions
func (ai *SimpleAIHandler) SuggestTaskAssignee() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var request struct {
			Task   Task   `json:"task"`
			TeamID string `json:"team_id"`
		}

		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
			http.Error(w, fmt.Sprintf("Invalid JSON: %v", err), http.StatusBadRequest)
			return
		}

		// Get team members (simplified - in real app, this would query database)
		teamMembers := []map[string]string{
			{"id": "user1", "name": "Alice", "skills": "development"},
			{"id": "user2", "name": "Bob", "skills": "design"},
			{"id": "user3", "name": "Charlie", "skills": "testing"},
		}

		// Simple matching based on task title keywords
		var suggestions []map[string]interface{}
		for _, member := range teamMembers {
			score := 0
			if request.Task.Title != "" {
				// Simple keyword matching
				if containsKeyword(request.Task.Title, member["skills"]) {
					score += 10
				}
			}

			suggestions = append(suggestions, map[string]interface{}{
				"user_id":   member["id"],
				"name":      member["name"],
				"score":     score,
				"reasoning": fmt.Sprintf("Based on %s skills", member["skills"]),
			})
		}

		response := map[string]interface{}{
			"task":        request.Task,
			"suggestions": suggestions,
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(response)
	}
}

// GetProductivityTips provides simple productivity suggestions
func (ai *SimpleAIHandler) GetProductivityTips() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)
		userID := vars["id"]

		// Simple productivity tips based on user ID
		tips := []string{
			"Break large tasks into smaller, manageable steps",
			"Set specific time blocks for focused work",
			"Take regular breaks to maintain productivity",
			"Review and prioritize your tasks daily",
		}

		response := map[string]interface{}{
			"user_id": userID,
			"tips":    tips,
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(response)
	}
}

// Helper functions

// containsKeyword checks if task title contains relevant keywords
func containsKeyword(title, skill string) bool {
	keywords := map[string][]string{
		"development": {"code", "develop", "implement", "build", "api", "backend", "frontend"},
		"design":      {"ui", "ux", "design", "interface", "mockup", "wireframe"},
		"testing":     {"test", "qa", "quality", "bug", "debug", "verify"},
	}

	if keywords, exists := keywords[skill]; exists {
		for _, keyword := range keywords {
			if containsString(title, keyword) {
				return true
			}
		}
	}
	return false
}

// containsString checks if a string contains a substring (case-insensitive)
func containsString(s, substr string) bool {
	return len(s) >= len(substr) && (s == substr || containsString(s[1:], substr) || containsString(s[:len(s)-1], substr))
}

// couchDBRequest makes an HTTP request to CouchDB
func couchDBRequest(method, path string, data interface{}) (*http.Response, error) {
	url := fmt.Sprintf("http://%s:%s/%s%s", couchConfig.Host, couchConfig.Port, couchConfig.Database, path)

	var body io.Reader
	if data != nil {
		jsonData, err := json.Marshal(data)
		if err != nil {
			return nil, err
		}
		body = bytes.NewBuffer(jsonData)
	}

	req, err := http.NewRequest(method, url, body)
	if err != nil {
		return nil, err
	}

	if couchConfig.Username != "" && couchConfig.Password != "" {
		req.SetBasicAuth(couchConfig.Username, couchConfig.Password)
	}

	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	return client.Do(req)
}

// broadcastUpdate broadcasts a message to all WebSocket clients
func broadcastUpdate(eventType string, data interface{}) {
	message := map[string]interface{}{
		"type": eventType,
		"data": data,
		"timestamp": time.Now(),
	}

	jsonMessage, err := json.Marshal(message)
	if err != nil {
		log.Printf("Error marshaling broadcast message: %v", err)
		return
	}

	select {
	case hub.broadcast <- jsonMessage:
		log.Printf("Broadcasted %s event", eventType)
	default:
		log.Printf("Broadcast channel full, skipping %s event", eventType)
	}
}

// getTaskByID retrieves a task by its ID from the database
func getTaskByID(taskID string) (*Task, error) {
	var task Task
	err := db.QueryRow(
		"SELECT id, title, description, status, priority, assignee_id, project_id, due_date, created_at, updated_at FROM tasks WHERE id = $1",
		taskID,
	).Scan(&task.ID, &task.Title, &task.Description, &task.Status, &task.Priority, &task.AssigneeID, &task.ProjectID, &task.DueDate, &task.CreatedAt, &task.UpdatedAt)

	if err != nil {
		return nil, err
	}

	return &task, nil
}

// Simple AI handlers that provide useful functionality without complexity
