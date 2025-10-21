package com.educational.platform.controller;

import com.educational.platform.service.HealthCheckService;
import com.educational.platform.model.HealthStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 🏥 ENTERPRISE HEALTH CHECK CONTROLLER
 * ====================================
 * 
 * Exposes 5 mandatory health endpoints as required by anchor document:
 * - GET /health - Basic application health
 * - GET /ready - Readiness for traffic  
 * - GET /live - Liveness probe
 * - GET /health/dependencies - External service health
 * - GET /metrics - Prometheus metrics
 * 
 * Kubernetes Integration:
 * - Readiness probe: /ready
 * - Liveness probe: /live
 * - Health checks: /health
 * 
 * Monitoring Integration:
 * - Prometheus metrics: /metrics
 * - Grafana dashboards: /health endpoints
 */
@RestController
@RequestMapping("")
public class HealthController {

    @Autowired
    private HealthCheckService healthCheckService;

    /**
     * 🎯 ENDPOINT 1: Basic Health Check
     * ================================
     * Quick health status for load balancers and basic monitoring
     * 
     * Response Examples:
     * - 200 OK: {"status": "healthy", "message": "All systems operational"}
     * - 503 Service Unavailable: {"status": "unhealthy", "message": "Application health check failed"}
     */
    @GetMapping("/health")
    public ResponseEntity<HealthStatus> getHealth() {
        try {
            HealthStatus health = healthCheckService.getBasicHealth();
            
            if ("healthy".equals(health.getStatus())) {
                return ResponseEntity.ok(health);
            } else {
                return ResponseEntity.status(503).body(health);
            }
        } catch (Exception e) {
            HealthStatus errorHealth = new HealthStatus(
                "unhealthy", 
                "Health check endpoint failed: " + e.getMessage(), 
                Map.of("error", e.getMessage(), "timestamp", java.time.Instant.now().toString())
            );
            return ResponseEntity.status(503).body(errorHealth);
        }
    }

    /**
     * 🎯 ENDPOINT 2: Readiness Probe
     * ==============================
     * Kubernetes readiness probe endpoint
     * Returns 200 when application is ready to serve traffic
     * 
     * Kubernetes Configuration:
     * readinessProbe:
     *   httpGet:
     *     path: /ready
     *     port: 8080
     *   initialDelaySeconds: 30
     *   periodSeconds: 10
     */
    @GetMapping("/ready")
    public ResponseEntity<HealthStatus> getReadiness() {
        try {
            HealthStatus readiness = healthCheckService.getReadinessStatus();
            
            if ("ready".equals(readiness.getStatus())) {
                return ResponseEntity.ok(readiness);
            } else {
                return ResponseEntity.status(503).body(readiness);
            }
        } catch (Exception e) {
            HealthStatus errorReadiness = new HealthStatus(
                "not_ready", 
                "Readiness check failed: " + e.getMessage(), 
                Map.of("error", e.getMessage(), "ready", false)
            );
            return ResponseEntity.status(503).body(errorReadiness);
        }
    }

    /**
     * 🎯 ENDPOINT 3: Liveness Probe
     * =============================
     * Kubernetes liveness probe endpoint
     * Returns 200 when application is alive (should restart if failing)
     * 
     * Kubernetes Configuration:
     * livenessProbe:
     *   httpGet:
     *     path: /live
     *     port: 8080
     *   initialDelaySeconds: 60
     *   periodSeconds: 30
     */
    @GetMapping("/live")
    public ResponseEntity<HealthStatus> getLiveness() {
        try {
            HealthStatus liveness = healthCheckService.getLivenessStatus();
            
            if ("alive".equals(liveness.getStatus())) {
                return ResponseEntity.ok(liveness);
            } else {
                return ResponseEntity.status(503).body(liveness);
            }
        } catch (Exception e) {
            HealthStatus errorLiveness = new HealthStatus(
                "dead", 
                "Liveness check failed: " + e.getMessage(), 
                Map.of("error", e.getMessage(), "alive", false)
            );
            return ResponseEntity.status(503).body(errorLiveness);
        }
    }

    /**
     * 🎯 ENDPOINT 4: Dependencies Health Check
     * ========================================
     * Detailed health check of all external dependencies
     * Useful for monitoring and debugging integration issues
     * 
     * Returns:
     * - 200 OK: All dependencies healthy
     * - 207 Multi-Status: Some dependencies unhealthy (partial functionality)
     * - 503 Service Unavailable: Critical dependencies failed
     */
    @GetMapping("/health/dependencies")
    public ResponseEntity<HealthStatus> getDependenciesHealth() {
        try {
            HealthStatus dependencies = healthCheckService.getDependenciesHealth();
            
            switch (dependencies.getStatus()) {
                case "healthy":
                    return ResponseEntity.ok(dependencies);
                case "degraded":
                    // Some dependencies failing but service still functional
                    return ResponseEntity.status(207).body(dependencies);
                default:
                    return ResponseEntity.status(503).body(dependencies);
            }
        } catch (Exception e) {
            HealthStatus errorDependencies = new HealthStatus(
                "unhealthy", 
                "Dependencies check failed: " + e.getMessage(), 
                Map.of("error", e.getMessage())
            );
            return ResponseEntity.status(503).body(errorDependencies);
        }
    }

    /**
     * 🎯 ENDPOINT 5: Prometheus Metrics
     * =================================
     * Custom metrics endpoint for Prometheus scraping
     * Exposes business and technical metrics
     * 
     * Prometheus Configuration:
     * scrape_configs:
     *   - job_name: 'educational-platform'
     *     static_configs:
     *       - targets: ['educational-platform:8080']
     *     metrics_path: '/metrics'
     */
    @GetMapping("/metrics")
    public ResponseEntity<Map<String, Object>> getMetrics() {
        try {
            Map<String, Object> metrics = healthCheckService.getMetrics();
            return ResponseEntity.ok(metrics);
        } catch (Exception e) {
            Map<String, Object> errorMetrics = Map.of(
                "error", e.getMessage(),
                "timestamp", java.time.Instant.now().toString(),
                "status", "error"
            );
            return ResponseEntity.status(500).body(errorMetrics);
        }
    }

    /**
     * 🔧 ADDITIONAL ENDPOINT: Health Summary
     * =====================================
     * Combined health information for dashboards
     */
    @GetMapping("/health/summary")
    public ResponseEntity<Map<String, Object>> getHealthSummary() {
        try {
            HealthStatus basic = healthCheckService.getBasicHealth();
            HealthStatus readiness = healthCheckService.getReadinessStatus();
            HealthStatus dependencies = healthCheckService.getDependenciesHealth();
            
            Map<String, Object> summary = Map.of(
                "overall_status", basic.getStatus(),
                "ready_for_traffic", "ready".equals(readiness.getStatus()),
                "dependencies_healthy", "healthy".equals(dependencies.getStatus()),
                "uptime_seconds", basic.getDetails().get("uptime"),
                "timestamp", java.time.Instant.now().toString(),
                "health_endpoints", Map.of(
                    "basic", "/health",
                    "readiness", "/ready", 
                    "liveness", "/live",
                    "dependencies", "/health/dependencies",
                    "metrics", "/metrics"
                )
            );
            
            return ResponseEntity.ok(summary);
        } catch (Exception e) {
            Map<String, Object> errorSummary = Map.of(
                "error", e.getMessage(),
                "overall_status", "error"
            );
            return ResponseEntity.status(500).body(errorSummary);
        }
    }

    /**
     * 🧪 ADDITIONAL ENDPOINT: Deep Health Check
     * =========================================
     * Comprehensive health check for troubleshooting
     */
    @GetMapping("/health/deep")
    public ResponseEntity<Map<String, Object>> getDeepHealth() {
        try {
            Map<String, Object> deepHealth = Map.of(
                "basic_health", healthCheckService.getBasicHealth(),
                "readiness", healthCheckService.getReadinessStatus(),
                "liveness", healthCheckService.getLivenessStatus(),
                "dependencies", healthCheckService.getDependenciesHealth(),
                "metrics_sample", healthCheckService.getMetrics(),
                "check_timestamp", java.time.Instant.now().toString()
            );
            
            return ResponseEntity.ok(deepHealth);
        } catch (Exception e) {
            Map<String, Object> errorDeep = Map.of(
                "error", e.getMessage(),
                "status", "deep_check_failed",
                "timestamp", java.time.Instant.now().toString()
            );
            return ResponseEntity.status(500).body(errorDeep);
        }
    }
}