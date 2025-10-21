package com.edplatform.dto.auth;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * User Data Transfer Object
 * Used for transferring user information between layers
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserDto {

    private Long id;
    
    private String firstName;
    
    private String lastName;
    
    private String fullName; // Computed field: firstName + lastName
    
    private String username;
    
    private String email;
    
    // NOTE: Password is never included in DTO for security
    
    private String roleName;
    
    private String phoneNumber;
    
    private LocalDate dateOfBirth;
    
    private String profileImageUrl;
    
    private String bio;
    
    private String timezone;
    
    private String language;
    
    private Boolean isActive;
    
    private Boolean isVerified;
    
    // Notification preferences
    private Boolean emailNotifications;
    
    private Boolean pushNotifications;
    
    private Boolean smsNotifications;
    
    // Privacy settings
    private Boolean profilePublic;
    
    private Boolean showEmail;
    
    private Boolean showPhone;
    
    // Timestamps
    private LocalDateTime createdAt;
    
    private LocalDateTime updatedAt;
    
    private LocalDateTime lastLoginAt;
    
    // Optional: Statistics for profile
    private Integer coursesEnrolled;
    
    private Integer coursesCompleted;
    
    private Integer coursesTeaching; // For instructors
    
    private Double averageRating; // For instructors
}
