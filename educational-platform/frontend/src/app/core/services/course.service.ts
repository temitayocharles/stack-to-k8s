import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { Course, CourseCategory, CourseLevel } from '../../shared/models/course.model';

export interface CourseSearchParams {
  page?: number;
  size?: number;
  search?: string;
  category?: CourseCategory | string;
  level?: CourseLevel | string;
  minPrice?: number;
  maxPrice?: number;
  instructorId?: number;
  startDate?: string;
  endDate?: string;
  sortBy?: string;
  sortDirection?: 'ASC' | 'DESC';
}

export interface CourseCreateRequest {
  title: string;
  description: string;
  category: CourseCategory;
  level: CourseLevel;
  creditHours: number;
  price?: number;
  maxEnrollments?: number;
  prerequisiteIds?: number[];
  startDate?: string;
  endDate?: string;
  enrollmentDeadline?: string;
  thumbnailUrl?: string;
  syllabus?: string;
  learningObjectives?: string[];
  estimatedDurationHours?: number;
}

export interface CourseUpdateRequest extends Partial<CourseCreateRequest> {
  id: number;
}

export interface CourseStats {
  totalCourses: number;
  publishedCourses: number;
  draftCourses: number;
  totalEnrollments: number;
  averageRating: number;
  totalRevenue: number;
  coursesByCategory: Array<{
    category: string;
    count: number;
  }>;
  coursesByLevel: Array<{
    level: string;
    count: number;
  }>;
  monthlyEnrollments: Array<{
    month: string;
    enrollments: number;
    revenue: number;
  }>;
}

export interface CourseReview {
  id: number;
  studentId: number;
  studentName: string;
  rating: number;
  comment?: string;
  reviewDate: string;
  verified: boolean;
  helpful: number;
}

export interface LessonContent {
  id: number;
  title: string;
  description?: string;
  contentType: 'VIDEO' | 'TEXT' | 'QUIZ' | 'ASSIGNMENT' | 'RESOURCE';
  contentUrl?: string;
  duration?: number;
  sortOrder: number;
  completed?: boolean;
}

export interface CourseSection {
  id: number;
  title: string;
  description?: string;
  sortOrder: number;
  lessons: LessonContent[];
}

export interface DetailedCourse extends Course {
  sections: CourseSection[];
  reviews: CourseReview[];
  prerequisites: Course[];
  similarCourses: Course[];
  announcements: Array<{
    id: number;
    title: string;
    content: string;
    publishDate: string;
    priority: 'LOW' | 'MEDIUM' | 'HIGH';
  }>;
}

@Injectable({
  providedIn: 'root'
})
export class CourseService {
  private readonly apiUrl = `${environment.apiUrl}/api/courses`;

  constructor(private http: HttpClient) {}

  /**
   * Get paginated courses with filters
   */
  getCourses(params?: CourseSearchParams): Observable<{
    content: Course[];
    totalElements: number;
    totalPages: number;
    size: number;
    number: number;
  }> {
    let httpParams = new HttpParams();
    
    if (params) {
      Object.keys(params).forEach(key => {
        const value = (params as any)[key];
        if (value !== undefined && value !== null && value !== '') {
          httpParams = httpParams.set(key, value.toString());
        }
      });
    }

    return this.http.get<{
      content: Course[];
      totalElements: number;
      totalPages: number;
      size: number;
      number: number;
    }>(this.apiUrl, { params: httpParams });
  }

  /**
   * Get featured courses
   */
  getFeaturedCourses(): Observable<Course[]> {
    return this.http.get<Course[]>(`${this.apiUrl}/featured`);
  }

  /**
   * Get course by ID with detailed information
   */
  getCourseById(id: number): Observable<DetailedCourse> {
    return this.http.get<DetailedCourse>(`${this.apiUrl}/${id}`);
  }

  /**
   * Get basic course information by ID
   */
  getCourseBasicInfo(id: number): Observable<Course> {
    return this.http.get<Course>(`${this.apiUrl}/${id}/basic`);
  }

  /**
   * Search courses by title or description
   */
  searchCourses(query: string, params?: {
    page?: number;
    size?: number;
    category?: string;
    level?: string;
  }): Observable<{
    content: Course[];
    totalElements: number;
    totalPages: number;
  }> {
    let httpParams = new HttpParams().set('q', query);
    
    if (params) {
      Object.keys(params).forEach(key => {
        const value = (params as any)[key];
        if (value !== undefined && value !== null) {
          httpParams = httpParams.set(key, value.toString());
        }
      });
    }

    return this.http.get<{
      content: Course[];
      totalElements: number;
      totalPages: number;
    }>(`${this.apiUrl}/search`, { params: httpParams });
  }

  /**
   * Get courses by category
   */
  getCoursesByCategory(category: CourseCategory, params?: {
    page?: number;
    size?: number;
    level?: CourseLevel;
  }): Observable<{
    content: Course[];
    totalElements: number;
  }> {
    let httpParams = new HttpParams();
    
    if (params) {
      Object.keys(params).forEach(key => {
        const value = (params as any)[key];
        if (value !== undefined && value !== null) {
          httpParams = httpParams.set(key, value.toString());
        }
      });
    }

    return this.http.get<{
      content: Course[];
      totalElements: number;
    }>(`${this.apiUrl}/category/${category}`, { params: httpParams });
  }

  /**
   * Get courses by instructor
   */
  getCoursesByInstructor(instructorId: number): Observable<Course[]> {
    return this.http.get<Course[]>(`${this.apiUrl}/instructor/${instructorId}`);
  }

  /**
   * Get trending courses
   */
  getTrendingCourses(limit: number = 10): Observable<Course[]> {
    return this.http.get<Course[]>(`${this.apiUrl}/trending`, {
      params: { limit: limit.toString() }
    });
  }

  /**
   * Get recently added courses
   */
  getRecentCourses(limit: number = 10): Observable<Course[]> {
    return this.http.get<Course[]>(`${this.apiUrl}/recent`, {
      params: { limit: limit.toString() }
    });
  }

  /**
   * Get course recommendations for a user
   */
  getRecommendedCourses(): Observable<Course[]> {
    return this.http.get<Course[]>(`${this.apiUrl}/recommendations`);
  }

  /**
   * Get course statistics
   */
  getCourseStats(): Observable<CourseStats> {
    return this.http.get<CourseStats>(`${this.apiUrl}/stats`);
  }

  /**
   * Get course reviews with pagination
   */
  getCourseReviews(courseId: number, params?: {
    page?: number;
    size?: number;
    rating?: number;
  }): Observable<{
    content: CourseReview[];
    totalElements: number;
    averageRating: number;
    ratingDistribution: { [key: number]: number };
  }> {
    let httpParams = new HttpParams();
    
    if (params) {
      Object.keys(params).forEach(key => {
        const value = (params as any)[key];
        if (value !== undefined && value !== null) {
          httpParams = httpParams.set(key, value.toString());
        }
      });
    }

    return this.http.get<{
      content: CourseReview[];
      totalElements: number;
      averageRating: number;
      ratingDistribution: { [key: number]: number };
    }>(`${this.apiUrl}/${courseId}/reviews`, { params: httpParams });
  }

  /**
   * Get course content/curriculum
   */
  getCourseCurriculum(courseId: number): Observable<CourseSection[]> {
    return this.http.get<CourseSection[]>(`${this.apiUrl}/${courseId}/curriculum`);
  }

  /**
   * Get course prerequisites
   */
  getCoursePrerequisites(courseId: number): Observable<Course[]> {
    return this.http.get<Course[]>(`${this.apiUrl}/${courseId}/prerequisites`);
  }

  /**
   * Get similar courses
   */
  getSimilarCourses(courseId: number, limit: number = 5): Observable<Course[]> {
    return this.http.get<Course[]>(`${this.apiUrl}/${courseId}/similar`, {
      params: { limit: limit.toString() }
    });
  }

  /**
   * Get course enrollment statistics
   */
  getCourseEnrollmentStats(courseId: number): Observable<{
    totalEnrollments: number;
    activeEnrollments: number;
    completionRate: number;
    averageProgress: number;
    enrollmentTrend: Array<{
      date: string;
      enrollments: number;
    }>;
  }> {
    return this.http.get<{
      totalEnrollments: number;
      activeEnrollments: number;
      completionRate: number;
      averageProgress: number;
      enrollmentTrend: Array<{
        date: string;
        enrollments: number;
      }>;
    }>(`${this.apiUrl}/${courseId}/enrollment-stats`);
  }

  /**
   * Create a new course (instructor only)
   */
  createCourse(course: CourseCreateRequest): Observable<Course> {
    return this.http.post<Course>(this.apiUrl, course);
  }

  /**
   * Update a course (instructor only)
   */
  updateCourse(courseId: number, course: Partial<CourseUpdateRequest>): Observable<Course> {
    return this.http.put<Course>(`${this.apiUrl}/${courseId}`, course);
  }

  /**
   * Delete a course (instructor only)
   */
  deleteCourse(courseId: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${courseId}`);
  }

  /**
   * Publish a course (instructor only)
   */
  publishCourse(courseId: number): Observable<Course> {
    return this.http.put<Course>(`${this.apiUrl}/${courseId}/publish`, {});
  }

  /**
   * Unpublish a course (instructor only)
   */
  unpublishCourse(courseId: number): Observable<Course> {
    return this.http.put<Course>(`${this.apiUrl}/${courseId}/unpublish`, {});
  }

  /**
   * Get instructor's courses
   */
  getInstructorCourses(params?: {
    page?: number;
    size?: number;
    status?: 'PUBLISHED' | 'DRAFT';
  }): Observable<{
    content: Course[];
    totalElements: number;
  }> {
    let httpParams = new HttpParams();
    
    if (params) {
      Object.keys(params).forEach(key => {
        const value = (params as any)[key];
        if (value !== undefined && value !== null) {
          httpParams = httpParams.set(key, value.toString());
        }
      });
    }

    return this.http.get<{
      content: Course[];
      totalElements: number;
    }>(`${this.apiUrl}/my-courses`, { params: httpParams });
  }

  /**
   * Upload course thumbnail
   */
  uploadThumbnail(courseId: number, file: File): Observable<{ url: string }> {
    const formData = new FormData();
    formData.append('thumbnail', file);
    
    return this.http.post<{ url: string }>(`${this.apiUrl}/${courseId}/thumbnail`, formData);
  }

  /**
   * Get available course categories
   */
  getCategories(): Observable<CourseCategory[]> {
    return this.http.get<CourseCategory[]>(`${this.apiUrl}/categories`);
  }

  /**
   * Get available course levels
   */
  getLevels(): Observable<CourseLevel[]> {
    return this.http.get<CourseLevel[]>(`${this.apiUrl}/levels`);
  }

  /**
   * Get course analytics (instructor only)
   */
  getCourseAnalytics(courseId: number): Observable<{
    enrollmentStats: {
      total: number;
      thisMonth: number;
      growth: number;
    };
    completionStats: {
      completionRate: number;
      averageProgress: number;
      dropoutRate: number;
    };
    engagementStats: {
      averageTimeSpent: number;
      lessonsCompleted: number;
      quizAttempts: number;
    };
    revenueStats: {
      totalRevenue: number;
      thisMonth: number;
      averagePrice: number;
    };
    reviewStats: {
      averageRating: number;
      totalReviews: number;
      ratingTrend: Array<{
        month: string;
        rating: number;
      }>;
    };
  }> {
    return this.http.get<{
      enrollmentStats: {
        total: number;
        thisMonth: number;
        growth: number;
      };
      completionStats: {
        completionRate: number;
        averageProgress: number;
        dropoutRate: number;
      };
      engagementStats: {
        averageTimeSpent: number;
        lessonsCompleted: number;
        quizAttempts: number;
      };
      revenueStats: {
        totalRevenue: number;
        thisMonth: number;
        averagePrice: number;
      };
      reviewStats: {
        averageRating: number;
        totalReviews: number;
        ratingTrend: Array<{
          month: string;
          rating: number;
        }>;
      };
    }>(`${this.apiUrl}/${courseId}/analytics`);
  }

  /**
   * Export course data (instructor only)
   */
  exportCourseData(courseId: number, format: 'PDF' | 'EXCEL'): Observable<Blob> {
    return this.http.get(`${this.apiUrl}/${courseId}/export`, {
      params: { format },
      responseType: 'blob'
    });
  }
}
