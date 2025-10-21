import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatGridListModule } from '@angular/material/grid-list';
import { RouterModule } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';
import { User } from '../../../shared/models/user.model';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    MatCardModule,
    MatIconModule,
    MatButtonModule,
    MatProgressBarModule,
    MatGridListModule
  ],
  template: `
    <div class="dashboard-container">
      <div class="dashboard-header">
        <h1>Welcome back, {{ currentUser?.firstName }}!</h1>
        <p class="header-subtitle">Here's what's happening in your learning journey</p>
      </div>

      <!-- Quick Stats -->
      <div class="stats-grid">
        <mat-card class="stat-card">
          <mat-card-content>
            <div class="stat-content">
              <mat-icon class="stat-icon enrolled">book</mat-icon>
              <div class="stat-details">
                <h3>5</h3>
                <p>Enrolled Courses</p>
              </div>
            </div>
          </mat-card-content>
        </mat-card>

        <mat-card class="stat-card">
          <mat-card-content>
            <div class="stat-content">
              <mat-icon class="stat-icon completed">check_circle</mat-icon>
              <div class="stat-details">
                <h3>2</h3>
                <p>Completed Courses</p>
              </div>
            </div>
          </mat-card-content>
        </mat-card>

        <mat-card class="stat-card">
          <mat-card-content>
            <div class="stat-content">
              <mat-icon class="stat-icon assignments">assignment</mat-icon>
              <div class="stat-details">
                <h3>8</h3>
                <p>Pending Assignments</p>
              </div>
            </div>
          </mat-card-content>
        </mat-card>

        <mat-card class="stat-card">
          <mat-card-content>
            <div class="stat-content">
              <mat-icon class="stat-icon grade">grade</mat-icon>
              <div class="stat-details">
                <h3>92%</h3>
                <p>Average Grade</p>
              </div>
            </div>
          </mat-card-content>
        </mat-card>
      </div>

      <!-- Current Courses -->
      <div class="section">
        <div class="section-header">
          <h2>Current Courses</h2>
          <button mat-button color="primary" routerLink="/catalog">
            <mat-icon>add</mat-icon>
            Browse Courses
          </button>
        </div>

        <div class="courses-grid">
          <mat-card class="course-card">
            <mat-card-header>
              <mat-card-title>Advanced Angular Development</mat-card-title>
              <mat-card-subtitle>Dr. Sarah Johnson</mat-card-subtitle>
            </mat-card-header>
            <mat-card-content>
              <div class="course-progress">
                <div class="progress-info">
                  <span>Progress: 75%</span>
                  <span>12/16 lessons</span>
                </div>
                <mat-progress-bar mode="determinate" [value]="75"></mat-progress-bar>
              </div>
              <p class="course-description">
                Master advanced Angular concepts including state management, performance optimization, and testing.
              </p>
            </mat-card-content>
            <mat-card-actions>
              <button mat-button color="primary">Continue Learning</button>
              <button mat-button>View Details</button>
            </mat-card-actions>
          </mat-card>

          <mat-card class="course-card">
            <mat-card-header>
              <mat-card-title>Database Design Fundamentals</mat-card-title>
              <mat-card-subtitle>Prof. Michael Chen</mat-card-subtitle>
            </mat-card-header>
            <mat-card-content>
              <div class="course-progress">
                <div class="progress-info">
                  <span>Progress: 45%</span>
                  <span>9/20 lessons</span>
                </div>
                <mat-progress-bar mode="determinate" [value]="45"></mat-progress-bar>
              </div>
              <p class="course-description">
                Learn the principles of database design, normalization, and query optimization.
              </p>
            </mat-card-content>
            <mat-card-actions>
              <button mat-button color="primary">Continue Learning</button>
              <button mat-button>View Details</button>
            </mat-card-actions>
          </mat-card>

          <mat-card class="course-card">
            <mat-card-header>
              <mat-card-title>Introduction to Machine Learning</mat-card-title>
              <mat-card-subtitle>Dr. Emily Rodriguez</mat-card-subtitle>
            </mat-card-header>
            <mat-card-content>
              <div class="course-progress">
                <div class="progress-info">
                  <span>Progress: 20%</span>
                  <span>3/15 lessons</span>
                </div>
                <mat-progress-bar mode="determinate" [value]="20"></mat-progress-bar>
              </div>
              <p class="course-description">
                Explore the fundamentals of machine learning algorithms and their practical applications.
              </p>
            </mat-card-content>
            <mat-card-actions>
              <button mat-button color="primary">Continue Learning</button>
              <button mat-button>View Details</button>
            </mat-card-actions>
          </mat-card>
        </div>
      </div>

      <!-- Recent Activity -->
      <div class="section">
        <div class="section-header">
          <h2>Recent Activity</h2>
          <button mat-button routerLink="/grades">View All</button>
        </div>

        <mat-card class="activity-card">
          <mat-card-content>
            <div class="activity-list">
              <div class="activity-item">
                <mat-icon class="activity-icon completed">check_circle</mat-icon>
                <div class="activity-details">
                  <h4>Completed Quiz: Angular Components</h4>
                  <p>Advanced Angular Development • Score: 95%</p>
                  <span class="activity-time">2 hours ago</span>
                </div>
              </div>

              <div class="activity-item">
                <mat-icon class="activity-icon assignment">assignment_turned_in</mat-icon>
                <div class="activity-details">
                  <h4>Submitted Assignment: Database Schema</h4>
                  <p>Database Design Fundamentals • Submitted on time</p>
                  <span class="activity-time">1 day ago</span>
                </div>
              </div>

              <div class="activity-item">
                <mat-icon class="activity-icon lesson">play_circle_filled</mat-icon>
                <div class="activity-details">
                  <h4>Completed Lesson: Neural Networks Basics</h4>
                  <p>Introduction to Machine Learning</p>
                  <span class="activity-time">2 days ago</span>
                </div>
              </div>

              <div class="activity-item">
                <mat-icon class="activity-icon grade">star</mat-icon>
                <div class="activity-details">
                  <h4>Received Grade: Final Project</h4>
                  <p>Web Development Basics • Grade: A (92%)</p>
                  <span class="activity-time">1 week ago</span>
                </div>
              </div>
            </div>
          </mat-card-content>
        </mat-card>
      </div>

      <!-- Upcoming Deadlines -->
      <div class="section">
        <div class="section-header">
          <h2>Upcoming Deadlines</h2>
          <button mat-button routerLink="/assignments">View All</button>
        </div>

        <mat-card class="deadlines-card">
          <mat-card-content>
            <div class="deadline-list">
              <div class="deadline-item urgent">
                <div class="deadline-date">
                  <span class="day">16</span>
                  <span class="month">Sep</span>
                </div>
                <div class="deadline-details">
                  <h4>Angular Final Project</h4>
                  <p>Advanced Angular Development</p>
                  <span class="deadline-status urgent">Due in 1 day</span>
                </div>
              </div>

              <div class="deadline-item">
                <div class="deadline-date">
                  <span class="day">20</span>
                  <span class="month">Sep</span>
                </div>
                <div class="deadline-details">
                  <h4>Database Normalization Quiz</h4>
                  <p>Database Design Fundamentals</p>
                  <span class="deadline-status">Due in 5 days</span>
                </div>
              </div>

              <div class="deadline-item">
                <div class="deadline-date">
                  <span class="day">25</span>
                  <span class="month">Sep</span>
                </div>
                <div class="deadline-details">
                  <h4>ML Algorithm Implementation</h4>
                  <p>Introduction to Machine Learning</p>
                  <span class="deadline-status">Due in 10 days</span>
                </div>
              </div>
            </div>
          </mat-card-content>
        </mat-card>
      </div>
    </div>
  `,
  styles: [`
    .dashboard-container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 2rem;
    }

    .dashboard-header {
      margin-bottom: 2rem;
    }

    .dashboard-header h1 {
      font-size: 2.5rem;
      font-weight: 600;
      margin: 0 0 0.5rem 0;
      color: #333;
    }

    .header-subtitle {
      font-size: 1.1rem;
      color: #666;
      margin: 0;
    }

    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 1.5rem;
      margin-bottom: 3rem;
    }

    .stat-card {
      transition: transform 0.2s ease, box-shadow 0.2s ease;
    }

    .stat-card:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    }

    .stat-content {
      display: flex;
      align-items: center;
      gap: 1rem;
    }

    .stat-icon {
      font-size: 2.5rem;
      width: 2.5rem;
      height: 2.5rem;
    }

    .stat-icon.enrolled { color: #2196f3; }
    .stat-icon.completed { color: #4caf50; }
    .stat-icon.assignments { color: #ff9800; }
    .stat-icon.grade { color: #9c27b0; }

    .stat-details h3 {
      font-size: 2rem;
      font-weight: 600;
      margin: 0;
      color: #333;
    }

    .stat-details p {
      margin: 0;
      color: #666;
      font-size: 0.875rem;
    }

    .section {
      margin-bottom: 3rem;
    }

    .section-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 1.5rem;
    }

    .section-header h2 {
      font-size: 1.75rem;
      font-weight: 600;
      margin: 0;
      color: #333;
    }

    .courses-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
      gap: 1.5rem;
    }

    .course-card {
      transition: transform 0.2s ease, box-shadow 0.2s ease;
    }

    .course-card:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    }

    .course-progress {
      margin: 1rem 0;
    }

    .progress-info {
      display: flex;
      justify-content: space-between;
      margin-bottom: 0.5rem;
      font-size: 0.875rem;
      color: #666;
    }

    .course-description {
      color: #666;
      font-size: 0.875rem;
      line-height: 1.5;
    }

    .activity-list, .deadline-list {
      display: flex;
      flex-direction: column;
      gap: 1rem;
    }

    .activity-item, .deadline-item {
      display: flex;
      align-items: center;
      gap: 1rem;
      padding: 1rem;
      border-radius: 8px;
      background: #f8f9fa;
    }

    .activity-icon {
      font-size: 1.5rem;
      width: 1.5rem;
      height: 1.5rem;
    }

    .activity-icon.completed { color: #4caf50; }
    .activity-icon.assignment { color: #2196f3; }
    .activity-icon.lesson { color: #ff9800; }
    .activity-icon.grade { color: #9c27b0; }

    .activity-details h4 {
      margin: 0 0 0.25rem 0;
      font-size: 1rem;
      color: #333;
    }

    .activity-details p {
      margin: 0 0 0.25rem 0;
      font-size: 0.875rem;
      color: #666;
    }

    .activity-time {
      font-size: 0.75rem;
      color: #999;
    }

    .deadline-date {
      display: flex;
      flex-direction: column;
      align-items: center;
      padding: 0.5rem;
      background: white;
      border-radius: 8px;
      border: 2px solid #e0e0e0;
      min-width: 60px;
    }

    .deadline-item.urgent .deadline-date {
      border-color: #f44336;
      background: #ffebee;
    }

    .deadline-date .day {
      font-size: 1.25rem;
      font-weight: 600;
      color: #333;
    }

    .deadline-date .month {
      font-size: 0.75rem;
      color: #666;
      text-transform: uppercase;
    }

    .deadline-details {
      flex: 1;
    }

    .deadline-details h4 {
      margin: 0 0 0.25rem 0;
      font-size: 1rem;
      color: #333;
    }

    .deadline-details p {
      margin: 0 0 0.25rem 0;
      font-size: 0.875rem;
      color: #666;
    }

    .deadline-status {
      font-size: 0.75rem;
      padding: 0.25rem 0.5rem;
      border-radius: 12px;
      background: #e3f2fd;
      color: #1976d2;
    }

    .deadline-status.urgent {
      background: #ffebee;
      color: #d32f2f;
    }

    @media (max-width: 768px) {
      .dashboard-container {
        padding: 1rem;
      }

      .dashboard-header h1 {
        font-size: 2rem;
      }

      .stats-grid {
        grid-template-columns: repeat(2, 1fr);
      }

      .courses-grid {
        grid-template-columns: 1fr;
      }

      .section-header {
        flex-direction: column;
        align-items: flex-start;
        gap: 1rem;
      }
    }

    @media (max-width: 480px) {
      .stats-grid {
        grid-template-columns: 1fr;
      }
    }
  `]
})
export class DashboardComponent implements OnInit {
  currentUser: User | null = null;

  constructor(private authService: AuthService) {}

  ngOnInit(): void {
    this.currentUser = this.authService.currentUserValue;
  }
}
