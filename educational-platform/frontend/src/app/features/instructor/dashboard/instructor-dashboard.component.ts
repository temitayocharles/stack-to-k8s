import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTabsModule } from '@angular/material/tabs';
import { MatTableModule } from '@angular/material/table';
import { MatChipsModule } from '@angular/material/chips';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatMenuModule } from '@angular/material/menu';
import { MatBadgeModule } from '@angular/material/badge';
import { MatDividerModule } from '@angular/material/divider';
import { AuthService } from '../../../core/services/auth.service';

// Temporary interfaces
interface Course {
  id: number;
  title: string;
  description: string;
  category: string;
  level: string;
  enrollmentCount: number;
  status: string;
  rating?: number;
  revenue: number;
  completionRate: number;
  createdAt: string;
  lastActivity: string;
}

interface DashboardStats {
  totalCourses: number;
  totalStudents: number;
  totalRevenue: number;
  averageRating: number;
  publishedCourses: number;
  draftCourses: number;
  totalReviews: number;
  completionRate: number;
}

interface RecentActivity {
  id: number;
  type: 'ENROLLMENT' | 'COMPLETION' | 'REVIEW' | 'QUESTION';
  description: string;
  timestamp: string;
  courseTitle: string;
  studentName?: string;
  rating?: number;
}

interface MonthlyData {
  month: string;
  enrollments: number;
  revenue: number;
  completions: number;
}

@Component({
  selector: 'app-instructor-dashboard',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatTabsModule,
    MatTableModule,
    MatChipsModule,
    MatProgressBarModule,
    MatMenuModule,
    MatBadgeModule,
    MatDividerModule
  ],
  template: `
    <div class="dashboard-container">
      <!-- Header -->
      <div class="dashboard-header">
        <div class="header-content">
          <div class="welcome-section">
            <h1>Welcome back, {{ instructorName }}!</h1>
            <p class="subtitle">Here's what's happening with your courses today.</p>
          </div>
          <div class="quick-actions">
            <button mat-raised-button color="primary" routerLink="/instructor/courses/create">
              <mat-icon>add</mat-icon>
              Create Course
            </button>
            <button mat-stroked-button routerLink="/instructor/courses">
              <mat-icon>library_books</mat-icon>
              All Courses
            </button>
          </div>
        </div>
      </div>

      <!-- Stats Overview -->
      <div class="stats-grid">
        <mat-card class="stat-card">
          <mat-card-content>
            <div class="stat-content">
              <div class="stat-icon courses">
                <mat-icon>school</mat-icon>
              </div>
              <div class="stat-info">
                <div class="stat-value">{{ stats.totalCourses }}</div>
                <div class="stat-label">Total Courses</div>
                <div class="stat-breakdown">
                  {{ stats.publishedCourses }} published, {{ stats.draftCourses }} drafts
                </div>
              </div>
            </div>
          </mat-card-content>
        </mat-card>

        <mat-card class="stat-card">
          <mat-card-content>
            <div class="stat-content">
              <div class="stat-icon students">
                <mat-icon>people</mat-icon>
              </div>
              <div class="stat-info">
                <div class="stat-value">{{ stats.totalStudents | number }}</div>
                <div class="stat-label">Total Students</div>
                <div class="stat-breakdown">
                  Across all courses
                </div>
              </div>
            </div>
          </mat-card-content>
        </mat-card>

        <mat-card class="stat-card">
          <mat-card-content>
            <div class="stat-content">
              <div class="stat-icon revenue">
                <mat-icon>attach_money</mat-icon>
              </div>
              <div class="stat-info">
                <div class="stat-value">\${{ stats.totalRevenue | number:'1.0-0' }}</div>
                <div class="stat-label">Total Revenue</div>
                <div class="stat-breakdown">
                  This month: \${{ monthlyRevenue | number:'1.0-0' }}
                </div>
              </div>
            </div>
          </mat-card-content>
        </mat-card>

        <mat-card class="stat-card">
          <mat-card-content>
            <div class="stat-content">
              <div class="stat-icon rating">
                <mat-icon>star</mat-icon>
              </div>
              <div class="stat-info">
                <div class="stat-value">{{ stats.averageRating | number:'1.1-1' }}</div>
                <div class="stat-label">Average Rating</div>
                <div class="stat-breakdown">
                  {{ stats.totalReviews }} reviews
                </div>
              </div>
            </div>
          </mat-card-content>
        </mat-card>
      </div>

      <!-- Main Content -->
      <div class="main-content">
        <!-- Left Column -->
        <div class="left-column">
          <!-- Recent Activity -->
          <mat-card class="activity-card">
            <mat-card-header>
              <mat-card-title>Recent Activity</mat-card-title>
              <button mat-icon-button [matMenuTriggerFor]="activityMenu">
                <mat-icon>more_vert</mat-icon>
              </button>
              <mat-menu #activityMenu="matMenu">
                <button mat-menu-item>
                  <mat-icon>refresh</mat-icon>
                  Refresh
                </button>
                <button mat-menu-item>
                  <mat-icon>settings</mat-icon>
                  Settings
                </button>
              </mat-menu>
            </mat-card-header>
            <mat-card-content>
              <div class="activity-list">
                <div *ngFor="let activity of recentActivities; trackBy: trackActivity" 
                     class="activity-item">
                  <div class="activity-icon" [class]="activity.type.toLowerCase()">
                    <mat-icon>{{ getActivityIcon(activity.type) }}</mat-icon>
                  </div>
                  <div class="activity-content">
                    <div class="activity-description">{{ activity.description }}</div>
                    <div class="activity-meta">
                      <span class="course-name">{{ activity.courseTitle }}</span>
                      <span class="timestamp">{{ activity.timestamp | date:'short' }}</span>
                    </div>
                    <div *ngIf="activity.rating" class="activity-rating">
                      <mat-icon class="star-icon">star</mat-icon>
                      <span>{{ activity.rating }}/5</span>
                    </div>
                  </div>
                </div>
                
                <div *ngIf="recentActivities.length === 0" class="no-activity">
                  <mat-icon>notifications_none</mat-icon>
                  <p>No recent activity</p>
                </div>
              </div>
            </mat-card-content>
            <mat-card-actions>
              <button mat-button routerLink="/instructor/activity">
                View All Activity
              </button>
            </mat-card-actions>
          </mat-card>

          <!-- Course Performance -->
          <mat-card class="performance-card">
            <mat-card-header>
              <mat-card-title>Course Performance</mat-card-title>
            </mat-card-header>
            <mat-card-content>
              <div class="performance-chart">
                <!-- Monthly Trends Chart Placeholder -->
                <div class="chart-container">
                  <div class="chart-header">
                    <h4>Monthly Enrollments & Revenue</h4>
                  </div>
                  <div class="chart-placeholder">
                    <div class="chart-bars">
                      <div *ngFor="let data of monthlyData" class="chart-bar">
                        <div class="bar-enrollments" 
                             [style.height.%]="(data.enrollments / maxEnrollments) * 100">
                        </div>
                        <div class="bar-revenue" 
                             [style.height.%]="(data.revenue / maxRevenue) * 100">
                        </div>
                        <div class="bar-label">{{ data.month }}</div>
                      </div>
                    </div>
                    <div class="chart-legend">
                      <div class="legend-item">
                        <div class="legend-color enrollments"></div>
                        <span>Enrollments</span>
                      </div>
                      <div class="legend-item">
                        <div class="legend-color revenue"></div>
                        <span>Revenue (\$)</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </mat-card-content>
          </mat-card>
        </div>

        <!-- Right Column -->
        <div class="right-column">
          <!-- Top Performing Courses -->
          <mat-card class="top-courses-card">
            <mat-card-header>
              <mat-card-title>Top Performing Courses</mat-card-title>
            </mat-card-header>
            <mat-card-content>
              <div class="courses-list">
                <div *ngFor="let course of topCourses; let i = index" class="course-item">
                  <div class="course-rank">
                    <span class="rank-number">{{ i + 1 }}</span>
                  </div>
                  <div class="course-info">
                    <div class="course-title">{{ course.title }}</div>
                    <div class="course-stats">
                      <mat-chip-set>
                        <mat-chip class="enrollment-chip">
                          <mat-icon>people</mat-icon>
                          {{ course.enrollmentCount }} students
                        </mat-chip>
                        <mat-chip class="rating-chip" *ngIf="course.rating">
                          <mat-icon>star</mat-icon>
                          {{ course.rating | number:'1.1-1' }}
                        </mat-chip>
                        <mat-chip class="revenue-chip">
                          <mat-icon>attach_money</mat-icon>
                          {{ course.revenue | number:'1.0-0' }}
                        </mat-chip>
                      </mat-chip-set>
                    </div>
                    <div class="completion-rate">
                      <span class="label">Completion Rate:</span>
                      <mat-progress-bar 
                        mode="determinate" 
                        [value]="course.completionRate"
                        class="completion-bar">
                      </mat-progress-bar>
                      <span class="percentage">{{ course.completionRate }}%</span>
                    </div>
                  </div>
                  <div class="course-actions">
                    <button mat-icon-button [matMenuTriggerFor]="courseMenu">
                      <mat-icon>more_vert</mat-icon>
                    </button>
                    <mat-menu #courseMenu="matMenu">
                      <button mat-menu-item [routerLink]="['/courses', course.id]">
                        <mat-icon>visibility</mat-icon>
                        View Course
                      </button>
                      <button mat-menu-item [routerLink]="['/instructor/courses', course.id, 'edit']">
                        <mat-icon>edit</mat-icon>
                        Edit Course
                      </button>
                      <button mat-menu-item [routerLink]="['/instructor/courses', course.id, 'analytics']">
                        <mat-icon>analytics</mat-icon>
                        View Analytics
                      </button>
                    </mat-menu>
                  </div>
                </div>
              </div>
            </mat-card-content>
            <mat-card-actions>
              <button mat-button routerLink="/instructor/courses">
                View All Courses
              </button>
            </mat-card-actions>
          </mat-card>

          <!-- Quick Stats -->
          <mat-card class="quick-stats-card">
            <mat-card-header>
              <mat-card-title>Quick Stats</mat-card-title>
            </mat-card-header>
            <mat-card-content>
              <div class="quick-stats-grid">
                <div class="quick-stat">
                  <div class="stat-icon-small">
                    <mat-icon>trending_up</mat-icon>
                  </div>
                  <div class="stat-content-small">
                    <div class="stat-value-small">{{ stats.completionRate }}%</div>
                    <div class="stat-label-small">Avg. Completion Rate</div>
                  </div>
                </div>

                <div class="quick-stat">
                  <div class="stat-icon-small">
                    <mat-icon>schedule</mat-icon>
                  </div>
                  <div class="stat-content-small">
                    <div class="stat-value-small">{{ averageStudyTime }}h</div>
                    <div class="stat-label-small">Avg. Study Time</div>
                  </div>
                </div>

                <div class="quick-stat">
                  <div class="stat-icon-small">
                    <mat-icon>feedback</mat-icon>
                  </div>
                  <div class="stat-content-small">
                    <div class="stat-value-small">{{ pendingReviews }}</div>
                    <div class="stat-label-small">Pending Reviews</div>
                  </div>
                </div>

                <div class="quick-stat">
                  <div class="stat-icon-small">
                    <mat-icon>help_outline</mat-icon>
                  </div>
                  <div class="stat-content-small">
                    <div class="stat-value-small">{{ pendingQuestions }}</div>
                    <div class="stat-label-small">Pending Questions</div>
                  </div>
                </div>
              </div>
            </mat-card-content>
          </mat-card>

          <!-- Action Items -->
          <mat-card class="action-items-card">
            <mat-card-header>
              <mat-card-title>
                Action Items
                <mat-icon matBadge="{{ actionItems.length }}" matBadgeColor="warn" 
                          *ngIf="actionItems.length > 0">
                  notification_important
                </mat-icon>
              </mat-card-title>
            </mat-card-header>
            <mat-card-content>
              <div class="action-items-list">
                <div *ngFor="let item of actionItems" class="action-item">
                  <div class="action-icon" [class]="item.priority.toLowerCase()">
                    <mat-icon>{{ getActionIcon(item.type) }}</mat-icon>
                  </div>
                  <div class="action-content">
                    <div class="action-title">{{ item.title }}</div>
                    <div class="action-description">{{ item.description }}</div>
                    <div class="action-meta">
                      <span class="priority" [class]="item.priority.toLowerCase()">
                        {{ item.priority }}
                      </span>
                      <span class="due-date">Due: {{ item.dueDate | date:'mediumDate' }}</span>
                    </div>
                  </div>
                  <div class="action-actions">
                    <button mat-icon-button color="primary" (click)="handleAction(item)">
                      <mat-icon>arrow_forward</mat-icon>
                    </button>
                  </div>
                </div>

                <div *ngIf="actionItems.length === 0" class="no-actions">
                  <mat-icon>check_circle</mat-icon>
                  <p>All caught up! No pending actions.</p>
                </div>
              </div>
            </mat-card-content>
          </mat-card>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .dashboard-container {
      max-width: 1400px;
      margin: 0 auto;
      padding: 2rem;
    }

    .dashboard-header {
      margin-bottom: 2rem;
    }

    .header-content {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      gap: 2rem;
    }

    .welcome-section h1 {
      font-size: 2rem;
      font-weight: 600;
      margin: 0 0 0.5rem 0;
      color: #333;
    }

    .subtitle {
      color: #666;
      font-size: 1.1rem;
      margin: 0;
    }

    .quick-actions {
      display: flex;
      gap: 1rem;
    }

    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 1.5rem;
      margin-bottom: 2rem;
    }

    .stat-card {
      transition: transform 0.2s ease;
    }

    .stat-card:hover {
      transform: translateY(-2px);
    }

    .stat-content {
      display: flex;
      align-items: center;
      gap: 1rem;
    }

    .stat-icon {
      width: 60px;
      height: 60px;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
    }

    .stat-icon.courses { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
    .stat-icon.students { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); }
    .stat-icon.revenue { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); }
    .stat-icon.rating { background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%); }

    .stat-icon mat-icon {
      font-size: 2rem;
      width: 2rem;
      height: 2rem;
    }

    .stat-value {
      font-size: 2rem;
      font-weight: 700;
      color: #333;
      line-height: 1;
    }

    .stat-label {
      font-size: 0.875rem;
      font-weight: 500;
      color: #666;
      margin-bottom: 0.25rem;
    }

    .stat-breakdown {
      font-size: 0.75rem;
      color: #999;
    }

    .main-content {
      display: grid;
      grid-template-columns: 1fr 400px;
      gap: 2rem;
    }

    .activity-card,
    .performance-card,
    .top-courses-card,
    .quick-stats-card,
    .action-items-card {
      margin-bottom: 1.5rem;
    }

    .activity-list {
      max-height: 400px;
      overflow-y: auto;
    }

    .activity-item {
      display: flex;
      align-items: flex-start;
      gap: 1rem;
      padding: 1rem 0;
      border-bottom: 1px solid #f0f0f0;
    }

    .activity-item:last-child {
      border-bottom: none;
    }

    .activity-icon {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
      font-size: 1.2rem;
    }

    .activity-icon.enrollment { background: #2196f3; }
    .activity-icon.completion { background: #4caf50; }
    .activity-icon.review { background: #ff9800; }
    .activity-icon.question { background: #9c27b0; }

    .activity-description {
      font-weight: 500;
      margin-bottom: 0.25rem;
    }

    .activity-meta {
      display: flex;
      gap: 1rem;
      font-size: 0.875rem;
      color: #666;
    }

    .activity-rating {
      display: flex;
      align-items: center;
      gap: 0.25rem;
      margin-top: 0.25rem;
      font-size: 0.875rem;
      color: #ff9800;
    }

    .star-icon {
      font-size: 1rem;
      width: 1rem;
      height: 1rem;
    }

    .no-activity {
      text-align: center;
      padding: 2rem;
      color: #999;
    }

    .no-activity mat-icon {
      font-size: 3rem;
      width: 3rem;
      height: 3rem;
      margin-bottom: 1rem;
    }

    .chart-container {
      padding: 1rem 0;
    }

    .chart-header h4 {
      margin: 0 0 1rem 0;
      color: #333;
    }

    .chart-bars {
      display: flex;
      align-items: flex-end;
      justify-content: space-between;
      height: 200px;
      margin-bottom: 1rem;
      gap: 0.5rem;
    }

    .chart-bar {
      flex: 1;
      display: flex;
      flex-direction: column;
      align-items: center;
      position: relative;
    }

    .bar-enrollments,
    .bar-revenue {
      width: 20px;
      min-height: 10px;
      margin: 2px;
    }

    .bar-enrollments { background: #2196f3; }
    .bar-revenue { background: #4caf50; }

    .bar-label {
      font-size: 0.75rem;
      margin-top: 0.5rem;
      color: #666;
    }

    .chart-legend {
      display: flex;
      justify-content: center;
      gap: 1rem;
    }

    .legend-item {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      font-size: 0.875rem;
    }

    .legend-color {
      width: 16px;
      height: 16px;
      border-radius: 2px;
    }

    .legend-color.enrollments { background: #2196f3; }
    .legend-color.revenue { background: #4caf50; }

    .courses-list {
      max-height: 400px;
      overflow-y: auto;
    }

    .course-item {
      display: flex;
      align-items: center;
      gap: 1rem;
      padding: 1rem 0;
      border-bottom: 1px solid #f0f0f0;
    }

    .course-item:last-child {
      border-bottom: none;
    }

    .course-rank {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      background: #f5f5f5;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 700;
      color: #666;
    }

    .rank-number {
      font-size: 1.2rem;
    }

    .course-info {
      flex: 1;
    }

    .course-title {
      font-weight: 600;
      margin-bottom: 0.5rem;
      color: #333;
    }

    .course-stats {
      margin-bottom: 0.5rem;
    }

    .enrollment-chip,
    .rating-chip,
    .revenue-chip {
      font-size: 0.75rem;
      height: auto;
      padding: 0.25rem 0.5rem;
    }

    .completion-rate {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      font-size: 0.875rem;
    }

    .completion-bar {
      flex: 1;
      height: 8px;
      border-radius: 4px;
    }

    .percentage {
      min-width: 40px;
      text-align: right;
      font-weight: 500;
    }

    .quick-stats-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 1rem;
    }

    .quick-stat {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      padding: 0.75rem;
      background: #f9f9f9;
      border-radius: 8px;
    }

    .stat-icon-small {
      width: 40px;
      height: 40px;
      border-radius: 8px;
      background: #2196f3;
      color: white;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .stat-value-small {
      font-size: 1.2rem;
      font-weight: 600;
      color: #333;
    }

    .stat-label-small {
      font-size: 0.75rem;
      color: #666;
    }

    .action-items-list {
      max-height: 300px;
      overflow-y: auto;
    }

    .action-item {
      display: flex;
      align-items: center;
      gap: 1rem;
      padding: 1rem 0;
      border-bottom: 1px solid #f0f0f0;
    }

    .action-item:last-child {
      border-bottom: none;
    }

    .action-icon {
      width: 40px;
      height: 40px;
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
    }

    .action-icon.high { background: #f44336; }
    .action-icon.medium { background: #ff9800; }
    .action-icon.low { background: #4caf50; }

    .action-content {
      flex: 1;
    }

    .action-title {
      font-weight: 500;
      margin-bottom: 0.25rem;
    }

    .action-description {
      font-size: 0.875rem;
      color: #666;
      margin-bottom: 0.25rem;
    }

    .action-meta {
      display: flex;
      gap: 1rem;
      font-size: 0.75rem;
    }

    .priority {
      padding: 0.125rem 0.5rem;
      border-radius: 12px;
      font-weight: 500;
      text-transform: uppercase;
    }

    .priority.high {
      background: #ffebee;
      color: #c62828;
    }

    .priority.medium {
      background: #fff3e0;
      color: #e65100;
    }

    .priority.low {
      background: #e8f5e8;
      color: #2e7d32;
    }

    .no-actions {
      text-align: center;
      padding: 2rem;
      color: #4caf50;
    }

    .no-actions mat-icon {
      font-size: 3rem;
      width: 3rem;
      height: 3rem;
      margin-bottom: 1rem;
    }

    @media (max-width: 1200px) {
      .main-content {
        grid-template-columns: 1fr;
      }
    }

    @media (max-width: 768px) {
      .dashboard-container {
        padding: 1rem;
      }

      .header-content {
        flex-direction: column;
        align-items: stretch;
      }

      .stats-grid {
        grid-template-columns: 1fr;
      }

      .quick-stats-grid {
        grid-template-columns: 1fr;
      }
    }
  `]
})
export class InstructorDashboardComponent implements OnInit {
  instructorName = '';
  
  stats: DashboardStats = {
    totalCourses: 0,
    totalStudents: 0,
    totalRevenue: 0,
    averageRating: 0,
    publishedCourses: 0,
    draftCourses: 0,
    totalReviews: 0,
    completionRate: 0
  };

  monthlyRevenue = 0;
  averageStudyTime = 0;
  pendingReviews = 0;
  pendingQuestions = 0;

  recentActivities: RecentActivity[] = [];
  topCourses: Course[] = [];
  monthlyData: MonthlyData[] = [];
  maxEnrollments = 1;
  maxRevenue = 1;

  actionItems: any[] = [];

  constructor(private authService: AuthService) {}

  ngOnInit(): void {
    this.loadInstructorData();
    this.loadDashboardStats();
    this.loadRecentActivity();
    this.loadTopCourses();
    this.loadMonthlyData();
    this.loadActionItems();
  }

  private loadInstructorData(): void {
    const user = this.authService.currentUserValue;
    if (user) {
      this.instructorName = `${user.firstName} ${user.lastName}`;
    }
  }

  private loadDashboardStats(): void {
    // Simulated data - replace with actual service calls
    this.stats = {
      totalCourses: 12,
      totalStudents: 1847,
      totalRevenue: 45670,
      averageRating: 4.7,
      publishedCourses: 10,
      draftCourses: 2,
      totalReviews: 342,
      completionRate: 78
    };

    this.monthlyRevenue = 3420;
    this.averageStudyTime = 24;
    this.pendingReviews = 8;
    this.pendingQuestions = 15;
  }

  private loadRecentActivity(): void {
    // Simulated data
    this.recentActivities = [
      {
        id: 1,
        type: 'ENROLLMENT',
        description: 'New student enrolled',
        timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(),
        courseTitle: 'Advanced Web Development',
        studentName: 'John Doe'
      },
      {
        id: 2,
        type: 'REVIEW',
        description: 'Received a new review',
        timestamp: new Date(Date.now() - 4 * 60 * 60 * 1000).toISOString(),
        courseTitle: 'React Fundamentals',
        studentName: 'Jane Smith',
        rating: 5
      },
      {
        id: 3,
        type: 'COMPLETION',
        description: 'Student completed course',
        timestamp: new Date(Date.now() - 6 * 60 * 60 * 1000).toISOString(),
        courseTitle: 'JavaScript Basics',
        studentName: 'Mike Johnson'
      }
    ];
  }

  private loadTopCourses(): void {
    // Simulated data
    this.topCourses = [
      {
        id: 1,
        title: 'Advanced Web Development',
        description: 'Complete guide to modern web development',
        category: 'TECHNOLOGY',
        level: 'ADVANCED',
        enrollmentCount: 342,
        status: 'PUBLISHED',
        rating: 4.8,
        revenue: 15400,
        completionRate: 85,
        createdAt: '2024-01-15',
        lastActivity: '2024-03-15'
      },
      {
        id: 2,
        title: 'React Fundamentals',
        description: 'Learn React from scratch',
        category: 'TECHNOLOGY',
        level: 'INTERMEDIATE',
        enrollmentCount: 287,
        status: 'PUBLISHED',
        rating: 4.6,
        revenue: 12200,
        completionRate: 78,
        createdAt: '2024-02-01',
        lastActivity: '2024-03-14'
      }
    ];
  }

  private loadMonthlyData(): void {
    // Simulated data
    this.monthlyData = [
      { month: 'Jan', enrollments: 45, revenue: 2100, completions: 32 },
      { month: 'Feb', enrollments: 62, revenue: 2800, completions: 48 },
      { month: 'Mar', enrollments: 78, revenue: 3400, completions: 67 },
      { month: 'Apr', enrollments: 55, revenue: 2900, completions: 51 },
      { month: 'May', enrollments: 89, revenue: 4200, completions: 73 },
      { month: 'Jun', enrollments: 92, revenue: 4600, completions: 81 }
    ];

    this.maxEnrollments = Math.max(...this.monthlyData.map(d => d.enrollments));
    this.maxRevenue = Math.max(...this.monthlyData.map(d => d.revenue));
  }

  private loadActionItems(): void {
    // Simulated data
    this.actionItems = [
      {
        id: 1,
        type: 'REVIEW_RESPONSE',
        title: 'Respond to course reviews',
        description: '8 reviews waiting for instructor response',
        priority: 'HIGH',
        dueDate: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000)
      },
      {
        id: 2,
        type: 'CONTENT_UPDATE',
        title: 'Update course content',
        description: 'JavaScript Basics course needs content refresh',
        priority: 'MEDIUM',
        dueDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
      }
    ];
  }

  getActivityIcon(type: string): string {
    const icons: { [key: string]: string } = {
      'ENROLLMENT': 'person_add',
      'COMPLETION': 'check_circle',
      'REVIEW': 'star',
      'QUESTION': 'help_outline'
    };
    return icons[type] || 'notifications';
  }

  getActionIcon(type: string): string {
    const icons: { [key: string]: string } = {
      'REVIEW_RESPONSE': 'reply',
      'CONTENT_UPDATE': 'edit',
      'ASSIGNMENT_GRADE': 'grade',
      'QUESTION_ANSWER': 'question_answer'
    };
    return icons[type] || 'task';
  }

  trackActivity(index: number, activity: RecentActivity): number {
    return activity.id;
  }

  handleAction(item: any): void {
    // Handle action item click
    console.log('Handling action:', item);
  }
}
