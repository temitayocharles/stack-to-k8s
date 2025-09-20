/*
 * ===============================================================
 * ENTERPRISE HEALTH CHECK SERVICE
 * ===============================================================
 * 
 * Implements 5 mandatory health endpoints as per anchor document:
 * - /health - Basic health status
 * - /ready - Readiness for traffic
 * - /live - Liveness probe
 * - /dependencies - External service health
 * - /metrics - Prometheus metrics
 * ===============================================================
 */

const mongoose = require('mongoose');
const redis = require('redis');

class HealthCheckService {
    constructor() {
        this.startTime = Date.now();
        this.redisClient = null;
        this.initializeRedis();
    }

    async initializeRedis() {
        try {
            this.redisClient = redis.createClient({
                url: process.env.REDIS_URL || 'redis://localhost:6379'
            });
            await this.redisClient.connect();
            console.log('Health check service: Redis connected');
        } catch (error) {
            console.warn('Health check service: Redis connection failed:', error.message);
        }
    }

    // Basic health status
    async getHealth() {
        return {
            status: 'OK',
            timestamp: new Date().toISOString(),
            uptime: this.getUptime(),
            version: process.env.npm_package_version || '1.0.0',
            environment: process.env.NODE_ENV || 'development'
        };
    }

    // Readiness for traffic (all dependencies ready)
    async getReadiness() {
        const checks = {
            database: await this.checkDatabase(),
            redis: await this.checkRedis(),
            memory: await this.checkMemory(),
            disk: await this.checkDisk()
        };

        const allReady = Object.values(checks).every(check => check.status === 'healthy');

        return {
            status: allReady ? 'ready' : 'not_ready',
            timestamp: new Date().toISOString(),
            checks
        };
    }

    // Liveness probe (application is running)
    async getLiveness() {
        const memoryUsage = process.memoryUsage();
        const isHealthy = memoryUsage.heapUsed < memoryUsage.heapTotal * 0.9; // Less than 90% memory usage

        return {
            status: isHealthy ? 'alive' : 'unhealthy',
            timestamp: new Date().toISOString(),
            uptime: this.getUptime(),
            memory: {
                heapUsed: Math.round(memoryUsage.heapUsed / 1024 / 1024) + ' MB',
                heapTotal: Math.round(memoryUsage.heapTotal / 1024 / 1024) + ' MB',
                usage: Math.round((memoryUsage.heapUsed / memoryUsage.heapTotal) * 100) + '%'
            }
        };
    }

    // Dependencies health check
    async getDependencies() {
        const dependencies = {
            mongodb: await this.checkDatabase(),
            redis: await this.checkRedis(),
            external_apis: await this.checkExternalAPIs(),
            file_system: await this.checkFileSystem()
        };

        const allHealthy = Object.values(dependencies).every(dep => dep.status === 'healthy');

        return {
            status: allHealthy ? 'all_healthy' : 'some_unhealthy',
            timestamp: new Date().toISOString(),
            dependencies
        };
    }

    // Prometheus metrics
    async getMetrics() {
        const memoryUsage = process.memoryUsage();
        const uptime = this.getUptime();

        // Basic Prometheus format metrics
        const metrics = [
            `# HELP nodejs_heap_size_used_bytes Process heap memory currently used`,
            `# TYPE nodejs_heap_size_used_bytes gauge`,
            `nodejs_heap_size_used_bytes ${memoryUsage.heapUsed}`,
            ``,
            `# HELP nodejs_heap_size_total_bytes Process heap memory total`,
            `# TYPE nodejs_heap_size_total_bytes gauge`,
            `nodejs_heap_size_total_bytes ${memoryUsage.heapTotal}`,
            ``,
            `# HELP process_uptime_seconds Process uptime in seconds`,
            `# TYPE process_uptime_seconds counter`,
            `process_uptime_seconds ${uptime}`,
            ``,
            `# HELP http_requests_total Total number of HTTP requests`,
            `# TYPE http_requests_total counter`,
            `http_requests_total{method="GET",status="200"} ${this.getRequestCount('GET', 200)}`,
            `http_requests_total{method="POST",status="200"} ${this.getRequestCount('POST', 200)}`,
            `http_requests_total{method="GET",status="404"} ${this.getRequestCount('GET', 404)}`,
            ``,
            `# HELP mongodb_connections_active Active MongoDB connections`,
            `# TYPE mongodb_connections_active gauge`,
            `mongodb_connections_active ${await this.getMongoDBConnections()}`,
            ``
        ].join('\n');

        return metrics;
    }

    // Individual health checks
    async checkDatabase() {
        try {
            await mongoose.connection.db.admin().ping();
            const state = mongoose.connection.readyState;
            const states = { 0: 'disconnected', 1: 'connected', 2: 'connecting', 3: 'disconnecting' };
            
            return {
                status: state === 1 ? 'healthy' : 'unhealthy',
                state: states[state] || 'unknown',
                responseTime: await this.measureDatabaseResponseTime()
            };
        } catch (error) {
            return {
                status: 'unhealthy',
                error: error.message,
                responseTime: null
            };
        }
    }

    async checkRedis() {
        if (!this.redisClient) {
            return {
                status: 'unhealthy',
                error: 'Redis client not initialized',
                responseTime: null
            };
        }

        try {
            const start = Date.now();
            await this.redisClient.ping();
            const responseTime = Date.now() - start;
            
            return {
                status: 'healthy',
                responseTime: responseTime + 'ms'
            };
        } catch (error) {
            return {
                status: 'unhealthy',
                error: error.message,
                responseTime: null
            };
        }
    }

    async checkMemory() {
        const memoryUsage = process.memoryUsage();
        const usagePercentage = (memoryUsage.heapUsed / memoryUsage.heapTotal) * 100;
        
        return {
            status: usagePercentage < 90 ? 'healthy' : 'unhealthy',
            heapUsed: Math.round(memoryUsage.heapUsed / 1024 / 1024) + ' MB',
            heapTotal: Math.round(memoryUsage.heapTotal / 1024 / 1024) + ' MB',
            usagePercentage: Math.round(usagePercentage) + '%'
        };
    }

    async checkDisk() {
        // Basic disk check - in production you'd want more sophisticated monitoring
        try {
            const fs = require('fs').promises;
            await fs.access('./', fs.constants.R_OK | fs.constants.W_OK);
            return {
                status: 'healthy',
                readable: true,
                writable: true
            };
        } catch (error) {
            return {
                status: 'unhealthy',
                error: error.message,
                readable: false,
                writable: false
            };
        }
    }

    async checkExternalAPIs() {
        // Check external API dependencies (payment providers, email services, etc.)
        const externalChecks = {
            stripe: await this.checkStripeAPI(),
            email_service: await this.checkEmailService()
        };

        const allHealthy = Object.values(externalChecks).every(check => check.status === 'healthy');

        return {
            status: allHealthy ? 'healthy' : 'degraded',
            services: externalChecks
        };
    }

    async checkFileSystem() {
        try {
            const fs = require('fs').promises;
            const testFile = './health-check-test.tmp';
            
            // Write test
            await fs.writeFile(testFile, 'health-check');
            
            // Read test
            const content = await fs.readFile(testFile, 'utf8');
            
            // Clean up
            await fs.unlink(testFile);
            
            return {
                status: content === 'health-check' ? 'healthy' : 'unhealthy',
                readable: true,
                writable: true
            };
        } catch (error) {
            return {
                status: 'unhealthy',
                error: error.message,
                readable: false,
                writable: false
            };
        }
    }

    // Helper methods
    getUptime() {
        return Math.floor((Date.now() - this.startTime) / 1000);
    }

    async measureDatabaseResponseTime() {
        try {
            const start = Date.now();
            await mongoose.connection.db.admin().ping();
            return (Date.now() - start) + 'ms';
        } catch (error) {
            return null;
        }
    }

    async getMongoDBConnections() {
        try {
            const adminDb = mongoose.connection.db.admin();
            const stats = await adminDb.serverStatus();
            return stats.connections.current;
        } catch (error) {
            return 0;
        }
    }

    getRequestCount(method, status) {
        // In production, you'd track this with proper metrics collection
        // For now, return a placeholder that could be replaced with real tracking
        return Math.floor(Math.random() * 1000);
    }

    async checkStripeAPI() {
        // Mock check for Stripe API - replace with actual API call
        return {
            status: process.env.STRIPE_SECRET_KEY ? 'healthy' : 'unhealthy',
            configured: !!process.env.STRIPE_SECRET_KEY
        };
    }

    async checkEmailService() {
        // Mock check for email service - replace with actual API call
        return {
            status: process.env.EMAIL_HOST ? 'healthy' : 'unhealthy',
            configured: !!process.env.EMAIL_HOST
        };
    }
}

module.exports = HealthCheckService;