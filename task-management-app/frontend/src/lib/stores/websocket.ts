import { writable, get } from 'svelte/store';
import { tasksStore, commentsStore } from './data';
import { showSuccess, showInfo, showError } from './toast';

// Enhanced WebSocket message interface matching backend structure
export interface WebSocketMessage {
  id: string;
  type: WSMessageType;
  data: any;
  user_id: string;
  username: string;
  room?: string;
  timestamp: number;
  requires_ack?: boolean;
}

export type WSMessageType = 
  // Task related messages
  | 'task_created' | 'task_updated' | 'task_deleted' | 'task_assigned'
  // Collaboration messages
  | 'user_typing' | 'user_presence' | 'cursor_position' | 'document_edit'
  // System messages  
  | 'user_joined' | 'user_left' | 'room_joined' | 'room_left'
  | 'notification' | 'heartbeat' | 'error' | 'acknowledgment';

export interface UserPresence {
  user_id: string;
  username: string;
  status: 'online' | 'away' | 'busy' | 'offline' | 'focused';
  activity: string;
  last_seen: number;
}

export interface CursorPosition {
  user_id: string;
  username: string;
  task_id: string;
  x: number;
  y: number;
  element?: string;
}

export interface TypingIndicator {
  user_id: string;
  username: string;
  task_id: string;
  is_typing: boolean;
}

// Enhanced stores
export const websocketStore = writable<WebSocket | null>(null);
export const connectionStatusStore = writable<'connecting' | 'connected' | 'disconnected'>('disconnected');
export const userPresenceStore = writable<Map<string, UserPresence>>(new Map());
export const activeCursorsStore = writable<Map<string, CursorPosition>>(new Map());
export const typingIndicatorsStore = writable<Map<string, TypingIndicator>>(new Map());
export const connectedUsersStore = writable<string[]>([]);

// User info
let currentUserId = `user_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
let currentUsername = 'Anonymous User';

// Configuration
let reconnectAttempts = 0;
const maxReconnectAttempts = 5;
const reconnectDelay = 3000;

export function setUserInfo(userId: string, username: string) {
  currentUserId = userId;
  currentUsername = username;
}

export function connectWebSocket() {
  const wsUrl = `${import.meta.env.VITE_WS_URL || 'ws://localhost:8082/api/v1/ws'}?user_id=${currentUserId}&username=${encodeURIComponent(currentUsername)}`;
  
  connectionStatusStore.set('connecting');
  
  try {
    const ws = new WebSocket(wsUrl);
    
    ws.onopen = () => {
      console.log('✅ Enhanced WebSocket connected');
      connectionStatusStore.set('connected');
      websocketStore.set(ws);
      reconnectAttempts = 0;
      
      // Send initial presence
      sendMessage({
        type: 'user_presence',
        data: { status: 'online', activity: 'Active' }
      });
      
      showSuccess('Connected', 'Real-time collaboration enabled');
    };
    
    ws.onmessage = (event) => {
      try {
        const message: WebSocketMessage = JSON.parse(event.data);
        handleWebSocketMessage(message);
      } catch (error) {
        console.error('Failed to parse WebSocket message:', error);
      }
    };
    
    ws.onclose = (event) => {
      console.log('WebSocket disconnected:', event.code, event.reason);
      connectionStatusStore.set('disconnected');
      websocketStore.set(null);
      
      // Clear presence and collaboration data
      userPresenceStore.set(new Map());
      activeCursorsStore.set(new Map());
      typingIndicatorsStore.set(new Map());
      connectedUsersStore.set([]);
      
      // Attempt to reconnect
      if (reconnectAttempts < maxReconnectAttempts) {
        reconnectAttempts++;
        console.log(`Attempting to reconnect... (${reconnectAttempts}/${maxReconnectAttempts})`);
        
        setTimeout(() => {
          connectWebSocket();
        }, reconnectDelay * reconnectAttempts);
      } else {
        showError('Connection Lost', 'Unable to establish real-time connection');
      }
    };
    
    ws.onerror = (error) => {
      console.error('WebSocket error:', error);
      connectionStatusStore.set('disconnected');
    };
    
  } catch (error) {
    console.error('Failed to create WebSocket connection:', error);
    connectionStatusStore.set('disconnected');
    showError('Connection Failed', 'Unable to connect to real-time updates');
  }
}

// Send message to WebSocket
export function sendMessage(partialMessage: { type: WSMessageType; data: any; room?: string }) {
  const ws = get(websocketStore);
  if (!ws || ws.readyState !== WebSocket.OPEN) {
    console.warn('WebSocket not connected, message not sent:', partialMessage);
    return;
  }

  const message: WebSocketMessage = {
    id: `${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
    type: partialMessage.type,
    data: partialMessage.data,
    user_id: currentUserId,
    username: currentUsername,
    room: partialMessage.room,
    timestamp: Date.now()
  };

  ws.send(JSON.stringify(message));
}

// Enhanced message handling
function handleWebSocketMessage(message: WebSocketMessage) {
  console.log('📨 Enhanced WebSocket message:', message);
  
  switch (message.type) {
    case 'task_created':
      handleTaskCreated(message.data);
      break;
    case 'task_updated':
      handleTaskUpdated(message.data);
      break;
    case 'task_deleted':
      handleTaskDeleted(message.data);
      break;
    case 'user_joined':
      handleUserJoined(message.data);
      break;
    case 'user_left':
      handleUserLeft(message.data);
      break;
    case 'user_presence':
      handleUserPresence(message.data);
      break;
    case 'user_typing':
      handleTypingIndicator(message.data);
      break;
    case 'cursor_position':
      handleCursorPosition(message.data);
      break;
    case 'heartbeat':
      // Handle heartbeat silently
      break;
    case 'error':
      handleError(message.data);
      break;
    default:
      console.log('Unknown message type:', message.type);
  }
}

// Task-related handlers
function handleTaskCreated(task: any) {
  tasksStore.update(tasks => [...tasks, task]);
  showInfo('Task Created', `"${task.title}" was created by ${task.username || 'someone'}`);
}

function handleTaskUpdated(task: any) {
  tasksStore.update(tasks => 
    tasks.map(t => t.id === task.id ? task : t)
  );
  showInfo('Task Updated', `"${task.title}" was updated`);
}

function handleTaskDeleted(data: { id: string }) {
  tasksStore.update(tasks => 
    tasks.filter(t => t.id !== data.id)
  );
  showInfo('Task Deleted', 'A task was deleted');
}

// Collaboration handlers
function handleUserJoined(presence: UserPresence) {
  userPresenceStore.update(users => {
    users.set(presence.user_id, presence);
    return users;
  });
  
  connectedUsersStore.update(userIds => {
    if (!userIds.includes(presence.user_id)) {
      userIds.push(presence.user_id);
    }
    return userIds;
  });
  
  if (presence.user_id !== currentUserId) {
    showInfo('User Joined', `${presence.username} joined the workspace`);
  }
}

function handleUserLeft(data: { user_id: string; username: string }) {
  userPresenceStore.update(users => {
    users.delete(data.user_id);
    return users;
  });
  
  connectedUsersStore.update(userIds => 
    userIds.filter(id => id !== data.user_id)
  );
  
  // Remove typing indicators and cursors
  typingIndicatorsStore.update(typing => {
    typing.delete(data.user_id);
    return typing;
  });
  
  activeCursorsStore.update(cursors => {
    cursors.delete(data.user_id);
    return cursors;
  });
  
  if (data.user_id !== currentUserId) {
    showInfo('User Left', `${data.username} left the workspace`);
  }
}

function handleUserPresence(presence: UserPresence) {
  userPresenceStore.update(users => {
    users.set(presence.user_id, presence);
    return users;
  });
}

function handleTypingIndicator(typing: TypingIndicator) {
  if (typing.user_id === currentUserId) return; // Ignore own typing
  
  typingIndicatorsStore.update(indicators => {
    if (typing.is_typing) {
      indicators.set(typing.user_id, typing);
    } else {
      indicators.delete(typing.user_id);
    }
    return indicators;
  });
  
  // Auto-clear typing indicators after 3 seconds
  if (typing.is_typing) {
    setTimeout(() => {
      typingIndicatorsStore.update(indicators => {
        indicators.delete(typing.user_id);
        return indicators;
      });
    }, 3000);
  }
}

function handleCursorPosition(cursor: CursorPosition) {
  if (cursor.user_id === currentUserId) return; // Ignore own cursor
  
  activeCursorsStore.update(cursors => {
    cursors.set(cursor.user_id, cursor);
    return cursors;
  });
  
  // Auto-clear cursor after 5 seconds of inactivity
  setTimeout(() => {
    activeCursorsStore.update(cursors => {
      cursors.delete(cursor.user_id);
      return cursors;
    });
  }, 5000);
}

function handleError(error: any) {
  console.error('WebSocket error message:', error);
  showError('Collaboration Error', error.error || 'An error occurred');
}

// Collaboration utility functions
export function sendTypingIndicator(taskId: string, isTyping: boolean) {
  sendMessage({
    type: 'user_typing',
    data: {
      user_id: currentUserId,
      username: currentUsername,
      task_id: taskId,
      is_typing: isTyping
    }
  });
}

export function sendCursorPosition(taskId: string, x: number, y: number, element?: string) {
  sendMessage({
    type: 'cursor_position',
    data: {
      user_id: currentUserId,
      username: currentUsername,
      task_id: taskId,
      x,
      y,
      element
    }
  });
}

export function updatePresence(status: UserPresence['status'], activity: string) {
  sendMessage({
    type: 'user_presence',
    data: {
      status,
      activity
    }
  });
}

export function joinRoom(roomId: string) {
  sendMessage({
    type: 'room_joined',
    data: { room_id: roomId }
  });
}

export function leaveRoom(roomId: string) {
  sendMessage({
    type: 'room_left', 
    data: { room_id: roomId }
  });
}

export function disconnectWebSocket() {
  // Send offline status before disconnecting
  const ws = get(websocketStore);
  if (ws && ws.readyState === WebSocket.OPEN) {
    updatePresence('offline', 'Disconnecting');
  }
  
  websocketStore.update(ws => {
    if (ws) {
      ws.close();
    }
    return null;
  });
  
  connectionStatusStore.set('disconnected');
  userPresenceStore.set(new Map());
  activeCursorsStore.set(new Map());
  typingIndicatorsStore.set(new Map());
  connectedUsersStore.set([]);
}

// Get current user info
export function getCurrentUser() {
  return { userId: currentUserId, username: currentUsername };
}
