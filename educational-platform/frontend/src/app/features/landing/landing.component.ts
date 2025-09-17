import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatCardModule } from '@angular/material/card';
import { MatGridListModule } from '@angular/material/grid-list';

@Component({
  selector: 'app-landing',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    MatButtonModule,
    MatIconModule,
    MatCardModule,
    MatGridListModule
  ],
  template: `
    <div class="landing-container">
      <!-- Hero Section -->
      <section class="hero-section">
        <div class="hero-content">
          <h1 class="hero-title">
            Welcome to EduPlatform
          </h1>
          <p class="hero-subtitle">
            Transform your learning experience with our comprehensive educational platform.
            Join thousands of students and instructors worldwide.
          </p>
          <div class="hero-actions">
            <button 
              mat-raised-button 
              color="primary" 
              class="cta-button"
              routerLink="/auth/register">
              Get Started
            </button>
            <button 
              mat-stroked-button 
              color="primary" 
              routerLink="/auth/login">
              Sign In
            </button>
          </div>
        </div>
        <div class="hero-image">
          <mat-icon class="hero-icon">school</mat-icon>
        </div>
      </section>

      <!-- Features Section -->
      <section class="features-section">
        <div class="section-header">
          <h2>Why Choose EduPlatform?</h2>
          <p>Discover the features that make learning effective and engaging</p>
        </div>
        
        <mat-grid-list cols="3" rowHeight="300px" gutterSize="24px" class="features-grid">
          <mat-grid-tile>
            <mat-card class="feature-card">
              <mat-card-header>
                <mat-icon mat-card-avatar color="primary">book</mat-icon>
                <mat-card-title>Interactive Courses</mat-card-title>
              </mat-card-header>
              <mat-card-content>
                <p>Engage with dynamic content including videos, quizzes, and interactive assignments designed to enhance your learning experience.</p>
              </mat-card-content>
            </mat-card>
          </mat-grid-tile>

          <mat-grid-tile>
            <mat-card class="feature-card">
              <mat-card-header>
                <mat-icon mat-card-avatar color="primary">people</mat-icon>
                <mat-card-title>Expert Instructors</mat-card-title>
              </mat-card-header>
              <mat-card-content>
                <p>Learn from industry professionals and experienced educators who are passionate about sharing their knowledge.</p>
              </mat-card-content>
            </mat-card>
          </mat-grid-tile>

          <mat-grid-tile>
            <mat-card class="feature-card">
              <mat-card-header>
                <mat-icon mat-card-avatar color="primary">analytics</mat-icon>
                <mat-card-title>Progress Tracking</mat-card-title>
              </mat-card-header>
              <mat-card-content>
                <p>Monitor your learning journey with detailed analytics, performance metrics, and personalized recommendations.</p>
              </mat-card-content>
            </mat-card>
          </mat-grid-tile>

          <mat-grid-tile>
            <mat-card class="feature-card">
              <mat-card-header>
                <mat-icon mat-card-avatar color="primary">schedule</mat-icon>
                <mat-card-title>Flexible Learning</mat-card-title>
              </mat-card-header>
              <mat-card-content>
                <p>Study at your own pace with 24/7 access to course materials and deadlines that work with your schedule.</p>
              </mat-card-content>
            </mat-card>
          </mat-grid-tile>

          <mat-grid-tile>
            <mat-card class="feature-card">
              <mat-card-header>
                <mat-icon mat-card-avatar color="primary">badge</mat-icon>
                <mat-card-title>Certificates</mat-card-title>
              </mat-card-header>
              <mat-card-content>
                <p>Earn recognized certificates upon course completion to showcase your skills and advance your career.</p>
              </mat-card-content>
            </mat-card>
          </mat-grid-tile>

          <mat-grid-tile>
            <mat-card class="feature-card">
              <mat-card-header>
                <mat-icon mat-card-avatar color="primary">support</mat-icon>
                <mat-card-title>24/7 Support</mat-card-title>
              </mat-card-header>
              <mat-card-content>
                <p>Get help whenever you need it with our dedicated support team and comprehensive help resources.</p>
              </mat-card-content>
            </mat-card>
          </mat-grid-tile>
        </mat-grid-list>
      </section>

      <!-- Statistics Section -->
      <section class="stats-section">
        <div class="stats-container">
          <div class="stat-item">
            <h3>10,000+</h3>
            <p>Students Enrolled</p>
          </div>
          <div class="stat-item">
            <h3>500+</h3>
            <p>Courses Available</p>
          </div>
          <div class="stat-item">
            <h3>200+</h3>
            <p>Expert Instructors</p>
          </div>
          <div class="stat-item">
            <h3>95%</h3>
            <p>Completion Rate</p>
          </div>
        </div>
      </section>

      <!-- CTA Section -->
      <section class="cta-section">
        <div class="cta-content">
          <h2>Ready to Start Learning?</h2>
          <p>Join our community of learners and take your skills to the next level</p>
          <button 
            mat-raised-button 
            color="accent" 
            size="large"
            routerLink="/auth/register">
            Start Your Journey Today
          </button>
        </div>
      </section>
    </div>
  `,
  styles: [`
    .landing-container {
      min-height: 100vh;
    }

    .hero-section {
      display: flex;
      align-items: center;
      min-height: 80vh;
      padding: 0 5%;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
    }

    .hero-content {
      flex: 1;
      max-width: 600px;
    }

    .hero-title {
      font-size: 3.5rem;
      font-weight: 700;
      margin-bottom: 1.5rem;
      line-height: 1.2;
    }

    .hero-subtitle {
      font-size: 1.25rem;
      margin-bottom: 2rem;
      opacity: 0.9;
      line-height: 1.6;
    }

    .hero-actions {
      display: flex;
      gap: 1rem;
      flex-wrap: wrap;
    }

    .cta-button {
      padding: 12px 24px;
      font-size: 1.1rem;
    }

    .hero-image {
      flex: 1;
      display: flex;
      justify-content: center;
      align-items: center;
    }

    .hero-icon {
      font-size: 300px;
      width: 300px;
      height: 300px;
      opacity: 0.3;
    }

    .features-section {
      padding: 80px 5%;
      background: #f8f9fa;
    }

    .section-header {
      text-align: center;
      margin-bottom: 3rem;
    }

    .section-header h2 {
      font-size: 2.5rem;
      margin-bottom: 1rem;
      color: #333;
    }

    .section-header p {
      font-size: 1.2rem;
      color: #666;
    }

    .features-grid {
      max-width: 1200px;
      margin: 0 auto;
    }

    .feature-card {
      height: 100%;
      display: flex;
      flex-direction: column;
      transition: transform 0.3s ease, box-shadow 0.3s ease;
    }

    .feature-card:hover {
      transform: translateY(-4px);
      box-shadow: 0 8px 24px rgba(0,0,0,0.15);
    }

    .stats-section {
      padding: 60px 5%;
      background: #3f51b5;
      color: white;
    }

    .stats-container {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 2rem;
      max-width: 1000px;
      margin: 0 auto;
      text-align: center;
    }

    .stat-item h3 {
      font-size: 3rem;
      margin-bottom: 0.5rem;
      font-weight: 700;
    }

    .stat-item p {
      font-size: 1.1rem;
      opacity: 0.9;
    }

    .cta-section {
      padding: 80px 5%;
      text-align: center;
      background: white;
    }

    .cta-content h2 {
      font-size: 2.5rem;
      margin-bottom: 1rem;
      color: #333;
    }

    .cta-content p {
      font-size: 1.2rem;
      margin-bottom: 2rem;
      color: #666;
    }

    @media (max-width: 768px) {
      .hero-section {
        flex-direction: column;
        text-align: center;
        padding: 2rem 5%;
      }

      .hero-title {
        font-size: 2.5rem;
      }

      .hero-icon {
        font-size: 200px;
        width: 200px;
        height: 200px;
      }

      .features-grid {
        grid-template-columns: 1fr;
      }

      .stats-container {
        grid-template-columns: repeat(2, 1fr);
      }
    }

    @media (max-width: 480px) {
      .hero-title {
        font-size: 2rem;
      }
      
      .stats-container {
        grid-template-columns: 1fr;
      }
    }
  `]
})
export class LandingComponent {}
