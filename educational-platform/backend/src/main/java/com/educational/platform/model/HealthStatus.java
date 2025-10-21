package com.educational.platform.model;

import java.util.Map;

/**
 * 🏥 HEALTH STATUS MODEL
 * =====================
 * 
 * Standard health status response format for all health endpoints
 * Supports Kubernetes probes and monitoring integration
 */
public class HealthStatus {
    private String status;
    private String message;
    private Map<String, Object> details;
    
    public HealthStatus() {}
    
    public HealthStatus(String status, String message, Map<String, Object> details) {
        this.status = status;
        this.message = message;
        this.details = details;
    }
    
    // Getters and setters
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    
    public Map<String, Object> getDetails() { return details; }
    public void setDetails(Map<String, Object> details) { this.details = details; }
}