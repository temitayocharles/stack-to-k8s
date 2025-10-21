import React, { useState, useEffect, useRef } from 'react';
import { toast } from 'react-toastify';

const RealTimeNotifications = () => {
  const [isConnected, setIsConnected] = useState(false);
  const [notifications, setNotifications] = useState([]);
  const [connectionStatus, setConnectionStatus] = useState('disconnected');
  const [connectionId] = useState(() => `conn_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`);
  const connectionInterval = useRef(null);
  const notificationSound = useRef(null);

  useEffect(() => {
    // Initialize notification sound
    notificationSound.current = new Audio('/notification-sound.mp3');
    notificationSound.current.volume = 0.3;

    // Connect to real-time system
    connectToRealTime();

    // Cleanup on unmount
    return () => {
      disconnectFromRealTime();
      if (connectionInterval.current) {
        clearInterval(connectionInterval.current);
      }
    };
  }, []);

  const connectToRealTime = async () => {
    try {
      const token = localStorage.getItem('token');
      const userRole = localStorage.getItem('userRole') || 'customer';
      
      setConnectionStatus('connecting');
      
      const response = await fetch('/api/realtime/connect', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          connectionId,
          userRole
        })
      });

      if (response.ok) {
        setIsConnected(true);
        setConnectionStatus('connected');
        toast.success('Connected to real-time updates');
        
        // Start heartbeat to maintain connection
        startHeartbeat();
        
        // Simulate WebSocket message handling
        startMessagePolling();
      } else {
        setConnectionStatus('error');
        toast.error('Failed to connect to real-time updates');
      }
    } catch (error) {
      setConnectionStatus('error');
      toast.error('Connection error occurred');
      console.error('Real-time connection error:', error);
    }
  };

  const disconnectFromRealTime = async () => {
    try {
      const token = localStorage.getItem('token');
      
      await fetch('/api/realtime/disconnect', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          connectionId
        })
      });

      setIsConnected(false);
      setConnectionStatus('disconnected');
      
      if (connectionInterval.current) {
        clearInterval(connectionInterval.current);
      }
    } catch (error) {
      console.error('Disconnect error:', error);
    }
  };

  const startHeartbeat = () => {
    connectionInterval.current = setInterval(() => {
      // Simulate heartbeat to keep connection alive
      fetch('/api/realtime/status', {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      }).catch(() => {
        // Connection lost, attempt to reconnect
        setIsConnected(false);
        setConnectionStatus('reconnecting');
        setTimeout(connectToRealTime, 3000);
      });
    }, 30000); // Every 30 seconds
  };

  const startMessagePolling = () => {
    // In production, this would be replaced with actual WebSocket connection
    // This simulates receiving real-time messages
    const messageInterval = setInterval(() => {
      // This is a simulation - in production, messages would come via WebSocket
      // The actual real-time messages would be sent from the backend routes
    }, 1000);

    return () => clearInterval(messageInterval);
  };

  const handleNewNotification = (notification) => {
    setNotifications(prev => [notification, ...prev.slice(0, 49)]); // Keep last 50
    
    // Play notification sound
    if (notificationSound.current) {
      notificationSound.current.play().catch(() => {
        // Audio play failed, ignore
      });
    }

    // Show toast notification
    const toastContent = (
      <div>
        <strong>{notification.title}</strong>
        <p className="text-sm">{notification.message}</p>
      </div>
    );

    switch (notification.notificationType) {
      case 'success':
        toast.success(toastContent);
        break;
      case 'warning':
        toast.warning(toastContent);
        break;
      case 'error':
        toast.error(toastContent);
        break;
      default:
        toast.info(toastContent);
    }
  };

  const markNotificationAsRead = async (notificationId) => {
    try {
      setNotifications(prev =>
        prev.map(notification =>
          notification.notificationId === notificationId
            ? { ...notification, read: true }
            : notification
        )
      );
    } catch (error) {
      console.error('Failed to mark notification as read:', error);
    }
  };

  const clearAllNotifications = () => {
    setNotifications([]);
  };

  const getNotificationIcon = (type) => {
    switch (type) {
      case 'order_update': return '📦';
      case 'inventory_alert': return '⚠️';
      case 'chat_message': return '💬';
      case 'broadcast': return '📢';
      case 'notification': return '🔔';
      default: return '📢';
    }
  };

  const getConnectionStatusColor = () => {
    switch (connectionStatus) {
      case 'connected': return 'text-green-500';
      case 'connecting': 
      case 'reconnecting': return 'text-yellow-500';
      case 'error': return 'text-red-500';
      default: return 'text-gray-500';
    }
  };

  const getConnectionStatusText = () => {
    switch (connectionStatus) {
      case 'connected': return 'Connected';
      case 'connecting': return 'Connecting...';
      case 'reconnecting': return 'Reconnecting...';
      case 'error': return 'Connection Error';
      default: return 'Disconnected';
    }
  };

  // Simulate receiving different types of notifications
  const simulateOrderUpdate = () => {
    const notification = {
      type: 'order_update',
      notificationId: `notif_${Date.now()}`,
      title: 'Order Updated',
      message: 'Your order #12345 has been shipped and is on its way!',
      notificationType: 'success',
      timestamp: new Date(),
      read: false,
      actionUrl: '/orders/12345'
    };
    handleNewNotification(notification);
  };

  const simulateInventoryAlert = () => {
    const notification = {
      type: 'inventory_alert',
      notificationId: `notif_${Date.now()}`,
      title: 'Low Stock Alert',
      message: 'iPhone 13 Pro Max is running low on stock (3 units remaining)',
      notificationType: 'warning',
      timestamp: new Date(),
      read: false,
      actionUrl: '/admin/inventory'
    };
    handleNewNotification(notification);
  };

  const simulateChatMessage = () => {
    const notification = {
      type: 'chat_message',
      notificationId: `notif_${Date.now()}`,
      title: 'New Message',
      message: 'Customer support: "Thank you for contacting us. How can we help you today?"',
      notificationType: 'info',
      timestamp: new Date(),
      read: false,
      actionUrl: '/chat'
    };
    handleNewNotification(notification);
  };

  return (
    <div className="fixed top-4 right-4 z-50 w-80">
      {/* Connection Status */}
      <div className="bg-white rounded-lg shadow-lg border border-gray-200 mb-4 p-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <div className={`w-3 h-3 rounded-full ${isConnected ? 'bg-green-500' : 'bg-red-500'} animate-pulse`}></div>
            <span className={`text-sm font-medium ${getConnectionStatusColor()}`}>
              {getConnectionStatusText()}
            </span>
          </div>
          
          <div className="flex space-x-2">
            {!isConnected && (
              <button
                onClick={connectToRealTime}
                className="text-xs text-blue-500 hover:text-blue-700"
              >
                Reconnect
              </button>
            )}
            
            {/* Demo buttons */}
            <div className="flex space-x-1">
              <button
                onClick={simulateOrderUpdate}
                className="text-xs bg-green-100 text-green-800 px-2 py-1 rounded"
                title="Simulate Order Update"
              >
                📦
              </button>
              <button
                onClick={simulateInventoryAlert}
                className="text-xs bg-yellow-100 text-yellow-800 px-2 py-1 rounded"
                title="Simulate Inventory Alert"
              >
                ⚠️
              </button>
              <button
                onClick={simulateChatMessage}
                className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded"
                title="Simulate Chat Message"
              >
                💬
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Notifications Panel */}
      {notifications.length > 0 && (
        <div className="bg-white rounded-lg shadow-lg border border-gray-200 max-h-96 overflow-hidden">
          {/* Header */}
          <div className="px-4 py-3 border-b border-gray-200 bg-gray-50">
            <div className="flex items-center justify-between">
              <h3 className="text-sm font-medium text-gray-900">
                Notifications ({notifications.filter(n => !n.read).length})
              </h3>
              <button
                onClick={clearAllNotifications}
                className="text-xs text-gray-500 hover:text-gray-700"
              >
                Clear All
              </button>
            </div>
          </div>

          {/* Notifications List */}
          <div className="max-h-80 overflow-y-auto">
            {notifications.map((notification) => (
              <div
                key={notification.notificationId}
                className={`px-4 py-3 border-b border-gray-100 hover:bg-gray-50 cursor-pointer ${
                  !notification.read ? 'bg-blue-50 border-l-4 border-l-blue-500' : ''
                }`}
                onClick={() => {
                  markNotificationAsRead(notification.notificationId);
                  if (notification.actionUrl) {
                    // In production, navigate to the action URL
                    console.log('Navigate to:', notification.actionUrl);
                  }
                }}
              >
                <div className="flex items-start space-x-3">
                  <span className="text-lg flex-shrink-0">
                    {getNotificationIcon(notification.type)}
                  </span>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between">
                      <p className="text-sm font-medium text-gray-900 truncate">
                        {notification.title}
                      </p>
                      <span className="text-xs text-gray-500">
                        {formatTimeAgo(notification.timestamp)}
                      </span>
                    </div>
                    <p className="text-sm text-gray-600 mt-1 line-clamp-2">
                      {notification.message}
                    </p>
                    {notification.actionUrl && (
                      <p className="text-xs text-blue-500 mt-1">
                        Click to view details →
                      </p>
                    )}
                  </div>
                  {!notification.read && (
                    <div className="w-2 h-2 bg-blue-500 rounded-full flex-shrink-0 mt-2"></div>
                  )}
                </div>
              </div>
            ))}
          </div>

          {/* Footer */}
          <div className="px-4 py-2 bg-gray-50 border-t border-gray-200">
            <p className="text-xs text-gray-500 text-center">
              Real-time notifications are {isConnected ? 'active' : 'inactive'}
            </p>
          </div>
        </div>
      )}

      {/* No Notifications State */}
      {notifications.length === 0 && isConnected && (
        <div className="bg-white rounded-lg shadow-lg border border-gray-200 p-6 text-center">
          <div className="text-4xl mb-2">🔔</div>
          <h3 className="text-sm font-medium text-gray-900 mb-1">
            Real-time notifications active
          </h3>
          <p className="text-xs text-gray-500">
            You'll be notified of order updates, messages, and important alerts
          </p>
          
          {/* Demo section */}
          <div className="mt-4 pt-4 border-t border-gray-200">
            <p className="text-xs text-gray-400 mb-2">Demo: Try notifications</p>
            <div className="flex justify-center space-x-2">
              <button
                onClick={simulateOrderUpdate}
                className="text-xs bg-green-100 text-green-800 px-2 py-1 rounded hover:bg-green-200"
              >
                Order Update
              </button>
              <button
                onClick={simulateInventoryAlert}
                className="text-xs bg-yellow-100 text-yellow-800 px-2 py-1 rounded hover:bg-yellow-200"
              >
                Inventory Alert
              </button>
              <button
                onClick={simulateChatMessage}
                className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded hover:bg-blue-200"
              >
                Chat Message
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

// Helper function to format time ago
const formatTimeAgo = (timestamp) => {
  const now = new Date();
  const diff = now - new Date(timestamp);
  const minutes = Math.floor(diff / 60000);
  const hours = Math.floor(minutes / 60);
  const days = Math.floor(hours / 24);

  if (days > 0) return `${days}d ago`;
  if (hours > 0) return `${hours}h ago`;
  if (minutes > 0) return `${minutes}m ago`;
  return 'Just now';
};

export default RealTimeNotifications;