package main

import (
	"sync"
	"time"
)

// SimpleAnalyticsEngine - Simplified analytics engine to avoid conflicts
type SimpleAnalyticsEngine struct {
	projectData    map[string]*SimpleProjectData    `json:"project_data"`
	userMetrics    map[string]*SimpleUserMetrics    `json:"user_metrics"`
	dashboards     map[string]*SimpleDashboard      `json:"dashboards"`
	reports        map[string]*SimpleReport         `json:"reports"`
	realtimeData   map[string]*SimpleRealtimeData   `json:"realtime_data"`
	mutex          sync.RWMutex
}

// SimpleProjectData - Basic project metrics
type SimpleProjectData struct {
	ProjectID       string    `json:"project_id"`
	Name           string    `json:"name"`
	TasksTotal     int       `json:"tasks_total"`
	TasksCompleted int       `json:"tasks_completed"`
	CompletionRate float64   `json:"completion_rate"`
	TeamSize       int       `json:"team_size"`
	StartDate      time.Time `json:"start_date"`
	DueDate        *time.Time `json:"due_date,omitempty"`
	HealthScore    float64   `json:"health_score"`
	LastUpdated    time.Time `json:"last_updated"`
}

// SimpleUserMetrics - Basic user performance metrics
type SimpleUserMetrics struct {
	UserID           string    `json:"user_id"`
	TasksCompleted   int       `json:"tasks_completed"`
	TasksInProgress  int       `json:"tasks_in_progress"`
	AverageTime      time.Duration `json:"average_time"`
	ProductivityScore float64  `json:"productivity_score"`
	LastActive       time.Time `json:"last_active"`
}

// SimpleDashboard - User analytics dashboard
type SimpleDashboard struct {
	DashboardID    string                    `json:"dashboard_id"`
	UserID         string                    `json:"user_id"`
	Projects       []*SimpleProjectData      `json:"projects"`
	PersonalMetrics *SimpleUserMetrics       `json:"personal_metrics"`
	RecentActivity []string                  `json:"recent_activity"`
	Notifications  []string                  `json:"notifications"`
	QuickStats     map[string]interface{}    `json:"quick_stats"`
	GeneratedAt    time.Time                 `json:"generated_at"`
}

// SimpleReport - Analytics report
type SimpleReport struct {
	ReportID     string                 `json:"report_id"`
	ReportType   string                 `json:"report_type"`
	ProjectID    string                 `json:"project_id,omitempty"`
	UserID       string                 `json:"user_id,omitempty"`
	Data         map[string]interface{} `json:"data"`
	Period       string                 `json:"period"`
	GeneratedAt  time.Time              `json:"generated_at"`
	Summary      string                 `json:"summary"`
}

// SimpleRealtimeData - Real-time metrics
type SimpleRealtimeData struct {
	ProjectID       string                 `json:"project_id"`
	ActiveUsers     int                    `json:"active_users"`
	TasksInProgress int                    `json:"tasks_in_progress"`
	RecentUpdates   []string               `json:"recent_updates"`
	CurrentMetrics  map[string]interface{} `json:"current_metrics"`
	LastRefresh     time.Time              `json:"last_refresh"`
}

// NewSimpleAnalyticsEngine - Create new simplified analytics engine
func NewSimpleAnalyticsEngine() *SimpleAnalyticsEngine {
	return &SimpleAnalyticsEngine{
		projectData:  make(map[string]*SimpleProjectData),
		userMetrics:  make(map[string]*SimpleUserMetrics),
		dashboards:   make(map[string]*SimpleDashboard),
		reports:      make(map[string]*SimpleReport),
		realtimeData: make(map[string]*SimpleRealtimeData),
	}
}

// GetProjectMetrics - Get metrics for a project
func (sae *SimpleAnalyticsEngine) GetProjectMetrics(projectID string) (*SimpleProjectData, error) {
	sae.mutex.RLock()
	defer sae.mutex.RUnlock()

	if data, exists := sae.projectData[projectID]; exists {
		return data, nil
	}

	// Create default data if not exists
	data := &SimpleProjectData{
		ProjectID:      projectID,
		Name:          "Sample Project",
		TasksTotal:    10,
		TasksCompleted: 7,
		CompletionRate: 0.7,
		TeamSize:      5,
		StartDate:     time.Now().AddDate(0, 0, -30),
		HealthScore:   0.85,
		LastUpdated:   time.Now(),
	}

	sae.projectData[projectID] = data
	return data, nil
}

// GetDashboard - Get dashboard for a user
func (sae *SimpleAnalyticsEngine) GetDashboard(userID string) (*SimpleDashboard, error) {
	sae.mutex.RLock()
	defer sae.mutex.RUnlock()

	if dashboard, exists := sae.dashboards[userID]; exists {
		dashboard.GeneratedAt = time.Now()
		return dashboard, nil
	}

	// Create default dashboard
	dashboard := &SimpleDashboard{
		DashboardID: generateID(),
		UserID:      userID,
		Projects:    []*SimpleProjectData{},
		PersonalMetrics: &SimpleUserMetrics{
			UserID:           userID,
			TasksCompleted:   15,
			TasksInProgress:  3,
			AverageTime:      2 * time.Hour,
			ProductivityScore: 0.82,
			LastActive:       time.Now(),
		},
		RecentActivity: []string{
			"Completed task: Implement user authentication",
			"Started task: Design dashboard UI",
			"Updated task: Fix login bug",
		},
		Notifications: []string{
			"You have 3 tasks due today",
			"Team meeting in 1 hour",
		},
		QuickStats: map[string]interface{}{
			"tasks_today":      5,
			"time_logged":      "6h 30m",
			"productivity":     "82%",
			"team_velocity":    "8.5",
		},
		GeneratedAt: time.Now(),
	}

	sae.dashboards[userID] = dashboard
	return dashboard, nil
}

// GenerateReport - Generate analytics report
func (sae *SimpleAnalyticsEngine) GenerateReport(projectID, userID, reportType, period string) (*SimpleReport, error) {
	sae.mutex.Lock()
	defer sae.mutex.Unlock()

	report := &SimpleReport{
		ReportID:    generateID(),
		ReportType:  reportType,
		ProjectID:   projectID,
		UserID:      userID,
		Period:      period,
		GeneratedAt: time.Now(),
		Data: map[string]interface{}{
			"summary": "Project performance is above average",
			"completion_rate": 0.75,
			"team_productivity": 0.88,
			"risk_factors": []string{"Resource constraints", "Timeline pressure"},
			"recommendations": []string{
				"Increase team collaboration",
				"Focus on high-priority tasks",
				"Implement daily standups",
			},
		},
		Summary: "Overall project health is good with 75% completion rate and strong team productivity.",
	}

	sae.reports[report.ReportID] = report
	return report, nil
}

// GetRealtimeMetrics - Get real-time metrics for a project
func (sae *SimpleAnalyticsEngine) GetRealtimeMetrics(projectID string) (*SimpleRealtimeData, error) {
	sae.mutex.RLock()
	defer sae.mutex.RUnlock()

	if data, exists := sae.realtimeData[projectID]; exists {
		data.LastRefresh = time.Now()
		return data, nil
	}

	// Create default real-time data
	data := &SimpleRealtimeData{
		ProjectID:       projectID,
		ActiveUsers:     3,
		TasksInProgress: 8,
		RecentUpdates: []string{
			"Task 'Fix authentication bug' completed by John",
			"New task 'Implement dashboard' created by Sarah",
			"Task 'Code review' started by Mike",
		},
		CurrentMetrics: map[string]interface{}{
			"velocity":        8.5,
			"burndown_rate":   0.85,
			"team_load":       0.72,
			"quality_score":   0.91,
		},
		LastRefresh: time.Now(),
	}

	sae.realtimeData[projectID] = data
	return data, nil
}

// UpdateProjectData - Update project metrics
func (sae *SimpleAnalyticsEngine) UpdateProjectData(projectID string, updates map[string]interface{}) error {
	sae.mutex.Lock()
	defer sae.mutex.Unlock()

	data, exists := sae.projectData[projectID]
	if !exists {
		data = &SimpleProjectData{
			ProjectID: projectID,
			Name:      "New Project",
		}
		sae.projectData[projectID] = data
	}

	// Update fields based on provided data
	if name, ok := updates["name"].(string); ok {
		data.Name = name
	}
	if tasksTotal, ok := updates["tasks_total"].(int); ok {
		data.TasksTotal = tasksTotal
	}
	if tasksCompleted, ok := updates["tasks_completed"].(int); ok {
		data.TasksCompleted = tasksCompleted
	}
	if teamSize, ok := updates["team_size"].(int); ok {
		data.TeamSize = teamSize
	}

	// Recalculate completion rate
	if data.TasksTotal > 0 {
		data.CompletionRate = float64(data.TasksCompleted) / float64(data.TasksTotal)
	}

	// Update health score based on completion rate
	data.HealthScore = data.CompletionRate * 0.8 + 0.2 // Between 0.2 and 1.0

	data.LastUpdated = time.Now()
	return nil
}

// GetUserMetrics - Get metrics for a specific user
func (sae *SimpleAnalyticsEngine) GetUserMetrics(userID string) (*SimpleUserMetrics, error) {
	sae.mutex.RLock()
	defer sae.mutex.RUnlock()

	if metrics, exists := sae.userMetrics[userID]; exists {
		return metrics, nil
	}

	// Create default metrics
	metrics := &SimpleUserMetrics{
		UserID:           userID,
		TasksCompleted:   12,
		TasksInProgress:  4,
		AverageTime:      3 * time.Hour,
		ProductivityScore: 0.78,
		LastActive:       time.Now(),
	}

	sae.userMetrics[userID] = metrics
	return metrics, nil
}