package com.educational.platform.service;

import com.educational.platform.model.HealthStatus;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import io.micrometer.core.instrument.Counter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/**
 * 🏥 COMPREHENSIVE HEALTH CHECK SERVICE
 * ====================================
 * 
 * Enterprise-grade health monitoring for Kubernetes production deployment
 * Implements 5 health endpoints with comprehensive monitoring
 * - /health (basic health status)
 * - /ready (readiness probe)
 * - /live (liveness probe) 
 * - /dependencies (external service health)
 * - /metrics (prometheus metrics)
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class HealthCheckService {

    private final DataSource dataSource;
    private final RedisTemplate<String, Object> redisTemplate;
    private final CacheManager cacheManager;
    private final MeterRegistry meterRegistry;
    
    // Health check counters and timers - initialized in @PostConstruct
    private Counter healthCheckCounter;
    private Timer databaseCheckTimer;
    private Timer redisCheckTimer;

    @PostConstruct
    public void initializeMetrics() {
        this.healthCheckCounter = Counter.builder("health_checks_total")
                .description("Total health checks performed")
                .register(meterRegistry);
        
        this.databaseCheckTimer = Timer.builder("database_check_duration")
                .description("Database connectivity check duration")
                .register(meterRegistry);
        
        this.redisCheckTimer = Timer.builder("redis_check_duration")
                .description("Redis connectivity check duration")
                .register(meterRegistry);
    }

    /**
     * 🎯 BASIC HEALTH CHECK
     * Returns overall application health status
     */
    public HealthStatus getBasicHealth() {
        log.debug("Performing basic health check");
        healthCheckCounter.increment();
        
        Map<String, Object> details = new HashMap<>();
        details.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        details.put("application", "Educational Platform");
        details.put("version", "1.0.0");
        
        try {
            // Check critical dependencies
            boolean dbHealthy = checkDatabaseConnectivity();
            boolean redisHealthy = checkRedisConnectivity();
            
            details.put("database", dbHealthy ? "UP" : "DOWN");
            details.put("redis", redisHealthy ? "UP" : "DOWN");
            
            if (dbHealthy && redisHealthy) {
                return new HealthStatus("UP", "Application is healthy", details);
            } else {
                return new HealthStatus("DOWN", "Some dependencies are unavailable", details);
            }
            
        } catch (Exception e) {
            log.error("Health check failed", e);
            details.put("error", e.getMessage());
            return new HealthStatus("DOWN", "Health check failed", details);
        }
    }

    /**
     * 🚀 READINESS PROBE
     * Checks if application is ready to serve traffic
     */
    public HealthStatus getReadinessStatus() {
        try {
            log.debug("Performing readiness check");
            
            Map<String, Object> details = new HashMap<>();
            details.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
            
            // Check all critical dependencies for readiness
            boolean dbReady = checkDatabaseConnectivity();
            boolean redisReady = checkRedisConnectivity();
            boolean cacheReady = checkCacheConnectivity();
            
            details.put("database_ready", dbReady);
            details.put("redis_ready", redisReady);
            details.put("cache_ready", cacheReady);
            
            if (dbReady && redisReady && cacheReady) {
                return new HealthStatus("READY", "Application ready to serve traffic", details);
            } else {
                return new HealthStatus("NOT_READY", "Application not ready", details);
            }
            
        } catch (Exception e) {
            log.error("Readiness check failed", e);
            Map<String, Object> errorDetails = new HashMap<>();
            errorDetails.put("error", e.getMessage());
            return new HealthStatus("NOT_READY", "Readiness check failed", errorDetails);
        }
    }

    /**
     * 💗 LIVENESS PROBE  
     * Checks if application is alive (basic responsiveness)
     */
    public HealthStatus getLivenessStatus() {
        log.debug("Performing liveness check");
        
        Map<String, Object> details = new HashMap<>();
        details.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        details.put("uptime", System.currentTimeMillis());
        
        // Basic liveness - if we can execute this method, we're alive
        try {
            // Simple memory check
            Runtime runtime = Runtime.getRuntime();
            long totalMemory = runtime.totalMemory();
            long freeMemory = runtime.freeMemory();
            long usedMemory = totalMemory - freeMemory;
            
            details.put("memory_total", totalMemory);
            details.put("memory_used", usedMemory);
            details.put("memory_free", freeMemory);
            details.put("memory_usage_percent", (usedMemory * 100) / totalMemory);
            
            return new HealthStatus("ALIVE", "Application is alive", details);
            
        } catch (Exception e) {
            log.error("Liveness check failed", e);
            Map<String, Object> errorDetails = new HashMap<>();
            errorDetails.put("error", e.getMessage());
            return new HealthStatus("DEAD", "Liveness check failed", errorDetails);
        }
    }

    /**
     * 🔗 DEPENDENCIES HEALTH CHECK
     * Comprehensive check of all external dependencies
     */
    public HealthStatus getDependenciesHealth() {
        log.debug("Performing dependencies health check");
        
        Map<String, Object> details = new HashMap<>();
        details.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        
        try {
            // Database dependency
            boolean dbHealthy = checkDatabaseConnectivity();
            
            // Redis dependency  
            boolean redisHealthy = checkRedisConnectivity();
            
            // Cache dependency
            boolean cacheHealthy = checkCacheConnectivity();
            
            details.put("postgresql", dbHealthy ? "UP" : "DOWN");
            details.put("redis", redisHealthy ? "UP" : "DOWN"); 
            details.put("cache_manager", cacheHealthy ? "UP" : "DOWN");
            
            // Overall dependency health
            boolean allHealthy = dbHealthy && redisHealthy && cacheHealthy;
            String status = allHealthy ? "UP" : "DEGRADED";
            String message = allHealthy ? "All dependencies healthy" : "Some dependencies unavailable";
            
            return new HealthStatus(status, message, details);
            
        } catch (Exception e) {
            log.error("Dependencies check failed", e);
            details.put("error", e.getMessage());
            return new HealthStatus("DOWN", "Dependencies check failed", details);
        }
    }

    /**
     * 📊 METRICS ENDPOINT
     * Returns application metrics for monitoring
     */
    public Map<String, Object> getMetrics() {
        Map<String, Object> metrics = new HashMap<>();
        
        try {
            // Basic application metrics
            metrics.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
            metrics.put("application", "Educational Platform");
            
            // JVM metrics
            Runtime runtime = Runtime.getRuntime();
            metrics.put("jvm_memory_total", runtime.totalMemory());
            metrics.put("jvm_memory_free", runtime.freeMemory());
            metrics.put("jvm_memory_used", runtime.totalMemory() - runtime.freeMemory());
            metrics.put("jvm_processors", runtime.availableProcessors());
            
            // Health check metrics
            boolean dbHealthy = checkDatabaseConnectivity();
            boolean redisHealthy = checkRedisConnectivity();
            
            metrics.put("database_healthy", dbHealthy);
            metrics.put("redis_healthy", redisHealthy);
            
            // Custom metrics
            metrics.put("health_checks_performed", healthCheckCounter.count());
            
            return metrics;
            
        } catch (Exception e) {
            log.error("Metrics collection failed", e);
            metrics.put("error", e.getMessage());
            return metrics;
        }
    }

    /**
     * 🗄️ DATABASE CONNECTIVITY CHECK
     */
    private boolean checkDatabaseConnectivity() {
        try (Connection connection = dataSource.getConnection()) {
            return connection.isValid(5); // 5 second timeout
        } catch (SQLException e) {
            log.warn("Database connectivity check failed: {}", e.getMessage());
            return false;
        }
    }

    /**
     * 🔴 REDIS CONNECTIVITY CHECK
     */
    private boolean checkRedisConnectivity() {
        try {
            redisTemplate.opsForValue().set("health_check", "ping", 10, TimeUnit.SECONDS);
            String result = (String) redisTemplate.opsForValue().get("health_check");
            redisTemplate.delete("health_check");
            return "ping".equals(result);
        } catch (Exception e) {
            log.warn("Redis connectivity check failed: {}", e.getMessage());
            return false;
        }
    }

    /**
     * 💾 CACHE CONNECTIVITY CHECK
     */
    private boolean checkCacheConnectivity() {
        try {
            Cache cache = cacheManager.getCache("health-check");
            if (cache != null) {
                cache.put("test", "value");
                String result = cache.get("test", String.class);
                cache.evict("test");
                return "value".equals(result);
            }
            return false;
        } catch (Exception e) {
            log.warn("Cache connectivity check failed: {}", e.getMessage());
            return false;
        }
    }
}