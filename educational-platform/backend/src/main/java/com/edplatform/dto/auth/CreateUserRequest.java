package com.edplatform.dto.auth;

import com.edplatform.entity.User;
import com.edplatform.entity.Role;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import jakarta.validation.constraints.Pattern;

/**
 * Request DTO for creating a new user
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateUserRequest {

    @NotBlank(message = "First name is required")
    @Size(min = 2, max = 50, message = "First name must be between 2 and 50 characters")
    private String firstName;

    @NotBlank(message = "Last name is required")
    @Size(min = 2, max = 50, message = "Last name must be between 2 and 50 characters")
    private String lastName;

    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    @Size(max = 100, message = "Email cannot exceed 100 characters")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 8, max = 100, message = "Password must be between 8 and 100 characters")
    @Pattern(
        regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$",
        message = "Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character"
    )
    private String password;

    @NotBlank(message = "Confirm password is required")
    private String confirmPassword;

    private Role role = Role.STUDENT; // Default role

    @Pattern(regexp = "^\\+?[1-9]\\d{1,14}$", message = "Phone number must be valid")
    private String phoneNumber;

    // Terms and conditions acceptance
    @NotNull(message = "You must accept the terms and conditions")
    private Boolean acceptTerms;

    // Privacy policy acceptance
    @NotNull(message = "You must accept the privacy policy")
    private Boolean acceptPrivacy;

    // Marketing emails opt-in (optional)
    private Boolean marketingEmails = false;

    /**
     * Validation method to check if passwords match
     */
    public boolean isPasswordsMatch() {
        return password != null && password.equals(confirmPassword);
    }

    /**
     * Validation method to check if terms are accepted
     */
    public boolean isTermsAccepted() {
        return acceptTerms != null && acceptTerms;
    }

    /**
     * Validation method to check if privacy policy is accepted
     */
    public boolean isPrivacyAccepted() {
        return acceptPrivacy != null && acceptPrivacy;
    }
}
