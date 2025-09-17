package com.edplatform.controller;

import com.edplatform.dto.auth.*;
import com.edplatform.entity.User;
import com.edplatform.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@Tag(name = "Authentication", description = "Authentication management APIs")
@CrossOrigin(origins = "*", maxAge = 3600)
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/login")
    @Operation(summary = "User login", description = "Authenticate user and return JWT token")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest loginRequest) {
        LoginResponse response = authService.login(loginRequest);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/register")
    @Operation(summary = "User registration", description = "Register a new user account")
    public ResponseEntity<UserDto> register(@Valid @RequestBody CreateUserRequest signupRequest) {
        UserDto user = authService.register(signupRequest);
        return ResponseEntity.status(HttpStatus.CREATED).body(user);
    }

    @PostMapping("/refresh-token")
    @Operation(summary = "Refresh JWT token", description = "Get new JWT token using refresh token")
    public ResponseEntity<LoginResponse> refreshToken(@RequestBody Map<String, String> request) {
        String refreshToken = request.get("refreshToken");
        LoginResponse response = authService.refreshToken(refreshToken);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/me")
    @Operation(summary = "Get current user", description = "Get current authenticated user details")
    public ResponseEntity<UserDto> getCurrentUser(@AuthenticationPrincipal User currentUser) {
        UserDto user = authService.getCurrentUser(currentUser.getEmail());
        return ResponseEntity.ok(user);
    }

    @PutMapping("/profile")
    @Operation(summary = "Update user profile", description = "Update current user profile information")
    public ResponseEntity<UserDto> updateProfile(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody UpdateUserRequest updateRequest) {
        UserDto updatedUser = authService.updateProfile(currentUser.getEmail(), updateRequest);
        return ResponseEntity.ok(updatedUser);
    }

    @PutMapping("/change-password")
    @Operation(summary = "Change password", description = "Change user password")
    public ResponseEntity<Map<String, String>> changePassword(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody ChangePasswordRequest changePasswordRequest) {
        
        // Validate password confirmation
        if (!changePasswordRequest.getNewPassword().equals(changePasswordRequest.getConfirmPassword())) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "New password and confirm password do not match"));
        }
        
        authService.changePassword(currentUser.getEmail(), changePasswordRequest);
        return ResponseEntity.ok(Map.of("message", "Password changed successfully"));
    }

    @PostMapping("/reset-password")
    @Operation(summary = "Request password reset", description = "Send password reset email")
    public ResponseEntity<Map<String, String>> resetPassword(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        // TODO: Implement password reset functionality
        return ResponseEntity.ok(Map.of("message", "Password reset email sent"));
    }

    @PostMapping("/reset-password/confirm")
    @Operation(summary = "Confirm password reset", description = "Reset password using token")
    public ResponseEntity<Map<String, String>> confirmResetPassword(@RequestBody Map<String, String> request) {
        String token = request.get("token");
        String newPassword = request.get("newPassword");
        // TODO: Implement password reset confirmation
        return ResponseEntity.ok(Map.of("message", "Password reset successfully"));
    }

    @PostMapping("/verify-email")
    @Operation(summary = "Verify email", description = "Verify user email using token")
    public ResponseEntity<Map<String, String>> verifyEmail(@RequestParam("token") String token) {
        authService.verifyEmail(token);
        return ResponseEntity.ok(Map.of("message", "Email verified successfully"));
    }

    @PostMapping("/resend-verification")
    @Operation(summary = "Resend verification email", description = "Resend email verification link")
    public ResponseEntity<Map<String, String>> resendVerification(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        // TODO: Implement resend verification functionality
        return ResponseEntity.ok(Map.of("message", "Verification email sent"));
    }

    @GetMapping("/health")
    @Operation(summary = "Health check", description = "Check if authentication service is running")
    public ResponseEntity<Map<String, String>> health() {
        return ResponseEntity.ok(Map.of(
                "status", "UP",
                "service", "auth-service",
                "timestamp", String.valueOf(System.currentTimeMillis())
        ));
    }
}
