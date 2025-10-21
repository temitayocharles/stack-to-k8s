import axios, { AxiosInstance, AxiosRequestConfig } from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Base API configuration
const BASE_URL = process.env.EXPO_PUBLIC_API_URL || 'http://localhost:3000/api/v1';

class APIClient {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: BASE_URL,
      timeout: 30000,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    });

    this.setupInterceptors();
  }

  private setupInterceptors() {
    // Request interceptor to add auth token
    this.client.interceptors.request.use(
      async (config) => {
        try {
          const token = await AsyncStorage.getItem('accessToken');
          if (token) {
            config.headers.Authorization = `Bearer ${token}`;
          }
        } catch (error) {
          console.warn('Error getting token from storage:', error);
        }
        
        return config;
      },
      (error) => {
        return Promise.reject(error);
      }
    );

    // Response interceptor to handle token refresh
    this.client.interceptors.response.use(
      (response) => response,
      async (error) => {
        const originalRequest = error.config;

        if (error.response?.status === 401 && !originalRequest._retry) {
          originalRequest._retry = true;

          try {
            const refreshToken = await AsyncStorage.getItem('refreshToken');
            if (refreshToken) {
              const response = await this.client.post('/auth/refresh', {
                refresh_token: refreshToken,
              });

              const { access_token, refresh_token: newRefreshToken } = response.data;
              
              await AsyncStorage.setItem('accessToken', access_token);
              if (newRefreshToken) {
                await AsyncStorage.setItem('refreshToken', newRefreshToken);
              }

              // Retry the original request with new token
              originalRequest.headers.Authorization = `Bearer ${access_token}`;
              return this.client(originalRequest);
            }
          } catch (refreshError) {
            // Refresh failed, redirect to login
            await AsyncStorage.multiRemove(['accessToken', 'refreshToken', 'user']);
            // You might want to dispatch a logout action here
            return Promise.reject(refreshError);
          }
        }

        return Promise.reject(error);
      }
    );
  }

  async get(url: string, config?: AxiosRequestConfig) {
    return this.client.get(url, config);
  }

  async post(url: string, data?: any, config?: AxiosRequestConfig) {
    return this.client.post(url, data, config);
  }

  async put(url: string, data?: any, config?: AxiosRequestConfig) {
    return this.client.put(url, data, config);
  }

  async patch(url: string, data?: any, config?: AxiosRequestConfig) {
    return this.client.patch(url, data, config);
  }

  async delete(url: string, config?: AxiosRequestConfig) {
    return this.client.delete(url, config);
  }

  // Upload file with progress tracking
  async upload(url: string, formData: FormData, onProgress?: (progress: number) => void) {
    return this.client.post(url, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
      onUploadProgress: (progressEvent) => {
        if (onProgress && progressEvent.total) {
          const progress = Math.round((progressEvent.loaded * 100) / progressEvent.total);
          onProgress(progress);
        }
      },
    });
  }
}

export const apiClient = new APIClient();

// Auth API
export const authAPI = {
  login: (email: string, password: string) =>
    apiClient.post('/auth/login', { email, password }),
  
  register: (userData: { email: string; password: string; username: string; name: string }) =>
    apiClient.post('/auth/register', userData),
  
  logout: () =>
    apiClient.post('/auth/logout'),
  
  refreshToken: (refreshToken: string) =>
    apiClient.post('/auth/refresh', { refresh_token: refreshToken }),
  
  forgotPassword: (email: string) =>
    apiClient.post('/auth/forgot-password', { email }),
  
  resetPassword: (token: string, password: string) =>
    apiClient.post('/auth/reset-password', { token, password }),
  
  verifyEmail: (token: string) =>
    apiClient.post('/auth/verify-email', { token }),
  
  resendVerification: (email: string) =>
    apiClient.post('/auth/resend-verification', { email }),
};

// User API
export const userAPI = {
  getCurrentUser: () =>
    apiClient.get('/users/me'),
  
  updateProfile: (data: any) =>
    apiClient.patch('/users/me', data),
  
  uploadAvatar: (formData: FormData, onProgress?: (progress: number) => void) =>
    apiClient.upload('/users/me/avatar', formData, onProgress),
  
  getProfile: (username: string) =>
    apiClient.get(`/users/${username}`),
  
  searchUsers: (query: string, page?: number) =>
    apiClient.get('/users/search', { params: { q: query, page } }),
  
  getSuggestedUsers: () =>
    apiClient.get('/users/suggested'),
  
  followUser: (userId: string) =>
    apiClient.post(`/users/${userId}/follow`),
  
  unfollowUser: (userId: string) =>
    apiClient.delete(`/users/${userId}/follow`),
  
  getFollowers: (username: string, page?: number) =>
    apiClient.get(`/users/${username}/followers`, { params: { page } }),
  
  getFollowing: (username: string, page?: number) =>
    apiClient.get(`/users/${username}/following`, { params: { page } }),
  
  blockUser: (userId: string) =>
    apiClient.post(`/users/${userId}/block`),
  
  unblockUser: (userId: string) =>
    apiClient.delete(`/users/${userId}/block`),
  
  reportUser: (userId: string, reason: string) =>
    apiClient.post(`/users/${userId}/report`, { reason }),
};

// Post API
export const postAPI = {
  getFeed: (page?: number) =>
    apiClient.get('/posts/feed', { params: { page } }),
  
  createPost: (data: { content: string; visibility?: string; images?: string[]; videos?: string[] }) =>
    apiClient.post('/posts', data),
  
  getPost: (postId: string) =>
    apiClient.get(`/posts/${postId}`),
  
  updatePost: (postId: string, data: { content: string; visibility?: string }) =>
    apiClient.patch(`/posts/${postId}`, data),
  
  deletePost: (postId: string) =>
    apiClient.delete(`/posts/${postId}`),
  
  likePost: (postId: string) =>
    apiClient.post(`/posts/${postId}/like`),
  
  unlikePost: (postId: string) =>
    apiClient.delete(`/posts/${postId}/like`),
  
  sharePost: (postId: string, content?: string) =>
    apiClient.post(`/posts/${postId}/share`, { content }),
  
  getUserPosts: (username: string, page?: number) =>
    apiClient.get(`/users/${username}/posts`, { params: { page } }),
  
  getTrendingPosts: () =>
    apiClient.get('/posts/trending'),
  
  getDiscoverPosts: () =>
    apiClient.get('/posts/discover'),
  
  searchPosts: (query: string, page?: number) =>
    apiClient.get('/posts/search', { params: { q: query, page } }),
  
  uploadMedia: (formData: FormData, onProgress?: (progress: number) => void) =>
    apiClient.upload('/posts/media', formData, onProgress),
};

// Comment API
export const commentAPI = {
  getPostComments: (postId: string, page?: number) =>
    apiClient.get(`/posts/${postId}/comments`, { params: { page } }),
  
  createComment: (data: { postId: string; content: string; parentCommentId?: string }) =>
    apiClient.post(`/posts/${data.postId}/comments`, {
      content: data.content,
      parent_comment_id: data.parentCommentId,
    }),
  
  updateComment: (commentId: string, content: string) =>
    apiClient.patch(`/comments/${commentId}`, { content }),
  
  deleteComment: (commentId: string) =>
    apiClient.delete(`/comments/${commentId}`),
  
  likeComment: (commentId: string) =>
    apiClient.post(`/comments/${commentId}/like`),
  
  unlikeComment: (commentId: string) =>
    apiClient.delete(`/comments/${commentId}/like`),
  
  getCommentReplies: (commentId: string, page?: number) =>
    apiClient.get(`/comments/${commentId}/replies`, { params: { page } }),
};

// Notification API
export const notificationAPI = {
  getNotifications: (page?: number) =>
    apiClient.get('/notifications', { params: { page } }),
  
  getUnreadCount: () =>
    apiClient.get('/notifications/unread-count'),
  
  markAsRead: (notificationId: string) =>
    apiClient.patch(`/notifications/${notificationId}/read`),
  
  markAllAsRead: () =>
    apiClient.patch('/notifications/read-all'),
  
  deleteNotification: (notificationId: string) =>
    apiClient.delete(`/notifications/${notificationId}`),
  
  clearAllNotifications: () =>
    apiClient.delete('/notifications'),
  
  updateSettings: (settings: any) =>
    apiClient.patch('/notifications/settings', settings),
};

// Real-time WebSocket connection
export class WebSocketService {
  private ws: WebSocket | null = null;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;
  private reconnectDelay = 1000;

  connect(token: string) {
    const wsUrl = BASE_URL.replace(/^http/, 'ws') + `/ws?token=${token}`;
    
    this.ws = new WebSocket(wsUrl);
    
    this.ws.onopen = () => {
      console.log('WebSocket connected');
      this.reconnectAttempts = 0;
    };
    
    this.ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        this.handleMessage(data);
      } catch (error) {
        console.error('Error parsing WebSocket message:', error);
      }
    };
    
    this.ws.onclose = () => {
      console.log('WebSocket disconnected');
      this.attemptReconnect(token);
    };
    
    this.ws.onerror = (error) => {
      console.error('WebSocket error:', error);
    };
  }

  private attemptReconnect(token: string) {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++;
      setTimeout(() => {
        console.log(`Attempting to reconnect... (${this.reconnectAttempts}/${this.maxReconnectAttempts})`);
        this.connect(token);
      }, this.reconnectDelay * this.reconnectAttempts);
    }
  }

  private handleMessage(data: any) {
    // Handle different types of real-time messages
    switch (data.type) {
      case 'notification':
        // Dispatch notification to Redux store
        break;
      case 'post_update':
        // Update post in store
        break;
      case 'comment_update':
        // Update comment in store
        break;
      default:
        console.log('Unknown WebSocket message type:', data.type);
    }
  }

  send(data: any) {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify(data));
    }
  }

  disconnect() {
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
  }
}

export const webSocketService = new WebSocketService();
