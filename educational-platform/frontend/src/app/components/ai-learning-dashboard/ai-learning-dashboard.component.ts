import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { Chart, registerables } from 'chart.js';

// Register Chart.js components
Chart.register(...registerables);

interface LearningAnalytics {
  learningMetrics: {
    totalStudyTime: number;
    averageSessionDuration: number;
    completionRate: number;
    skillMasteryLevel: number;
    learningVelocity: number;
    retentionRate: number;
    engagementScore: number;
  };
  learningPatterns: {
    preferredLearningTime: string[];
    optimalSessionDuration: number;
    contentTypePreferences: Map<string, number>;
    difficultyProgression: number[];
    learningCurve: number[];
  };
  knowledgeRetention: {
    shortTermRetention: number;
    longTermRetention: number;
    forgettingCurve: number[];
    retentionByTopic: Map<string, number>;
    reviewEffectiveness: number;
  };
  performanceInsights: {
    strengths: string[];
    improvementAreas: string[];
    learningRecommendations: string[];
    predictionAccuracy: number;
    riskFactors: string[];
  };
  engagementMetrics: {
    sessionConsistency: number;
    interactionRate: number;
    completionMomentum: number;
    motivationLevel: number;
    socialEngagement: number;
  };
}

interface CourseRecommendations {
  userId: number;
  generatedAt: string;
  recommendations: CourseRecommendation[];
  totalRecommendations: number;
  insights: {
    recommendationTypeDistribution: Map<string, number>;
    averageConfidence: number;
    recommendedFocusAreas: string[];
    learningAdvice: string[];
  };
}

interface CourseRecommendation {
  course: {
    id: number;
    title: string;
    description: string;
    level: string;
    estimatedHours: number;
    rating: number;
  };
  recommendationType: string;
  confidenceScore: number;
  reason: string;
  expectedBenefit: string;
  priority: string;
  learningPathId?: number;
  metadata: any;
}

interface ProgressDashboard {
  userId: number;
  generatedAt: string;
  overallSummary: {
    totalCoursesEnrolled: number;
    coursesCompleted: number;
    completionRate: number;
    totalTimeSpentHours: number;
    currentLearningStreak: number;
    thisWeekTimeHours: number;
    activeGoals: number;
  };
  courseProgress: CourseProgress[];
  recentActivity: RecentActivity[];
  learningStreaks: {
    currentStreak: number;
    longestStreak: number;
    weekStreak: number;
    streakMilestones: string[];
  };
  milestones: {
    name: string;
    achievedAt: string;
    description: string;
  }[];
  performanceInsights: {
    insightType: string;
    skillArea: string;
    confidenceScore: number;
    insightText: string;
    actionableRecommendation: string;
  }[];
  timeAnalytics: {
    dailyAverageMinutes: number;
    weeklyBreakdown: Map<string, number>;
    peakLearningHours: string[];
    timeByContentType: Map<string, number>;
    efficiencyScore: number;
  };
  goalTracking: {
    activeGoals: string[];
    completionRate: number;
    goalProgress: string[];
  };
}

interface CourseProgress {
  userId: number;
  courseId: number;
  completionPercentage: number;
  timeSpentHours: number;
  lastActivity: string;
  lastActionType: string;
  chapterProgress: {
    chapterId: number;
    chapterName: string;
    completionPercentage: number;
    timeSpentMinutes: number;
  }[];
  performanceMetrics: any;
  estimatedCompletionDays: number;
}

interface RecentActivity {
  timestamp: string;
  actionType: string;
  contentType: string;
  courseId: number;
  chapterId: number;
  timeSpentMinutes: number;
  progressPercentage: number;
}

@Component({
  selector: 'app-ai-learning-dashboard',
  template: `
    <div class="ai-learning-dashboard">
      <div class="dashboard-header">
        <h1 class="dashboard-title">
          <i class="fas fa-brain"></i>
          AI-Powered Learning Dashboard
        </h1>
        <div class="dashboard-controls">
          <select [(ngModel)]="selectedTimeRange" (change)="loadDashboardData()" class="time-range-selector">
            <option value="7">Last 7 days</option>
            <option value="30">Last 30 days</option>
            <option value="90">Last 3 months</option>
            <option value="365">Last year</option>
          </select>
          <button (click)="refreshData()" class="refresh-btn">
            <i class="fas fa-sync-alt"></i>
            Refresh
          </button>
        </div>
      </div>

      <!-- Loading State -->
      <div *ngIf="loading" class="loading-state">
        <div class="spinner"></div>
        <p>Analyzing your learning patterns with AI...</p>
      </div>

      <!-- Dashboard Content -->
      <div *ngIf="!loading" class="dashboard-content">
        
        <!-- Quick Stats Cards -->
        <div class="stats-grid">
          <div class="stat-card completion-rate">
            <div class="stat-icon">
              <i class="fas fa-graduation-cap"></i>
            </div>
            <div class="stat-content">
              <h3>{{progressDashboard?.overallSummary?.completionRate | number:'1.1-1'}}%</h3>
              <p>Course Completion Rate</p>
              <div class="stat-trend positive" *ngIf="progressDashboard?.overallSummary?.completionRate > 75">
                <i class="fas fa-arrow-up"></i> Excellent progress!
              </div>
            </div>
          </div>

          <div class="stat-card learning-streak">
            <div class="stat-icon">
              <i class="fas fa-fire"></i>
            </div>
            <div class="stat-content">
              <h3>{{progressDashboard?.learningStreaks?.currentStreak || 0}}</h3>
              <p>Day Learning Streak</p>
              <div class="stat-trend" [ngClass]="{
                'positive': progressDashboard?.learningStreaks?.currentStreak > 7,
                'neutral': progressDashboard?.learningStreaks?.currentStreak >= 3 && progressDashboard?.learningStreaks?.currentStreak <= 7,
                'negative': progressDashboard?.learningStreaks?.currentStreak < 3
              }">
                <i class="fas fa-chart-line"></i> 
                {{getStreakMessage()}}
              </div>
            </div>
          </div>

          <div class="stat-card study-time">
            <div class="stat-icon">
              <i class="fas fa-clock"></i>
            </div>
            <div class="stat-content">
              <h3>{{progressDashboard?.timeAnalytics?.dailyAverageMinutes | number:'1.0-0'}}m</h3>
              <p>Daily Average Study Time</p>
              <div class="stat-trend positive">
                <i class="fas fa-target"></i> Goal: 60m/day
              </div>
            </div>
          </div>

          <div class="stat-card ai-score">
            <div class="stat-icon">
              <i class="fas fa-robot"></i>
            </div>
            <div class="stat-content">
              <h3>{{learningAnalytics?.learningMetrics?.engagementScore | number:'1.0-0'}}</h3>
              <p>AI Engagement Score</p>
              <div class="stat-trend positive">
                <i class="fas fa-brain"></i> AI-optimized learning
              </div>
            </div>
          </div>
        </div>

        <!-- AI Insights Panel -->
        <div class="ai-insights-panel">
          <h2>
            <i class="fas fa-lightbulb"></i>
            AI-Generated Insights
          </h2>
          <div class="insights-grid">
            <div *ngFor="let insight of progressDashboard?.performanceInsights" 
                 class="insight-card" 
                 [ngClass]="insight.insightType.toLowerCase()">
              <div class="insight-header">
                <span class="insight-type">{{insight.insightType}}</span>
                <span class="confidence-score">{{insight.confidenceScore * 100 | number:'1.0-0'}}% confidence</span>
              </div>
              <div class="insight-content">
                <h4>{{insight.skillArea}}</h4>
                <p class="insight-text">{{insight.insightText}}</p>
                <div class="actionable-recommendation">
                  <strong>Recommendation:</strong>
                  <p>{{insight.actionableRecommendation}}</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Learning Analytics Charts -->
        <div class="analytics-section">
          <div class="analytics-grid">
            
            <!-- Learning Pattern Chart -->
            <div class="chart-card">
              <h3>Learning Patterns Analysis</h3>
              <canvas id="learningPatternsChart"></canvas>
              <div class="chart-insights">
                <p><strong>Peak Learning Time:</strong> {{getPeakLearningTime()}}</p>
                <p><strong>Optimal Session:</strong> {{learningAnalytics?.learningPatterns?.optimalSessionDuration}}min</p>
              </div>
            </div>

            <!-- Knowledge Retention Chart -->
            <div class="chart-card">
              <h3>Knowledge Retention Curve</h3>
              <canvas id="retentionChart"></canvas>
              <div class="chart-insights">
                <p><strong>Short-term Retention:</strong> {{learningAnalytics?.knowledgeRetention?.shortTermRetention | number:'1.1-1'}}%</p>
                <p><strong>Long-term Retention:</strong> {{learningAnalytics?.knowledgeRetention?.longTermRetention | number:'1.1-1'}}%</p>
              </div>
            </div>

            <!-- Performance Trends Chart -->
            <div class="chart-card">
              <h3>Performance Trends</h3>
              <canvas id="performanceChart"></canvas>
              <div class="chart-insights">
                <p><strong>Learning Velocity:</strong> {{learningAnalytics?.learningMetrics?.learningVelocity | number:'1.1-1'}}x</p>
                <p><strong>Skill Mastery:</strong> {{learningAnalytics?.learningMetrics?.skillMasteryLevel | number:'1.1-1'}}%</p>
              </div>
            </div>

            <!-- Time Analytics Chart -->
            <div class="chart-card">
              <h3>Weekly Study Time Breakdown</h3>
              <canvas id="timeAnalyticsChart"></canvas>
              <div class="chart-insights">
                <p><strong>Total This Week:</strong> {{progressDashboard?.overallSummary?.thisWeekTimeHours | number:'1.1-1'}}h</p>
                <p><strong>Efficiency Score:</strong> {{progressDashboard?.timeAnalytics?.efficiencyScore | number:'1.0-0'}}/100</p>
              </div>
            </div>

          </div>
        </div>

        <!-- AI Course Recommendations -->
        <div class="recommendations-section">
          <h2>
            <i class="fas fa-magic"></i>
            AI-Curated Course Recommendations
          </h2>
          <div class="recommendations-filter">
            <button *ngFor="let type of recommendationTypes" 
                    (click)="filterRecommendations(type)"
                    [class.active]="selectedRecommendationType === type"
                    class="filter-btn">
              {{type.replace('_', ' ') | titlecase}}
            </button>
          </div>
          <div class="recommendations-grid">
            <div *ngFor="let recommendation of filteredRecommendations" class="recommendation-card">
              <div class="recommendation-header">
                <h4>{{recommendation.course.title}}</h4>
                <div class="recommendation-meta">
                  <span class="confidence-badge" [ngClass]="getConfidenceClass(recommendation.confidenceScore)">
                    {{recommendation.confidenceScore * 100 | number:'1.0-0'}}% match
                  </span>
                  <span class="priority-badge" [ngClass]="recommendation.priority.toLowerCase()">
                    {{recommendation.priority}} priority
                  </span>
                </div>
              </div>
              <div class="recommendation-content">
                <p class="course-description">{{recommendation.course.description}}</p>
                <div class="course-details">
                  <span class="course-level">{{recommendation.course.level}}</span>
                  <span class="course-duration">{{recommendation.course.estimatedHours}}h</span>
                  <span class="course-rating">
                    <i class="fas fa-star"></i>
                    {{recommendation.course.rating}}
                  </span>
                </div>
                <div class="recommendation-reason">
                  <strong>Why this course?</strong>
                  <p>{{recommendation.reason}}</p>
                </div>
                <div class="expected-benefit">
                  <strong>Expected benefit:</strong>
                  <p>{{recommendation.expectedBenefit}}</p>
                </div>
              </div>
              <div class="recommendation-actions">
                <button (click)="enrollInCourse(recommendation.course.id)" class="enroll-btn">
                  <i class="fas fa-plus"></i>
                  Enroll Now
                </button>
                <button (click)="addToWishlist(recommendation.course.id)" class="wishlist-btn">
                  <i class="fas fa-bookmark"></i>
                  Save for Later
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Learning Goals & Milestones -->
        <div class="goals-section">
          <div class="goals-grid">
            
            <!-- Active Goals -->
            <div class="goals-card">
              <h3>
                <i class="fas fa-target"></i>
                Active Learning Goals
              </h3>
              <div class="goals-list">
                <div *ngFor="let goal of progressDashboard?.goalTracking?.activeGoals" class="goal-item">
                  <div class="goal-content">
                    <span class="goal-text">{{goal}}</span>
                    <div class="goal-progress">
                      <div class="progress-bar">
                        <div class="progress-fill" [style.width]="getGoalProgress(goal) + '%'"></div>
                      </div>
                      <span class="progress-text">{{getGoalProgress(goal)}}%</span>
                    </div>
                  </div>
                </div>
              </div>
              <button (click)="addNewGoal()" class="add-goal-btn">
                <i class="fas fa-plus"></i>
                Add New Goal
              </button>
            </div>

            <!-- Recent Milestones -->
            <div class="milestones-card">
              <h3>
                <i class="fas fa-trophy"></i>
                Recent Achievements
              </h3>
              <div class="milestones-list">
                <div *ngFor="let milestone of progressDashboard?.milestones" class="milestone-item">
                  <div class="milestone-icon">
                    <i class="fas fa-medal"></i>
                  </div>
                  <div class="milestone-content">
                    <h4>{{milestone.name}}</h4>
                    <p>{{milestone.description}}</p>
                    <span class="milestone-date">{{milestone.achievedAt | date:'medium'}}</span>
                  </div>
                </div>
              </div>
            </div>

          </div>
        </div>

        <!-- Recent Activity Timeline -->
        <div class="activity-section">
          <h2>
            <i class="fas fa-history"></i>
            Recent Learning Activity
          </h2>
          <div class="activity-timeline">
            <div *ngFor="let activity of progressDashboard?.recentActivity" class="activity-item">
              <div class="activity-time">
                {{activity.timestamp | date:'short'}}
              </div>
              <div class="activity-content">
                <div class="activity-type" [ngClass]="activity.actionType.toLowerCase()">
                  {{activity.actionType | titlecase}}
                </div>
                <div class="activity-details">
                  <span class="content-type">{{activity.contentType}}</span>
                  <span class="course-id">Course {{activity.courseId}}</span>
                  <span class="time-spent">{{activity.timeSpentMinutes}}min</span>
                </div>
                <div class="activity-progress" *ngIf="activity.progressPercentage">
                  Progress: {{activity.progressPercentage}}%
                </div>
              </div>
            </div>
          </div>
        </div>

      </div>
    </div>
  `,
  styles: [`
    .ai-learning-dashboard {
      padding: 20px;
      max-width: 1400px;
      margin: 0 auto;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
    }

    .dashboard-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 30px;
      background: rgba(255, 255, 255, 0.1);
      backdrop-filter: blur(10px);
      padding: 20px;
      border-radius: 15px;
      border: 1px solid rgba(255, 255, 255, 0.2);
    }

    .dashboard-title {
      color: white;
      font-size: 2.5rem;
      font-weight: 700;
      margin: 0;
      text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
    }

    .dashboard-title i {
      margin-right: 15px;
      color: #64ffda;
    }

    .dashboard-controls {
      display: flex;
      gap: 15px;
      align-items: center;
    }

    .time-range-selector {
      padding: 10px 15px;
      border-radius: 8px;
      border: none;
      background: rgba(255, 255, 255, 0.9);
      color: #333;
      font-weight: 500;
    }

    .refresh-btn {
      padding: 10px 20px;
      background: #64ffda;
      color: #1a1a1a;
      border: none;
      border-radius: 8px;
      font-weight: 600;
      cursor: pointer;
      transition: transform 0.2s;
    }

    .refresh-btn:hover {
      transform: translateY(-2px);
    }

    .loading-state {
      text-align: center;
      padding: 60px 20px;
      color: white;
    }

    .spinner {
      width: 50px;
      height: 50px;
      border: 3px solid rgba(255, 255, 255, 0.3);
      border-top: 3px solid #64ffda;
      border-radius: 50%;
      animation: spin 1s linear infinite;
      margin: 0 auto 20px;
    }

    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }

    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
      gap: 20px;
      margin-bottom: 30px;
    }

    .stat-card {
      background: rgba(255, 255, 255, 0.95);
      padding: 25px;
      border-radius: 15px;
      display: flex;
      align-items: center;
      gap: 20px;
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
      border: 1px solid rgba(255, 255, 255, 0.2);
    }

    .stat-icon {
      width: 60px;
      height: 60px;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 1.5rem;
      color: white;
    }

    .completion-rate .stat-icon {
      background: linear-gradient(135deg, #11998e, #38ef7d);
    }

    .learning-streak .stat-icon {
      background: linear-gradient(135deg, #ff6b6b, #ffa726);
    }

    .study-time .stat-icon {
      background: linear-gradient(135deg, #667eea, #764ba2);
    }

    .ai-score .stat-icon {
      background: linear-gradient(135deg, #f093fb, #f5576c);
    }

    .stat-content h3 {
      font-size: 2rem;
      font-weight: 700;
      margin: 0 0 5px 0;
      color: #2c3e50;
    }

    .stat-content p {
      margin: 0 0 10px 0;
      color: #7f8c8d;
      font-weight: 500;
    }

    .stat-trend {
      font-size: 0.9rem;
      font-weight: 500;
      display: flex;
      align-items: center;
      gap: 5px;
    }

    .stat-trend.positive {
      color: #27ae60;
    }

    .stat-trend.neutral {
      color: #f39c12;
    }

    .stat-trend.negative {
      color: #e74c3c;
    }

    .ai-insights-panel {
      background: rgba(255, 255, 255, 0.95);
      padding: 30px;
      border-radius: 15px;
      margin-bottom: 30px;
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
    }

    .ai-insights-panel h2 {
      color: #2c3e50;
      margin-bottom: 20px;
      font-size: 1.8rem;
    }

    .ai-insights-panel h2 i {
      margin-right: 10px;
      color: #f39c12;
    }

    .insights-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
      gap: 20px;
    }

    .insight-card {
      padding: 20px;
      border-radius: 12px;
      border-left: 4px solid;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    }

    .insight-card.strength {
      background: #d5f4e6;
      border-left-color: #27ae60;
    }

    .insight-card.weakness {
      background: #ffeaa7;
      border-left-color: #f39c12;
    }

    .insight-card.recommendation {
      background: #e3f2fd;
      border-left-color: #3498db;
    }

    .insight-card.prediction {
      background: #f8d7da;
      border-left-color: #9b59b6;
    }

    .insight-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 15px;
    }

    .insight-type {
      font-weight: 700;
      text-transform: uppercase;
      font-size: 0.8rem;
      letter-spacing: 1px;
    }

    .confidence-score {
      background: rgba(0, 0, 0, 0.1);
      padding: 4px 8px;
      border-radius: 6px;
      font-size: 0.8rem;
      font-weight: 600;
    }

    .insight-content h4 {
      margin: 0 0 10px 0;
      color: #2c3e50;
    }

    .insight-text {
      margin-bottom: 15px;
      line-height: 1.6;
    }

    .actionable-recommendation {
      background: rgba(255, 255, 255, 0.7);
      padding: 15px;
      border-radius: 8px;
      margin-top: 10px;
    }

    .analytics-section {
      margin-bottom: 30px;
    }

    .analytics-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(450px, 1fr));
      gap: 20px;
    }

    .chart-card {
      background: rgba(255, 255, 255, 0.95);
      padding: 25px;
      border-radius: 15px;
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
    }

    .chart-card h3 {
      color: #2c3e50;
      margin-bottom: 20px;
      font-size: 1.3rem;
    }

    .chart-card canvas {
      margin-bottom: 15px;
    }

    .chart-insights {
      border-top: 1px solid #ecf0f1;
      padding-top: 15px;
      font-size: 0.9rem;
    }

    .chart-insights p {
      margin: 5px 0;
      color: #7f8c8d;
    }

    .recommendations-section {
      background: rgba(255, 255, 255, 0.95);
      padding: 30px;
      border-radius: 15px;
      margin-bottom: 30px;
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
    }

    .recommendations-section h2 {
      color: #2c3e50;
      margin-bottom: 20px;
      font-size: 1.8rem;
    }

    .recommendations-section h2 i {
      margin-right: 10px;
      color: #9b59b6;
    }

    .recommendations-filter {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
      margin-bottom: 25px;
    }

    .filter-btn {
      padding: 8px 16px;
      border: 2px solid #e9ecef;
      background: white;
      border-radius: 20px;
      cursor: pointer;
      transition: all 0.3s;
      font-weight: 500;
    }

    .filter-btn.active,
    .filter-btn:hover {
      background: #9b59b6;
      color: white;
      border-color: #9b59b6;
    }

    .recommendations-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
      gap: 20px;
    }

    .recommendation-card {
      border: 1px solid #e9ecef;
      border-radius: 12px;
      padding: 20px;
      background: white;
      transition: transform 0.3s, box-shadow 0.3s;
    }

    .recommendation-card:hover {
      transform: translateY(-5px);
      box-shadow: 0 12px 24px rgba(0, 0, 0, 0.15);
    }

    .recommendation-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 15px;
    }

    .recommendation-header h4 {
      margin: 0;
      color: #2c3e50;
      font-size: 1.2rem;
    }

    .recommendation-meta {
      display: flex;
      flex-direction: column;
      gap: 5px;
    }

    .confidence-badge {
      padding: 4px 8px;
      border-radius: 6px;
      font-size: 0.8rem;
      font-weight: 600;
      text-align: center;
    }

    .confidence-badge.high {
      background: #d5f4e6;
      color: #27ae60;
    }

    .confidence-badge.medium {
      background: #ffeaa7;
      color: #f39c12;
    }

    .confidence-badge.low {
      background: #ffe5e5;
      color: #e74c3c;
    }

    .priority-badge {
      padding: 4px 8px;
      border-radius: 6px;
      font-size: 0.8rem;
      font-weight: 600;
      text-align: center;
      text-transform: uppercase;
    }

    .priority-badge.high {
      background: #e74c3c;
      color: white;
    }

    .priority-badge.medium {
      background: #f39c12;
      color: white;
    }

    .priority-badge.low {
      background: #95a5a6;
      color: white;
    }

    .recommendation-content {
      margin-bottom: 20px;
    }

    .course-description {
      margin-bottom: 15px;
      line-height: 1.6;
      color: #7f8c8d;
    }

    .course-details {
      display: flex;
      gap: 15px;
      margin-bottom: 15px;
      font-size: 0.9rem;
    }

    .course-level,
    .course-duration,
    .course-rating {
      background: #ecf0f1;
      padding: 4px 8px;
      border-radius: 6px;
      color: #2c3e50;
      font-weight: 500;
    }

    .course-rating i {
      color: #f39c12;
      margin-right: 4px;
    }

    .recommendation-reason,
    .expected-benefit {
      margin-bottom: 15px;
    }

    .recommendation-reason strong,
    .expected-benefit strong {
      color: #2c3e50;
      display: block;
      margin-bottom: 5px;
    }

    .recommendation-reason p,
    .expected-benefit p {
      margin: 0;
      font-size: 0.9rem;
      line-height: 1.5;
      color: #7f8c8d;
    }

    .recommendation-actions {
      display: flex;
      gap: 10px;
    }

    .enroll-btn {
      flex: 1;
      padding: 12px;
      background: #9b59b6;
      color: white;
      border: none;
      border-radius: 8px;
      font-weight: 600;
      cursor: pointer;
      transition: background 0.3s;
    }

    .enroll-btn:hover {
      background: #8e44ad;
    }

    .wishlist-btn {
      padding: 12px;
      background: transparent;
      color: #9b59b6;
      border: 2px solid #9b59b6;
      border-radius: 8px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.3s;
    }

    .wishlist-btn:hover {
      background: #9b59b6;
      color: white;
    }

    .goals-section {
      margin-bottom: 30px;
    }

    .goals-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
      gap: 20px;
    }

    .goals-card,
    .milestones-card {
      background: rgba(255, 255, 255, 0.95);
      padding: 25px;
      border-radius: 15px;
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
    }

    .goals-card h3,
    .milestones-card h3 {
      color: #2c3e50;
      margin-bottom: 20px;
      font-size: 1.3rem;
    }

    .goals-card h3 i,
    .milestones-card h3 i {
      margin-right: 10px;
      color: #e67e22;
    }

    .goal-item {
      margin-bottom: 15px;
      padding: 15px;
      background: #f8f9fa;
      border-radius: 8px;
    }

    .goal-text {
      display: block;
      margin-bottom: 10px;
      font-weight: 500;
      color: #2c3e50;
    }

    .goal-progress {
      display: flex;
      align-items: center;
      gap: 10px;
    }

    .progress-bar {
      flex: 1;
      height: 8px;
      background: #e9ecef;
      border-radius: 4px;
      overflow: hidden;
    }

    .progress-fill {
      height: 100%;
      background: linear-gradient(90deg, #11998e, #38ef7d);
      transition: width 0.3s;
    }

    .progress-text {
      font-weight: 600;
      color: #2c3e50;
      font-size: 0.9rem;
    }

    .add-goal-btn {
      width: 100%;
      padding: 12px;
      background: transparent;
      color: #e67e22;
      border: 2px dashed #e67e22;
      border-radius: 8px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.3s;
    }

    .add-goal-btn:hover {
      background: #e67e22;
      color: white;
    }

    .milestone-item {
      display: flex;
      gap: 15px;
      margin-bottom: 15px;
      padding: 15px;
      background: #f8f9fa;
      border-radius: 8px;
    }

    .milestone-icon {
      width: 40px;
      height: 40px;
      background: linear-gradient(135deg, #f39c12, #e67e22);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
      font-size: 1.2rem;
    }

    .milestone-content h4 {
      margin: 0 0 5px 0;
      color: #2c3e50;
    }

    .milestone-content p {
      margin: 0 0 5px 0;
      color: #7f8c8d;
      font-size: 0.9rem;
    }

    .milestone-date {
      font-size: 0.8rem;
      color: #95a5a6;
    }

    .activity-section {
      background: rgba(255, 255, 255, 0.95);
      padding: 30px;
      border-radius: 15px;
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
    }

    .activity-section h2 {
      color: #2c3e50;
      margin-bottom: 25px;
      font-size: 1.8rem;
    }

    .activity-section h2 i {
      margin-right: 10px;
      color: #3498db;
    }

    .activity-timeline {
      max-height: 400px;
      overflow-y: auto;
    }

    .activity-item {
      display: flex;
      gap: 20px;
      margin-bottom: 15px;
      padding: 15px;
      background: #f8f9fa;
      border-radius: 8px;
      border-left: 4px solid #3498db;
    }

    .activity-time {
      min-width: 140px;
      font-weight: 600;
      color: #7f8c8d;
      font-size: 0.9rem;
    }

    .activity-content {
      flex: 1;
    }

    .activity-type {
      font-weight: 600;
      margin-bottom: 5px;
      text-transform: uppercase;
      font-size: 0.9rem;
    }

    .activity-type.completed {
      color: #27ae60;
    }

    .activity-type.started {
      color: #3498db;
    }

    .activity-type.paused {
      color: #f39c12;
    }

    .activity-details {
      display: flex;
      gap: 10px;
      margin-bottom: 5px;
      font-size: 0.8rem;
      color: #7f8c8d;
    }

    .activity-details span {
      background: rgba(0, 0, 0, 0.1);
      padding: 2px 6px;
      border-radius: 4px;
    }

    .activity-progress {
      font-size: 0.8rem;
      color: #27ae60;
      font-weight: 500;
    }

    @media (max-width: 768px) {
      .ai-learning-dashboard {
        padding: 15px;
      }

      .dashboard-header {
        flex-direction: column;
        gap: 15px;
        text-align: center;
      }

      .dashboard-title {
        font-size: 2rem;
      }

      .stats-grid {
        grid-template-columns: 1fr;
      }

      .analytics-grid {
        grid-template-columns: 1fr;
      }

      .recommendations-grid {
        grid-template-columns: 1fr;
      }

      .goals-grid {
        grid-template-columns: 1fr;
      }

      .activity-item {
        flex-direction: column;
        gap: 10px;
      }

      .activity-time {
        min-width: auto;
      }
    }
  `]
})
export class AiLearningDashboardComponent implements OnInit {
  userId!: number;
  selectedTimeRange: number = 30;
  loading: boolean = true;
  
  learningAnalytics: LearningAnalytics | null = null;
  courseRecommendations: CourseRecommendations | null = null;
  progressDashboard: ProgressDashboard | null = null;
  
  recommendationTypes: string[] = ['ALL', 'SKILL_PROGRESSION', 'INTEREST_BASED', 'COLLABORATIVE', 'PERFORMANCE_BASED', 'TRENDING'];
  selectedRecommendationType: string = 'ALL';
  filteredRecommendations: CourseRecommendation[] = [];

  constructor(
    private route: ActivatedRoute
  ) {}

  ngOnInit() {
    this.route.params.subscribe(params => {
      this.userId = +params['userId'] || 1;
      this.loadDashboardData();
    });
  }

  async loadDashboardData() {
    this.loading = true;
    
    try {
      // Simulate API calls with mock data
      await this.loadLearningAnalytics();
      await this.loadCourseRecommendations();
      await this.loadProgressDashboard();
      
      // Initialize charts after data is loaded
      setTimeout(() => {
        this.initializeCharts();
      }, 100);
      
    } catch (error) {
      console.error('Error loading dashboard data:', error);
    } finally {
      this.loading = false;
    }
  }

  async loadLearningAnalytics() {
    // Mock learning analytics data
    this.learningAnalytics = {
      learningMetrics: {
        totalStudyTime: 1250,
        averageSessionDuration: 45,
        completionRate: 78.5,
        skillMasteryLevel: 82.3,
        learningVelocity: 1.4,
        retentionRate: 85.7,
        engagementScore: 92
      },
      learningPatterns: {
        preferredLearningTime: ['14:00-16:00', '19:00-21:00'],
        optimalSessionDuration: 45,
        contentTypePreferences: new Map([
          ['video', 65],
          ['interactive', 25],
          ['text', 10]
        ]),
        difficultyProgression: [60, 70, 75, 82, 88],
        learningCurve: [40, 55, 68, 75, 82, 85]
      },
      knowledgeRetention: {
        shortTermRetention: 92.5,
        longTermRetention: 78.2,
        forgettingCurve: [100, 95, 85, 75, 70, 68],
        retentionByTopic: new Map([
          ['JavaScript', 85],
          ['React', 78],
          ['Node.js', 82]
        ]),
        reviewEffectiveness: 88.5
      },
      performanceInsights: {
        strengths: ['Problem Solving', 'Pattern Recognition', 'Code Quality'],
        improvementAreas: ['Time Management', 'Advanced Algorithms'],
        learningRecommendations: ['Focus on morning study sessions', 'Increase interactive content'],
        predictionAccuracy: 89.5,
        riskFactors: ['Session inconsistency during weekends']
      },
      engagementMetrics: {
        sessionConsistency: 85.5,
        interactionRate: 78.2,
        completionMomentum: 92.1,
        motivationLevel: 88.7,
        socialEngagement: 65.3
      }
    };
  }

  async loadCourseRecommendations() {
    // Mock course recommendations
    this.courseRecommendations = {
      userId: this.userId,
      generatedAt: new Date().toISOString(),
      recommendations: [
        {
          course: {
            id: 1,
            title: 'Advanced React Patterns',
            description: 'Master advanced React patterns including hooks, context, and performance optimization.',
            level: 'Advanced',
            estimatedHours: 25,
            rating: 4.8
          },
          recommendationType: 'SKILL_PROGRESSION',
          confidenceScore: 0.92,
          reason: 'Based on your strong JavaScript foundation and current React progress',
          expectedBenefit: 'Improve component architecture and application performance',
          priority: 'HIGH',
          metadata: {}
        },
        {
          course: {
            id: 2,
            title: 'Node.js Microservices',
            description: 'Build scalable microservices architecture with Node.js and Docker.',
            level: 'Intermediate',
            estimatedHours: 30,
            rating: 4.6
          },
          recommendationType: 'INTEREST_BASED',
          confidenceScore: 0.85,
          reason: 'Aligns with your backend development interests',
          expectedBenefit: 'Enable building distributed applications',
          priority: 'MEDIUM',
          metadata: {}
        },
        {
          course: {
            id: 3,
            title: 'Machine Learning Fundamentals',
            description: 'Introduction to machine learning concepts and practical applications.',
            level: 'Beginner',
            estimatedHours: 40,
            rating: 4.7
          },
          recommendationType: 'TRENDING',
          confidenceScore: 0.75,
          reason: 'Popular among learners with similar profiles',
          expectedBenefit: 'Expand into AI/ML domain',
          priority: 'LOW',
          metadata: {}
        }
      ],
      totalRecommendations: 3,
      insights: {
        recommendationTypeDistribution: new Map([
          ['SKILL_PROGRESSION', 1],
          ['INTEREST_BASED', 1],
          ['TRENDING', 1]
        ]),
        averageConfidence: 0.84,
        recommendedFocusAreas: ['Frontend Development', 'Backend Architecture', 'Emerging Technologies'],
        learningAdvice: ['Maintain consistent study schedule', 'Focus on practical projects', 'Join study groups']
      }
    };

    this.filteredRecommendations = this.courseRecommendations.recommendations;
  }

  async loadProgressDashboard() {
    // Mock progress dashboard data
    this.progressDashboard = {
      userId: this.userId,
      generatedAt: new Date().toISOString(),
      overallSummary: {
        totalCoursesEnrolled: 8,
        coursesCompleted: 5,
        completionRate: 62.5,
        totalTimeSpentHours: 125.5,
        currentLearningStreak: 7,
        thisWeekTimeHours: 12.5,
        activeGoals: 3
      },
      courseProgress: [],
      recentActivity: [
        {
          timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(),
          actionType: 'COMPLETED',
          contentType: 'VIDEO',
          courseId: 1,
          chapterId: 3,
          timeSpentMinutes: 25,
          progressPercentage: 15.5
        },
        {
          timestamp: new Date(Date.now() - 5 * 60 * 60 * 1000).toISOString(),
          actionType: 'STARTED',
          contentType: 'QUIZ',
          courseId: 2,
          chapterId: 1,
          timeSpentMinutes: 15,
          progressPercentage: 8.2
        }
      ],
      learningStreaks: {
        currentStreak: 7,
        longestStreak: 21,
        weekStreak: 5,
        streakMilestones: ['7-day streak', '14-day streak']
      },
      milestones: [
        {
          name: 'First Course Completed',
          achievedAt: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000).toISOString(),
          description: 'Completed your first course on the platform'
        },
        {
          name: '7-Day Learning Streak',
          achievedAt: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000).toISOString(),
          description: 'Maintained learning activity for 7 consecutive days'
        }
      ],
      performanceInsights: [
        {
          insightType: 'STRENGTH',
          skillArea: 'Time Management',
          confidenceScore: 0.85,
          insightText: 'You learn most effectively between 2-4 PM based on your activity patterns.',
          actionableRecommendation: 'Schedule your most challenging topics during your peak hours (2-4 PM) for optimal learning.'
        },
        {
          insightType: 'PREDICTION',
          skillArea: 'Overall Performance',
          confidenceScore: 0.78,
          insightText: 'Your performance has improved 15% over the last month, indicating strong learning momentum.',
          actionableRecommendation: 'Maintain your current study schedule and consider taking on more challenging content.'
        }
      ],
      timeAnalytics: {
        dailyAverageMinutes: 45,
        weeklyBreakdown: new Map([
          ['Monday', 60],
          ['Tuesday', 45],
          ['Wednesday', 30],
          ['Thursday', 75],
          ['Friday', 40],
          ['Saturday', 90],
          ['Sunday', 20]
        ]),
        peakLearningHours: ['14:00-16:00', '19:00-21:00'],
        timeByContentType: new Map([
          ['VIDEO', 60],
          ['TEXT', 25],
          ['QUIZ', 10],
          ['ASSIGNMENT', 5]
        ]),
        efficiencyScore: 85.5
      },
      goalTracking: {
        activeGoals: [
          'Complete Java Fundamentals',
          'Achieve 90% quiz average',
          'Study 5 hours this week'
        ],
        completionRate: 75.0,
        goalProgress: [
          'Java Fundamentals: 80% complete',
          'Quiz average: 88% (goal: 90%)',
          'Weekly study time: 4.2/5 hours'
        ]
      }
    };
  }

  initializeCharts() {
    this.createLearningPatternsChart();
    this.createRetentionChart();
    this.createPerformanceChart();
    this.createTimeAnalyticsChart();
  }

  createLearningPatternsChart() {
    const canvas = document.getElementById('learningPatternsChart') as HTMLCanvasElement;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    new Chart(ctx, {
      type: 'radar',
      data: {
        labels: ['Morning', 'Afternoon', 'Evening', 'Night', 'Weekend', 'Weekday'],
        datasets: [{
          label: 'Learning Effectiveness',
          data: [65, 95, 85, 45, 70, 90],
          backgroundColor: 'rgba(54, 162, 235, 0.2)',
          borderColor: 'rgba(54, 162, 235, 1)',
          borderWidth: 2,
          pointBackgroundColor: 'rgba(54, 162, 235, 1)'
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          r: {
            beginAtZero: true,
            max: 100
          }
        }
      }
    });
  }

  createRetentionChart() {
    const canvas = document.getElementById('retentionChart') as HTMLCanvasElement;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    new Chart(ctx, {
      type: 'line',
      data: {
        labels: ['Day 1', 'Day 3', 'Week 1', 'Week 2', 'Month 1', 'Month 3'],
        datasets: [{
          label: 'Knowledge Retention %',
          data: [100, 95, 85, 75, 70, 68],
          backgroundColor: 'rgba(255, 99, 132, 0.2)',
          borderColor: 'rgba(255, 99, 132, 1)',
          borderWidth: 2,
          fill: true,
          tension: 0.4
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          y: {
            beginAtZero: true,
            max: 100
          }
        }
      }
    });
  }

  createPerformanceChart() {
    const canvas = document.getElementById('performanceChart') as HTMLCanvasElement;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    new Chart(ctx, {
      type: 'line',
      data: {
        labels: ['Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5', 'Week 6'],
        datasets: [
          {
            label: 'Skill Mastery',
            data: [60, 70, 75, 82, 88, 92],
            backgroundColor: 'rgba(75, 192, 192, 0.2)',
            borderColor: 'rgba(75, 192, 192, 1)',
            borderWidth: 2,
            tension: 0.4
          },
          {
            label: 'Learning Velocity',
            data: [1.0, 1.1, 1.2, 1.4, 1.5, 1.6],
            backgroundColor: 'rgba(153, 102, 255, 0.2)',
            borderColor: 'rgba(153, 102, 255, 1)',
            borderWidth: 2,
            tension: 0.4,
            yAxisID: 'y1'
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          y: {
            type: 'linear',
            display: true,
            position: 'left',
            beginAtZero: true,
            max: 100
          },
          y1: {
            type: 'linear',
            display: true,
            position: 'right',
            beginAtZero: true,
            max: 2.0,
            grid: {
              drawOnChartArea: false
            }
          }
        }
      }
    });
  }

  createTimeAnalyticsChart() {
    const canvas = document.getElementById('timeAnalyticsChart') as HTMLCanvasElement;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    new Chart(ctx, {
      type: 'bar',
      data: {
        labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        datasets: [{
          label: 'Study Time (minutes)',
          data: [60, 45, 30, 75, 40, 90, 20],
          backgroundColor: [
            'rgba(255, 99, 132, 0.8)',
            'rgba(54, 162, 235, 0.8)',
            'rgba(255, 205, 86, 0.8)',
            'rgba(75, 192, 192, 0.8)',
            'rgba(153, 102, 255, 0.8)',
            'rgba(255, 159, 64, 0.8)',
            'rgba(199, 199, 199, 0.8)'
          ],
          borderColor: [
            'rgba(255, 99, 132, 1)',
            'rgba(54, 162, 235, 1)',
            'rgba(255, 205, 86, 1)',
            'rgba(75, 192, 192, 1)',
            'rgba(153, 102, 255, 1)',
            'rgba(255, 159, 64, 1)',
            'rgba(199, 199, 199, 1)'
          ],
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          y: {
            beginAtZero: true
          }
        }
      }
    });
  }

  refreshData() {
    this.loadDashboardData();
  }

  filterRecommendations(type: string) {
    this.selectedRecommendationType = type;
    if (type === 'ALL') {
      this.filteredRecommendations = this.courseRecommendations?.recommendations || [];
    } else {
      this.filteredRecommendations = this.courseRecommendations?.recommendations.filter(
        rec => rec.recommendationType === type
      ) || [];
    }
  }

  getConfidenceClass(score: number): string {
    if (score >= 0.8) return 'high';
    if (score >= 0.6) return 'medium';
    return 'low';
  }

  getStreakMessage(): string {
    const streak = this.progressDashboard?.learningStreaks?.currentStreak || 0;
    if (streak > 7) return 'Amazing consistency!';
    if (streak >= 3) return 'Good momentum!';
    return 'Build your streak!';
  }

  getPeakLearningTime(): string {
    return this.learningAnalytics?.learningPatterns?.preferredLearningTime?.join(', ') || 'Not determined';
  }

  getGoalProgress(goal: string): number {
    // Mock goal progress calculation
    const progressMap: { [key: string]: number } = {
      'Complete Java Fundamentals': 80,
      'Achieve 90% quiz average': 88,
      'Study 5 hours this week': 84
    };
    return progressMap[goal] || 0;
  }

  enrollInCourse(courseId: number) {
    console.log('Enrolling in course:', courseId);
    // Implement course enrollment logic
  }

  addToWishlist(courseId: number) {
    console.log('Adding to wishlist:', courseId);
    // Implement wishlist logic
  }

  addNewGoal() {
    console.log('Adding new goal');
    // Implement goal creation logic
  }
}