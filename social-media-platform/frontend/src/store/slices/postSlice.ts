import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';
import { postAPI } from '../../services/api';
import { User } from './authSlice';

export interface Post {
  id: string;
  content: string;
  visibility: 'public' | 'private' | 'followers';
  likes_count: number;
  comments_count: number;
  shares_count: number;
  engagement_score: number;
  hashtags: string[];
  mentions: string[];
  has_media: boolean;
  image_urls: string[];
  video_urls: string[];
  is_shared: boolean;
  created_at: string;
  updated_at: string;
  formatted_created_at: string;
  user: User;
  current_user_liked: boolean;
  can_comment: boolean;
  original_post?: Post;
  recent_comments?: any[];
  recent_likes?: any[];
}

interface PostState {
  feed: Post[];
  userPosts: Post[];
  trendingPosts: Post[];
  discoverPosts: Post[];
  searchResults: Post[];
  currentPost: Post | null;
  isLoading: boolean;
  isCreating: boolean;
  isLiking: boolean;
  error: string | null;
  feedPage: number;
  userPostsPage: number;
  hasMoreFeed: boolean;
  hasMoreUserPosts: boolean;
  refreshing: boolean;
}

const initialState: PostState = {
  feed: [],
  userPosts: [],
  trendingPosts: [],
  discoverPosts: [],
  searchResults: [],
  currentPost: null,
  isLoading: false,
  isCreating: false,
  isLiking: false,
  error: null,
  feedPage: 1,
  userPostsPage: 1,
  hasMoreFeed: true,
  hasMoreUserPosts: true,
  refreshing: false,
};

// Async thunks
export const getFeed = createAsyncThunk(
  'posts/getFeed',
  async (params: { page?: number; refresh?: boolean }, { rejectWithValue }) => {
    try {
      const response = await postAPI.getFeed(params.page);
      return { ...response.data, refresh: params.refresh };
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to get feed');
    }
  }
);

export const createPost = createAsyncThunk(
  'posts/create',
  async (postData: {
    content: string;
    visibility?: string;
    images?: string[];
    videos?: string[];
  }, { rejectWithValue }) => {
    try {
      const response = await postAPI.createPost(postData);
      return response.data.post;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to create post');
    }
  }
);

export const getPost = createAsyncThunk(
  'posts/getPost',
  async (postId: string, { rejectWithValue }) => {
    try {
      const response = await postAPI.getPost(postId);
      return response.data.post;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to get post');
    }
  }
);

export const updatePost = createAsyncThunk(
  'posts/update',
  async (params: { postId: string; content: string; visibility?: string }, { rejectWithValue }) => {
    try {
      const response = await postAPI.updatePost(params.postId, {
        content: params.content,
        visibility: params.visibility,
      });
      return response.data.post;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to update post');
    }
  }
);

export const deletePost = createAsyncThunk(
  'posts/delete',
  async (postId: string, { rejectWithValue }) => {
    try {
      await postAPI.deletePost(postId);
      return postId;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to delete post');
    }
  }
);

export const likePost = createAsyncThunk(
  'posts/like',
  async (postId: string, { rejectWithValue }) => {
    try {
      const response = await postAPI.likePost(postId);
      return { postId, data: response.data };
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to like post');
    }
  }
);

export const unlikePost = createAsyncThunk(
  'posts/unlike',
  async (postId: string, { rejectWithValue }) => {
    try {
      const response = await postAPI.unlikePost(postId);
      return { postId, data: response.data };
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to unlike post');
    }
  }
);

export const sharePost = createAsyncThunk(
  'posts/share',
  async (params: { postId: string; content?: string }, { rejectWithValue }) => {
    try {
      const response = await postAPI.sharePost(params.postId, params.content);
      return response.data.shared_post;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to share post');
    }
  }
);

export const getUserPosts = createAsyncThunk(
  'posts/getUserPosts',
  async (params: { username: string; page?: number }, { rejectWithValue }) => {
    try {
      const response = await postAPI.getUserPosts(params.username, params.page);
      return response.data;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to get user posts');
    }
  }
);

export const getTrendingPosts = createAsyncThunk(
  'posts/getTrending',
  async (_, { rejectWithValue }) => {
    try {
      const response = await postAPI.getTrendingPosts();
      return response.data.posts;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to get trending posts');
    }
  }
);

export const getDiscoverPosts = createAsyncThunk(
  'posts/getDiscover',
  async (_, { rejectWithValue }) => {
    try {
      const response = await postAPI.getDiscoverPosts();
      return response.data.posts;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to get discover posts');
    }
  }
);

export const searchPosts = createAsyncThunk(
  'posts/search',
  async (query: string, { rejectWithValue }) => {
    try {
      const response = await postAPI.searchPosts(query);
      return response.data.posts;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Search failed');
    }
  }
);

const postSlice = createSlice({
  name: 'posts',
  initialState,
  reducers: {
    clearPostError: (state) => {
      state.error = null;
    },
    clearCurrentPost: (state) => {
      state.currentPost = null;
    },
    clearSearchResults: (state) => {
      state.searchResults = [];
    },
    updatePostLocally: (state, action: PayloadAction<{ postId: string; updates: Partial<Post> }>) => {
      const { postId, updates } = action.payload;
      
      // Update in feed
      const feedIndex = state.feed.findIndex(post => post.id === postId);
      if (feedIndex !== -1) {
        state.feed[feedIndex] = { ...state.feed[feedIndex], ...updates };
      }
      
      // Update in user posts
      const userPostIndex = state.userPosts.findIndex(post => post.id === postId);
      if (userPostIndex !== -1) {
        state.userPosts[userPostIndex] = { ...state.userPosts[userPostIndex], ...updates };
      }
      
      // Update current post
      if (state.currentPost && state.currentPost.id === postId) {
        state.currentPost = { ...state.currentPost, ...updates };
      }
    },
    addPostToFeed: (state, action: PayloadAction<Post>) => {
      state.feed.unshift(action.payload);
    },
    removePostFromFeed: (state, action: PayloadAction<string>) => {
      state.feed = state.feed.filter(post => post.id !== action.payload);
      state.userPosts = state.userPosts.filter(post => post.id !== action.payload);
    },
    resetFeedPage: (state) => {
      state.feedPage = 1;
      state.feed = [];
      state.hasMoreFeed = true;
    },
    resetUserPostsPage: (state) => {
      state.userPostsPage = 1;
      state.userPosts = [];
      state.hasMoreUserPosts = true;
    },
    setRefreshing: (state, action: PayloadAction<boolean>) => {
      state.refreshing = action.payload;
    },
  },
  extraReducers: (builder) => {
    // Get feed
    builder
      .addCase(getFeed.pending, (state, action) => {
        if (action.meta.arg.refresh) {
          state.refreshing = true;
        } else if (state.feedPage === 1) {
          state.isLoading = true;
        }
        state.error = null;
      })
      .addCase(getFeed.fulfilled, (state, action) => {
        state.isLoading = false;
        state.refreshing = false;
        
        if (action.payload.refresh || state.feedPage === 1) {
          state.feed = action.payload.posts;
          state.feedPage = 2;
        } else {
          state.feed = [...state.feed, ...action.payload.posts];
          state.feedPage += 1;
        }
        
        state.hasMoreFeed = action.payload.meta?.has_more || false;
        state.error = null;
      })
      .addCase(getFeed.rejected, (state, action) => {
        state.isLoading = false;
        state.refreshing = false;
        state.error = action.payload as string;
      });

    // Create post
    builder
      .addCase(createPost.pending, (state) => {
        state.isCreating = true;
        state.error = null;
      })
      .addCase(createPost.fulfilled, (state, action) => {
        state.isCreating = false;
        state.feed.unshift(action.payload);
        state.userPosts.unshift(action.payload);
        state.error = null;
      })
      .addCase(createPost.rejected, (state, action) => {
        state.isCreating = false;
        state.error = action.payload as string;
      });

    // Get single post
    builder
      .addCase(getPost.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(getPost.fulfilled, (state, action) => {
        state.isLoading = false;
        state.currentPost = action.payload;
        state.error = null;
      })
      .addCase(getPost.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      });

    // Update post
    builder
      .addCase(updatePost.fulfilled, (state, action) => {
        const postId = action.payload.id;
        
        // Update in all relevant arrays
        [state.feed, state.userPosts, state.trendingPosts, state.discoverPosts].forEach(array => {
          const index = array.findIndex(post => post.id === postId);
          if (index !== -1) {
            array[index] = action.payload;
          }
        });
        
        if (state.currentPost && state.currentPost.id === postId) {
          state.currentPost = action.payload;
        }
      });

    // Delete post
    builder
      .addCase(deletePost.fulfilled, (state, action) => {
        const postId = action.payload;
        
        state.feed = state.feed.filter(post => post.id !== postId);
        state.userPosts = state.userPosts.filter(post => post.id !== postId);
        state.trendingPosts = state.trendingPosts.filter(post => post.id !== postId);
        state.discoverPosts = state.discoverPosts.filter(post => post.id !== postId);
        
        if (state.currentPost && state.currentPost.id === postId) {
          state.currentPost = null;
        }
      });

    // Like post
    builder
      .addCase(likePost.pending, (state) => {
        state.isLiking = true;
      })
      .addCase(likePost.fulfilled, (state, action) => {
        state.isLiking = false;
        const { postId, data } = action.payload;
        
        const updatePost = (post: Post) => {
          if (post.id === postId) {
            post.current_user_liked = data.liked;
            post.likes_count = data.likes_count;
          }
        };
        
        state.feed.forEach(updatePost);
        state.userPosts.forEach(updatePost);
        if (state.currentPost?.id === postId) {
          updatePost(state.currentPost);
        }
      })
      .addCase(likePost.rejected, (state) => {
        state.isLiking = false;
      });

    // Unlike post
    builder
      .addCase(unlikePost.fulfilled, (state, action) => {
        const { postId, data } = action.payload;
        
        const updatePost = (post: Post) => {
          if (post.id === postId) {
            post.current_user_liked = data.liked;
            post.likes_count = data.likes_count;
          }
        };
        
        state.feed.forEach(updatePost);
        state.userPosts.forEach(updatePost);
        if (state.currentPost?.id === postId) {
          updatePost(state.currentPost);
        }
      });

    // Share post
    builder
      .addCase(sharePost.fulfilled, (state, action) => {
        state.feed.unshift(action.payload);
        state.userPosts.unshift(action.payload);
      });

    // Get user posts
    builder
      .addCase(getUserPosts.pending, (state) => {
        if (state.userPostsPage === 1) {
          state.isLoading = true;
        }
        state.error = null;
      })
      .addCase(getUserPosts.fulfilled, (state, action) => {
        state.isLoading = false;
        
        if (state.userPostsPage === 1) {
          state.userPosts = action.payload.posts;
        } else {
          state.userPosts = [...state.userPosts, ...action.payload.posts];
        }
        
        state.hasMoreUserPosts = action.payload.meta?.has_more || false;
        state.userPostsPage += 1;
        state.error = null;
      })
      .addCase(getUserPosts.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      });

    // Get trending posts
    builder
      .addCase(getTrendingPosts.fulfilled, (state, action) => {
        state.trendingPosts = action.payload;
      });

    // Get discover posts
    builder
      .addCase(getDiscoverPosts.fulfilled, (state, action) => {
        state.discoverPosts = action.payload;
      });

    // Search posts
    builder
      .addCase(searchPosts.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(searchPosts.fulfilled, (state, action) => {
        state.isLoading = false;
        state.searchResults = action.payload;
        state.error = null;
      })
      .addCase(searchPosts.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      });
  },
});

export const {
  clearPostError,
  clearCurrentPost,
  clearSearchResults,
  updatePostLocally,
  addPostToFeed,
  removePostFromFeed,
  resetFeedPage,
  resetUserPostsPage,
  setRefreshing,
} = postSlice.actions;

export default postSlice.reducer;
