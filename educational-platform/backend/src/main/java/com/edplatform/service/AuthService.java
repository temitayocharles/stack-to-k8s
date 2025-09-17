package com.edplatform.service;

import com.edplatform.dto.auth.*;
import com.edplatform.entity.User;
import com.edplatform.exception.BusinessException;
import com.edplatform.exception.ResourceNotFoundException;
import com.edplatform.repository.UserRepository;
import com.edplatform.security.JwtTokenProvider;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.validation.Valid;
import java.time.LocalDateTime;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Service class for handling authentication and authorization operations
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider jwtTokenProvider;
    private final UserMapper userMapper;

    /**
     * Register a new user
     */
    public UserDto registerUser(@Valid CreateUserRequest request) {
        log.info("Attempting to register user with email: {}", request.getEmail());

        // Check if user already exists
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BusinessException("User with email " + request.getEmail() + " already exists");
        }

        // Check if username is taken
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new BusinessException("Username " + request.getUsername() + " is already taken");
        }

        // Create new user entity
        User user = User.builder()
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .username(request.getUsername())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .role(request.getRole() != null ? request.getRole() : User.Role.STUDENT)
                .isActive(true)
                .isVerified(false) // Email verification required
                .createdAt(LocalDateTime.now())
                .build();

        User savedUser = userRepository.save(user);
        log.info("User registered successfully with ID: {}", savedUser.getId());

        return userMapper.toDto(savedUser);
    }

    /**
     * Authenticate user and return JWT token
     */
    public LoginResponse authenticateUser(@Valid LoginRequest request) {
        log.info("Attempting to authenticate user: {}", request.getEmail());

        try {
            // Authenticate user
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            request.getEmail(),
                            request.getPassword()
                    )
            );

            // Set authentication in context
            SecurityContextHolder.getContext().setAuthentication(authentication);

            // Get user details
            User user = userRepository.findByEmail(request.getEmail())
                    .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + request.getEmail()));

            // Check if user is active
            if (!user.getIsActive()) {
                throw new BusinessException("User account is deactivated");
            }

            // Generate JWT token
            String token = jwtTokenProvider.generateToken(authentication);
            String refreshToken = jwtTokenProvider.generateRefreshToken(authentication);

            // Update last login time
            user.setLastLoginAt(LocalDateTime.now());
            userRepository.save(user);

            log.info("User authenticated successfully: {}", user.getEmail());

            return LoginResponse.builder()
                    .token(token)
                    .refreshToken(refreshToken)
                    .tokenType("Bearer")
                    .expiresIn(jwtTokenProvider.getJwtExpirationInMs())
                    .user(userMapper.toDto(user))
                    .build();

        } catch (Exception e) {
            log.error("Authentication failed for user: {}", request.getEmail(), e);
            throw new BusinessException("Invalid email or password");
        }
    }

    /**
     * Refresh JWT token
     */
    public LoginResponse refreshToken(String refreshToken) {
        log.info("Attempting to refresh token");

        try {
            // Validate refresh token
            if (!jwtTokenProvider.validateToken(refreshToken)) {
                throw new BusinessException("Invalid refresh token");
            }

            // Get username from token
            String email = jwtTokenProvider.getUsernameFromToken(refreshToken);
            User user = userRepository.findByEmail(email)
                    .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + email));

            // Create new authentication
            Authentication authentication = new UsernamePasswordAuthenticationToken(
                    email, null, user.getAuthorities()
            );

            // Generate new tokens
            String newToken = jwtTokenProvider.generateToken(authentication);
            String newRefreshToken = jwtTokenProvider.generateRefreshToken(authentication);

            log.info("Token refreshed successfully for user: {}", email);

            return LoginResponse.builder()
                    .token(newToken)
                    .refreshToken(newRefreshToken)
                    .tokenType("Bearer")
                    .expiresIn(jwtTokenProvider.getJwtExpirationInMs())
                    .user(userMapper.toDto(user))
                    .build();

        } catch (Exception e) {
            log.error("Token refresh failed", e);
            throw new BusinessException("Token refresh failed");
        }
    }

    /**
     * Get current authenticated user
     */
    public UserDto getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new BusinessException("No authenticated user found");
        }

        String email = authentication.getName();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + email));

        return userMapper.toDto(user);
    }

    /**
     * Update user profile
     */
    public UserDto updateUserProfile(@Valid UpdateUserRequest request) {
        User currentUser = getCurrentAuthenticatedUser();
        
        log.info("Updating profile for user: {}", currentUser.getEmail());

        // Update user fields
        if (request.getFirstName() != null) {
            currentUser.setFirstName(request.getFirstName());
        }
        if (request.getLastName() != null) {
            currentUser.setLastName(request.getLastName());
        }
        if (request.getPhoneNumber() != null) {
            currentUser.setPhoneNumber(request.getPhoneNumber());
        }
        if (request.getDateOfBirth() != null) {
            currentUser.setDateOfBirth(request.getDateOfBirth());
        }

        currentUser.setUpdatedAt(LocalDateTime.now());
        User savedUser = userRepository.save(currentUser);

        log.info("Profile updated successfully for user: {}", savedUser.getEmail());
        return userMapper.toDto(savedUser);
    }

    /**
     * Change user password
     */
    public void changePassword(@Valid ChangePasswordRequest request) {
        User currentUser = getCurrentAuthenticatedUser();
        
        log.info("Changing password for user: {}", currentUser.getEmail());

        // Verify current password
        if (!passwordEncoder.matches(request.getCurrentPassword(), currentUser.getPassword())) {
            throw new BusinessException("Current password is incorrect");
        }

        // Validate new password
        if (request.getCurrentPassword().equals(request.getNewPassword())) {
            throw new BusinessException("New password must be different from current password");
        }

        // Update password
        currentUser.setPassword(passwordEncoder.encode(request.getNewPassword()));
        currentUser.setUpdatedAt(LocalDateTime.now());
        userRepository.save(currentUser);

        log.info("Password changed successfully for user: {}", currentUser.getEmail());
    }

    /**
     * Deactivate user account
     */
    public void deactivateAccount() {
        User currentUser = getCurrentAuthenticatedUser();
        
        log.info("Deactivating account for user: {}", currentUser.getEmail());

        currentUser.setIsActive(false);
        currentUser.setUpdatedAt(LocalDateTime.now());
        userRepository.save(currentUser);

        log.info("Account deactivated successfully for user: {}", currentUser.getEmail());
    }

    /**
     * Helper method to get current authenticated user entity
     */
    private User getCurrentAuthenticatedUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new BusinessException("No authenticated user found");
        }

        String email = authentication.getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + email));
    }

    /**
     * Check if user has specific role
     */
    public boolean hasRole(String role) {
        try {
            User currentUser = getCurrentAuthenticatedUser();
            return currentUser.getRole().name().equals(role);
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Get user authorities/permissions
     */
    public Set<String> getUserAuthorities() {
        try {
            User currentUser = getCurrentAuthenticatedUser();
            return currentUser.getAuthorities().stream()
                    .map(authority -> authority.getAuthority())
                    .collect(Collectors.toSet());
        } catch (Exception e) {
            return Set.of();
        }
    }
}
