package com.edplatform.dto.auth;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

/**
 * Request DTO for user login
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LoginRequest {

    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    private String email;

    @NotBlank(message = "Password is required")
    private String password;

    // Optional: Remember me functionality
    private Boolean rememberMe = false;

    // Optional: Device information for security
    private String deviceInfo;

    // Optional: User agent for tracking
    private String userAgent;

    // Manual getters for compile-time safety
    public String getEmail() { return email; }
    public String getPassword() { return password; }
}
