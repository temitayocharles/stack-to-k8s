import React, { createContext, useContext, useReducer, useEffect } from 'react';
import Cookies from 'js-cookie';
import { authService } from '../services';
import toast from 'react-hot-toast';

const AuthContext = createContext();

const initialState = {
  user: null,
  token: null,
  loading: true,
  error: null
};

const authReducer = (state, action) => {
  switch (action.type) {
    case 'SET_LOADING':
      return { ...state, loading: action.payload };
    case 'SET_USER':
      return { ...state, user: action.payload, loading: false, error: null };
    case 'SET_TOKEN':
      return { ...state, token: action.payload };
    case 'SET_ERROR':
      return { ...state, error: action.payload, loading: false };
    case 'LOGOUT':
      return { ...initialState, loading: false };
    default:
      return state;
  }
};

export const AuthProvider = ({ children }) => {
  const [state, dispatch] = useReducer(authReducer, initialState);

  // Check for existing token on mount
  useEffect(() => {
    const token = Cookies.get('token');
    if (token) {
      dispatch({ type: 'SET_TOKEN', payload: token });
      getCurrentUser();
    } else {
      dispatch({ type: 'SET_LOADING', payload: false });
    }
  }, []);

  const getCurrentUser = async () => {
    try {
      const data = await authService.getCurrentUser();
      dispatch({ type: 'SET_USER', payload: data.user });
    } catch (error) {
      console.error('Get current user error:', error);
      logout();
    }
  };

  const login = async (credentials) => {
    try {
      dispatch({ type: 'SET_LOADING', payload: true });
      const data = await authService.login(credentials);
      
      // Set token in cookie
      Cookies.set('token', data.token, { expires: 30 });
      
      dispatch({ type: 'SET_TOKEN', payload: data.token });
      dispatch({ type: 'SET_USER', payload: data.user });
      
      toast.success('Login successful!');
      return data;
    } catch (error) {
      const message = error.response?.data?.message || 'Login failed';
      dispatch({ type: 'SET_ERROR', payload: message });
      toast.error(message);
      throw error;
    }
  };

  const register = async (userData) => {
    try {
      dispatch({ type: 'SET_LOADING', payload: true });
      const data = await authService.register(userData);
      
      // Set token in cookie
      Cookies.set('token', data.token, { expires: 30 });
      
      dispatch({ type: 'SET_TOKEN', payload: data.token });
      dispatch({ type: 'SET_USER', payload: data.user });
      
      toast.success('Registration successful!');
      return data;
    } catch (error) {
      const message = error.response?.data?.message || 'Registration failed';
      dispatch({ type: 'SET_ERROR', payload: message });
      toast.error(message);
      throw error;
    }
  };

  const logout = () => {
    Cookies.remove('token');
    dispatch({ type: 'LOGOUT' });
    toast.success('Logged out successfully');
  };

  const updateProfile = async (userData) => {
    try {
      const data = await authService.updateProfile(userData);
      dispatch({ type: 'SET_USER', payload: data.user });
      toast.success('Profile updated successfully!');
      return data;
    } catch (error) {
      const message = error.response?.data?.message || 'Update failed';
      toast.error(message);
      throw error;
    }
  };

  const value = {
    user: state.user,
    token: state.token,
    loading: state.loading,
    error: state.error,
    login,
    register,
    logout,
    updateProfile,
    getCurrentUser
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
