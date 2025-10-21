import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { useSelector } from 'react-redux';
import { RootState } from '../store';

// Import screens
import LoginScreen from '../screens/auth/LoginScreen';
import RegisterScreen from '../screens/auth/RegisterScreen';
import ForgotPasswordScreen from '../screens/auth/ForgotPasswordScreen';
import ResetPasswordScreen from '../screens/auth/ResetPasswordScreen';

import HomeScreen from '../screens/main/HomeScreen';
import DiscoverScreen from '../screens/main/DiscoverScreen';
import CreatePostScreen from '../screens/main/CreatePostScreen';
import NotificationsScreen from '../screens/main/NotificationsScreen';
import ProfileScreen from '../screens/main/ProfileScreen';

import PostDetailScreen from '../screens/post/PostDetailScreen';
import EditPostScreen from '../screens/post/EditPostScreen';
import UserProfileScreen from '../screens/user/UserProfileScreen';
import EditProfileScreen from '../screens/user/EditProfileScreen';
import FollowersScreen from '../screens/user/FollowersScreen';
import FollowingScreen from '../screens/user/FollowingScreen';
import SearchScreen from '../screens/search/SearchScreen';
import SettingsScreen from '../screens/settings/SettingsScreen';
import PrivacySettingsScreen from '../screens/settings/PrivacySettingsScreen';
import NotificationSettingsScreen from '../screens/settings/NotificationSettingsScreen';

// Navigation parameter types
export type AuthStackParamList = {
  Login: undefined;
  Register: undefined;
  ForgotPassword: undefined;
  ResetPassword: { token: string };
};

export type MainTabParamList = {
  Home: undefined;
  Discover: undefined;
  CreatePost: undefined;
  Notifications: undefined;
  Profile: undefined;
};

export type RootStackParamList = {
  // Auth screens
  Login: undefined;
  Register: undefined;
  ForgotPassword: undefined;
  ResetPassword: { token: string };
  
  // Main tab navigator
  MainTabs: undefined;
  
  // Modal screens
  PostDetail: { postId: string };
  EditPost: { postId: string };
  UserProfile: { username: string };
  EditProfile: undefined;
  Followers: { username: string };
  Following: { username: string };
  Search: { initialQuery?: string };
  Settings: undefined;
  PrivacySettings: undefined;
  NotificationSettings: undefined;
};

const AuthStack = createNativeStackNavigator<AuthStackParamList>();
const MainTab = createBottomTabNavigator<MainTabParamList>();
const RootStack = createNativeStackNavigator<RootStackParamList>();

// Auth Stack Navigator
const AuthStackNavigator = () => {
  return (
    <AuthStack.Navigator
      screenOptions={{
        headerShown: false,
        animation: 'slide_from_right',
      }}
    >
      <AuthStack.Screen name="Login" component={LoginScreen} />
      <AuthStack.Screen name="Register" component={RegisterScreen} />
      <AuthStack.Screen name="ForgotPassword" component={ForgotPasswordScreen} />
      <AuthStack.Screen name="ResetPassword" component={ResetPasswordScreen} />
    </AuthStack.Navigator>
  );
};

// Main Tab Navigator
const MainTabNavigator = () => {
  return (
    <MainTab.Navigator
      screenOptions={({ route }) => ({
        headerShown: false,
        tabBarStyle: {
          backgroundColor: '#ffffff',
          borderTopWidth: 1,
          borderTopColor: '#e1e8ed',
          paddingBottom: 5,
          paddingTop: 5,
          height: 60,
        },
        tabBarActiveTintColor: '#1da1f2',
        tabBarInactiveTintColor: '#657786',
        tabBarLabelStyle: {
          fontSize: 12,
          fontWeight: '500',
        },
        tabBarIcon: ({ focused, color, size }) => {
          let iconName;
          
          switch (route.name) {
            case 'Home':
              iconName = focused ? 'home' : 'home-outline';
              break;
            case 'Discover':
              iconName = focused ? 'search' : 'search-outline';
              break;
            case 'CreatePost':
              iconName = focused ? 'add-circle' : 'add-circle-outline';
              break;
            case 'Notifications':
              iconName = focused ? 'notifications' : 'notifications-outline';
              break;
            case 'Profile':
              iconName = focused ? 'person' : 'person-outline';
              break;
            default:
              iconName = 'home-outline';
          }
          
          // You would return an Icon component here
          // For example: <Ionicons name={iconName} size={size} color={color} />
          return null;
        },
      })}
    >
      <MainTab.Screen 
        name="Home" 
        component={HomeScreen}
        options={{ tabBarLabel: 'Home' }}
      />
      <MainTab.Screen 
        name="Discover" 
        component={DiscoverScreen}
        options={{ tabBarLabel: 'Discover' }}
      />
      <MainTab.Screen 
        name="CreatePost" 
        component={CreatePostScreen}
        options={{ tabBarLabel: 'Post' }}
      />
      <MainTab.Screen 
        name="Notifications" 
        component={NotificationsScreen}
        options={{ 
          tabBarLabel: 'Notifications',
          tabBarBadge: undefined, // Will be set dynamically based on unread count
        }}
      />
      <MainTab.Screen 
        name="Profile" 
        component={ProfileScreen}
        options={{ tabBarLabel: 'Profile' }}
      />
    </MainTab.Navigator>
  );
};

// Root Stack Navigator
const RootStackNavigator = () => {
  const isAuthenticated = useSelector((state: RootState) => state.auth.isAuthenticated);
  
  return (
    <RootStack.Navigator
      screenOptions={{
        headerShown: false,
        animation: 'slide_from_right',
      }}
    >
      {isAuthenticated ? (
        // Authenticated screens
        <RootStack.Group>
          <RootStack.Screen name="MainTabs" component={MainTabNavigator} />
          
          {/* Modal screens */}
          <RootStack.Group screenOptions={{ presentation: 'modal' }}>
            <RootStack.Screen 
              name="PostDetail" 
              component={PostDetailScreen}
              options={{
                headerShown: true,
                title: 'Post',
                animation: 'slide_from_bottom',
              }}
            />
            <RootStack.Screen 
              name="EditPost" 
              component={EditPostScreen}
              options={{
                headerShown: true,
                title: 'Edit Post',
                animation: 'slide_from_bottom',
              }}
            />
            <RootStack.Screen 
              name="UserProfile" 
              component={UserProfileScreen}
              options={{
                headerShown: true,
                title: 'Profile',
              }}
            />
            <RootStack.Screen 
              name="EditProfile" 
              component={EditProfileScreen}
              options={{
                headerShown: true,
                title: 'Edit Profile',
                animation: 'slide_from_bottom',
              }}
            />
            <RootStack.Screen 
              name="Followers" 
              component={FollowersScreen}
              options={{
                headerShown: true,
                title: 'Followers',
              }}
            />
            <RootStack.Screen 
              name="Following" 
              component={FollowingScreen}
              options={{
                headerShown: true,
                title: 'Following',
              }}
            />
            <RootStack.Screen 
              name="Search" 
              component={SearchScreen}
              options={{
                headerShown: true,
                title: 'Search',
                animation: 'slide_from_bottom',
              }}
            />
            <RootStack.Screen 
              name="Settings" 
              component={SettingsScreen}
              options={{
                headerShown: true,
                title: 'Settings',
              }}
            />
            <RootStack.Screen 
              name="PrivacySettings" 
              component={PrivacySettingsScreen}
              options={{
                headerShown: true,
                title: 'Privacy Settings',
              }}
            />
            <RootStack.Screen 
              name="NotificationSettings" 
              component={NotificationSettingsScreen}
              options={{
                headerShown: true,
                title: 'Notification Settings',
              }}
            />
          </RootStack.Group>
        </RootStack.Group>
      ) : (
        // Authentication screens
        <RootStack.Group>
          <RootStack.Screen name="Login" component={LoginScreen} />
          <RootStack.Screen name="Register" component={RegisterScreen} />
          <RootStack.Screen name="ForgotPassword" component={ForgotPasswordScreen} />
          <RootStack.Screen name="ResetPassword" component={ResetPasswordScreen} />
        </RootStack.Group>
      )}
    </RootStack.Navigator>
  );
};

// Main Navigation Component
const AppNavigator = () => {
  return (
    <NavigationContainer>
      <RootStackNavigator />
    </NavigationContainer>
  );
};

export default AppNavigator;
