const express = require('express');
const { body, validationResult } = require('express-validator');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

// Store active connections (in production, use Redis)
const activeConnections = new Map();
const adminConnections = new Set();

// @route   POST /api/realtime/connect
// @desc    Register user for real-time updates
// @access  Private
router.post('/connect', authenticate, async (req, res) => {
  try {
    const userId = req.user.id;
    const { connectionId, userRole } = req.body;

    // Store connection info
    activeConnections.set(connectionId, {
      userId: userId,
      role: userRole,
      connectedAt: new Date(),
      lastActivity: new Date()
    });

    // Add to admin connections if user is admin
    if (userRole === 'admin') {
      adminConnections.add(connectionId);
    }

    console.log(`User ${userId} connected with ID ${connectionId}`);

    res.json({
      message: 'Connected to real-time updates',
      connectionId: connectionId,
      features: {
        orderUpdates: true,
        inventoryAlerts: userRole === 'admin',
        chatSupport: true,
        notifications: true
      }
    });
  } catch (error) {
    console.error('Real-time connection error:', error);
    res.status(500).json({ message: 'Connection failed' });
  }
});

// @route   POST /api/realtime/disconnect
// @desc    Disconnect user from real-time updates
// @access  Private
router.post('/disconnect', authenticate, async (req, res) => {
  try {
    const { connectionId } = req.body;

    // Remove from active connections
    activeConnections.delete(connectionId);
    adminConnections.delete(connectionId);

    console.log(`Connection ${connectionId} disconnected`);

    res.json({ message: 'Disconnected successfully' });
  } catch (error) {
    console.error('Disconnect error:', error);
    res.status(500).json({ message: 'Disconnect failed' });
  }
});

// @route   POST /api/realtime/order-update
// @desc    Send real-time order status update
// @access  Private (System/Admin)
router.post('/order-update', authenticate, async (req, res) => {
  try {
    const { orderId, status, userId, message, metadata } = req.body;

    const updateData = {
      type: 'order_update',
      orderId: orderId,
      status: status,
      message: message,
      metadata: metadata,
      timestamp: new Date()
    };

    // Send to specific user
    const userConnections = Array.from(activeConnections.entries())
      .filter(([connectionId, conn]) => conn.userId === userId);

    console.log(`Sending order update to ${userConnections.length} connections for user ${userId}`);

    // Simulate WebSocket broadcast (in production, use socket.io)
    userConnections.forEach(([connectionId, conn]) => {
      console.log(`Broadcasting to connection ${connectionId}:`, updateData);
    });

    // Also send to admin connections for monitoring
    const adminUpdate = {
      ...updateData,
      type: 'admin_order_update',
      customerInfo: { userId: userId }
    };

    adminConnections.forEach(connectionId => {
      console.log(`Broadcasting to admin ${connectionId}:`, adminUpdate);
    });

    res.json({
      message: 'Order update broadcasted',
      sentTo: userConnections.length,
      adminNotified: adminConnections.size
    });
  } catch (error) {
    console.error('Order update broadcast error:', error);
    res.status(500).json({ message: 'Failed to send order update' });
  }
});

// @route   POST /api/realtime/inventory-alert
// @desc    Send real-time inventory alert to admins
// @access  Private (System)
router.post('/inventory-alert', authenticate, async (req, res) => {
  try {
    const { productId, productName, currentStock, threshold, alertType } = req.body;

    const alertData = {
      type: 'inventory_alert',
      alertType: alertType, // 'low_stock', 'out_of_stock', 'restock_needed'
      product: {
        id: productId,
        name: productName,
        currentStock: currentStock,
        threshold: threshold
      },
      severity: currentStock === 0 ? 'critical' : 
                currentStock <= 5 ? 'high' : 'medium',
      timestamp: new Date(),
      action: currentStock === 0 ? 'restock_immediately' : 'monitor_closely'
    };

    // Broadcast to all admin connections
    console.log(`Broadcasting inventory alert to ${adminConnections.size} admin connections`);
    adminConnections.forEach(connectionId => {
      console.log(`Sending inventory alert to admin ${connectionId}:`, alertData);
    });

    res.json({
      message: 'Inventory alert broadcasted',
      adminNotified: adminConnections.size,
      severity: alertData.severity
    });
  } catch (error) {
    console.error('Inventory alert error:', error);
    res.status(500).json({ message: 'Failed to send inventory alert' });
  }
});

// @route   POST /api/realtime/chat-message
// @desc    Send real-time chat message
// @access  Private
router.post('/chat-message', authenticate, [
  body('message').trim().notEmpty().withMessage('Message is required'),
  body('chatId').notEmpty().withMessage('Chat ID is required'),
  body('recipientId').optional().isMongoId().withMessage('Valid recipient ID required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { message, chatId, recipientId, messageType = 'text' } = req.body;
    const senderId = req.user.id;

    const chatMessage = {
      type: 'chat_message',
      chatId: chatId,
      senderId: senderId,
      senderName: `${req.user.firstName} ${req.user.lastName}`,
      recipientId: recipientId,
      message: message,
      messageType: messageType,
      timestamp: new Date(),
      messageId: `msg_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
    };

    // Send to recipient if specified
    if (recipientId) {
      const recipientConnections = Array.from(activeConnections.entries())
        .filter(([connectionId, conn]) => conn.userId === recipientId);

      recipientConnections.forEach(([connectionId, conn]) => {
        console.log(`Sending chat message to ${connectionId}:`, chatMessage);
      });
    }

    // Send to all participants in the chat (for group chats)
    const chatConnections = Array.from(activeConnections.entries())
      .filter(([connectionId, conn]) => {
        // In production, check if user is part of the chat
        return true; // Simplified for demo
      });

    chatConnections.forEach(([connectionId, conn]) => {
      if (conn.userId !== senderId) { // Don't send back to sender
        console.log(`Broadcasting chat message to ${connectionId}:`, chatMessage);
      }
    });

    res.json({
      message: 'Chat message sent',
      messageId: chatMessage.messageId,
      sentTo: chatConnections.length
    });
  } catch (error) {
    console.error('Chat message error:', error);
    res.status(500).json({ message: 'Failed to send chat message' });
  }
});

// @route   POST /api/realtime/notification
// @desc    Send real-time notification to user
// @access  Private (System/Admin)
router.post('/notification', authenticate, [
  body('userId').isMongoId().withMessage('Valid user ID required'),
  body('title').trim().notEmpty().withMessage('Title is required'),
  body('message').trim().notEmpty().withMessage('Message is required'),
  body('type').isIn(['info', 'success', 'warning', 'error']).withMessage('Valid notification type required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { userId, title, message, type, actionUrl, persistent = false } = req.body;

    const notification = {
      type: 'notification',
      notificationId: `notif_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      userId: userId,
      title: title,
      message: message,
      notificationType: type,
      actionUrl: actionUrl,
      persistent: persistent,
      timestamp: new Date(),
      read: false
    };

    // Send to user's active connections
    const userConnections = Array.from(activeConnections.entries())
      .filter(([connectionId, conn]) => conn.userId === userId);

    userConnections.forEach(([connectionId, conn]) => {
      console.log(`Sending notification to ${connectionId}:`, notification);
    });

    // If user is not connected and notification is persistent, store it
    if (userConnections.length === 0 && persistent) {
      console.log('User not connected, storing persistent notification:', notification);
      // In production, save to database for later delivery
    }

    res.json({
      message: 'Notification sent',
      notificationId: notification.notificationId,
      delivered: userConnections.length > 0,
      stored: userConnections.length === 0 && persistent
    });
  } catch (error) {
    console.error('Notification error:', error);
    res.status(500).json({ message: 'Failed to send notification' });
  }
});

// @route   GET /api/realtime/status
// @desc    Get real-time system status
// @access  Private (Admin)
router.get('/status', authenticate, async (req, res) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Admin access required' });
    }

    const connectionStats = {
      totalConnections: activeConnections.size,
      adminConnections: adminConnections.size,
      userConnections: activeConnections.size - adminConnections.size,
      connectionDetails: Array.from(activeConnections.entries()).map(([connectionId, conn]) => ({
        connectionId,
        userId: conn.userId,
        role: conn.role,
        connectedAt: conn.connectedAt,
        lastActivity: conn.lastActivity,
        duration: Math.floor((new Date() - conn.connectedAt) / 1000 / 60) // minutes
      }))
    };

    res.json({
      status: 'operational',
      timestamp: new Date(),
      connections: connectionStats,
      features: {
        orderUpdates: true,
        inventoryAlerts: true,
        chatSupport: true,
        notifications: true,
        adminBroadcast: true
      }
    });
  } catch (error) {
    console.error('Real-time status error:', error);
    res.status(500).json({ message: 'Failed to get status' });
  }
});

// @route   POST /api/realtime/broadcast
// @desc    Broadcast message to all connected users
// @access  Private (Admin)
router.post('/broadcast', authenticate, [
  body('message').trim().notEmpty().withMessage('Message is required'),
  body('type').isIn(['announcement', 'maintenance', 'promotion', 'alert']).withMessage('Valid broadcast type required')
], async (req, res) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Admin access required' });
    }

    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { message, type, title, actionUrl, targetRole } = req.body;

    const broadcastMessage = {
      type: 'broadcast',
      broadcastType: type,
      title: title || 'System Announcement',
      message: message,
      actionUrl: actionUrl,
      timestamp: new Date(),
      broadcastId: `broadcast_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      sender: {
        id: req.user.id,
        name: `${req.user.firstName} ${req.user.lastName}`
      }
    };

    // Filter connections by target role if specified
    let targetConnections = Array.from(activeConnections.entries());
    if (targetRole) {
      targetConnections = targetConnections.filter(([connectionId, conn]) => 
        conn.role === targetRole
      );
    }

    // Broadcast to all target connections
    targetConnections.forEach(([connectionId, conn]) => {
      console.log(`Broadcasting to ${connectionId}:`, broadcastMessage);
    });

    res.json({
      message: 'Broadcast sent successfully',
      broadcastId: broadcastMessage.broadcastId,
      sentTo: targetConnections.length,
      targetRole: targetRole || 'all'
    });
  } catch (error) {
    console.error('Broadcast error:', error);
    res.status(500).json({ message: 'Failed to send broadcast' });
  }
});

// Utility function to cleanup inactive connections
function cleanupInactiveConnections() {
  const now = new Date();
  const timeout = 30 * 60 * 1000; // 30 minutes

  for (const [connectionId, conn] of activeConnections.entries()) {
    if (now - conn.lastActivity > timeout) {
      console.log(`Cleaning up inactive connection: ${connectionId}`);
      activeConnections.delete(connectionId);
      adminConnections.delete(connectionId);
    }
  }
}

// Run cleanup every 10 minutes
setInterval(cleanupInactiveConnections, 10 * 60 * 1000);

module.exports = router;