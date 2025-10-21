export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080/api',
  wsUrl: 'ws://localhost:8080/ws',
  
  // OAuth configurations
  oauth: {
    google: {
      clientId: 'your-google-client-id'
    },
    github: {
      clientId: 'your-github-client-id'
    }
  },
  
  // File upload configurations
  upload: {
    maxFileSize: 10 * 1024 * 1024, // 10MB
    allowedFileTypes: [
      'image/jpeg',
      'image/png',
      'image/gif',
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'text/plain'
    ]
  },
  
  // Feature flags
  features: {
    enableNotifications: true,
    enableChat: true,
    enableVideoCall: true,
    enableAnalytics: true,
    enableDarkMode: true
  },
  
  // Cache configurations
  cache: {
    defaultTTL: 300000, // 5 minutes
    userProfileTTL: 600000, // 10 minutes
    courseDataTTL: 900000 // 15 minutes
  }
};
