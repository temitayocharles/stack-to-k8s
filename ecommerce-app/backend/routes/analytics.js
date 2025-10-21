const express = require('express');
const { body, validationResult } = require('express-validator');
const Product = require('../models/Product');
const User = require('../models/User');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

// @route   POST /api/analytics/product-view
// @desc    Track product views for analytics
// @access  Public
router.post('/product-view', [
  body('productId').isMongoId().withMessage('Valid product ID is required'),
  body('userId').optional().isMongoId().withMessage('Valid user ID required if provided'),
  body('sessionId').trim().notEmpty().withMessage('Session ID is required'),
  body('source').optional().isIn(['search', 'category', 'recommendation', 'direct', 'external']).withMessage('Invalid source')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { productId, userId, sessionId, source = 'direct', referrer } = req.body;

    // Update product view count
    await Product.findByIdAndUpdate(productId, { 
      $inc: { viewCount: 1 }
    });

    // Store detailed analytics (in real app, this would go to analytics service)
    const analyticsData = {
      type: 'product_view',
      productId,
      userId,
      sessionId,
      source,
      referrer,
      timestamp: new Date(),
      userAgent: req.headers['user-agent'],
      ip: req.ip
    };

    // In production, send to analytics service (Google Analytics, Mixpanel, etc.)
    console.log('Analytics Event:', analyticsData);

    res.json({ success: true, message: 'View tracked' });
  } catch (error) {
    console.error('Track view error:', error);
    res.status(500).json({ message: 'Analytics tracking error' });
  }
});

// @route   POST /api/analytics/add-to-cart
// @desc    Track add to cart events
// @access  Private
router.post('/add-to-cart', authenticate, [
  body('productId').isMongoId().withMessage('Valid product ID is required'),
  body('quantity').isInt({ min: 1 }).withMessage('Quantity must be at least 1'),
  body('price').isFloat({ min: 0 }).withMessage('Price must be non-negative')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { productId, quantity, price } = req.body;

    const analyticsData = {
      type: 'add_to_cart',
      productId,
      userId: req.user.id,
      quantity,
      price,
      value: price * quantity,
      timestamp: new Date()
    };

    // Track conversion funnel progress
    console.log('Conversion Event:', analyticsData);

    res.json({ success: true, message: 'Add to cart tracked' });
  } catch (error) {
    console.error('Track add to cart error:', error);
    res.status(500).json({ message: 'Analytics tracking error' });
  }
});

// @route   GET /api/analytics/recommendations/:userId
// @desc    Get personalized product recommendations
// @access  Private
router.get('/recommendations/:userId', authenticate, async (req, res) => {
  try {
    const userId = req.params.userId;
    
    // Get user's order history for collaborative filtering
    const user = await User.findById(userId).populate('wishlist');
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Simple recommendation algorithm based on:
    // 1. User's wishlist categories
    // 2. Previously purchased categories
    // 3. Popular products in those categories
    
    const wishlistCategories = user.wishlist.map(item => item.category);
    
    let recommendations = [];
    
    if (wishlistCategories.length > 0) {
      // Get products from wishlist categories
      recommendations = await Product.find({
        category: { $in: wishlistCategories },
        _id: { $nin: user.wishlist.map(item => item._id) },
        status: 'active'
      })
      .populate('category', 'name')
      .sort({ 'ratings.average': -1, salesCount: -1 })
      .limit(8);
    }
    
    // If not enough recommendations, add popular products
    if (recommendations.length < 8) {
      const additionalRecs = await Product.find({
        _id: { $nin: [...user.wishlist.map(item => item._id), ...recommendations.map(item => item._id)] },
        status: 'active',
        featured: true
      })
      .populate('category', 'name')
      .sort({ salesCount: -1, 'ratings.average': -1 })
      .limit(8 - recommendations.length);
      
      recommendations = [...recommendations, ...additionalRecs];
    }

    res.json({ 
      recommendations,
      algorithm: 'collaborative_filtering_v1',
      timestamp: new Date()
    });
  } catch (error) {
    console.error('Get recommendations error:', error);
    res.status(500).json({ message: 'Recommendations error' });
  }
});

// @route   GET /api/analytics/trending
// @desc    Get trending products based on recent activity
// @access  Public
router.get('/trending', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    const timeframe = req.query.timeframe || '7d'; // 1d, 7d, 30d
    
    // Calculate date threshold
    const daysAgo = timeframe === '1d' ? 1 : timeframe === '7d' ? 7 : 30;
    const dateThreshold = new Date();
    dateThreshold.setDate(dateThreshold.getDate() - daysAgo);
    
    // Get products with highest view counts and sales in timeframe
    // In production, this would query analytics data
    const trendingProducts = await Product.find({
      status: 'active',
      updatedAt: { $gte: dateThreshold }
    })
    .populate('category', 'name')
    .sort({ 
      viewCount: -1, 
      salesCount: -1, 
      'ratings.average': -1 
    })
    .limit(limit);

    res.json({
      products: trendingProducts,
      timeframe,
      algorithm: 'view_and_sales_velocity',
      lastUpdated: new Date()
    });
  } catch (error) {
    console.error('Get trending error:', error);
    res.status(500).json({ message: 'Trending products error' });
  }
});

// @route   POST /api/analytics/purchase-complete
// @desc    Track completed purchases for conversion analytics
// @access  Private
router.post('/purchase-complete', authenticate, [
  body('orderId').isMongoId().withMessage('Valid order ID is required'),
  body('totalAmount').isFloat({ min: 0 }).withMessage('Total amount must be non-negative'),
  body('items').isArray({ min: 1 }).withMessage('Items array is required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { orderId, totalAmount, items, paymentMethod } = req.body;

    const purchaseData = {
      type: 'purchase_complete',
      orderId,
      userId: req.user.id,
      totalAmount,
      itemCount: items.length,
      items: items.map(item => ({
        productId: item.productId,
        quantity: item.quantity,
        price: item.price
      })),
      paymentMethod,
      timestamp: new Date()
    };

    // Track conversion completion
    console.log('Purchase Conversion:', purchaseData);

    // Update product sales counts
    for (const item of items) {
      await Product.findByIdAndUpdate(item.productId, {
        $inc: { salesCount: item.quantity }
      });
    }

    res.json({ success: true, message: 'Purchase tracked' });
  } catch (error) {
    console.error('Track purchase error:', error);
    res.status(500).json({ message: 'Purchase tracking error' });
  }
});

// @route   GET /api/analytics/user-behavior/:userId
// @desc    Get user behavior insights
// @access  Private (Admin or own user)
router.get('/user-behavior/:userId', authenticate, async (req, res) => {
  try {
    const userId = req.params.userId;
    
    // Check authorization
    if (req.user.id !== userId && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Access denied' });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Calculate user behavior metrics
    // In production, this would aggregate from analytics events
    const behaviorData = {
      userId,
      profileCompleteness: calculateProfileCompleteness(user),
      wishlistSize: user.wishlist.length,
      averageSessionDuration: '5m 32s', // Mock data
      preferredCategories: ['Electronics', 'Clothing'], // Mock data
      browsingPattern: 'evening_shopper', // Mock data
      conversionRate: 0.12, // Mock data
      lifetimeValue: 1250.50, // Mock data
      riskSegment: 'low_churn_risk',
      lastActive: user.lastLoginAt || user.updatedAt
    };

    res.json(behaviorData);
  } catch (error) {
    console.error('Get user behavior error:', error);
    res.status(500).json({ message: 'User behavior analytics error' });
  }
});

// Helper function to calculate profile completeness
function calculateProfileCompleteness(user) {
  let score = 0;
  const totalFields = 8;

  if (user.firstName) score++;
  if (user.lastName) score++;
  if (user.email) score++;
  if (user.phone) score++;
  if (user.avatar) score++;
  if (user.addresses && user.addresses.length > 0) score++;
  if (user.dateOfBirth) score++;
  if (user.isEmailVerified) score++;

  return Math.round((score / totalFields) * 100);
}

module.exports = router;