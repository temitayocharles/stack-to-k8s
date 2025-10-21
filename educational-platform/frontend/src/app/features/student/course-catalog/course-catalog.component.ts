import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatChipsModule } from '@angular/material/chips';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { MatSnackBarModule, MatSnackBar } from '@angular/material/snack-bar';
import { RouterModule } from '@angular/router';
import { CourseService } from '../../../core/services/course.service';
import { EnrollmentService } from '../../../core/services/enrollment.service';
import { AuthService } from '../../../core/services/auth.service';

// Temporary interface definitions until models are properly set up
interface Course {
  id: number;
  title: string;
  description: string;
  category: string;
  level: string;
  creditHours: number;
  price?: number;
  thumbnailUrl?: string;
  instructorName: string;
  instructorLastName: string;
  enrollmentCount: number;
  rating?: number;
  totalRatings: number;
  estimatedDurationHours?: number;
  lessonCount: number;
  startDate?: string;
  enrollmentDeadline?: string;
}

enum CourseCategory {
  TECHNOLOGY = 'TECHNOLOGY',
  BUSINESS = 'BUSINESS',
  DESIGN = 'DESIGN',
  SCIENCE = 'SCIENCE',
  MATHEMATICS = 'MATHEMATICS',
  LANGUAGE = 'LANGUAGE',
  HEALTH = 'HEALTH',
  ARTS = 'ARTS',
  CYBERSECURITY = 'CYBERSECURITY'
}

enum CourseLevel {
  BEGINNER = 'BEGINNER',
  INTERMEDIATE = 'INTERMEDIATE',
  ADVANCED = 'ADVANCED'
}

@Component({
  selector: 'app-course-catalog',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    RouterModule,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatChipsModule,
    MatProgressBarModule,
    MatPaginatorModule,
    MatSnackBarModule
  ],
  template: `
    <div class="catalog-container">
      <!-- Header -->
      <div class="catalog-header">
        <h1>Course Catalog</h1>
        <p class="header-subtitle">Discover and enroll in our comprehensive courses</p>
      </div>

      <!-- Search and Filters -->
      <div class="search-filters">
        <mat-form-field class="search-field" appearance="outline">
          <mat-label>Search courses</mat-label>
          <input matInput 
                 [(ngModel)]="searchTerm" 
                 (input)="onSearchChange()"
                 placeholder="Enter course title or keyword">
          <mat-icon matSuffix>search</mat-icon>
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Category</mat-label>
          <mat-select [(ngModel)]="selectedCategory" (selectionChange)="onFilterChange()">
            <mat-option value="">All Categories</mat-option>
            <mat-option *ngFor="let category of categories" [value]="category">
              {{ category | titlecase }}
            </mat-option>
          </mat-select>
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Level</mat-label>
          <mat-select [(ngModel)]="selectedLevel" (selectionChange)="onFilterChange()">
            <mat-option value="">All Levels</mat-option>
            <mat-option *ngFor="let level of levels" [value]="level">
              {{ level | titlecase }}
            </mat-option>
          </mat-select>
        </mat-form-field>

        <button mat-raised-button color="primary" (click)="clearFilters()">
          <mat-icon>clear</mat-icon>
          Clear Filters
        </button>
      </div>

      <!-- Featured Courses -->
      <div class="featured-section" *ngIf="featuredCourses.length > 0 && !searchTerm">
        <h2>Featured Courses</h2>
        <div class="featured-grid">
          <mat-card *ngFor="let course of featuredCourses" class="featured-course-card">
            <div class="course-image">
              <img [src]="course.thumbnailUrl || '/assets/default-course.jpg'" 
                   [alt]="course.title">
              <div class="featured-badge">
                <mat-icon>star</mat-icon>
                Featured
              </div>
            </div>
            <mat-card-header>
              <mat-card-title>{{ course.title }}</mat-card-title>
              <mat-card-subtitle>{{ course.instructorName }} {{ course.instructorLastName }}</mat-card-subtitle>
            </mat-card-header>
            <mat-card-content>
              <p class="course-description">{{ course.description | slice:0:150 }}...</p>
              
              <div class="course-metadata">
                <mat-chip-set>
                  <mat-chip [style.background-color]="getCategoryColor(course.category)">
                    {{ course.category | titlecase }}
                  </mat-chip>
                  <mat-chip>{{ course.level | titlecase }}</mat-chip>
                  <mat-chip>{{ course.creditHours }} Credits</mat-chip>
                </mat-chip-set>
              </div>

              <div class="course-stats">
                <div class="stat">
                  <mat-icon>people</mat-icon>
                  <span>{{ course.enrollmentCount }} students</span>
                </div>
                <div class="stat" *ngIf="course.rating">
                  <mat-icon>star</mat-icon>
                  <span>{{ course.rating | number:'1.1-1' }} ({{ course.totalRatings }})</span>
                </div>
                <div class="stat">
                  <mat-icon>schedule</mat-icon>
                  <span>{{ course.estimatedDurationHours }}h</span>
                </div>
              </div>

              <div class="course-price" *ngIf="course.price && course.price > 0">
                <span class="price">\${{ course.price | number:'1.2-2' }}</span>
              </div>
              <div class="course-price" *ngIf="!course.price || course.price === 0">
                <span class="price free">Free</span>
              </div>
            </mat-card-content>
            <mat-card-actions>
              <button mat-raised-button 
                      color="primary" 
                      [disabled]="isEnrolling[course.id] || enrollmentStatus[course.id]"
                      (click)="enrollInCourse(course)">
                <mat-icon *ngIf="enrollmentStatus[course.id]">check</mat-icon>
                <mat-icon *ngIf="isEnrolling[course.id]">hourglass_empty</mat-icon>
                {{ getEnrollButtonText(course) }}
              </button>
              <button mat-button routerLink="/courses/{{ course.id }}">
                View Details
              </button>
            </mat-card-actions>
          </mat-card>
        </div>
      </div>

      <!-- All Courses -->
      <div class="courses-section">
        <div class="section-header">
          <h2>{{ searchTerm ? 'Search Results' : 'All Courses' }}</h2>
          <div class="results-info">
            <span>{{ totalCourses }} courses found</span>
          </div>
        </div>

        <!-- Loading State -->
        <div *ngIf="loading" class="loading-container">
          <mat-progress-bar mode="indeterminate"></mat-progress-bar>
          <p>Loading courses...</p>
        </div>

        <!-- No Results -->
        <div *ngIf="!loading && courses.length === 0" class="no-results">
          <mat-icon>search_off</mat-icon>
          <h3>No courses found</h3>
          <p>Try adjusting your search criteria or browse our featured courses above.</p>
          <button mat-raised-button color="primary" (click)="clearFilters()">
            Clear Filters
          </button>
        </div>

        <!-- Courses Grid -->
        <div *ngIf="!loading && courses.length > 0" class="courses-grid">
          <mat-card *ngFor="let course of courses" class="course-card">
            <div class="course-image">
              <img [src]="course.thumbnailUrl || '/assets/default-course.jpg'" 
                   [alt]="course.title">
              <div class="course-level-badge" [class]="course.level.toLowerCase()">
                {{ course.level | titlecase }}
              </div>
            </div>
            
            <mat-card-header>
              <mat-card-title>{{ course.title }}</mat-card-title>
              <mat-card-subtitle>{{ course.instructorName }} {{ course.instructorLastName }}</mat-card-subtitle>
            </mat-card-header>
            
            <mat-card-content>
              <p class="course-description">{{ course.description | slice:0:120 }}...</p>
              
              <div class="course-metadata">
                <mat-chip-set>
                  <mat-chip [style.background-color]="getCategoryColor(course.category)">
                    {{ course.category | titlecase }}
                  </mat-chip>
                  <mat-chip>{{ course.creditHours }} Credits</mat-chip>
                </mat-chip-set>
              </div>

              <div class="course-stats">
                <div class="stat">
                  <mat-icon>people</mat-icon>
                  <span>{{ course.enrollmentCount }}</span>
                </div>
                <div class="stat" *ngIf="course.rating">
                  <mat-icon>star</mat-icon>
                  <span>{{ course.rating | number:'1.1-1' }}</span>
                </div>
                <div class="stat">
                  <mat-icon>schedule</mat-icon>
                  <span>{{ course.estimatedDurationHours }}h</span>
                </div>
                <div class="stat">
                  <mat-icon>book</mat-icon>
                  <span>{{ course.lessonCount }} lessons</span>
                </div>
              </div>

              <div class="course-dates" *ngIf="course.startDate">
                <div class="date-info">
                  <mat-icon>event</mat-icon>
                  <span>Starts: {{ course.startDate | date:'mediumDate' }}</span>
                </div>
                <div class="date-info" *ngIf="course.enrollmentDeadline">
                  <mat-icon>event_busy</mat-icon>
                  <span>Deadline: {{ course.enrollmentDeadline | date:'mediumDate' }}</span>
                </div>
              </div>

              <div class="course-price">
                <span class="price" *ngIf="course.price && course.price > 0">
                  \${{ course.price | number:'1.2-2' }}
                </span>
                <span class="price free" *ngIf="!course.price || course.price === 0">
                  Free
                </span>
              </div>
            </mat-card-content>
            
            <mat-card-actions>
              <button mat-raised-button 
                      color="primary" 
                      [disabled]="isEnrolling[course.id] || enrollmentStatus[course.id]"
                      (click)="enrollInCourse(course)">
                <mat-icon *ngIf="enrollmentStatus[course.id]">check</mat-icon>
                <mat-icon *ngIf="isEnrolling[course.id]">hourglass_empty</mat-icon>
                {{ getEnrollButtonText(course) }}
              </button>
              <button mat-button routerLink="/courses/{{ course.id }}">
                Details
              </button>
            </mat-card-actions>
          </mat-card>
        </div>

        <!-- Pagination -->
        <mat-paginator *ngIf="!loading && courses.length > 0"
                       [length]="totalCourses"
                       [pageSize]="pageSize"
                       [pageSizeOptions]="[12, 24, 48]"
                       [pageIndex]="currentPage"
                       (page)="onPageChange($event)"
                       showFirstLastButtons>
        </mat-paginator>
      </div>
    </div>
  `,
  styles: [`
    .catalog-container {
      max-width: 1400px;
      margin: 0 auto;
      padding: 2rem;
    }

    .catalog-header {
      text-align: center;
      margin-bottom: 3rem;
    }

    .catalog-header h1 {
      font-size: 2.5rem;
      font-weight: 600;
      margin: 0 0 1rem 0;
      color: #333;
    }

    .header-subtitle {
      font-size: 1.2rem;
      color: #666;
      margin: 0;
    }

    .search-filters {
      display: flex;
      gap: 1rem;
      margin-bottom: 3rem;
      flex-wrap: wrap;
      align-items: center;
    }

    .search-field {
      flex: 1;
      min-width: 300px;
    }

    .featured-section {
      margin-bottom: 4rem;
    }

    .featured-section h2 {
      font-size: 2rem;
      font-weight: 600;
      margin-bottom: 1.5rem;
      color: #333;
    }

    .featured-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
      gap: 2rem;
      margin-bottom: 2rem;
    }

    .featured-course-card {
      position: relative;
      transition: transform 0.3s ease, box-shadow 0.3s ease;
    }

    .featured-course-card:hover {
      transform: translateY(-4px);
      box-shadow: 0 8px 24px rgba(0,0,0,0.15);
    }

    .course-image {
      position: relative;
      height: 200px;
      overflow: hidden;
    }

    .course-image img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    .featured-badge {
      position: absolute;
      top: 1rem;
      right: 1rem;
      background: #ff6b35;
      color: white;
      padding: 0.5rem 1rem;
      border-radius: 20px;
      display: flex;
      align-items: center;
      gap: 0.5rem;
      font-size: 0.875rem;
      font-weight: 500;
    }

    .course-level-badge {
      position: absolute;
      top: 1rem;
      right: 1rem;
      padding: 0.25rem 0.75rem;
      border-radius: 12px;
      font-size: 0.75rem;
      font-weight: 500;
      color: white;
    }

    .course-level-badge.beginner { background: #4caf50; }
    .course-level-badge.intermediate { background: #ff9800; }
    .course-level-badge.advanced { background: #f44336; }

    .courses-section h2 {
      font-size: 1.75rem;
      font-weight: 600;
      margin-bottom: 1.5rem;
      color: #333;
    }

    .section-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 2rem;
    }

    .results-info {
      color: #666;
      font-size: 0.875rem;
    }

    .courses-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
      gap: 1.5rem;
      margin-bottom: 2rem;
    }

    .course-card {
      transition: transform 0.2s ease, box-shadow 0.2s ease;
      height: fit-content;
    }

    .course-card:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    }

    .course-card .course-image {
      height: 180px;
    }

    .course-description {
      color: #666;
      font-size: 0.875rem;
      line-height: 1.5;
      margin-bottom: 1rem;
    }

    .course-metadata {
      margin-bottom: 1rem;
    }

    .course-stats {
      display: flex;
      flex-wrap: wrap;
      gap: 1rem;
      margin-bottom: 1rem;
    }

    .stat {
      display: flex;
      align-items: center;
      gap: 0.25rem;
      font-size: 0.875rem;
      color: #666;
    }

    .stat mat-icon {
      font-size: 1rem;
      width: 1rem;
      height: 1rem;
    }

    .course-dates {
      margin-bottom: 1rem;
    }

    .date-info {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      font-size: 0.875rem;
      color: #666;
      margin-bottom: 0.25rem;
    }

    .date-info mat-icon {
      font-size: 1rem;
      width: 1rem;
      height: 1rem;
    }

    .course-price {
      margin-bottom: 1rem;
    }

    .price {
      font-size: 1.25rem;
      font-weight: 600;
      color: #2196f3;
    }

    .price.free {
      color: #4caf50;
    }

    .loading-container {
      text-align: center;
      padding: 3rem;
    }

    .loading-container p {
      margin-top: 1rem;
      color: #666;
    }

    .no-results {
      text-align: center;
      padding: 3rem;
    }

    .no-results mat-icon {
      font-size: 4rem;
      width: 4rem;
      height: 4rem;
      color: #ccc;
      margin-bottom: 1rem;
    }

    .no-results h3 {
      font-size: 1.5rem;
      margin-bottom: 1rem;
      color: #333;
    }

    .no-results p {
      color: #666;
      margin-bottom: 2rem;
    }

    @media (max-width: 768px) {
      .catalog-container {
        padding: 1rem;
      }

      .catalog-header h1 {
        font-size: 2rem;
      }

      .search-filters {
        flex-direction: column;
        align-items: stretch;
      }

      .search-field {
        min-width: auto;
      }

      .featured-grid,
      .courses-grid {
        grid-template-columns: 1fr;
      }

      .section-header {
        flex-direction: column;
        align-items: flex-start;
        gap: 1rem;
      }

      .course-stats {
        justify-content: space-between;
      }
    }
  `]
})
export class CourseCatalogComponent implements OnInit {
  courses: Course[] = [];
  featuredCourses: Course[] = [];
  loading = false;
  searchTerm = '';
  selectedCategory = '';
  selectedLevel = '';
  currentPage = 0;
  pageSize = 12;
  totalCourses = 0;
  
  enrollmentStatus: { [courseId: number]: boolean } = {};
  isEnrolling: { [courseId: number]: boolean } = {};

  categories = Object.values(CourseCategory);
  levels = Object.values(CourseLevel);

  private searchTimeout: any;

  constructor(
    private courseService: CourseService,
    private enrollmentService: EnrollmentService,
    private authService: AuthService,
    private snackBar: MatSnackBar
  ) {}

  ngOnInit(): void {
    this.loadFeaturedCourses();
    this.loadCourses();
  }

  loadFeaturedCourses(): void {
    this.courseService.getFeaturedCourses().subscribe({
      next: (courses) => {
        this.featuredCourses = courses;
        this.checkEnrollmentStatus(courses);
      },
      error: (error) => {
        console.error('Error loading featured courses:', error);
      }
    });
  }

  loadCourses(): void {
    this.loading = true;
    
    const params = {
      page: this.currentPage,
      size: this.pageSize,
      search: this.searchTerm,
      category: this.selectedCategory,
      level: this.selectedLevel
    };

    this.courseService.getCourses(params).subscribe({
      next: (response) => {
        this.courses = response.content;
        this.totalCourses = response.totalElements;
        this.checkEnrollmentStatus(this.courses);
        this.loading = false;
      },
      error: (error) => {
        console.error('Error loading courses:', error);
        this.loading = false;
        this.snackBar.open('Error loading courses', 'Close', { duration: 3000 });
      }
    });
  }

  onSearchChange(): void {
    clearTimeout(this.searchTimeout);
    this.searchTimeout = setTimeout(() => {
      this.currentPage = 0;
      this.loadCourses();
    }, 500);
  }

  onFilterChange(): void {
    this.currentPage = 0;
    this.loadCourses();
  }

  clearFilters(): void {
    this.searchTerm = '';
    this.selectedCategory = '';
    this.selectedLevel = '';
    this.currentPage = 0;
    this.loadCourses();
  }

  onPageChange(event: PageEvent): void {
    this.currentPage = event.pageIndex;
    this.pageSize = event.pageSize;
    this.loadCourses();
  }

  enrollInCourse(course: Course): void {
    if (!this.authService.isAuthenticated || !this.authService.isStudent) {
      this.snackBar.open('Please log in as a student to enroll', 'Close', { duration: 3000 });
      return;
    }

    this.isEnrolling[course.id] = true;

    this.enrollmentService.enrollInCourse(course.id).subscribe({
      next: () => {
        this.enrollmentStatus[course.id] = true;
        this.isEnrolling[course.id] = false;
        this.snackBar.open(`Successfully enrolled in ${course.title}`, 'Close', { duration: 3000 });
      },
      error: (error) => {
        this.isEnrolling[course.id] = false;
        const message = error.error?.message || 'Failed to enroll in course';
        this.snackBar.open(message, 'Close', { duration: 5000 });
      }
    });
  }

  getEnrollButtonText(course: Course): string {
    if (this.isEnrolling[course.id]) return 'Enrolling...';
    if (this.enrollmentStatus[course.id]) return 'Enrolled';
    return 'Enroll Now';
  }

  getCategoryColor(category: string): string {
    const colors: { [key: string]: string } = {
      'TECHNOLOGY': '#2196f3',
      'BUSINESS': '#4caf50',
      'DESIGN': '#e91e63',
      'SCIENCE': '#ff9800',
      'MATHEMATICS': '#9c27b0',
      'LANGUAGE': '#f44336',
      'HEALTH': '#00bcd4',
      'ARTS': '#ff5722',
      'CYBERSECURITY': '#795548'
    };
    return colors[category] || '#607d8b';
  }

  private checkEnrollmentStatus(courses: Course[]): void {
    if (!this.authService.isAuthenticated || !this.authService.isStudent) {
      return;
    }

    courses.forEach(course => {
      this.enrollmentService.isEnrolled(course.id).subscribe({
        next: (isEnrolled) => {
          this.enrollmentStatus[course.id] = isEnrolled;
        },
        error: (error) => {
          console.error(`Error checking enrollment for course ${course.id}:`, error);
        }
      });
    });
  }
}
