import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { NgChartsModule } from 'ng2-charts';
import { ChartData, ChartOptions, ChartType } from 'chart.js';

@Component({
  selector: 'app-ai-learning-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule, NgChartsModule],
  template: `
    <div class="ai-learning-dashboard">
      <h2 class="dashboard-title">🤖 AI-Powered Learning Analytics</h2>
      
      <!-- Learning Metrics Overview -->
      <div class="metrics-grid">
        <div class="metric-card">
          <h3>Total Learning Time</h3>
          <div class="metric-value">{{ learningMetrics.totalLearningTime || 0 }} hours</div>
        </div>
        <div class="metric-card">
          <h3>Courses Completed</h3>
          <div class="metric-value">{{ learningMetrics.coursesCompleted || 0 }}</div>
        </div>
        <div class="metric-card">
          <h3>Average Score</h3>
          <div class="metric-value">{{ learningMetrics.averageScore || 0 }}%</div>
        </div>
        <div class="metric-card">
          <h3>Learning Streak</h3>
          <div class="metric-value">{{ learningMetrics.streakDays || 0 }} days</div>
        </div>
      </div>

      <!-- Learning Patterns Chart -->
      <div class="chart-section">
        <h3>Learning Patterns Analysis</h3>
        <div class="chart-container">
          <canvas baseChart
                  [data]="learningPatternsChartData"
                  [options]="chartOptions"
                  [type]="'radar'">
          </canvas>
        </div>
      </div>

      <!-- Performance Trends -->
      <div class="chart-section">
        <h3>Performance Trends</h3>
        <div class="chart-container">
          <canvas baseChart
                  [data]="performanceTrendsData"
                  [options]="lineChartOptions"
                  [type]="'line'">
          </canvas>
        </div>
      </div>

      <!-- AI Insights -->
      <div class="insights-section">
        <h3>🎯 AI-Generated Insights</h3>
        <div class="insights-grid">
          <div class="insight-card strength">
            <h4>Strengths</h4>
            <ul>
              <li *ngFor="let strength of aiInsights.strengths">{{ strength }}</li>
            </ul>
          </div>
          <div class="insight-card improvement">
            <h4>Areas for Improvement</h4>
            <ul>
              <li *ngFor="let area of aiInsights.improvementAreas">{{ area }}</li>
            </ul>
          </div>
          <div class="insight-card recommendations">
            <h4>Personalized Recommendations</h4>
            <ul>
              <li *ngFor="let rec of aiInsights.recommendations">{{ rec }}</li>
            </ul>
          </div>
        </div>
      </div>

      <!-- Course Recommendations -->
      <div class="recommendations-section">
        <h3>📚 AI Course Recommendations</h3>
        <div class="recommendations-grid">
          <div class="recommendation-card" *ngFor="let course of courseRecommendations">
            <h4>{{ course.title }}</h4>
            <p class="category">{{ course.category }}</p>
            <div class="recommendation-score">
              <span class="score">{{ course.recommendationScore }}/10</span>
              <span class="reason">{{ course.reason }}</span>
            </div>
            <button class="enroll-btn">Enroll Now</button>
          </div>
        </div>
      </div>

      <!-- Time Analytics -->
      <div class="chart-section">
        <h3>Learning Time Distribution</h3>
        <div class="chart-container">
          <canvas baseChart
                  [data]="timeAnalyticsData"
                  [options]="barChartOptions"
                  [type]="'bar'">
          </canvas>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .ai-learning-dashboard {
      padding: 20px;
      max-width: 1200px;
      margin: 0 auto;
    }

    .dashboard-title {
      text-align: center;
      color: #2c3e50;
      margin-bottom: 30px;
      font-size: 2.5rem;
    }

    .metrics-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 20px;
      margin-bottom: 30px;
    }

    .metric-card {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      padding: 20px;
      border-radius: 10px;
      text-align: center;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    }

    .metric-card h3 {
      margin: 0 0 10px 0;
      font-size: 1rem;
      opacity: 0.9;
    }

    .metric-value {
      font-size: 2rem;
      font-weight: bold;
    }

    .chart-section {
      background: white;
      border-radius: 10px;
      padding: 20px;
      margin-bottom: 30px;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }

    .chart-section h3 {
      margin-top: 0;
      color: #2c3e50;
      border-bottom: 2px solid #3498db;
      padding-bottom: 10px;
    }

    .chart-container {
      position: relative;
      height: 400px;
      margin-top: 20px;
    }

    .insights-section {
      background: white;
      border-radius: 10px;
      padding: 20px;
      margin-bottom: 30px;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }

    .insights-section h3 {
      margin-top: 0;
      color: #2c3e50;
      border-bottom: 2px solid #e74c3c;
      padding-bottom: 10px;
    }

    .insights-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
      gap: 20px;
      margin-top: 20px;
    }

    .insight-card {
      padding: 20px;
      border-radius: 8px;
      border-left: 4px solid;
    }

    .insight-card.strength {
      background: #d5f4e6;
      border-left-color: #27ae60;
    }

    .insight-card.improvement {
      background: #fdeaa7;
      border-left-color: #f39c12;
    }

    .insight-card.recommendations {
      background: #e3f2fd;
      border-left-color: #3498db;
    }

    .insight-card h4 {
      margin-top: 0;
      color: #2c3e50;
    }

    .insight-card ul {
      list-style-type: none;
      padding: 0;
    }

    .insight-card li {
      padding: 5px 0;
      border-bottom: 1px solid rgba(0, 0, 0, 0.1);
    }

    .insight-card li:last-child {
      border-bottom: none;
    }

    .recommendations-section {
      background: white;
      border-radius: 10px;
      padding: 20px;
      margin-bottom: 30px;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }

    .recommendations-section h3 {
      margin-top: 0;
      color: #2c3e50;
      border-bottom: 2px solid #9b59b6;
      padding-bottom: 10px;
    }

    .recommendations-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
      gap: 20px;
      margin-top: 20px;
    }

    .recommendation-card {
      background: #f8f9fa;
      border: 1px solid #dee2e6;
      border-radius: 8px;
      padding: 20px;
      transition: transform 0.2s, box-shadow 0.2s;
    }

    .recommendation-card:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
    }

    .recommendation-card h4 {
      margin-top: 0;
      color: #2c3e50;
      font-size: 1.2rem;
    }

    .category {
      color: #7f8c8d;
      font-style: italic;
      margin-bottom: 10px;
    }

    .recommendation-score {
      margin-bottom: 15px;
    }

    .score {
      background: #3498db;
      color: white;
      padding: 4px 8px;
      border-radius: 4px;
      font-weight: bold;
      margin-right: 10px;
    }

    .reason {
      font-size: 0.9rem;
      color: #7f8c8d;
    }

    .enroll-btn {
      background: linear-gradient(135deg, #3498db, #2980b9);
      color: white;
      border: none;
      padding: 10px 20px;
      border-radius: 5px;
      cursor: pointer;
      font-weight: bold;
      transition: all 0.2s;
    }

    .enroll-btn:hover {
      background: linear-gradient(135deg, #2980b9, #1f639a);
      transform: translateY(-1px);
    }

    @media (max-width: 768px) {
      .metrics-grid,
      .insights-grid,
      .recommendations-grid {
        grid-template-columns: 1fr;
      }
      
      .dashboard-title {
        font-size: 2rem;
      }
      
      .chart-container {
        height: 300px;
      }
    }
  `]
})
export class AiLearningDashboardComponent implements OnInit {
  learningMetrics = {
    totalLearningTime: 120.5,
    coursesCompleted: 3,
    averageScore: 87.2,
    streakDays: 12
  };

  aiInsights = {
    strengths: [
      'Consistent study habits',
      'Strong problem-solving skills',
      'Good code quality',
      'Active participation in discussions'
    ],
    improvementAreas: [
      'Time management during assessments',
      'Documentation practices',
      'Test coverage in projects',
      'Algorithm optimization techniques'
    ],
    recommendations: [
      'Practice coding challenges daily for 30 minutes',
      'Join study groups for collaborative learning',
      'Focus on data structures and algorithms',
      'Take regular breaks to improve retention'
    ]
  };

  courseRecommendations = [
    {
      title: 'Advanced JavaScript Patterns',
      category: 'Programming',
      recommendationScore: 9.2,
      reason: 'Based on your strong JavaScript fundamentals'
    },
    {
      title: 'React Performance Optimization',
      category: 'Frontend Development',
      recommendationScore: 8.8,
      reason: 'Matches your current React learning path'
    },
    {
      title: 'Machine Learning Basics',
      category: 'Data Science',
      recommendationScore: 8.5,
      reason: 'Aligns with your mathematical strengths'
    },
    {
      title: 'System Design Fundamentals',
      category: 'Software Architecture',
      recommendationScore: 8.2,
      reason: 'Next step in your development journey'
    }
  ];

  // Chart data
  learningPatternsChartData: ChartData<'radar'> = {
    labels: ['Problem Solving', 'Code Quality', 'Consistency', 'Collaboration', 'Creativity', 'Speed'],
    datasets: [{
      label: 'Your Learning Pattern',
      data: [8.5, 9.2, 7.8, 8.9, 7.5, 6.8],
      backgroundColor: 'rgba(52, 152, 219, 0.2)',
      borderColor: 'rgba(52, 152, 219, 1)',
      borderWidth: 2,
      pointBackgroundColor: 'rgba(52, 152, 219, 1)',
      pointBorderColor: '#fff',
      pointHoverBackgroundColor: '#fff',
      pointHoverBorderColor: 'rgba(52, 152, 219, 1)'
    }]
  };

  performanceTrendsData: ChartData<'line'> = {
    labels: ['Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5', 'Week 6'],
    datasets: [{
      label: 'Average Score',
      data: [75, 78, 82, 85, 88, 87],
      borderColor: 'rgba(46, 204, 113, 1)',
      backgroundColor: 'rgba(46, 204, 113, 0.1)',
      borderWidth: 3,
      fill: true,
      tension: 0.4
    }]
  };

  timeAnalyticsData: ChartData<'bar'> = {
    labels: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
    datasets: [{
      label: 'Hours Studied',
      data: [2.5, 3.2, 2.8, 3.5, 2.2, 1.8, 2.1],
      backgroundColor: [
        'rgba(231, 76, 60, 0.7)',
        'rgba(52, 152, 219, 0.7)',
        'rgba(46, 204, 113, 0.7)',
        'rgba(241, 196, 15, 0.7)',
        'rgba(155, 89, 182, 0.7)',
        'rgba(230, 126, 34, 0.7)',
        'rgba(149, 165, 166, 0.7)'
      ],
      borderColor: [
        'rgba(231, 76, 60, 1)',
        'rgba(52, 152, 219, 1)',
        'rgba(46, 204, 113, 1)',
        'rgba(241, 196, 15, 1)',
        'rgba(155, 89, 182, 1)',
        'rgba(230, 126, 34, 1)',
        'rgba(149, 165, 166, 1)'
      ],
      borderWidth: 2
    }]
  };

  chartOptions: ChartOptions<'radar'> = {
    responsive: true,
    maintainAspectRatio: false,
    scales: {
      r: {
        angleLines: {
          display: false
        },
        suggestedMin: 0,
        suggestedMax: 10
      }
    },
    plugins: {
      legend: {
        position: 'top',
      },
      title: {
        display: true,
        text: 'Learning Pattern Analysis'
      }
    }
  };

  lineChartOptions: ChartOptions<'line'> = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'top',
      },
      title: {
        display: true,
        text: 'Performance Improvement Over Time'
      }
    },
    scales: {
      y: {
        beginAtZero: true,
        max: 100
      }
    }
  };

  barChartOptions: ChartOptions<'bar'> = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'top',
      },
      title: {
        display: true,
        text: 'Weekly Learning Time Distribution'
      }
    },
    scales: {
      y: {
        beginAtZero: true
      }
    }
  };

  ngOnInit() {
    this.loadLearningAnalytics();
  }

  loadLearningAnalytics() {
    // In a real application, this would call the API
    console.log('Loading AI learning analytics...');
    // Mock API call simulation
    setTimeout(() => {
      console.log('Learning analytics loaded successfully');
    }, 1000);
  }
}