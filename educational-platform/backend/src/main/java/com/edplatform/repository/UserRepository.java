package com.edplatform.repository;

import com.edplatform.entity.User;
import com.edplatform.entity.Role;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);
    
    Optional<User> findByStudentId(String studentId);
    
    Optional<User> findByEmployeeId(String employeeId);
    
    boolean existsByEmail(String email);
    
    boolean existsByStudentId(String studentId);
    
    boolean existsByEmployeeId(String employeeId);
    
    @Query("SELECT u FROM User u WHERE u.roles LIKE %:role%")
    List<User> findByRole(@Param("role") Role role);
    
    @Query("SELECT u FROM User u WHERE u.isActive = true")
    List<User> findAllActiveUsers();
    
    @Query("SELECT u FROM User u WHERE u.isEmailVerified = false")
    List<User> findAllUnverifiedUsers();
    
    @Query("SELECT u FROM User u WHERE u.lastLogin < :date")
    List<User> findUsersLastLoginBefore(@Param("date") LocalDateTime date);
    
    @Query("SELECT u FROM User u WHERE u.firstName LIKE %:name% OR u.lastName LIKE %:name% OR u.email LIKE %:name%")
    List<User> searchByName(@Param("name") String name);
    
    @Query("SELECT u FROM User u JOIN u.enrollments e WHERE e.course.id = :courseId AND e.status = 'ACTIVE'")
    List<User> findStudentsByCourseId(@Param("courseId") Long courseId);
    
    @Query("SELECT u FROM User u WHERE u.roles LIKE '%INSTRUCTOR%' AND u.department = :department")
    List<User> findInstructorsByDepartment(@Param("department") String department);
    
    Optional<User> findByEmailVerificationToken(String token);
    
    Optional<User> findByPasswordResetToken(String token);
    
    @Query("SELECT u FROM User u WHERE u.passwordResetExpires < :now")
    List<User> findUsersWithExpiredPasswordResetTokens(@Param("now") LocalDateTime now);
    
    @Query("SELECT COUNT(u) FROM User u WHERE u.roles LIKE %:role%")
    long countByRole(@Param("role") Role role);
    
    @Query("SELECT u FROM User u WHERE u.createdAt BETWEEN :startDate AND :endDate")
    List<User> findUsersCreatedBetween(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
}
