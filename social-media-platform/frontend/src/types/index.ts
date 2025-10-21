// API Response types
export interface ApiResponse<T = any> {
  data: T;
  message?: string;
  success: boolean;
  meta?: {
    page?: number;
    per_page?: number;
    total?: number;
    total_pages?: number;
    has_more?: boolean;
  };
}

export interface ApiError {
  message: string;
  errors?: Record<string, string[]>;
  status?: number;
}

// Navigation types
export interface NavigationProps {
  navigation: any;
  route: any;
}

// Form types
export interface FormField {
  value: string;
  error?: string;
  touched?: boolean;
}

export interface FormState {
  [key: string]: FormField;
}

// Media types
export interface MediaFile {
  id: string;
  url: string;
  thumbnail_url?: string;
  type: 'image' | 'video';
  size: number;
  width?: number;
  height?: number;
  duration?: number; // For videos
  alt_text?: string;
}

// File upload types
export interface UploadProgress {
  loaded: number;
  total: number;
  percentage: number;
}

export interface FileUploadState {
  file: File | null;
  progress: UploadProgress;
  status: 'idle' | 'uploading' | 'success' | 'error';
  error?: string;
}

// Notification types
export interface PushNotificationData {
  title: string;
  body: string;
  data?: Record<string, any>;
  badge?: number;
  sound?: string;
  category?: string;
}

// WebSocket message types
export interface WebSocketMessage {
  type: string;
  data: any;
  timestamp: string;
}

// Pagination types
export interface PaginationParams {
  page?: number;
  per_page?: number;
  sort_by?: string;
  sort_order?: 'asc' | 'desc';
}

export interface PaginatedResponse<T> {
  data: T[];
  meta: {
    current_page: number;
    per_page: number;
    total: number;
    total_pages: number;
    has_more: boolean;
    has_previous: boolean;
  };
}

// Search types
export interface SearchFilters {
  type?: 'posts' | 'users' | 'hashtags';
  date_from?: string;
  date_to?: string;
  location?: string;
  verified_only?: boolean;
}

export interface SearchParams extends PaginationParams {
  query: string;
  filters?: SearchFilters;
}

// Analytics types
export interface AnalyticsEvent {
  name: string;
  properties?: Record<string, any>;
  timestamp?: string;
  user_id?: string;
  session_id?: string;
}

export interface UserAnalytics {
  posts_count: number;
  followers_count: number;
  following_count: number;
  likes_received: number;
  comments_received: number;
  shares_received: number;
  profile_views: number;
  engagement_rate: number;
}

// Device types
export interface DeviceInfo {
  id: string;
  type: 'mobile' | 'tablet' | 'desktop';
  os: string;
  browser?: string;
  app_version?: string;
  last_active: string;
  push_token?: string;
  is_current: boolean;
}

// Theme types
export interface ThemeColors {
  primary: string;
  secondary: string;
  background: string;
  surface: string;
  text: string;
  textSecondary: string;
  border: string;
  error: string;
  warning: string;
  success: string;
  info: string;
}

export interface Theme {
  colors: ThemeColors;
  spacing: Record<string, number>;
  typography: {
    fontSize: Record<string, number>;
    fontWeight: Record<string, string>;
    lineHeight: Record<string, number>;
  };
  borderRadius: Record<string, number>;
  shadows: Record<string, any>;
}

// Generic utility types
export type Nullable<T> = T | null;
export type Optional<T> = T | undefined;
export type PartialBy<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>;
export type RequiredBy<T, K extends keyof T> = T & Required<Pick<T, K>>;

// Async state types
export interface AsyncState<T = any> {
  data: T | null;
  loading: boolean;
  error: string | null;
  lastFetch?: string;
}

export interface AsyncListState<T = any> extends AsyncState<T[]> {
  page: number;
  hasMore: boolean;
  refreshing: boolean;
}

// Feature flag types
export interface FeatureFlag {
  name: string;
  enabled: boolean;
  rollout_percentage?: number;
  user_groups?: string[];
  platforms?: ('ios' | 'android' | 'web')[];
}

// A/B Testing types
export interface ABTest {
  name: string;
  variant: string;
  experiment_id: string;
  user_id: string;
  started_at: string;
}

// Cache types
export interface CacheEntry<T = any> {
  data: T;
  timestamp: number;
  ttl: number; // Time to live in milliseconds
}

export interface CacheConfig {
  ttl: number;
  maxSize?: number;
  strategy?: 'lru' | 'fifo';
}

// Error types
export interface ErrorInfo {
  componentStack: string;
  errorBoundary?: string;
}

export interface ErrorReport {
  error: Error;
  errorInfo: ErrorInfo;
  userId?: string;
  timestamp: string;
  url: string;
  userAgent: string;
  additional?: Record<string, any>;
}

// Performance types
export interface PerformanceMetric {
  name: string;
  value: number;
  unit: 'ms' | 'bytes' | 'count' | 'percentage';
  timestamp: string;
  tags?: Record<string, string>;
}

// Accessibility types
export interface AccessibilityProps {
  accessibilityLabel?: string;
  accessibilityHint?: string;
  accessibilityRole?: string;
  accessibilityState?: {
    disabled?: boolean;
    selected?: boolean;
    checked?: boolean | 'mixed';
    busy?: boolean;
    expanded?: boolean;
  };
  accessible?: boolean;
  testID?: string;
}

// Component prop types
export interface ComponentProps {
  style?: any;
  testID?: string;
  children?: React.ReactNode;
}

export interface TouchableProps extends ComponentProps {
  onPress?: () => void;
  disabled?: boolean;
  activeOpacity?: number;
}

// Event types
export interface AppEvent {
  type: string;
  payload?: any;
  timestamp: string;
  source: string;
}

export interface UserEvent extends AppEvent {
  userId: string;
  sessionId: string;
  action: string;
  target?: string;
}

// Backup and sync types
export interface BackupData {
  version: string;
  timestamp: string;
  user_data: any;
  settings: any;
  posts: any[];
  following: string[];
}

export interface SyncStatus {
  last_sync: string;
  pending_changes: number;
  conflicts: any[];
  status: 'idle' | 'syncing' | 'error' | 'conflict';
}

export default {};
