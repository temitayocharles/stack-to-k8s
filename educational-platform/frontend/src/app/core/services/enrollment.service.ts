import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface EnrollmentRequest {
  courseId: number;
}

export interface EnrollmentResponse {
  id: number;
  courseId: number;
  studentId: number;
  enrollmentDate: string;
  status: EnrollmentStatus;
  progress: number;
  grade?: number;
  completionDate?: string;
  courseName: string;
  instructorName: string;
  creditHours: number;
}

export interface EnrollmentStats {
  totalEnrollments: number;
  activeEnrollments: number;
  completedEnrollments: number;
  averageProgress: number;
  totalCreditsEarned: number;
}

export interface ProgressUpdate {
  lessonId: number;
  completed: boolean;
  timeSpent?: number;
}

export enum EnrollmentStatus {
  ENROLLED = 'ENROLLED',
  IN_PROGRESS = 'IN_PROGRESS',
  COMPLETED = 'COMPLETED',
  DROPPED = 'DROPPED',
  SUSPENDED = 'SUSPENDED'
}

@Injectable({
  providedIn: 'root'
})
export class EnrollmentService {
  private readonly apiUrl = `${environment.apiUrl}/api/enrollments`;

  constructor(private http: HttpClient) {}

  /**
   * Enroll in a course
   */
  enrollInCourse(courseId: number): Observable<EnrollmentResponse> {
    return this.http.post<EnrollmentResponse>(`${this.apiUrl}/enroll`, { courseId });
  }

  /**
   * Get student's enrollments with pagination and filtering
   */
  getMyEnrollments(params?: {
    page?: number;
    size?: number;
    status?: EnrollmentStatus;
    search?: string;
  }): Observable<{
    content: EnrollmentResponse[];
    totalElements: number;
    totalPages: number;
    size: number;
    number: number;
  }> {
    let httpParams = new HttpParams();
    
    if (params?.page !== undefined) {
      httpParams = httpParams.set('page', params.page.toString());
    }
    if (params?.size !== undefined) {
      httpParams = httpParams.set('size', params.size.toString());
    }
    if (params?.status) {
      httpParams = httpParams.set('status', params.status);
    }
    if (params?.search) {
      httpParams = httpParams.set('search', params.search);
    }

    return this.http.get<{
      content: EnrollmentResponse[];
      totalElements: number;
      totalPages: number;
      size: number;
      number: number;
    }>(`${this.apiUrl}/my-enrollments`, { params: httpParams });
  }

  /**
   * Get specific enrollment details
   */
  getEnrollment(enrollmentId: number): Observable<EnrollmentResponse> {
    return this.http.get<EnrollmentResponse>(`${this.apiUrl}/${enrollmentId}`);
  }

  /**
   * Get enrollment by course ID
   */
  getEnrollmentByCourse(courseId: number): Observable<EnrollmentResponse> {
    return this.http.get<EnrollmentResponse>(`${this.apiUrl}/course/${courseId}`);
  }

  /**
   * Check if student is enrolled in a course
   */
  isEnrolled(courseId: number): Observable<boolean> {
    return this.http.get<boolean>(`${this.apiUrl}/is-enrolled/${courseId}`);
  }

  /**
   * Update enrollment progress
   */
  updateProgress(enrollmentId: number, progress: ProgressUpdate): Observable<EnrollmentResponse> {
    return this.http.put<EnrollmentResponse>(`${this.apiUrl}/${enrollmentId}/progress`, progress);
  }

  /**
   * Drop from a course
   */
  dropCourse(enrollmentId: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${enrollmentId}`);
  }

  /**
   * Get enrollment statistics for student
   */
  getEnrollmentStats(): Observable<EnrollmentStats> {
    return this.http.get<EnrollmentStats>(`${this.apiUrl}/stats`);
  }

  /**
   * Submit course completion
   */
  completeCourse(enrollmentId: number): Observable<EnrollmentResponse> {
    return this.http.put<EnrollmentResponse>(`${this.apiUrl}/${enrollmentId}/complete`, {});
  }

  /**
   * Get course progress details
   */
  getCourseProgress(enrollmentId: number): Observable<{
    totalLessons: number;
    completedLessons: number;
    currentLesson?: string;
    timeSpent: number;
    lastAccessed: string;
    progressPercentage: number;
    milestones: Array<{
      name: string;
      completed: boolean;
      completedDate?: string;
    }>;
  }> {
    return this.http.get<{
      totalLessons: number;
      completedLessons: number;
      currentLesson?: string;
      timeSpent: number;
      lastAccessed: string;
      progressPercentage: number;
      milestones: Array<{
        name: string;
        completed: boolean;
        completedDate?: string;
      }>;
    }>(`${this.apiUrl}/${enrollmentId}/progress`);
  }

  /**
   * Get upcoming deadlines for enrolled courses
   */
  getUpcomingDeadlines(): Observable<Array<{
    enrollmentId: number;
    courseId: number;
    courseName: string;
    deadlineType: string;
    deadline: string;
    description: string;
    priority: 'HIGH' | 'MEDIUM' | 'LOW';
  }>> {
    return this.http.get<Array<{
      enrollmentId: number;
      courseId: number;
      courseName: string;
      deadlineType: string;
      deadline: string;
      description: string;
      priority: 'HIGH' | 'MEDIUM' | 'LOW';
    }>>(`${this.apiUrl}/deadlines`);
  }

  /**
   * Get recently accessed courses
   */
  getRecentlyAccessed(): Observable<EnrollmentResponse[]> {
    return this.http.get<EnrollmentResponse[]>(`${this.apiUrl}/recent`);
  }

  /**
   * Resume course from last position
   */
  resumeCourse(enrollmentId: number): Observable<{
    lessonId?: number;
    sectionId?: number;
    position: number;
    lastAccessed: string;
  }> {
    return this.http.get<{
      lessonId?: number;
      sectionId?: number;
      position: number;
      lastAccessed: string;
    }>(`${this.apiUrl}/${enrollmentId}/resume`);
  }

  /**
   * Get certificate information if course is completed
   */
  getCertificate(enrollmentId: number): Observable<{
    certificateId: string;
    studentName: string;
    courseName: string;
    completionDate: string;
    grade: number;
    certificateUrl: string;
    verified: boolean;
  }> {
    return this.http.get<{
      certificateId: string;
      studentName: string;
      courseName: string;
      completionDate: string;
      grade: number;
      certificateUrl: string;
      verified: boolean;
    }>(`${this.apiUrl}/${enrollmentId}/certificate`);
  }

  /**
   * Rate and review a completed course
   */
  submitReview(enrollmentId: number, review: {
    rating: number;
    comment?: string;
  }): Observable<{
    id: number;
    rating: number;
    comment?: string;
    reviewDate: string;
    studentName: string;
    verified: boolean;
  }> {
    return this.http.post<{
      id: number;
      rating: number;
      comment?: string;
      reviewDate: string;
      studentName: string;
      verified: boolean;
    }>(`${this.apiUrl}/${enrollmentId}/review`, review);
  }

  /**
   * Get study recommendations based on enrollment history
   */
  getStudyRecommendations(): Observable<Array<{
    courseId: number;
    title: string;
    reason: string;
    similarity: number;
    category: string;
    level: string;
  }>> {
    return this.http.get<Array<{
      courseId: number;
      title: string;
      reason: string;
      similarity: number;
      category: string;
      level: string;
    }>>(`${this.apiUrl}/recommendations`);
  }

  /**
   * Get learning analytics
   */
  getLearningAnalytics(): Observable<{
    totalStudyTime: number;
    averageSessionTime: number;
    studyStreak: number;
    preferredStudyTime: string;
    strongSubjects: string[];
    improvementAreas: string[];
    weeklyProgress: Array<{
      week: string;
      hoursStudied: number;
      lessonsCompleted: number;
    }>;
    performanceByCategory: Array<{
      category: string;
      averageScore: number;
      coursesCompleted: number;
    }>;
  }> {
    return this.http.get<{
      totalStudyTime: number;
      averageSessionTime: number;
      studyStreak: number;
      preferredStudyTime: string;
      strongSubjects: string[];
      improvementAreas: string[];
      weeklyProgress: Array<{
        week: string;
        hoursStudied: number;
        lessonsCompleted: number;
      }>;
      performanceByCategory: Array<{
        category: string;
        averageScore: number;
        coursesCompleted: number;
      }>;
    }>(`${this.apiUrl}/analytics`);
  }
}
