# Social Media Platform - Frontend (React Native Web)

A modern, full-featured social media platform frontend built with React Native Web, Redux Toolkit, and Expo. This application provides a seamless experience across mobile, tablet, and web platforms.

## 🏗️ Architecture Overview

### Technology Stack
- **Framework**: React Native Web with Expo
- **State Management**: Redux Toolkit with Redux Persist
- **Navigation**: React Navigation v6
- **API Layer**: Axios with interceptors
- **Real-time**: WebSocket integration
- **Styling**: StyleSheet with theme system
- **TypeScript**: Full type safety

### Project Structure
```
src/
├── components/           # Reusable UI components
│   ├── common/          # Generic components (Button, Input, etc.)
│   └── specific/        # Feature-specific components
├── config/              # App configuration and environment variables
├── hooks/               # Custom React hooks
├── navigation/          # Navigation configuration and routing
├── screens/             # Screen components organized by feature
│   ├── auth/           # Authentication screens
│   ├── main/           # Main app screens (Home, Profile, etc.)
│   ├── post/           # Post-related screens
│   ├── user/           # User-related screens
│   ├── search/         # Search functionality
│   └── settings/       # Settings and configuration
├── services/           # API services and external integrations
├── store/              # Redux store configuration
│   └── slices/         # Redux slices for different features
├── styles/             # Theme, colors, and styling constants
├── types/              # TypeScript type definitions
└── utils/              # Utility functions and helpers
```

## 🚀 Features

### Core Functionality
- ✅ User authentication (login, register, password reset)
- ✅ Profile management and customization
- ✅ Post creation, editing, and deletion
- ✅ Like, comment, and share system
- ✅ Follow/unfollow users
- ✅ Real-time notifications
- ✅ Search (users, posts, hashtags)
- ✅ Feed with infinite scroll
- ✅ Image and video upload
- ✅ Responsive design for all screen sizes

### Advanced Features
- 🔄 Real-time updates via WebSocket
- 💾 Offline support with Redux Persist
- 🌙 Dark/light theme support
- ♿ Accessibility features
- 📱 Push notifications
- 🔍 Advanced search filters
- 📊 Analytics integration
- 🔒 Security features (biometric auth, etc.)
- 🎨 Customizable themes
- 🌐 Internationalization ready

## 📱 Screen Flow

### Authentication Flow
```
LoginScreen → RegisterScreen
     ↓              ↓
HomeScreen ← ForgotPasswordScreen
```

### Main App Flow
```
HomeScreen (Feed) ↔ DiscoverScreen (Trending)
      ↓                      ↓
CreatePostScreen ←→ NotificationsScreen
      ↓                      ↓
ProfileScreen ←→ SettingsScreen
```

### Modal Screens
- PostDetailScreen
- EditPostScreen
- UserProfileScreen
- EditProfileScreen
- SearchScreen

## 🗃️ State Management

### Redux Store Structure
```
store/
├── auth/           # Authentication state
├── user/           # User profile and data
├── posts/          # Posts, feed, and interactions
├── comments/       # Comments and replies
├── notifications/  # Notifications and settings
└── ui/             # UI state, theme, and preferences
```

### Key State Features
- Persistent authentication state
- Optimistic updates for better UX
- Normalized data structure
- Real-time state synchronization
- Error handling and retry logic

## 🔌 API Integration

### Service Layer
- **authAPI**: Authentication endpoints
- **userAPI**: User management and profiles
- **postAPI**: Post CRUD operations
- **commentAPI**: Comment system
- **notificationAPI**: Notification management

### Features
- Automatic token refresh
- Request/response interceptors
- Error handling and retries
- Upload progress tracking
- Offline queue support

## 🎨 Theme System

### Design Tokens
- Colors (primary, secondary, semantic)
- Typography (fonts, sizes, weights)
- Spacing (margins, paddings)
- Shadows and elevation
- Border radius and borders

### Theme Features
- Light/dark mode support
- Custom color schemes
- Responsive breakpoints
- Accessibility compliance
- Dynamic theme switching

## 🧪 Component Library

### Common Components
- **Button**: Multi-variant button with loading states
- **Input**: Form inputs with validation
- **Card**: Content containers
- **Avatar**: User profile images
- **Badge**: Status indicators
- **Modal**: Overlay components

### Specialized Components
- **PostCard**: Post display component
- **CommentThread**: Nested comments
- **UserList**: User lists with actions
- **MediaViewer**: Image/video viewer
- **NotificationItem**: Notification display

## 📡 Real-time Features

### WebSocket Integration
- Live notifications
- Real-time like/comment updates
- Online presence indicators
- Typing indicators
- Live feed updates

### Implementation
- Automatic reconnection
- Message queuing
- Connection state management
- Error handling and fallbacks

## 🔧 Development Setup

### Prerequisites
- Node.js 18+
- npm or yarn
- Expo CLI
- React Native development environment

### Installation
```bash
# Install dependencies
npm install

# Install iOS dependencies (if developing for iOS)
cd ios && pod install && cd ..

# Start development server
npm start

# Run on specific platforms
npm run ios     # iOS simulator
npm run android # Android emulator
npm run web     # Web browser
```

### Environment Variables
Create a `.env` file in the project root:
```
EXPO_PUBLIC_API_URL=http://localhost:3000/api/v1
EXPO_PUBLIC_WS_URL=ws://localhost:3000/ws
EXPO_PUBLIC_SENTRY_DSN=your_sentry_dsn
EXPO_PUBLIC_MIXPANEL_TOKEN=your_mixpanel_token
```

## 🧪 Testing Strategy

### Testing Approach
- Unit tests for utilities and pure functions
- Integration tests for Redux slices
- Component testing with React Testing Library
- E2E testing with Detox/Playwright
- Visual regression testing

### Test Structure
```
__tests__/
├── components/     # Component tests
├── screens/        # Screen tests
├── store/          # Redux tests
├── services/       # API tests
├── utils/          # Utility tests
└── e2e/           # End-to-end tests
```

## 📦 Build and Deployment

### Build Configuration
- Environment-specific builds
- Code splitting and optimization
- Asset optimization
- Bundle analysis
- Source maps for debugging

### Deployment Targets
- **iOS**: App Store via Expo Application Services
- **Android**: Google Play Store via EAS
- **Web**: Static hosting (Vercel, Netlify)

### CI/CD Pipeline
```yaml
Build → Test → Security Scan → Deploy
  ↓       ↓         ↓           ↓
Bundle  Unit     SAST/DAST   Store Upload
        E2E      Dependency   Web Deploy
        Visual   Check       
```

## 🔒 Security Features

### Implementation
- Token-based authentication
- Secure storage for sensitive data
- Certificate pinning
- Input sanitization
- XSS protection
- CSRF protection

### Privacy
- Data encryption
- Privacy settings
- Data export/deletion
- GDPR compliance
- User consent management

## ♿ Accessibility

### Features
- Screen reader support
- High contrast mode
- Font scaling
- Voice control
- Keyboard navigation
- Focus management

### Standards
- WCAG 2.1 AA compliance
- Platform accessibility guidelines
- Inclusive design principles
- Regular accessibility audits

## 🚀 Performance Optimization

### Techniques
- Image lazy loading
- Virtual scrolling for lists
- Code splitting
- Bundle optimization
- Memory management
- Network optimization

### Monitoring
- Performance metrics
- Crash reporting
- User experience tracking
- Bundle size monitoring
- Network usage analysis

## 🤝 Contributing

### Development Workflow
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

### Code Standards
- TypeScript for type safety
- ESLint for code quality
- Prettier for formatting
- Conventional commits
- Code reviews required

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Documentation
- [API Documentation](../backend/README.md)
- [Deployment Guide](docs/deployment.md)
- [Contributing Guide](docs/contributing.md)
- [Troubleshooting](docs/troubleshooting.md)

### Community
- Issues: GitHub Issues
- Discussions: GitHub Discussions
- Chat: Discord/Slack
- Email: support@example.com

---

**Note**: This frontend is designed to work with the Ruby on Rails backend API. Ensure the backend is running and properly configured before starting the frontend development.
