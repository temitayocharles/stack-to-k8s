package com.educational.platform.model;

import java.util.Map;

/**
 * 🔍 HEALTH CHECK MODEL
 * ====================
 * 
 * Individual health check result for dependencies and components
 * Used by HealthStatus for detailed health reporting
 */
public class HealthCheck {
    private String name;
    private boolean healthy;
    private String message;
    private Map<String, Object> details;
    
    public HealthCheck() {}
    
    public HealthCheck(String name, boolean healthy, String message, Map<String, Object> details) {
        this.name = name;
        this.healthy = healthy;
        this.message = message;
        this.details = details;
    }
    
    // Getters and setters
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public boolean isHealthy() { return healthy; }
    public void setHealthy(boolean healthy) { this.healthy = healthy; }
    
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    
    public Map<String, Object> getDetails() { return details; }
    public void setDetails(Map<String, Object> details) { this.details = details; }
}