import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';
import { notificationAPI } from '../../services/api';
import { User } from './authSlice';

export interface Notification {
  id: string;
  type: 'like' | 'comment' | 'follow' | 'mention' | 'share' | 'system';
  title: string;
  message: string;
  data: {
    actor?: User;
    post_id?: string;
    comment_id?: string;
    user_id?: string;
    url?: string;
    [key: string]: any;
  };
  read: boolean;
  created_at: string;
  updated_at: string;
  formatted_created_at: string;
}

interface NotificationState {
  notifications: Notification[];
  unreadCount: number;
  isLoading: boolean;
  isMarkingRead: boolean;
  error: string | null;
  currentPage: number;
  hasMore: boolean;
  realTimeEnabled: boolean;
}

const initialState: NotificationState = {
  notifications: [],
  unreadCount: 0,
  isLoading: false,
  isMarkingRead: false,
  error: null,
  currentPage: 1,
  hasMore: true,
  realTimeEnabled: false,
};

// Async thunks
export const getNotifications = createAsyncThunk(
  'notifications/getNotifications',
  async (page?: number, { rejectWithValue }) => {
    try {
      const response = await notificationAPI.getNotifications(page);
      return response.data;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to get notifications');
    }
  }
);

export const getUnreadCount = createAsyncThunk(
  'notifications/getUnreadCount',
  async (_, { rejectWithValue }) => {
    try {
      const response = await notificationAPI.getUnreadCount();
      return response.data.count;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to get unread count');
    }
  }
);

export const markAsRead = createAsyncThunk(
  'notifications/markAsRead',
  async (notificationId: string, { rejectWithValue }) => {
    try {
      await notificationAPI.markAsRead(notificationId);
      return notificationId;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to mark as read');
    }
  }
);

export const markAllAsRead = createAsyncThunk(
  'notifications/markAllAsRead',
  async (_, { rejectWithValue }) => {
    try {
      await notificationAPI.markAllAsRead();
      return true;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to mark all as read');
    }
  }
);

export const deleteNotification = createAsyncThunk(
  'notifications/delete',
  async (notificationId: string, { rejectWithValue }) => {
    try {
      await notificationAPI.deleteNotification(notificationId);
      return notificationId;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to delete notification');
    }
  }
);

export const clearAllNotifications = createAsyncThunk(
  'notifications/clearAll',
  async (_, { rejectWithValue }) => {
    try {
      await notificationAPI.clearAllNotifications();
      return true;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to clear all notifications');
    }
  }
);

export const updateNotificationSettings = createAsyncThunk(
  'notifications/updateSettings',
  async (settings: {
    email_notifications?: boolean;
    push_notifications?: boolean;
    like_notifications?: boolean;
    comment_notifications?: boolean;
    follow_notifications?: boolean;
    mention_notifications?: boolean;
  }, { rejectWithValue }) => {
    try {
      const response = await notificationAPI.updateSettings(settings);
      return response.data.settings;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to update settings');
    }
  }
);

const notificationSlice = createSlice({
  name: 'notifications',
  initialState,
  reducers: {
    clearNotificationError: (state) => {
      state.error = null;
    },
    addNotification: (state, action: PayloadAction<Notification>) => {
      // Add new notification to the beginning of the list
      state.notifications.unshift(action.payload);
      
      // Update unread count if notification is unread
      if (!action.payload.read) {
        state.unreadCount += 1;
      }
      
      // Limit notifications to prevent memory issues
      if (state.notifications.length > 100) {
        state.notifications = state.notifications.slice(0, 100);
      }
    },
    updateNotification: (state, action: PayloadAction<{ id: string; updates: Partial<Notification> }>) => {
      const { id, updates } = action.payload;
      const index = state.notifications.findIndex(n => n.id === id);
      
      if (index !== -1) {
        const wasUnread = !state.notifications[index].read;
        state.notifications[index] = { ...state.notifications[index], ...updates };
        
        // Update unread count if read status changed
        if (wasUnread && updates.read === true) {
          state.unreadCount = Math.max(0, state.unreadCount - 1);
        } else if (!wasUnread && updates.read === false) {
          state.unreadCount += 1;
        }
      }
    },
    removeNotification: (state, action: PayloadAction<string>) => {
      const index = state.notifications.findIndex(n => n.id === action.payload);
      
      if (index !== -1) {
        // Update unread count if removing unread notification
        if (!state.notifications[index].read) {
          state.unreadCount = Math.max(0, state.unreadCount - 1);
        }
        
        state.notifications.splice(index, 1);
      }
    },
    setRealTimeEnabled: (state, action: PayloadAction<boolean>) => {
      state.realTimeEnabled = action.payload;
    },
    resetNotifications: (state) => {
      state.notifications = [];
      state.currentPage = 1;
      state.hasMore = true;
      state.unreadCount = 0;
    },
    setUnreadCount: (state, action: PayloadAction<number>) => {
      state.unreadCount = Math.max(0, action.payload);
    },
    decrementUnreadCount: (state) => {
      state.unreadCount = Math.max(0, state.unreadCount - 1);
    },
    incrementUnreadCount: (state) => {
      state.unreadCount += 1;
    },
  },
  extraReducers: (builder) => {
    // Get notifications
    builder
      .addCase(getNotifications.pending, (state) => {
        if (state.currentPage === 1) {
          state.isLoading = true;
        }
        state.error = null;
      })
      .addCase(getNotifications.fulfilled, (state, action) => {
        state.isLoading = false;
        
        if (state.currentPage === 1) {
          state.notifications = action.payload.notifications;
        } else {
          state.notifications = [...state.notifications, ...action.payload.notifications];
        }
        
        state.hasMore = action.payload.meta?.has_more || false;
        state.currentPage += 1;
        state.unreadCount = action.payload.unread_count || 0;
        state.error = null;
      })
      .addCase(getNotifications.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      });

    // Get unread count
    builder
      .addCase(getUnreadCount.fulfilled, (state, action) => {
        state.unreadCount = action.payload;
      });

    // Mark as read
    builder
      .addCase(markAsRead.pending, (state) => {
        state.isMarkingRead = true;
      })
      .addCase(markAsRead.fulfilled, (state, action) => {
        state.isMarkingRead = false;
        const notificationId = action.payload;
        const index = state.notifications.findIndex(n => n.id === notificationId);
        
        if (index !== -1 && !state.notifications[index].read) {
          state.notifications[index].read = true;
          state.unreadCount = Math.max(0, state.unreadCount - 1);
        }
      })
      .addCase(markAsRead.rejected, (state) => {
        state.isMarkingRead = false;
      });

    // Mark all as read
    builder
      .addCase(markAllAsRead.fulfilled, (state) => {
        state.notifications.forEach(notification => {
          notification.read = true;
        });
        state.unreadCount = 0;
      });

    // Delete notification
    builder
      .addCase(deleteNotification.fulfilled, (state, action) => {
        const notificationId = action.payload;
        const index = state.notifications.findIndex(n => n.id === notificationId);
        
        if (index !== -1) {
          if (!state.notifications[index].read) {
            state.unreadCount = Math.max(0, state.unreadCount - 1);
          }
          state.notifications.splice(index, 1);
        }
      });

    // Clear all notifications
    builder
      .addCase(clearAllNotifications.fulfilled, (state) => {
        state.notifications = [];
        state.unreadCount = 0;
        state.currentPage = 1;
        state.hasMore = true;
      });

    // Update notification settings (handled in user slice or settings slice)
    builder
      .addCase(updateNotificationSettings.fulfilled, (state, action) => {
        // Settings updated successfully - could store settings in state if needed
      });
  },
});

export const {
  clearNotificationError,
  addNotification,
  updateNotification,
  removeNotification,
  setRealTimeEnabled,
  resetNotifications,
  setUnreadCount,
  decrementUnreadCount,
  incrementUnreadCount,
} = notificationSlice.actions;

export default notificationSlice.reducer;
