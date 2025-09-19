const express = require('express');
const { body, validationResult } = require('express-validator');
const Product = require('../models/Product');
const { authenticate, authorize } = require('../middleware/auth');

const router = express.Router();

// @route   GET /api/inventory/low-stock
// @desc    Get products with low stock levels
// @access  Private (Admin only)
router.get('/low-stock', authenticate, authorize('admin'), async (req, res) => {
  try {
    const threshold = parseInt(req.query.threshold) || 10;
    
    const lowStockProducts = await Product.find({
      status: 'active',
      $or: [
        { quantity: { $lte: threshold } },
        { 'variants.quantity': { $lte: threshold } }
      ]
    })
    .populate('category', 'name')
    .sort({ quantity: 1 });

    // Calculate stock status for each product
    const stockReport = lowStockProducts.map(product => {
      let totalStock = product.quantity;
      let criticalVariants = [];

      if (product.variants && product.variants.length > 0) {
        product.variants.forEach(variant => {
          variant.options.forEach(option => {
            if (option.quantity <= threshold) {
              criticalVariants.push({
                variant: variant.name,
                option: option.name,
                quantity: option.quantity
              });
            }
            totalStock += option.quantity;
          });
        });
      }

      return {
        productId: product._id,
        name: product.name,
        sku: product.sku,
        category: product.category?.name,
        baseQuantity: product.quantity,
        totalStock,
        threshold,
        criticalVariants,
        daysUntilStockout: estimateStockoutDays(product),
        reorderPoint: Math.max(threshold * 2, 5),
        status: totalStock === 0 ? 'out_of_stock' : 
                totalStock <= 5 ? 'critical' : 
                totalStock <= threshold ? 'low' : 'normal'
      };
    });

    res.json({
      products: stockReport,
      summary: {
        totalProducts: stockReport.length,
        criticalProducts: stockReport.filter(p => p.status === 'critical').length,
        outOfStockProducts: stockReport.filter(p => p.status === 'out_of_stock').length,
        lowStockProducts: stockReport.filter(p => p.status === 'low').length
      }
    });
  } catch (error) {
    console.error('Low stock report error:', error);
    res.status(500).json({ message: 'Inventory report error' });
  }
});

// @route   POST /api/inventory/restock
// @desc    Restock product quantities
// @access  Private (Admin only)
router.post('/restock', authenticate, authorize('admin'), [
  body('productId').isMongoId().withMessage('Valid product ID is required'),
  body('quantity').isInt({ min: 1 }).withMessage('Quantity must be at least 1'),
  body('cost').optional().isFloat({ min: 0 }).withMessage('Cost must be non-negative'),
  body('supplier').optional().trim().notEmpty().withMessage('Supplier name required if provided'),
  body('batchNumber').optional().trim().notEmpty().withMessage('Batch number required if provided')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { productId, quantity, cost, supplier, batchNumber, notes } = req.body;

    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }

    // Update product quantity
    const previousQuantity = product.quantity;
    product.quantity += quantity;

    // Update cost price if provided
    if (cost !== undefined) {
      // Calculate weighted average cost
      const totalValue = (previousQuantity * (product.costPrice || 0)) + (quantity * cost);
      const totalQuantity = previousQuantity + quantity;
      product.costPrice = totalValue / totalQuantity;
    }

    // Add restock record to product history
    if (!product.stockHistory) {
      product.stockHistory = [];
    }

    product.stockHistory.push({
      type: 'restock',
      quantity: quantity,
      previousStock: previousQuantity,
      newStock: product.quantity,
      cost: cost,
      supplier: supplier,
      batchNumber: batchNumber,
      notes: notes,
      timestamp: new Date(),
      user: req.user.id
    });

    // Update product status if it was out of stock
    if (product.status === 'out_of_stock' && product.quantity > 0) {
      product.status = 'active';
    }

    await product.save();

    // Log inventory movement
    const inventoryLog = {
      type: 'stock_increase',
      productId: product._id,
      productName: product.name,
      sku: product.sku,
      quantityChanged: quantity,
      previousStock: previousQuantity,
      currentStock: product.quantity,
      cost: cost,
      supplier: supplier,
      batchNumber: batchNumber,
      user: req.user.id,
      timestamp: new Date()
    };

    console.log('Inventory Movement:', inventoryLog);

    res.json({
      message: 'Product restocked successfully',
      product: {
        id: product._id,
        name: product.name,
        sku: product.sku,
        previousQuantity,
        newQuantity: product.quantity,
        quantityAdded: quantity,
        newCostPrice: product.costPrice
      }
    });
  } catch (error) {
    console.error('Restock error:', error);
    res.status(500).json({ message: 'Restock operation failed' });
  }
});

// @route   POST /api/inventory/adjust
// @desc    Adjust inventory for corrections, damages, etc.
// @access  Private (Admin only)
router.post('/adjust', authenticate, authorize('admin'), [
  body('productId').isMongoId().withMessage('Valid product ID is required'),
  body('adjustment').isInt().withMessage('Adjustment must be an integer'),
  body('reason').isIn(['correction', 'damage', 'theft', 'expired', 'return', 'other']).withMessage('Valid reason required'),
  body('notes').optional().trim()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { productId, adjustment, reason, notes } = req.body;

    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }

    const previousQuantity = product.quantity;
    const newQuantity = Math.max(0, previousQuantity + adjustment);

    // Prevent negative stock
    if (newQuantity < 0) {
      return res.status(400).json({ 
        message: 'Adjustment would result in negative stock',
        currentStock: previousQuantity,
        requestedAdjustment: adjustment
      });
    }

    product.quantity = newQuantity;

    // Add adjustment record to history
    if (!product.stockHistory) {
      product.stockHistory = [];
    }

    product.stockHistory.push({
      type: 'adjustment',
      quantity: adjustment,
      previousStock: previousQuantity,
      newStock: newQuantity,
      reason: reason,
      notes: notes,
      timestamp: new Date(),
      user: req.user.id
    });

    // Update product status if necessary
    if (newQuantity === 0) {
      product.status = 'out_of_stock';
    } else if (product.status === 'out_of_stock' && newQuantity > 0) {
      product.status = 'active';
    }

    await product.save();

    // Log inventory movement
    const inventoryLog = {
      type: adjustment > 0 ? 'stock_increase' : 'stock_decrease',
      productId: product._id,
      productName: product.name,
      sku: product.sku,
      quantityChanged: Math.abs(adjustment),
      previousStock: previousQuantity,
      currentStock: newQuantity,
      reason: reason,
      notes: notes,
      user: req.user.id,
      timestamp: new Date()
    };

    console.log('Inventory Adjustment:', inventoryLog);

    res.json({
      message: 'Inventory adjusted successfully',
      product: {
        id: product._id,
        name: product.name,
        sku: product.sku,
        previousQuantity,
        newQuantity,
        adjustment,
        reason
      }
    });
  } catch (error) {
    console.error('Inventory adjustment error:', error);
    res.status(500).json({ message: 'Inventory adjustment failed' });
  }
});

// @route   GET /api/inventory/movements
// @desc    Get inventory movement history
// @access  Private (Admin only)
router.get('/movements', authenticate, authorize('admin'), async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    
    const productId = req.query.productId;
    const startDate = req.query.startDate ? new Date(req.query.startDate) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    const endDate = req.query.endDate ? new Date(req.query.endDate) : new Date();

    // Build aggregation pipeline
    const pipeline = [
      { $unwind: '$stockHistory' },
      {
        $match: {
          'stockHistory.timestamp': { $gte: startDate, $lte: endDate },
          ...(productId && { _id: productId })
        }
      },
      {
        $lookup: {
          from: 'users',
          localField: 'stockHistory.user',
          foreignField: '_id',
          as: 'user'
        }
      },
      {
        $project: {
          productName: '$name',
          sku: '$sku',
          movement: '$stockHistory',
          user: { $arrayElemAt: ['$user', 0] }
        }
      },
      { $sort: { 'movement.timestamp': -1 } },
      { $skip: skip },
      { $limit: limit }
    ];

    const movements = await Product.aggregate(pipeline);

    // Get total count for pagination
    const totalPipeline = [
      { $unwind: '$stockHistory' },
      {
        $match: {
          'stockHistory.timestamp': { $gte: startDate, $lte: endDate },
          ...(productId && { _id: productId })
        }
      },
      { $count: 'total' }
    ];

    const totalResult = await Product.aggregate(totalPipeline);
    const total = totalResult[0]?.total || 0;

    res.json({
      movements: movements.map(m => ({
        productName: m.productName,
        sku: m.sku,
        type: m.movement.type,
        quantity: m.movement.quantity,
        previousStock: m.movement.previousStock,
        newStock: m.movement.newStock,
        reason: m.movement.reason,
        cost: m.movement.cost,
        supplier: m.movement.supplier,
        batchNumber: m.movement.batchNumber,
        notes: m.movement.notes,
        timestamp: m.movement.timestamp,
        user: m.user ? `${m.user.firstName} ${m.user.lastName}` : 'Unknown'
      })),
      pagination: {
        currentPage: page,
        totalPages: Math.ceil(total / limit),
        totalMovements: total,
        hasNextPage: page < Math.ceil(total / limit),
        hasPrevPage: page > 1
      }
    });
  } catch (error) {
    console.error('Get inventory movements error:', error);
    res.status(500).json({ message: 'Failed to retrieve inventory movements' });
  }
});

// @route   GET /api/inventory/valuation
// @desc    Get inventory valuation report
// @access  Private (Admin only)
router.get('/valuation', authenticate, authorize('admin'), async (req, res) => {
  try {
    const products = await Product.find({ status: { $ne: 'discontinued' } })
      .populate('category', 'name')
      .select('name sku quantity costPrice price category');

    let totalInventoryValue = 0;
    let totalRetailValue = 0;
    const categoryBreakdown = {};

    const valuationReport = products.map(product => {
      const costValue = (product.costPrice || 0) * product.quantity;
      const retailValue = product.price * product.quantity;
      
      totalInventoryValue += costValue;
      totalRetailValue += retailValue;

      const categoryName = product.category?.name || 'Uncategorized';
      if (!categoryBreakdown[categoryName]) {
        categoryBreakdown[categoryName] = {
          products: 0,
          totalUnits: 0,
          costValue: 0,
          retailValue: 0
        };
      }

      categoryBreakdown[categoryName].products++;
      categoryBreakdown[categoryName].totalUnits += product.quantity;
      categoryBreakdown[categoryName].costValue += costValue;
      categoryBreakdown[categoryName].retailValue += retailValue;

      return {
        productId: product._id,
        name: product.name,
        sku: product.sku,
        category: categoryName,
        quantity: product.quantity,
        costPrice: product.costPrice || 0,
        retailPrice: product.price,
        costValue: costValue,
        retailValue: retailValue,
        markup: product.costPrice ? ((product.price - product.costPrice) / product.costPrice * 100).toFixed(2) : '0',
        turnoverRate: calculateTurnoverRate(product) // Mock calculation
      };
    });

    res.json({
      summary: {
        totalProducts: products.length,
        totalUnits: products.reduce((sum, p) => sum + p.quantity, 0),
        totalInventoryValue: totalInventoryValue.toFixed(2),
        totalRetailValue: totalRetailValue.toFixed(2),
        averageMarkup: totalInventoryValue > 0 ? (((totalRetailValue - totalInventoryValue) / totalInventoryValue) * 100).toFixed(2) : '0',
        potentialProfit: (totalRetailValue - totalInventoryValue).toFixed(2)
      },
      categoryBreakdown,
      products: valuationReport,
      generatedAt: new Date()
    });
  } catch (error) {
    console.error('Inventory valuation error:', error);
    res.status(500).json({ message: 'Failed to generate valuation report' });
  }
});

// Helper function to estimate stockout days
function estimateStockoutDays(product) {
  // Simple calculation based on sales velocity
  // In production, this would use historical sales data
  const avgDailySales = (product.salesCount || 0) / 30; // Rough estimate
  
  if (avgDailySales === 0) return 'Unknown';
  
  const daysRemaining = Math.floor(product.quantity / avgDailySales);
  return daysRemaining > 365 ? '365+' : daysRemaining.toString();
}

// Helper function to calculate inventory turnover rate
function calculateTurnoverRate(product) {
  // Mock calculation - in production, use actual sales data
  const annualSales = (product.salesCount || 0) * 12; // Rough estimate
  const averageInventory = product.quantity;
  
  if (averageInventory === 0) return 0;
  
  return (annualSales / averageInventory).toFixed(2);
}

module.exports = router;