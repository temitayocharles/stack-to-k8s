package main

import (
	"sync"
	"time"
)

// SimpleTimeTrackingEngine - Simplified time tracking to avoid conflicts
type SimpleTimeTrackingEngine struct {
	timeEntries    map[string][]*SimpleTimeEntry  `json:"time_entries"`
	userSessions   map[string]*SimpleUserSession  `json:"user_sessions"`
	mutex          sync.RWMutex
}

// SimpleTimeEntry - Simplified time entry
type SimpleTimeEntry struct {
	EntryID       string    `json:"entry_id"`
	UserID        string    `json:"user_id"`
	TaskID        string    `json:"task_id"`
	ActivityType  string    `json:"activity_type"`
	StartTime     time.Time `json:"start_time"`
	EndTime       *time.Time `json:"end_time,omitempty"`
	Duration      time.Duration `json:"duration"`
	Description   string    `json:"description"`
	IsActive      bool      `json:"is_active"`
	CreatedAt     time.Time `json:"created_at"`
}

// SimpleUserSession - Simplified user session
type SimpleUserSession struct {
	SessionID     string    `json:"session_id"`
	UserID        string    `json:"user_id"`
	StartTime     time.Time `json:"start_time"`
	LastActivity  time.Time `json:"last_activity"`
	IsActive      bool      `json:"is_active"`
	TotalDuration time.Duration `json:"total_duration"`
}

// SimpleTimeAnalytics - Simplified time analytics
type SimpleTimeAnalytics struct {
	UserID          string    `json:"user_id"`
	Period          string    `json:"period"`
	TotalTime       time.Duration `json:"total_time"`
	ProductiveTime  time.Duration `json:"productive_time"`
	BreakTime       time.Duration `json:"break_time"`
	TasksCompleted  int       `json:"tasks_completed"`
	AvgTaskDuration time.Duration `json:"avg_task_duration"`
	ProductivityScore float64 `json:"productivity_score"`
	GeneratedAt     time.Time `json:"generated_at"`
}

// SimpleProductivityAnalysis - Simplified productivity analysis
type SimpleProductivityAnalysis struct {
	UserID            string                    `json:"user_id"`
	ProductivityScore float64                   `json:"productivity_score"`
	FocusScore        float64                   `json:"focus_score"`
	EfficiencyScore   float64                   `json:"efficiency_score"`
	Recommendations   []string                  `json:"recommendations"`
	TimePatterns      map[string]time.Duration  `json:"time_patterns"`
	WeeklyTrend       string                    `json:"weekly_trend"`
	LastUpdated       time.Time                 `json:"last_updated"`
}

// SimpleActivityDetection - Simplified activity detection
type SimpleActivityDetection struct {
	ActivityType   string                 `json:"activity_type"`
	Confidence     float64                `json:"confidence"`
	Context        map[string]interface{} `json:"context"`
	DetectedAt     time.Time              `json:"detected_at"`
	Suggestions    []string               `json:"suggestions"`
}

// NewSimpleTimeTrackingEngine - Create new simplified time tracking engine
func NewSimpleTimeTrackingEngine() *SimpleTimeTrackingEngine {
	return &SimpleTimeTrackingEngine{
		timeEntries:  make(map[string][]*SimpleTimeEntry),
		userSessions: make(map[string]*SimpleUserSession),
	}
}

// StartTimeEntry - Start a new time entry
func (ste *SimpleTimeTrackingEngine) StartTimeEntry(userID, taskID, activityType, description string) (*SimpleTimeEntry, error) {
	ste.mutex.Lock()
	defer ste.mutex.Unlock()

	entry := &SimpleTimeEntry{
		EntryID:      generateID(),
		UserID:       userID,
		TaskID:       taskID,
		ActivityType: activityType,
		StartTime:    time.Now(),
		Description:  description,
		IsActive:     true,
		CreatedAt:    time.Now(),
	}

	if ste.timeEntries[userID] == nil {
		ste.timeEntries[userID] = []*SimpleTimeEntry{}
	}

	ste.timeEntries[userID] = append(ste.timeEntries[userID], entry)
	return entry, nil
}

// StopTimeEntry - Stop a time entry
func (ste *SimpleTimeTrackingEngine) StopTimeEntry(userID, entryID, notes string) (*SimpleTimeEntry, error) {
	ste.mutex.Lock()
	defer ste.mutex.Unlock()

	entries := ste.timeEntries[userID]
	for _, entry := range entries {
		if entry.EntryID == entryID && entry.IsActive {
			now := time.Now()
			entry.EndTime = &now
			entry.Duration = now.Sub(entry.StartTime)
			entry.IsActive = false
			if notes != "" {
				entry.Description += " | " + notes
			}
			return entry, nil
		}
	}

	return nil, nil // Entry not found
}

// GetTimeEntries - Get time entries for user and/or task
func (ste *SimpleTimeTrackingEngine) GetTimeEntries(userID, taskID string) ([]*SimpleTimeEntry, error) {
	ste.mutex.RLock()
	defer ste.mutex.RUnlock()

	entries := ste.timeEntries[userID]
	if taskID == "" {
		return entries, nil
	}

	// Filter by task ID
	var filtered []*SimpleTimeEntry
	for _, entry := range entries {
		if entry.TaskID == taskID {
			filtered = append(filtered, entry)
		}
	}

	return filtered, nil
}

// GetTimeAnalytics - Get time analytics for a user
func (ste *SimpleTimeTrackingEngine) GetTimeAnalytics(userID, period string) (*SimpleTimeAnalytics, error) {
	ste.mutex.RLock()
	defer ste.mutex.RUnlock()

	entries := ste.timeEntries[userID]
	analytics := &SimpleTimeAnalytics{
		UserID:      userID,
		Period:      period,
		GeneratedAt: time.Now(),
	}

	var totalTime, productiveTime time.Duration
	tasksCompleted := 0

	for _, entry := range entries {
		if entry.EndTime != nil {
			totalTime += entry.Duration
			if entry.ActivityType == "work" || entry.ActivityType == "coding" {
				productiveTime += entry.Duration
			}
			tasksCompleted++
		}
	}

	analytics.TotalTime = totalTime
	analytics.ProductiveTime = productiveTime
	analytics.BreakTime = totalTime - productiveTime
	analytics.TasksCompleted = tasksCompleted

	if tasksCompleted > 0 {
		analytics.AvgTaskDuration = totalTime / time.Duration(tasksCompleted)
	}

	if totalTime > 0 {
		analytics.ProductivityScore = float64(productiveTime) / float64(totalTime)
	}

	return analytics, nil
}

// GetProductivityAnalysis - Get productivity analysis for a user
func (ste *SimpleTimeTrackingEngine) GetProductivityAnalysis(userID string) (*SimpleProductivityAnalysis, error) {
	ste.mutex.RLock()
	defer ste.mutex.RUnlock()

	analysis := &SimpleProductivityAnalysis{
		UserID:        userID,
		TimePatterns:  make(map[string]time.Duration),
		LastUpdated:   time.Now(),
	}

	entries := ste.timeEntries[userID]
	if len(entries) == 0 {
		analysis.Recommendations = []string{"Start tracking time to get personalized insights"}
		return analysis, nil
	}

	// Calculate basic scores
	var totalTime, focusTime time.Duration
	for _, entry := range entries {
		if entry.EndTime != nil {
			totalTime += entry.Duration
			if entry.ActivityType == "work" || entry.ActivityType == "coding" {
				focusTime += entry.Duration
			}
		}
	}

	if totalTime > 0 {
		analysis.ProductivityScore = float64(focusTime) / float64(totalTime)
		analysis.FocusScore = analysis.ProductivityScore * 0.9 // Slightly lower
		analysis.EfficiencyScore = analysis.ProductivityScore * 1.1 // Slightly higher
	}

	// Basic recommendations
	analysis.Recommendations = []string{
		"Take regular breaks to maintain focus",
		"Track different activity types for better insights",
		"Set time-boxed goals for tasks",
	}

	if analysis.ProductivityScore < 0.7 {
		analysis.Recommendations = append(analysis.Recommendations, "Consider reducing distractions during work sessions")
	}

	analysis.WeeklyTrend = "stable"

	return analysis, nil
}

// DetectActivity - Simple activity detection
func (ste *SimpleTimeTrackingEngine) DetectActivity(userID string, context map[string]interface{}) (*SimpleActivityDetection, error) {
	detection := &SimpleActivityDetection{
		ActivityType: "work",
		Confidence:   0.8,
		Context:      context,
		DetectedAt:   time.Now(),
		Suggestions: []string{
			"Start time tracking for this activity",
			"Set a focus timer for deep work",
		},
	}

	return detection, nil
}

// Helper function to generate IDs
func generateID() string {
	return time.Now().Format("20060102150405") + "000"
}