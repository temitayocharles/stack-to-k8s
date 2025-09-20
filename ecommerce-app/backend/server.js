/*
 * ===============================================================
 * PROPRIETARY E-COMMERCE PLATFORM - BACKEND SERVER
 * ===============================================================
 * 
 * COPYRIGHT (c) 2025 Temitayo Charles Akinniranye
 * All Rights Reserved. Patent Pending.=============================================================
 * PROPRIETARY E-COMMERCE PLATFORM - BACKEND SERVER
 * ===============================================================
 * 
 * COPYRIGHT (c) 2025 [Your Full Legal Name]. All Rights Reserved.
 * PATENT PENDING - Commercial Use Strictly Prohibited
 * 
 * This Node.js/Express backend server is protected intellectual
 * property. Unauthorized commercial use will result in legal action.
 * 
 * For licensing inquiries: [your-email@domain.com]
 * ===============================================================
 */

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const app = express();

// Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.FRONTEND_URL || (process.env.NODE_ENV === 'production' ? 'https://yourfrontend.com' : 'http://localhost:3000'),
  credentials: true
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use(limiter);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Database connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/ecommerce', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('Connected to MongoDB'))
.catch(err => console.error('MongoDB connection error:', err));

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/products', require('./routes/products'));
app.use('/api/cart', require('./routes/cart'));
app.use('/api/orders', require('./routes/orders'));
app.use('/api/users', require('./routes/users'));
app.use('/api/categories', require('./routes/categories'));
app.use('/api/payments', require('./routes/payments'));

// Advanced Features Routes
app.use('/api/analytics', require('./routes/analytics'));
app.use('/api/inventory', require('./routes/inventory'));
app.use('/api/search', require('./routes/search'));
app.use('/api/realtime', require('./routes/realtime'));

// Enterprise Health Check System - 5 Mandatory Endpoints
const HealthCheckService = require('./services/healthCheck');
const healthService = new HealthCheckService();

// 1. Basic health status
app.get('/health', async (req, res) => {
  try {
    const health = await healthService.getHealth();
    res.json(health);
  } catch (error) {
    res.status(500).json({ status: 'ERROR', error: error.message });
  }
});

// 2. Readiness for traffic (Kubernetes readiness probe)
app.get('/ready', async (req, res) => {
  try {
    const readiness = await healthService.getReadiness();
    const statusCode = readiness.status === 'ready' ? 200 : 503;
    res.status(statusCode).json(readiness);
  } catch (error) {
    res.status(503).json({ status: 'not_ready', error: error.message });
  }
});

// 3. Liveness probe (Kubernetes liveness probe)
app.get('/live', async (req, res) => {
  try {
    const liveness = await healthService.getLiveness();
    const statusCode = liveness.status === 'alive' ? 200 : 503;
    res.status(statusCode).json(liveness);
  } catch (error) {
    res.status(503).json({ status: 'unhealthy', error: error.message });
  }
});

// 4. Dependencies health check
app.get('/health/dependencies', async (req, res) => {
  try {
    const dependencies = await healthService.getDependencies();
    const statusCode = dependencies.status === 'all_healthy' ? 200 : 206;
    res.status(statusCode).json(dependencies);
  } catch (error) {
    res.status(503).json({ status: 'error', error: error.message });
  }
});

// 5. Prometheus metrics
app.get('/metrics', async (req, res) => {
  try {
    const metrics = await healthService.getMetrics();
    res.set('Content-Type', 'text/plain; version=0.0.4; charset=utf-8');
    res.send(metrics);
  } catch (error) {
    res.status(500).send(`# Error generating metrics: ${error.message}`);
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ 
    message: 'Something went wrong!', 
    error: process.env.NODE_ENV === 'development' ? err.message : 'Internal server error' 
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ message: 'Route not found' });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
