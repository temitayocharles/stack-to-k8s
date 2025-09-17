import { writable } from 'svelte/store';
import { tasksStore, commentsStore } from './data';
import { showSuccess, showInfo, showError } from './toast';

export interface WebSocketMessage {
  type: string;
  data: any;
  timestamp: string;
}

export const websocketStore = writable<WebSocket | null>(null);
export const connectionStatusStore = writable<'connecting' | 'connected' | 'disconnected'>('disconnected');

let reconnectAttempts = 0;
const maxReconnectAttempts = 5;
const reconnectDelay = 3000;

export function connectWebSocket() {
  const wsUrl = import.meta.env.VITE_WS_URL || 'ws://localhost:8080/api/v1/ws';
  
  connectionStatusStore.set('connecting');
  
  try {
    const ws = new WebSocket(wsUrl);
    
    ws.onopen = () => {
      console.log('✅ WebSocket connected');
      connectionStatusStore.set('connected');
      websocketStore.set(ws);
      reconnectAttempts = 0;
      
      showSuccess('Connected', 'Real-time updates enabled');
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

function handleWebSocketMessage(message: WebSocketMessage) {
  console.log('📨 WebSocket message:', message);
  
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
    case 'comment_created':
      handleCommentCreated(message.data);
      break;
    default:
      console.log('Unknown message type:', message.type);
  }
}

function handleTaskCreated(task: any) {
  tasksStore.update(tasks => [...tasks, task]);
  showInfo('Task Created', `"${task.title}" was created`);
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

function handleCommentCreated(comment: any) {
  commentsStore.update(comments => [...comments, comment]);
  showInfo('New Comment', 'A new comment was added');
}

export function disconnectWebSocket() {
  websocketStore.update(ws => {
    if (ws) {
      ws.close();
    }
    return null;
  });
  connectionStatusStore.set('disconnected');
}
