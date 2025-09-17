import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';
import { commentAPI } from '../../services/api';
import { User } from './authSlice';

export interface Comment {
  id: string;
  content: string;
  likes_count: number;
  replies_count: number;
  depth: number;
  created_at: string;
  updated_at: string;
  formatted_created_at: string;
  user: User;
  current_user_liked: boolean;
  can_reply: boolean;
  parent_comment_id?: string;
  post_id: string;
  replies?: Comment[];
}

interface CommentState {
  comments: Comment[];
  postComments: { [postId: string]: Comment[] };
  isLoading: boolean;
  isCreating: boolean;
  isLiking: boolean;
  error: string | null;
  currentPage: number;
  hasMore: boolean;
  replyingTo: string | null;
}

const initialState: CommentState = {
  comments: [],
  postComments: {},
  isLoading: false,
  isCreating: false,
  isLiking: false,
  error: null,
  currentPage: 1,
  hasMore: true,
  replyingTo: null,
};

// Async thunks
export const getPostComments = createAsyncThunk(
  'comments/getPostComments',
  async (params: { postId: string; page?: number }, { rejectWithValue }) => {
    try {
      const response = await commentAPI.getPostComments(params.postId, params.page);
      return { postId: params.postId, ...response.data };
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to get comments');
    }
  }
);

export const createComment = createAsyncThunk(
  'comments/create',
  async (commentData: {
    postId: string;
    content: string;
    parentCommentId?: string;
  }, { rejectWithValue }) => {
    try {
      const response = await commentAPI.createComment(commentData);
      return { ...response.data.comment, postId: commentData.postId };
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to create comment');
    }
  }
);

export const updateComment = createAsyncThunk(
  'comments/update',
  async (params: { commentId: string; content: string }, { rejectWithValue }) => {
    try {
      const response = await commentAPI.updateComment(params.commentId, params.content);
      return response.data.comment;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to update comment');
    }
  }
);

export const deleteComment = createAsyncThunk(
  'comments/delete',
  async (commentId: string, { rejectWithValue }) => {
    try {
      await commentAPI.deleteComment(commentId);
      return commentId;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to delete comment');
    }
  }
);

export const likeComment = createAsyncThunk(
  'comments/like',
  async (commentId: string, { rejectWithValue }) => {
    try {
      const response = await commentAPI.likeComment(commentId);
      return { commentId, data: response.data };
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to like comment');
    }
  }
);

export const unlikeComment = createAsyncThunk(
  'comments/unlike',
  async (commentId: string, { rejectWithValue }) => {
    try {
      const response = await commentAPI.unlikeComment(commentId);
      return { commentId, data: response.data };
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to unlike comment');
    }
  }
);

export const getCommentReplies = createAsyncThunk(
  'comments/getReplies',
  async (params: { commentId: string; page?: number }, { rejectWithValue }) => {
    try {
      const response = await commentAPI.getCommentReplies(params.commentId, params.page);
      return { commentId: params.commentId, ...response.data };
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to get replies');
    }
  }
);

const commentSlice = createSlice({
  name: 'comments',
  initialState,
  reducers: {
    clearCommentError: (state) => {
      state.error = null;
    },
    setReplyingTo: (state, action: PayloadAction<string | null>) => {
      state.replyingTo = action.payload;
    },
    clearPostComments: (state, action: PayloadAction<string>) => {
      delete state.postComments[action.payload];
    },
    updateCommentLocally: (state, action: PayloadAction<{ commentId: string; updates: Partial<Comment> }>) => {
      const { commentId, updates } = action.payload;
      
      // Update in all post comments
      Object.keys(state.postComments).forEach(postId => {
        const comments = state.postComments[postId];
        const updateInArray = (commentsArray: Comment[]) => {
          commentsArray.forEach(comment => {
            if (comment.id === commentId) {
              Object.assign(comment, updates);
            }
            if (comment.replies) {
              updateInArray(comment.replies);
            }
          });
        };
        updateInArray(comments);
      });
    },
    addReplyToComment: (state, action: PayloadAction<{ parentId: string; reply: Comment }>) => {
      const { parentId, reply } = action.payload;
      
      Object.keys(state.postComments).forEach(postId => {
        const comments = state.postComments[postId];
        const findAndAddReply = (commentsArray: Comment[]) => {
          commentsArray.forEach(comment => {
            if (comment.id === parentId) {
              if (!comment.replies) {
                comment.replies = [];
              }
              comment.replies.push(reply);
              comment.replies_count += 1;
            }
            if (comment.replies) {
              findAndAddReply(comment.replies);
            }
          });
        };
        findAndAddReply(comments);
      });
    },
    removeCommentFromPost: (state, action: PayloadAction<{ postId: string; commentId: string }>) => {
      const { postId, commentId } = action.payload;
      
      if (state.postComments[postId]) {
        const removeFromArray = (commentsArray: Comment[]) => {
          return commentsArray.filter(comment => {
            if (comment.id === commentId) {
              return false;
            }
            if (comment.replies) {
              comment.replies = removeFromArray(comment.replies);
            }
            return true;
          });
        };
        
        state.postComments[postId] = removeFromArray(state.postComments[postId]);
      }
    },
  },
  extraReducers: (builder) => {
    // Get post comments
    builder
      .addCase(getPostComments.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(getPostComments.fulfilled, (state, action) => {
        state.isLoading = false;
        const { postId, comments, meta } = action.payload;
        
        if (state.currentPage === 1) {
          state.postComments[postId] = comments;
        } else {
          state.postComments[postId] = [...(state.postComments[postId] || []), ...comments];
        }
        
        state.hasMore = meta?.has_more || false;
        state.currentPage += 1;
        state.error = null;
      })
      .addCase(getPostComments.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      });

    // Create comment
    builder
      .addCase(createComment.pending, (state) => {
        state.isCreating = true;
        state.error = null;
      })
      .addCase(createComment.fulfilled, (state, action) => {
        state.isCreating = false;
        const comment = action.payload;
        const postId = comment.postId;
        
        if (!state.postComments[postId]) {
          state.postComments[postId] = [];
        }
        
        if (comment.parent_comment_id) {
          // This is a reply, add it to the parent comment
          const findAndAddReply = (commentsArray: Comment[]) => {
            commentsArray.forEach(c => {
              if (c.id === comment.parent_comment_id) {
                if (!c.replies) {
                  c.replies = [];
                }
                c.replies.push(comment);
                c.replies_count += 1;
              }
              if (c.replies) {
                findAndAddReply(c.replies);
              }
            });
          };
          findAndAddReply(state.postComments[postId]);
        } else {
          // This is a top-level comment
          state.postComments[postId].unshift(comment);
        }
        
        state.replyingTo = null;
        state.error = null;
      })
      .addCase(createComment.rejected, (state, action) => {
        state.isCreating = false;
        state.error = action.payload as string;
      });

    // Update comment
    builder
      .addCase(updateComment.fulfilled, (state, action) => {
        const updatedComment = action.payload;
        
        Object.keys(state.postComments).forEach(postId => {
          const comments = state.postComments[postId];
          const updateInArray = (commentsArray: Comment[]) => {
            commentsArray.forEach((comment, index) => {
              if (comment.id === updatedComment.id) {
                commentsArray[index] = updatedComment;
              }
              if (comment.replies) {
                updateInArray(comment.replies);
              }
            });
          };
          updateInArray(comments);
        });
      });

    // Delete comment
    builder
      .addCase(deleteComment.fulfilled, (state, action) => {
        const commentId = action.payload;
        
        Object.keys(state.postComments).forEach(postId => {
          const comments = state.postComments[postId];
          const removeFromArray = (commentsArray: Comment[]) => {
            return commentsArray.filter(comment => {
              if (comment.id === commentId) {
                return false;
              }
              if (comment.replies) {
                comment.replies = removeFromArray(comment.replies);
              }
              return true;
            });
          };
          
          state.postComments[postId] = removeFromArray(comments);
        });
      });

    // Like comment
    builder
      .addCase(likeComment.pending, (state) => {
        state.isLiking = true;
      })
      .addCase(likeComment.fulfilled, (state, action) => {
        state.isLiking = false;
        const { commentId, data } = action.payload;
        
        Object.keys(state.postComments).forEach(postId => {
          const comments = state.postComments[postId];
          const updateInArray = (commentsArray: Comment[]) => {
            commentsArray.forEach(comment => {
              if (comment.id === commentId) {
                comment.current_user_liked = data.liked;
                comment.likes_count = data.likes_count;
              }
              if (comment.replies) {
                updateInArray(comment.replies);
              }
            });
          };
          updateInArray(comments);
        });
      })
      .addCase(likeComment.rejected, (state) => {
        state.isLiking = false;
      });

    // Unlike comment
    builder
      .addCase(unlikeComment.fulfilled, (state, action) => {
        const { commentId, data } = action.payload;
        
        Object.keys(state.postComments).forEach(postId => {
          const comments = state.postComments[postId];
          const updateInArray = (commentsArray: Comment[]) => {
            commentsArray.forEach(comment => {
              if (comment.id === commentId) {
                comment.current_user_liked = data.liked;
                comment.likes_count = data.likes_count;
              }
              if (comment.replies) {
                updateInArray(comment.replies);
              }
            });
          };
          updateInArray(comments);
        });
      });

    // Get comment replies
    builder
      .addCase(getCommentReplies.fulfilled, (state, action) => {
        const { commentId, replies } = action.payload;
        
        Object.keys(state.postComments).forEach(postId => {
          const comments = state.postComments[postId];
          const findAndSetReplies = (commentsArray: Comment[]) => {
            commentsArray.forEach(comment => {
              if (comment.id === commentId) {
                comment.replies = replies;
              }
              if (comment.replies) {
                findAndSetReplies(comment.replies);
              }
            });
          };
          findAndSetReplies(comments);
        });
      });
  },
});

export const {
  clearCommentError,
  setReplyingTo,
  clearPostComments,
  updateCommentLocally,
  addReplyToComment,
  removeCommentFromPost,
} = commentSlice.actions;

export default commentSlice.reducer;
