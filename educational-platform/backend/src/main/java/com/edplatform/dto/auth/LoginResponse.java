package com.edplatform.dto.auth;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

/**
 * Response DTO for successful login
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LoginResponse {

    private String token;
    
    private String refreshToken;
    
    private String tokenType = "Bearer";
    
    private Long expiresIn; // Token expiration time in milliseconds
    
    private UserDto user;
    
    // Optional: Additional security information
    private String deviceId;
    
    private String sessionId;
    
    // Optional: First-time login flag
    private Boolean isFirstLogin = false;
    
    // Optional: Password expiration warning
    private Boolean passwordExpiringSoon = false;
}
