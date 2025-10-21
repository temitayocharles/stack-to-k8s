export interface Course {
  id: number;
  title: string;
  description: string;
  category: CourseCategory;
  level: CourseLevel;
  creditHours: number;
  price?: number;
  thumbnailUrl?: string;
  instructorId: number;
  instructorName: string;
  instructorLastName: string;
  enrollmentCount: number;
  maxEnrollments?: number;
  rating?: number;
  totalRatings: number;
  published: boolean;
  startDate?: string;
  endDate?: string;
  enrollmentDeadline?: string;
  createdAt: string;
  updatedAt: string;
  syllabus?: string;
  learningObjectives?: string[];
  estimatedDurationHours?: number;
  lessonCount: number;
  prerequisiteIds?: number[];
  tags?: string[];
  language: string;
  status: CourseStatus;
}

export enum CourseCategory {
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

export enum CourseLevel {
  BEGINNER = 'BEGINNER',
  INTERMEDIATE = 'INTERMEDIATE',
  ADVANCED = 'ADVANCED'
}

export enum CourseStatus {
  DRAFT = 'DRAFT',
  PUBLISHED = 'PUBLISHED',
  ARCHIVED = 'ARCHIVED',
  SUSPENDED = 'SUSPENDED'
}

export interface CourseLesson {
  id: number;
  title: string;
  description?: string;
  contentType: LessonContentType;
  contentUrl?: string;
  duration?: number;
  sortOrder: number;
  sectionId: number;
  completed?: boolean;
  resources?: LessonResource[];
}

export interface CourseSection {
  id: number;
  title: string;
  description?: string;
  sortOrder: number;
  courseId: number;
  lessons: CourseLesson[];
}

export interface LessonResource {
  id: number;
  title: string;
  type: ResourceType;
  url: string;
  downloadable: boolean;
  size?: number;
}

export enum LessonContentType {
  VIDEO = 'VIDEO',
  TEXT = 'TEXT',
  QUIZ = 'QUIZ',
  ASSIGNMENT = 'ASSIGNMENT',
  RESOURCE = 'RESOURCE',
  LIVE_SESSION = 'LIVE_SESSION'
}

export enum ResourceType {
  PDF = 'PDF',
  DOCUMENT = 'DOCUMENT',
  PRESENTATION = 'PRESENTATION',
  SPREADSHEET = 'SPREADSHEET',
  IMAGE = 'IMAGE',
  AUDIO = 'AUDIO',
  ARCHIVE = 'ARCHIVE',
  LINK = 'LINK'
}

export interface CourseProgress {
  courseId: number;
  enrollmentId: number;
  totalLessons: number;
  completedLessons: number;
  progressPercentage: number;
  currentLessonId?: number;
  timeSpent: number;
  lastAccessed: string;
  estimatedTimeToComplete?: number;
}

export interface CourseAnnouncement {
  id: number;
  courseId: number;
  title: string;
  content: string;
  publishDate: string;
  priority: AnnouncementPriority;
  authorId: number;
  authorName: string;
  pinned: boolean;
}

export enum AnnouncementPriority {
  LOW = 'LOW',
  MEDIUM = 'MEDIUM',
  HIGH = 'HIGH',
  URGENT = 'URGENT'
}

export interface CourseReview {
  id: number;
  courseId: number;
  studentId: number;
  studentName: string;
  rating: number;
  comment?: string;
  reviewDate: string;
  verified: boolean;
  helpful: number;
  reported: boolean;
}

export interface CourseFilter {
  categories?: CourseCategory[];
  levels?: CourseLevel[];
  minPrice?: number;
  maxPrice?: number;
  minRating?: number;
  languages?: string[];
  instructorIds?: number[];
  tags?: string[];
  startDateFrom?: string;
  startDateTo?: string;
  hasCertificate?: boolean;
  duration?: {
    min?: number;
    max?: number;
  };
}

export interface CourseSortOption {
  field: 'title' | 'rating' | 'enrollmentCount' | 'price' | 'createdAt' | 'startDate';
  direction: 'ASC' | 'DESC';
}

export interface CourseSearchResult {
  content: Course[];
  totalElements: number;
  totalPages: number;
  size: number;
  number: number;
  sort: CourseSortOption;
  first: boolean;
  last: boolean;
  numberOfElements: number;
}

export interface CourseStatistics {
  totalCourses: number;
  publishedCourses: number;
  draftCourses: number;
  totalEnrollments: number;
  averageRating: number;
  totalRevenue: number;
  completionRate: number;
  coursesByCategory: CategoryStats[];
  coursesByLevel: LevelStats[];
  monthlyTrends: MonthlyStats[];
}

export interface CategoryStats {
  category: CourseCategory;
  count: number;
  percentage: number;
  averageRating: number;
  totalEnrollments: number;
}

export interface LevelStats {
  level: CourseLevel;
  count: number;
  percentage: number;
  averageRating: number;
  completionRate: number;
}

export interface MonthlyStats {
  month: string;
  coursesCreated: number;
  enrollments: number;
  revenue: number;
  completions: number;
}

export interface CourseAccessInfo {
  hasAccess: boolean;
  accessType: 'ENROLLED' | 'PREVIEW' | 'INSTRUCTOR' | 'ADMIN';
  enrollmentId?: number;
  enrollmentDate?: string;
  progress?: number;
  lastAccessedLessonId?: number;
  canDownloadResources: boolean;
  canSubmitAssignments: boolean;
  canParticipateInDiscussions: boolean;
  certificateEligible: boolean;
}

export interface CourseRecommendation {
  course: Course;
  reason: string;
  similarity: number;
  basedOn: 'ENROLLMENT_HISTORY' | 'CATEGORY_PREFERENCE' | 'RATING_PATTERN' | 'POPULAR_AMONG_PEERS';
  confidence: number;
}

export interface CoursePrerequisite {
  courseId: number;
  prerequisiteId: number;
  prerequisiteTitle: string;
  required: boolean;
  completed?: boolean;
  completionDate?: string;
}

export interface CourseOutcome {
  id: number;
  description: string;
  measurable: boolean;
  assessmentMethod?: string;
  sortOrder: number;
  achieved?: boolean;
}

export interface CourseMaterial {
  id: number;
  title: string;
  description?: string;
  type: MaterialType;
  url?: string;
  content?: string;
  downloadable: boolean;
  required: boolean;
  sortOrder: number;
  tags?: string[];
}

export enum MaterialType {
  TEXTBOOK = 'TEXTBOOK',
  REFERENCE = 'REFERENCE',
  SOFTWARE = 'SOFTWARE',
  DATASET = 'DATASET',
  TOOL = 'TOOL',
  ARTICLE = 'ARTICLE',
  VIDEO_SERIES = 'VIDEO_SERIES',
  PRACTICE_EXERCISES = 'PRACTICE_EXERCISES'
}
