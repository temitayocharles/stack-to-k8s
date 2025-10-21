// Environment configuration
export const config = {
  // API Configuration
  API_URL: process.env.EXPO_PUBLIC_API_URL || 'http://localhost:3000/api/v1',
  WS_URL: process.env.EXPO_PUBLIC_WS_URL || 'ws://localhost:3000/ws',
  
  // App Configuration
  APP_NAME: 'Social Media Platform',
  APP_VERSION: '1.0.0',
  APP_SCHEME: 'socialmedia',
  
  // Feature Flags
  FEATURES: {
    REAL_TIME_CHAT: true,
    PUSH_NOTIFICATIONS: true,
    ANALYTICS: true,
    CRASH_REPORTING: true,
    A_B_TESTING: false,
    OFFLINE_MODE: true,
    DARK_MODE: true,
    VIDEO_POSTS: true,
    STORIES: false,
    LIVE_STREAMING: false,
  },
  
  // Limits and Constraints
  LIMITS: {
    POST_MAX_LENGTH: 280,
    COMMENT_MAX_LENGTH: 280,
    BIO_MAX_LENGTH: 160,
    USERNAME_MIN_LENGTH: 3,
    USERNAME_MAX_LENGTH: 20,
    PASSWORD_MIN_LENGTH: 6,
    MAX_IMAGES_PER_POST: 4,
    MAX_VIDEO_SIZE_MB: 100,
    MAX_IMAGE_SIZE_MB: 10,
    FEED_PAGE_SIZE: 20,
    COMMENTS_PAGE_SIZE: 50,
    FOLLOWERS_PAGE_SIZE: 50,
  },
  
  // File Upload Configuration
  UPLOAD: {
    ALLOWED_IMAGE_TYPES: ['image/jpeg', 'image/png', 'image/gif', 'image/webp'],
    ALLOWED_VIDEO_TYPES: ['video/mp4', 'video/quicktime', 'video/webm'],
    CHUNK_SIZE: 1024 * 1024, // 1MB chunks
    MAX_CONCURRENT_UPLOADS: 3,
    RETRY_ATTEMPTS: 3,
    TIMEOUT: 30000, // 30 seconds
  },
  
  // Cache Configuration
  CACHE: {
    FEED_TTL: 5 * 60 * 1000, // 5 minutes
    USER_PROFILE_TTL: 10 * 60 * 1000, // 10 minutes
    POSTS_TTL: 15 * 60 * 1000, // 15 minutes
    SEARCH_TTL: 2 * 60 * 1000, // 2 minutes
    MAX_CACHE_SIZE: 50 * 1024 * 1024, // 50MB
  },
  
  // Network Configuration
  NETWORK: {
    TIMEOUT: 30000, // 30 seconds
    RETRY_ATTEMPTS: 3,
    RETRY_DELAY: 1000, // 1 second
    CONNECTION_CHECK_INTERVAL: 5000, // 5 seconds
  },
  
  // Authentication Configuration
  AUTH: {
    TOKEN_REFRESH_THRESHOLD: 5 * 60 * 1000, // 5 minutes before expiry
    BIOMETRIC_ENABLED: true,
    SESSION_TIMEOUT: 24 * 60 * 60 * 1000, // 24 hours
    MAX_LOGIN_ATTEMPTS: 5,
    LOCKOUT_DURATION: 15 * 60 * 1000, // 15 minutes
  },
  
  // Analytics Configuration
  ANALYTICS: {
    FLUSH_INTERVAL: 30 * 1000, // 30 seconds
    BATCH_SIZE: 50,
    TRACK_CRASHES: true,
    TRACK_PERFORMANCE: true,
    TRACK_USER_INTERACTIONS: true,
  },
  
  // Notification Configuration
  NOTIFICATIONS: {
    ENABLED: true,
    BADGE_ENABLED: true,
    SOUND_ENABLED: true,
    VIBRATION_ENABLED: true,
    CATEGORIES: {
      LIKE: 'like',
      COMMENT: 'comment',
      FOLLOW: 'follow',
      MENTION: 'mention',
      SHARE: 'share',
      SYSTEM: 'system',
    },
  },
  
  // Theme Configuration
  THEME: {
    DEFAULT: 'light',
    AVAILABLE_THEMES: ['light', 'dark', 'auto'],
    CUSTOM_THEMES_ENABLED: false,
  },
  
  // Security Configuration
  SECURITY: {
    CERTIFICATE_PINNING: true,
    JAILBREAK_DETECTION: true,
    SCREENSHOT_PROTECTION: false,
    OBFUSCATION_ENABLED: true,
  },
  
  // Performance Configuration
  PERFORMANCE: {
    IMAGE_CACHE_SIZE: 100 * 1024 * 1024, // 100MB
    LIST_SCROLL_OPTIMIZATION: true,
    LAZY_LOADING_ENABLED: true,
    PRELOAD_NEXT_PAGE: true,
  },
  
  // Development Configuration
  DEV: {
    ENABLE_FLIPPER: __DEV__,
    ENABLE_LOGS: __DEV__,
    ENABLE_DEV_MENU: __DEV__,
    MOCK_API: false,
    ENABLE_STORYBOOK: false,
  },
  
  // External Services
  SERVICES: {
    SENTRY_DSN: process.env.EXPO_PUBLIC_SENTRY_DSN,
    MIXPANEL_TOKEN: process.env.EXPO_PUBLIC_MIXPANEL_TOKEN,
    FIREBASE_CONFIG: {
      apiKey: process.env.EXPO_PUBLIC_FIREBASE_API_KEY,
      authDomain: process.env.EXPO_PUBLIC_FIREBASE_AUTH_DOMAIN,
      projectId: process.env.EXPO_PUBLIC_FIREBASE_PROJECT_ID,
      storageBucket: process.env.EXPO_PUBLIC_FIREBASE_STORAGE_BUCKET,
      messagingSenderId: process.env.EXPO_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
      appId: process.env.EXPO_PUBLIC_FIREBASE_APP_ID,
    },
  },
  
  // Social Media Integration
  SOCIAL: {
    TWITTER_CONSUMER_KEY: process.env.EXPO_PUBLIC_TWITTER_CONSUMER_KEY,
    FACEBOOK_APP_ID: process.env.EXPO_PUBLIC_FACEBOOK_APP_ID,
    GOOGLE_CLIENT_ID: process.env.EXPO_PUBLIC_GOOGLE_CLIENT_ID,
  },
  
  // Accessibility Configuration
  ACCESSIBILITY: {
    FONT_SCALING_ENABLED: true,
    HIGH_CONTRAST_ENABLED: true,
    REDUCED_MOTION_ENABLED: true,
    SCREEN_READER_SUPPORT: true,
  },
  
  // Experimental Features
  EXPERIMENTAL: {
    NEW_ARCHITECTURE: false,
    CONCURRENT_FEATURES: false,
    HERMES_ENABLED: true,
  },
};

// Environment-specific overrides
const getEnvironmentConfig = () => {
  const environment = process.env.NODE_ENV || 'development';
  
  switch (environment) {
    case 'development':
      return {
        ...config,
        DEV: {
          ...config.DEV,
          ENABLE_LOGS: true,
          MOCK_API: false,
        },
        NETWORK: {
          ...config.NETWORK,
          TIMEOUT: 60000, // Longer timeout for development
        },
      };
      
    case 'staging':
      return {
        ...config,
        API_URL: process.env.EXPO_PUBLIC_STAGING_API_URL || config.API_URL,
        ANALYTICS: {
          ...config.ANALYTICS,
          TRACK_CRASHES: true,
          TRACK_PERFORMANCE: true,
        },
      };
      
    case 'production':
      return {
        ...config,
        DEV: {
          ...config.DEV,
          ENABLE_FLIPPER: false,
          ENABLE_LOGS: false,
          ENABLE_DEV_MENU: false,
        },
        SECURITY: {
          ...config.SECURITY,
          CERTIFICATE_PINNING: true,
          JAILBREAK_DETECTION: true,
        },
      };
      
    default:
      return config;
  }
};

export default getEnvironmentConfig();

// Helper functions to check feature flags
export const isFeatureEnabled = (feature: keyof typeof config.FEATURES): boolean => {
  return config.FEATURES[feature];
};

export const getLimit = (limit: keyof typeof config.LIMITS): number => {
  return config.LIMITS[limit];
};

export const getServiceConfig = (service: keyof typeof config.SERVICES): any => {
  return config.SERVICES[service];
};

// Environment checks
export const isDevelopment = process.env.NODE_ENV === 'development';
export const isProduction = process.env.NODE_ENV === 'production';
export const isStaging = process.env.NODE_ENV === 'staging';

// Platform checks
export const isIOS = require('react-native').Platform.OS === 'ios';
export const isAndroid = require('react-native').Platform.OS === 'android';
export const isWeb = require('react-native').Platform.OS === 'web';
