package com.edplatform.service;

import com.edplatform.dto.auth.UserDto;
import com.edplatform.entity.User;
import com.edplatform.entity.Role;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.NullValuePropertyMappingStrategy;

import java.util.List;

/**
 * MapStruct mapper for User entity and DTO conversions
 */
@Mapper(
    componentModel = "spring",
    nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE
)
public interface UserMapper {

    /**
     * Convert User entity to UserDto
     */
    @Mapping(target = "fullName", expression = "java(user.getFirstName() + \" \" + user.getLastName())")
    @Mapping(target = "roleName", expression = "java(mapRolesToString(user.getRoles()))")
    @Mapping(target = "username", source = "email")
    @Mapping(target = "isVerified", source = "isEmailVerified")
    UserDto toDto(User user);

    /**
     * Convert list of User entities to list of UserDtos
     */
    List<UserDto> toDtoList(List<User> users);

    /**
     * Update existing User entity from UserDto using MappingTarget
     */
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "email", ignore = true) // Email should not be changed
    @Mapping(target = "password", ignore = true) // Password handled separately
    @Mapping(target = "roles", ignore = true) // Role changes handled separately
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "version", ignore = true)
    @Mapping(target = "lastLogin", ignore = true)
    @Mapping(target = "isEmailVerified", source = "isVerified")
    @Mapping(target = "emailVerificationToken", ignore = true)
    @Mapping(target = "passwordResetToken", ignore = true)
    @Mapping(target = "passwordResetExpires", ignore = true)
    @Mapping(target = "enrollments", ignore = true)
    @Mapping(target = "taughtCourses", ignore = true)
    @Mapping(target = "quizAttempts", ignore = true)
    @Mapping(target = "assignments", ignore = true)
    @Mapping(target = "studentId", ignore = true)
    @Mapping(target = "enrollmentDate", ignore = true)
    @Mapping(target = "employeeId", ignore = true)
    @Mapping(target = "department", ignore = true)
    @Mapping(target = "specialization", ignore = true)
    @Mapping(target = "hireDate", ignore = true)
    void updateEntityFromDto(UserDto userDto, @MappingTarget User user);

    /**
     * Default method to handle role enum to string conversion
     */
    default String mapRole(Role role) {
        return role != null ? role.name() : null;
    }

    /**
     * Default method to handle string to role enum conversion
     */
    default Role mapRole(String role) {
        try {
            return role != null ? Role.valueOf(role.toUpperCase()) : null;
        } catch (IllegalArgumentException e) {
            return Role.STUDENT; // Default fallback
        }
    }

    /**
     * Helper method to convert roles set to string
     */
    default String mapRolesToString(java.util.Set<Role> roles) {
        if (roles == null || roles.isEmpty()) {
            return Role.STUDENT.name();
        }
        return roles.iterator().next().name(); // Return first role for simplicity
    }
}
