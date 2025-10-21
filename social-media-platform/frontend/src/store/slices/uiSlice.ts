import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';

interface UIState {
  theme: 'light' | 'dark' | 'system';
  fontScale: number;
  reducedMotion: boolean;
  highContrast: boolean;
  
  // Navigation state
  activeTab: string;
  navigationHistory: string[];
  
  // Modal/overlay state
  isPostModalOpen: boolean;
  isProfileModalOpen: boolean;
  isSettingsModalOpen: boolean;
  isImageViewerOpen: boolean;
  currentImageIndex: number;
  imageViewerImages: string[];
  
  // Loading states
  isAppLoading: boolean;
  isInitializing: boolean;
  loadingStates: { [key: string]: boolean };
  
  // Error handling
  globalError: string | null;
  networkError: boolean;
  
  // Search state
  searchQuery: string;
  searchHistory: string[];
  recentSearches: string[];
  
  // Feed preferences
  feedRefreshEnabled: boolean;
  autoPlayVideos: boolean;
  showSensitiveContent: boolean;
  
  // Network state
  isOnline: boolean;
  connectionSpeed: 'slow' | 'fast' | 'unknown';
  
  // Device info
  deviceType: 'mobile' | 'tablet' | 'desktop';
  orientation: 'portrait' | 'landscape';
  screenSize: { width: number; height: number };
  
  // App state
  appVersion: string;
  isUpdateAvailable: boolean;
  lastSyncTime: string | null;
  
  // Keyboard/focus state
  isKeyboardVisible: boolean;
  focusedElement: string | null;
  
  // Performance tracking
  renderTimes: { [component: string]: number };
  memoryUsage: number;
}

const initialState: UIState = {
  theme: 'system',
  fontScale: 1.0,
  reducedMotion: false,
  highContrast: false,
  
  activeTab: 'home',
  navigationHistory: [],
  
  isPostModalOpen: false,
  isProfileModalOpen: false,
  isSettingsModalOpen: false,
  isImageViewerOpen: false,
  currentImageIndex: 0,
  imageViewerImages: [],
  
  isAppLoading: false,
  isInitializing: true,
  loadingStates: {},
  
  globalError: null,
  networkError: false,
  
  searchQuery: '',
  searchHistory: [],
  recentSearches: [],
  
  feedRefreshEnabled: true,
  autoPlayVideos: true,
  showSensitiveContent: false,
  
  isOnline: true,
  connectionSpeed: 'unknown',
  
  deviceType: 'mobile',
  orientation: 'portrait',
  screenSize: { width: 375, height: 667 },
  
  appVersion: '1.0.0',
  isUpdateAvailable: false,
  lastSyncTime: null,
  
  isKeyboardVisible: false,
  focusedElement: null,
  
  renderTimes: {},
  memoryUsage: 0,
};

// Async thunks for persistent settings
export const loadUserPreferences = createAsyncThunk(
  'ui/loadUserPreferences',
  async (_, { rejectWithValue }) => {
    try {
      // Load from AsyncStorage or other persistent storage
      // This would be implemented based on your storage solution
      const preferences = {}; // await AsyncStorage.getItem('userPreferences');
      return preferences;
    } catch (error: any) {
      return rejectWithValue('Failed to load user preferences');
    }
  }
);

export const saveUserPreferences = createAsyncThunk(
  'ui/saveUserPreferences',
  async (preferences: Partial<UIState>, { rejectWithValue }) => {
    try {
      // Save to AsyncStorage or other persistent storage
      // await AsyncStorage.setItem('userPreferences', JSON.stringify(preferences));
      return preferences;
    } catch (error: any) {
      return rejectWithValue('Failed to save user preferences');
    }
  }
);

const uiSlice = createSlice({
  name: 'ui',
  initialState,
  reducers: {
    // Theme and accessibility
    setTheme: (state, action: PayloadAction<'light' | 'dark' | 'system'>) => {
      state.theme = action.payload;
    },
    setFontScale: (state, action: PayloadAction<number>) => {
      state.fontScale = Math.max(0.8, Math.min(2.0, action.payload));
    },
    setReducedMotion: (state, action: PayloadAction<boolean>) => {
      state.reducedMotion = action.payload;
    },
    setHighContrast: (state, action: PayloadAction<boolean>) => {
      state.highContrast = action.payload;
    },
    
    // Navigation
    setActiveTab: (state, action: PayloadAction<string>) => {
      state.activeTab = action.payload;
      state.navigationHistory.push(action.payload);
      
      // Keep history to reasonable size
      if (state.navigationHistory.length > 50) {
        state.navigationHistory = state.navigationHistory.slice(-25);
      }
    },
    goBack: (state) => {
      if (state.navigationHistory.length > 1) {
        state.navigationHistory.pop();
        state.activeTab = state.navigationHistory[state.navigationHistory.length - 1];
      }
    },
    clearNavigationHistory: (state) => {
      state.navigationHistory = [state.activeTab];
    },
    
    // Modals and overlays
    openPostModal: (state) => {
      state.isPostModalOpen = true;
    },
    closePostModal: (state) => {
      state.isPostModalOpen = false;
    },
    openProfileModal: (state) => {
      state.isProfileModalOpen = true;
    },
    closeProfileModal: (state) => {
      state.isProfileModalOpen = false;
    },
    openSettingsModal: (state) => {
      state.isSettingsModalOpen = true;
    },
    closeSettingsModal: (state) => {
      state.isSettingsModalOpen = false;
    },
    openImageViewer: (state, action: PayloadAction<{ images: string[]; index: number }>) => {
      state.isImageViewerOpen = true;
      state.imageViewerImages = action.payload.images;
      state.currentImageIndex = action.payload.index;
    },
    closeImageViewer: (state) => {
      state.isImageViewerOpen = false;
      state.imageViewerImages = [];
      state.currentImageIndex = 0;
    },
    setImageViewerIndex: (state, action: PayloadAction<number>) => {
      state.currentImageIndex = Math.max(0, Math.min(action.payload, state.imageViewerImages.length - 1));
    },
    
    // Loading states
    setAppLoading: (state, action: PayloadAction<boolean>) => {
      state.isAppLoading = action.payload;
    },
    setInitializing: (state, action: PayloadAction<boolean>) => {
      state.isInitializing = action.payload;
    },
    setLoadingState: (state, action: PayloadAction<{ key: string; loading: boolean }>) => {
      const { key, loading } = action.payload;
      if (loading) {
        state.loadingStates[key] = true;
      } else {
        delete state.loadingStates[key];
      }
    },
    clearAllLoadingStates: (state) => {
      state.loadingStates = {};
    },
    
    // Error handling
    setGlobalError: (state, action: PayloadAction<string | null>) => {
      state.globalError = action.payload;
    },
    setNetworkError: (state, action: PayloadAction<boolean>) => {
      state.networkError = action.payload;
    },
    clearErrors: (state) => {
      state.globalError = null;
      state.networkError = false;
    },
    
    // Search
    setSearchQuery: (state, action: PayloadAction<string>) => {
      state.searchQuery = action.payload;
    },
    addToSearchHistory: (state, action: PayloadAction<string>) => {
      const query = action.payload.trim();
      if (query && !state.searchHistory.includes(query)) {
        state.searchHistory.unshift(query);
        
        // Keep history to reasonable size
        if (state.searchHistory.length > 20) {
          state.searchHistory = state.searchHistory.slice(0, 20);
        }
      }
    },
    clearSearchHistory: (state) => {
      state.searchHistory = [];
    },
    addRecentSearch: (state, action: PayloadAction<string>) => {
      const query = action.payload.trim();
      if (query) {
        // Remove if already exists to move to top
        state.recentSearches = state.recentSearches.filter(s => s !== query);
        state.recentSearches.unshift(query);
        
        // Keep only recent searches
        if (state.recentSearches.length > 10) {
          state.recentSearches = state.recentSearches.slice(0, 10);
        }
      }
    },
    
    // Feed preferences
    setFeedRefreshEnabled: (state, action: PayloadAction<boolean>) => {
      state.feedRefreshEnabled = action.payload;
    },
    setAutoPlayVideos: (state, action: PayloadAction<boolean>) => {
      state.autoPlayVideos = action.payload;
    },
    setShowSensitiveContent: (state, action: PayloadAction<boolean>) => {
      state.showSensitiveContent = action.payload;
    },
    
    // Network state
    setOnlineStatus: (state, action: PayloadAction<boolean>) => {
      state.isOnline = action.payload;
      if (!action.payload) {
        state.networkError = true;
      }
    },
    setConnectionSpeed: (state, action: PayloadAction<'slow' | 'fast' | 'unknown'>) => {
      state.connectionSpeed = action.payload;
    },
    
    // Device info
    setDeviceType: (state, action: PayloadAction<'mobile' | 'tablet' | 'desktop'>) => {
      state.deviceType = action.payload;
    },
    setOrientation: (state, action: PayloadAction<'portrait' | 'landscape'>) => {
      state.orientation = action.payload;
    },
    setScreenSize: (state, action: PayloadAction<{ width: number; height: number }>) => {
      state.screenSize = action.payload;
    },
    
    // App state
    setAppVersion: (state, action: PayloadAction<string>) => {
      state.appVersion = action.payload;
    },
    setUpdateAvailable: (state, action: PayloadAction<boolean>) => {
      state.isUpdateAvailable = action.payload;
    },
    setLastSyncTime: (state, action: PayloadAction<string>) => {
      state.lastSyncTime = action.payload;
    },
    
    // Keyboard and focus
    setKeyboardVisible: (state, action: PayloadAction<boolean>) => {
      state.isKeyboardVisible = action.payload;
    },
    setFocusedElement: (state, action: PayloadAction<string | null>) => {
      state.focusedElement = action.payload;
    },
    
    // Performance tracking
    recordRenderTime: (state, action: PayloadAction<{ component: string; time: number }>) => {
      const { component, time } = action.payload;
      state.renderTimes[component] = time;
    },
    setMemoryUsage: (state, action: PayloadAction<number>) => {
      state.memoryUsage = action.payload;
    },
    clearPerformanceData: (state) => {
      state.renderTimes = {};
      state.memoryUsage = 0;
    },
    
    // Bulk actions
    resetUIState: (state) => {
      Object.assign(state, initialState);
    },
    updateMultipleSettings: (state, action: PayloadAction<Partial<UIState>>) => {
      Object.assign(state, action.payload);
    },
  },
  extraReducers: (builder) => {
    // Load user preferences
    builder
      .addCase(loadUserPreferences.fulfilled, (state, action) => {
        if (action.payload) {
          Object.assign(state, action.payload);
        }
      });

    // Save user preferences
    builder
      .addCase(saveUserPreferences.fulfilled, (state, action) => {
        // Preferences saved successfully
      });
  },
});

export const {
  // Theme and accessibility
  setTheme,
  setFontScale,
  setReducedMotion,
  setHighContrast,
  
  // Navigation
  setActiveTab,
  goBack,
  clearNavigationHistory,
  
  // Modals and overlays
  openPostModal,
  closePostModal,
  openProfileModal,
  closeProfileModal,
  openSettingsModal,
  closeSettingsModal,
  openImageViewer,
  closeImageViewer,
  setImageViewerIndex,
  
  // Loading states
  setAppLoading,
  setInitializing,
  setLoadingState,
  clearAllLoadingStates,
  
  // Error handling
  setGlobalError,
  setNetworkError,
  clearErrors,
  
  // Search
  setSearchQuery,
  addToSearchHistory,
  clearSearchHistory,
  addRecentSearch,
  
  // Feed preferences
  setFeedRefreshEnabled,
  setAutoPlayVideos,
  setShowSensitiveContent,
  
  // Network state
  setOnlineStatus,
  setConnectionSpeed,
  
  // Device info
  setDeviceType,
  setOrientation,
  setScreenSize,
  
  // App state
  setAppVersion,
  setUpdateAvailable,
  setLastSyncTime,
  
  // Keyboard and focus
  setKeyboardVisible,
  setFocusedElement,
  
  // Performance tracking
  recordRenderTime,
  setMemoryUsage,
  clearPerformanceData,
  
  // Bulk actions
  resetUIState,
  updateMultipleSettings,
} = uiSlice.actions;

export default uiSlice.reducer;
