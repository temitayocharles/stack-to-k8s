package main

import (
	"math"
	"sort"
	"sync"
	"time"
)

// SimplePrioritizationEngine - Simplified AI prioritization engine
type SimplePrioritizationEngine struct {
	userPreferences map[string]*SimplePriorityPrefs  `json:"user_preferences"`
	taskScores      map[string]*SimpleTaskScore      `json:"task_scores"`
	contextData     map[string]*SimpleContext        `json:"context_data"`
	mutex           sync.RWMutex
}

// SimplePriorityPrefs - User priority preferences
type SimplePriorityPrefs struct {
	UserID           string             `json:"user_id"`
	PriorityStyle    string             `json:"priority_style"`    // "deadline", "impact", "effort", "balanced"
	PreferredTypes   []string           `json:"preferred_types"`
	WeightDeadline   float64            `json:"weight_deadline"`   // 0-1
	WeightImpact     float64            `json:"weight_impact"`     // 0-1
	WeightEffort     float64            `json:"weight_effort"`     // 0-1
	WeightUrgency    float64            `json:"weight_urgency"`    // 0-1
	LastUpdated      time.Time          `json:"last_updated"`
}

// SimpleTaskScore - Task priority score
type SimpleTaskScore struct {
	TaskID         string    `json:"task_id"`
	OverallScore   float64   `json:"overall_score"`   // 0-1
	UrgencyScore   float64   `json:"urgency_score"`   // 0-1
	ImpactScore    float64   `json:"impact_score"`    // 0-1
	EffortScore    float64   `json:"effort_score"`    // 0-1 (higher = easier)
	DeadlineScore  float64   `json:"deadline_score"`  // 0-1
	Confidence     float64   `json:"confidence"`      // 0-1
	Reasoning      string    `json:"reasoning"`
	Recommendations []string `json:"recommendations"`
	CalculatedAt   time.Time `json:"calculated_at"`
}

// SimpleContext - Simplified context
type SimpleContext struct {
	UserID          string                 `json:"user_id"`
	CurrentTime     time.Time              `json:"current_time"`
	TimeOfDay       string                 `json:"time_of_day"`
	WorkloadLevel   float64                `json:"workload_level"`   // 0-1
	EnergyLevel     float64                `json:"energy_level"`     // 0-1
	FocusLevel      float64                `json:"focus_level"`      // 0-1
	TeamAvailability float64               `json:"team_availability"` // 0-1
	AdditionalData  map[string]interface{} `json:"additional_data"`
}

// SimplePrioritizedTask - Task with priority information
type SimplePrioritizedTask struct {
	Task            *Task             `json:"task"`
	PriorityScore   float64           `json:"priority_score"`
	Confidence      float64           `json:"confidence"`
	Reasoning       string            `json:"reasoning"`
	Recommendations []string          `json:"recommendations"`
	Context         *SimpleContext    `json:"context"`
	UpdatedAt       time.Time         `json:"updated_at"`
}

// NewSimplePrioritizationEngine - Create new simplified prioritization engine
func NewSimplePrioritizationEngine() *SimplePrioritizationEngine {
	return &SimplePrioritizationEngine{
		userPreferences: make(map[string]*SimplePriorityPrefs),
		taskScores:      make(map[string]*SimpleTaskScore),
		contextData:     make(map[string]*SimpleContext),
	}
}

// PrioritizeTasks - Prioritize a list of tasks
func (spe *SimplePrioritizationEngine) PrioritizeTasks(tasks []*Task, userID string, context *SimpleTaskContext) ([]*SimplePrioritizedTask, error) {
	spe.mutex.Lock()
	defer spe.mutex.Unlock()

	var prioritizedTasks []*SimplePrioritizedTask

	// Get or create user preferences
	prefs := spe.getUserPreferences(userID)
	
	// Get or create context
	simpleContext := spe.getSimpleContext(userID, context)

	for _, task := range tasks {
		score := spe.calculateTaskScore(task, prefs, simpleContext)
		
		prioritizedTask := &SimplePrioritizedTask{
			Task:          task,
			PriorityScore: score.OverallScore,
			Confidence:    score.Confidence,
			Reasoning:     score.Reasoning,
			Recommendations: score.Recommendations,
			Context:       simpleContext,
			UpdatedAt:     time.Now(),
		}

		prioritizedTasks = append(prioritizedTasks, prioritizedTask)
	}

	// Sort by priority score (highest first)
	sort.Slice(prioritizedTasks, func(i, j int) bool {
		return prioritizedTasks[i].PriorityScore > prioritizedTasks[j].PriorityScore
	})

	return prioritizedTasks, nil
}

// getUserPreferences - Get or create user preferences
func (spe *SimplePrioritizationEngine) getUserPreferences(userID string) *SimplePriorityPrefs {
	if prefs, exists := spe.userPreferences[userID]; exists {
		return prefs
	}

	// Default preferences
	prefs := &SimplePriorityPrefs{
		UserID:         userID,
		PriorityStyle:  "balanced",
		PreferredTypes: []string{"development", "bug_fix", "feature"},
		WeightDeadline: 0.3,
		WeightImpact:   0.3,
		WeightEffort:   0.2,
		WeightUrgency:  0.2,
		LastUpdated:    time.Now(),
	}

	spe.userPreferences[userID] = prefs
	return prefs
}

// getSimpleContext - Convert TaskContext to SimpleContext
func (spe *SimplePrioritizationEngine) getSimpleContext(userID string, context *SimpleTaskContext) *SimpleContext {
	simpleContext := &SimpleContext{
		UserID:           userID,
		CurrentTime:      time.Now(),
		TimeOfDay:        getCurrentTimeOfDay(),
		WorkloadLevel:    0.7,  // Default
		EnergyLevel:      0.8,  // Default
		FocusLevel:       0.75, // Default
		TeamAvailability: 0.8,  // Default
		AdditionalData:   make(map[string]interface{}),
	}

	if context != nil {
		if context.UserContext != nil {
			simpleContext.WorkloadLevel = context.UserContext.CurrentWorkload
			simpleContext.EnergyLevel = context.UserContext.EnergyLevel
		}
		if context.TemporalContext != nil {
			simpleContext.CurrentTime = context.TemporalContext.CurrentTime
		}
	}

	spe.contextData[userID] = simpleContext
	return simpleContext
}

// calculateTaskScore - Calculate comprehensive task score
func (spe *SimplePrioritizationEngine) calculateTaskScore(task *Task, prefs *SimplePriorityPrefs, context *SimpleContext) *SimpleTaskScore {
	score := &SimpleTaskScore{
		TaskID:       task.ID,
		CalculatedAt: time.Now(),
	}

	// Calculate component scores
	score.UrgencyScore = spe.calculateUrgencyScore(task, context)
	score.ImpactScore = spe.calculateImpactScore(task, context)
	score.EffortScore = spe.calculateEffortScore(task, context)
	score.DeadlineScore = spe.calculateDeadlineScore(task, context)

	// Calculate weighted overall score
	score.OverallScore = (score.UrgencyScore * prefs.WeightUrgency) +
		(score.ImpactScore * prefs.WeightImpact) +
		(score.EffortScore * prefs.WeightEffort) +
		(score.DeadlineScore * prefs.WeightDeadline)

	// Normalize to 0-1 range
	score.OverallScore = math.Max(0, math.Min(1, score.OverallScore))

	// Calculate confidence based on available data
	score.Confidence = spe.calculateConfidence(task, context)

	// Generate reasoning and recommendations
	score.Reasoning = spe.generateReasoning(score)
	score.Recommendations = spe.generateRecommendations(task, score)

	spe.taskScores[task.ID] = score
	return score
}

// calculateUrgencyScore - Calculate urgency based on priority and status
func (spe *SimplePrioritizationEngine) calculateUrgencyScore(task *Task, context *SimpleContext) float64 {
	urgency := 0.5 // Default

	switch task.Priority {
	case "critical":
		urgency = 1.0
	case "high":
		urgency = 0.8
	case "medium":
		urgency = 0.5
	case "low":
		urgency = 0.3
	}

	// Boost urgency for overdue or soon-due tasks
	if task.DueDate != nil {
		timeLeft := time.Until(*task.DueDate)
		if timeLeft < 0 {
			urgency = math.Min(1.0, urgency+0.3) // Overdue
		} else if timeLeft < 24*time.Hour {
			urgency = math.Min(1.0, urgency+0.2) // Due within 24 hours
		} else if timeLeft < 72*time.Hour {
			urgency = math.Min(1.0, urgency+0.1) // Due within 3 days
		}
	}

	return urgency
}

// calculateImpactScore - Calculate impact based on task properties
func (spe *SimplePrioritizationEngine) calculateImpactScore(task *Task, context *SimpleContext) float64 {
	impact := 0.5 // Default

	// Higher impact for certain task types
	highImpactTypes := map[string]float64{
		"bug_fix":     0.8,
		"security":    0.9,
		"feature":     0.7,
		"performance": 0.8,
	}

	if impactBoost, exists := highImpactTypes[task.Type]; exists {
		impact = impactBoost
	}

	// Boost impact based on priority
	switch task.Priority {
	case "critical":
		impact += 0.2
	case "high":
		impact += 0.1
	}

	return math.Min(1.0, impact)
}

// calculateEffortScore - Calculate effort score (higher = easier/less effort)
func (spe *SimplePrioritizationEngine) calculateEffortScore(task *Task, context *SimpleContext) float64 {
	effort := 0.5 // Default

	// Estimate effort based on description length (simple heuristic)
	descLength := len(task.Description)
	if descLength < 100 {
		effort = 0.8 // Simple task
	} else if descLength < 300 {
		effort = 0.6 // Medium task
	} else {
		effort = 0.4 // Complex task
	}

	// Adjust based on dependencies
	if len(task.Dependencies) == 0 {
		effort += 0.2 // No dependencies = easier
	} else {
		effort -= float64(len(task.Dependencies)) * 0.1 // More dependencies = harder
	}

	return math.Max(0.1, math.Min(1.0, effort))
}

// calculateDeadlineScore - Calculate deadline pressure
func (spe *SimplePrioritizationEngine) calculateDeadlineScore(task *Task, context *SimpleContext) float64 {
	if task.DueDate == nil {
		return 0.3 // No deadline = lower priority
	}

	timeLeft := time.Until(*task.DueDate)
	totalTime := task.DueDate.Sub(task.CreatedAt)

	if totalTime <= 0 {
		return 1.0 // Already overdue
	}

	// Calculate deadline pressure (0-1, where 1 = most urgent)
	pressure := 1.0 - (timeLeft.Seconds() / totalTime.Seconds())
	return math.Max(0, math.Min(1.0, pressure))
}

// calculateConfidence - Calculate confidence in the score
func (spe *SimplePrioritizationEngine) calculateConfidence(task *Task, context *SimpleContext) float64 {
	confidence := 0.5

	// Higher confidence with more task data
	if task.Priority != "" {
		confidence += 0.1
	}
	if task.DueDate != nil {
		confidence += 0.1
	}
	if task.Type != "" {
		confidence += 0.1
	}
	if len(task.Description) > 50 {
		confidence += 0.1
	}

	// Higher confidence with better context
	if context.EnergyLevel > 0 {
		confidence += 0.1
	}
	if context.WorkloadLevel > 0 {
		confidence += 0.1
	}

	return math.Min(1.0, confidence)
}

// generateReasoning - Generate human-readable reasoning
func (spe *SimplePrioritizationEngine) generateReasoning(score *SimpleTaskScore) string {
	if score.OverallScore > 0.8 {
		return "High priority due to urgency and impact factors"
	} else if score.OverallScore > 0.6 {
		return "Medium-high priority with good balance of factors"
	} else if score.OverallScore > 0.4 {
		return "Medium priority - consider scheduling appropriately"
	} else {
		return "Lower priority - can be scheduled when capacity allows"
	}
}

// generateRecommendations - Generate actionable recommendations
func (spe *SimplePrioritizationEngine) generateRecommendations(task *Task, score *SimpleTaskScore) []string {
	recommendations := []string{}

	if score.OverallScore > 0.8 {
		recommendations = append(recommendations, "Consider prioritizing this task today")
	}

	if score.DeadlineScore > 0.8 {
		recommendations = append(recommendations, "Deadline approaching - plan completion soon")
	}

	if score.EffortScore > 0.7 {
		recommendations = append(recommendations, "Quick win opportunity - low effort, good value")
	}

	if len(task.Dependencies) > 0 {
		recommendations = append(recommendations, "Coordinate with team to resolve dependencies first")
	}

	if score.Confidence < 0.6 {
		recommendations = append(recommendations, "Gather more information to improve priority assessment")
	}

	if len(recommendations) == 0 {
		recommendations = append(recommendations, "Schedule based on current workload and capacity")
	}

	return recommendations
}

// SimpleTaskContext - Simplified task context to avoid conflicts
type SimpleTaskContext struct {
	UserContext     *SimpleUserContext     `json:"user_context"`
	TemporalContext *SimpleTemporalContext `json:"temporal_context"`
}

// SimpleUserContext - Simplified user context
type SimpleUserContext struct {
	CurrentWorkload float64 `json:"current_workload"` // 0-1
	EnergyLevel     float64 `json:"energy_level"`     // 0-1
	StressLevel     float64 `json:"stress_level"`     // 0-1
}

// SimpleTemporalContext - Simplified temporal context
type SimpleTemporalContext struct {
	CurrentTime time.Time `json:"current_time"`
	TimeOfDay   string    `json:"time_of_day"`
}