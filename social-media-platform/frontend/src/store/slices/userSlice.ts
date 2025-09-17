import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';
import { userAPI } from '../../services/api';
import { User } from './authSlice';

interface UserProfile extends User {
  mutual_followers_count?: number;
  recent_posts?: any[];
}

interface UserState {
  profile: UserProfile | null;
  followers: User[];
  following: User[];
  suggestions: User[];
  searchResults: User[];
  isLoading: boolean;
  isFollowLoading: boolean;
  error: string | null;
  followersPage: number;
  followingPage: number;
  hasMoreFollowers: boolean;
  hasMoreFollowing: boolean;
}

const initialState: UserState = {
  profile: null,
  followers: [],
  following: [],
  suggestions: [],
  searchResults: [],
  isLoading: false,
  isFollowLoading: false,
  error: null,
  followersPage: 1,
  followingPage: 1,
  hasMoreFollowers: true,
  hasMoreFollowing: true,
};

// Async thunks
export const getUserProfile = createAsyncThunk(
  'user/getProfile',
  async (username: string, { rejectWithValue }) => {
    try {
      const response = await userAPI.getProfile(username);
      return response.data.user;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to get user profile');
    }
  }
);

export const updateUserProfile = createAsyncThunk(
  'user/updateProfile',
  async (userData: Partial<User>, { rejectWithValue }) => {
    try {
      const response = await userAPI.updateProfile(userData);
      return response.data.user;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to update profile');
    }
  }
);

export const followUser = createAsyncThunk(
  'user/follow',
  async (username: string, { rejectWithValue }) => {
    try {
      const response = await userAPI.followUser(username);
      return { username, data: response.data };
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to follow user');
    }
  }
);

export const unfollowUser = createAsyncThunk(
  'user/unfollow',
  async (username: string, { rejectWithValue }) => {
    try {
      const response = await userAPI.unfollowUser(username);
      return { username, data: response.data };
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to unfollow user');
    }
  }
);

export const getFollowers = createAsyncThunk(
  'user/getFollowers',
  async (params: { username: string; page?: number }, { rejectWithValue }) => {
    try {
      const response = await userAPI.getFollowers(params.username, params.page);
      return response.data;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to get followers');
    }
  }
);

export const getFollowing = createAsyncThunk(
  'user/getFollowing',
  async (params: { username: string; page?: number }, { rejectWithValue }) => {
    try {
      const response = await userAPI.getFollowing(params.username, params.page);
      return response.data;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to get following');
    }
  }
);

export const getUserSuggestions = createAsyncThunk(
  'user/getSuggestions',
  async (_, { rejectWithValue }) => {
    try {
      const response = await userAPI.getUserSuggestions();
      return response.data.suggestions;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to get suggestions');
    }
  }
);

export const searchUsers = createAsyncThunk(
  'user/search',
  async (query: string, { rejectWithValue }) => {
    try {
      const response = await userAPI.searchUsers(query);
      return response.data.users;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Search failed');
    }
  }
);

export const uploadAvatar = createAsyncThunk(
  'user/uploadAvatar',
  async (imageUri: string, { rejectWithValue }) => {
    try {
      const response = await userAPI.uploadAvatar(imageUri);
      return response.data.user;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to upload avatar');
    }
  }
);

export const uploadCoverPhoto = createAsyncThunk(
  'user/uploadCoverPhoto',
  async (imageUri: string, { rejectWithValue }) => {
    try {
      const response = await userAPI.uploadCoverPhoto(imageUri);
      return response.data.user;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to upload cover photo');
    }
  }
);

const userSlice = createSlice({
  name: 'user',
  initialState,
  reducers: {
    clearUserError: (state) => {
      state.error = null;
    },
    clearUserProfile: (state) => {
      state.profile = null;
    },
    clearSearchResults: (state) => {
      state.searchResults = [];
    },
    updateProfileLocally: (state, action: PayloadAction<Partial<UserProfile>>) => {
      if (state.profile) {
        state.profile = { ...state.profile, ...action.payload };
      }
    },
    resetFollowersPage: (state) => {
      state.followersPage = 1;
      state.followers = [];
      state.hasMoreFollowers = true;
    },
    resetFollowingPage: (state) => {
      state.followingPage = 1;
      state.following = [];
      state.hasMoreFollowing = true;
    },
  },
  extraReducers: (builder) => {
    // Get user profile
    builder
      .addCase(getUserProfile.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(getUserProfile.fulfilled, (state, action) => {
        state.isLoading = false;
        state.profile = action.payload;
        state.error = null;
      })
      .addCase(getUserProfile.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      });

    // Update profile
    builder
      .addCase(updateUserProfile.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(updateUserProfile.fulfilled, (state, action) => {
        state.isLoading = false;
        state.profile = action.payload;
        state.error = null;
      })
      .addCase(updateUserProfile.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      });

    // Follow user
    builder
      .addCase(followUser.pending, (state) => {
        state.isFollowLoading = true;
        state.error = null;
      })
      .addCase(followUser.fulfilled, (state, action) => {
        state.isFollowLoading = false;
        
        // Update profile if viewing the followed user
        if (state.profile && state.profile.username === action.payload.username) {
          state.profile.followers_count += 1;
        }
        
        // Update suggestions list
        state.suggestions = state.suggestions.filter(
          user => user.username !== action.payload.username
        );
        
        state.error = null;
      })
      .addCase(followUser.rejected, (state, action) => {
        state.isFollowLoading = false;
        state.error = action.payload as string;
      });

    // Unfollow user
    builder
      .addCase(unfollowUser.pending, (state) => {
        state.isFollowLoading = true;
        state.error = null;
      })
      .addCase(unfollowUser.fulfilled, (state, action) => {
        state.isFollowLoading = false;
        
        // Update profile if viewing the unfollowed user
        if (state.profile && state.profile.username === action.payload.username) {
          state.profile.followers_count -= 1;
        }
        
        // Remove from following list
        state.following = state.following.filter(
          user => user.username !== action.payload.username
        );
        
        state.error = null;
      })
      .addCase(unfollowUser.rejected, (state, action) => {
        state.isFollowLoading = false;
        state.error = action.payload as string;
      });

    // Get followers
    builder
      .addCase(getFollowers.pending, (state) => {
        if (state.followersPage === 1) {
          state.isLoading = true;
        }
        state.error = null;
      })
      .addCase(getFollowers.fulfilled, (state, action) => {
        state.isLoading = false;
        
        if (state.followersPage === 1) {
          state.followers = action.payload.followers;
        } else {
          state.followers = [...state.followers, ...action.payload.followers];
        }
        
        state.hasMoreFollowers = action.payload.meta?.has_more || false;
        state.followersPage += 1;
        state.error = null;
      })
      .addCase(getFollowers.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      });

    // Get following
    builder
      .addCase(getFollowing.pending, (state) => {
        if (state.followingPage === 1) {
          state.isLoading = true;
        }
        state.error = null;
      })
      .addCase(getFollowing.fulfilled, (state, action) => {
        state.isLoading = false;
        
        if (state.followingPage === 1) {
          state.following = action.payload.following;
        } else {
          state.following = [...state.following, ...action.payload.following];
        }
        
        state.hasMoreFollowing = action.payload.meta?.has_more || false;
        state.followingPage += 1;
        state.error = null;
      })
      .addCase(getFollowing.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      });

    // Get suggestions
    builder
      .addCase(getUserSuggestions.fulfilled, (state, action) => {
        state.suggestions = action.payload;
      });

    // Search users
    builder
      .addCase(searchUsers.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(searchUsers.fulfilled, (state, action) => {
        state.isLoading = false;
        state.searchResults = action.payload;
        state.error = null;
      })
      .addCase(searchUsers.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      });

    // Upload avatar
    builder
      .addCase(uploadAvatar.fulfilled, (state, action) => {
        if (state.profile) {
          state.profile.avatar_url = action.payload.avatar_url;
        }
      });

    // Upload cover photo
    builder
      .addCase(uploadCoverPhoto.fulfilled, (state, action) => {
        if (state.profile) {
          state.profile.cover_photo_url = action.payload.cover_photo_url;
        }
      });
  },
});

export const {
  clearUserError,
  clearUserProfile,
  clearSearchResults,
  updateProfileLocally,
  resetFollowersPage,
  resetFollowingPage,
} = userSlice.actions;

export default userSlice.reducer;
