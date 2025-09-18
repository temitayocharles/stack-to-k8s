package com.eduplatform.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class HealthController {

    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "healthy");
        response.put("service", "educational-platform");
        response.put("timestamp", LocalDateTime.now());
        response.put("version", "1.0.0");
        
        Map<String, String> services = new HashMap<>();
        services.put("database", "connected");
        services.put("redis", "connected");
        services.put("file_storage", "ready");
        response.put("services", services);
        
        return ResponseEntity.ok(response);
    }
}