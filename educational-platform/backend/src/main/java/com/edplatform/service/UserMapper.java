package com.edplatform.service;

import com.edplatform.dto.auth.UserDto;
import com.edplatform.entity.User;
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
    @Mapping(target = "password", ignore = true) // Never expose password
    @Mapping(target = "fullName", expression = "java(user.getFirstName() + \" \" + user.getLastName())")
    @Mapping(target = "roleName", source = "role")
    UserDto toDto(User user);

    /**
     * Convert UserDto to User entity
     */
    @Mapping(target = "id", ignore = true) // ID should not be set manually
    @Mapping(target = "password", ignore = true) // Password handled separately
    @Mapping(target = "createdAt", ignore = true) // Managed by service
    @Mapping(target = "updatedAt", ignore = true) // Managed by service
    @Mapping(target = "lastLoginAt", ignore = true) // Managed by service
    @Mapping(target = "authorities", ignore = true) // Derived from role
    User toEntity(UserDto userDto);

    /**
     * Convert list of User entities to list of UserDtos
     */
    List<UserDto> toDtoList(List<User> users);

    /**
     * Update existing User entity from UserDto
     */
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "email", ignore = true) // Email should not be changed
    @Mapping(target = "username", ignore = true) // Username should not be changed
    @Mapping(target = "password", ignore = true) // Password handled separately
    @Mapping(target = "role", ignore = true) // Role changes handled separately
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "lastLoginAt", ignore = true)
    @Mapping(target = "authorities", ignore = true)
    void updateEntityFromDto(UserDto userDto, @MappingTarget User user);

    /**
     * Create a basic User entity for registration
     */
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "password", ignore = true) // Password encoded separately
    @Mapping(target = "isActive", constant = "true")
    @Mapping(target = "isVerified", constant = "false")
    @Mapping(target = "createdAt", ignore = true) // Set by service
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "lastLoginAt", ignore = true)
    @Mapping(target = "authorities", ignore = true)
    User createEntityFromDto(UserDto userDto);

    /**
     * Default method to handle role enum to string conversion
     */
    default String mapRole(User.Role role) {
        return role != null ? role.name() : null;
    }

    /**
     * Default method to handle string to role enum conversion
     */
    default User.Role mapRole(String role) {
        try {
            return role != null ? User.Role.valueOf(role.toUpperCase()) : null;
        } catch (IllegalArgumentException e) {
            return User.Role.STUDENT; // Default fallback
        }
    }
}
