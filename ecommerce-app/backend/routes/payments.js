const express = require('express');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const { authenticate } = require('../middleware/auth');
const Order = require('../models/Order');

const router = express.Router();

// @route   POST /api/payments/create-payment-intent
// @desc    Create a Stripe payment intent
// @access  Private
router.post('/create-payment-intent', authenticate, async (req, res) => {
  try {
    const { orderId } = req.body;

    const order = await Order.findById(orderId);
    if (!order || order.user.toString() !== req.user.id) {
      return res.status(404).json({ message: 'Order not found' });
    }

    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(order.pricing.total * 100), // Stripe uses cents
      currency: 'usd',
      metadata: {
        orderId: order._id.toString(),
        userId: req.user.id
      }
    });

    // Update order with payment intent ID
    order.payment.paymentIntentId = paymentIntent.id;
    await order.save();

    res.json({
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id
    });
  } catch (error) {
    console.error('Create payment intent error:', error);
    res.status(500).json({ message: 'Payment processing error' });
  }
});

// @route   POST /api/payments/confirm
// @desc    Confirm payment
// @access  Private
router.post('/confirm', authenticate, async (req, res) => {
  try {
    const { paymentIntentId, orderId } = req.body;

    const order = await Order.findById(orderId);
    if (!order || order.user.toString() !== req.user.id) {
      return res.status(404).json({ message: 'Order not found' });
    }

    // Update payment status
    order.payment.status = 'completed';
    order.payment.paidAt = new Date();
    order.payment.transactionId = paymentIntentId;
    order.status = 'confirmed';

    await order.save();

    res.json({ message: 'Payment confirmed successfully' });
  } catch (error) {
    console.error('Confirm payment error:', error);
    res.status(500).json({ message: 'Payment confirmation error' });
  }
});

module.exports = router;
