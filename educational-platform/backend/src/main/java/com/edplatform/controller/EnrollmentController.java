package com.edplatform.controller;

import com.edplatform.dto.EnrollmentCreateRequest;
import com.edplatform.dto.EnrollmentResponse;
import com.edplatform.entity.User;
import com.edplatform.security.CurrentUser;
import com.edplatform.service.EnrollmentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/enrollments")
@Tag(name = "Enrollment Management", description = "APIs for managing course enrollments")
public class EnrollmentController {

    @Autowired
    private EnrollmentService enrollmentService;

    @PostMapping
    @PreAuthorize("hasRole('STUDENT')")
    @Operation(summary = "Enroll in a course", description = "Enroll the current user in a course")
    @SecurityRequirement(name = "bearerAuth")
    @ApiResponse(responseCode = "201", description = "Successfully enrolled in course")
    @ApiResponse(responseCode = "400", description = "Invalid enrollment request")
    @ApiResponse(responseCode = "401", description = "Unauthorized")
    @ApiResponse(responseCode = "403", description = "Forbidden - not a student")
    @ApiResponse(responseCode = "404", description = "Course not found")
    public ResponseEntity<EnrollmentResponse> enrollInCourse(
            @Valid @RequestBody EnrollmentCreateRequest request,
            @Parameter(hidden = true) @CurrentUser User currentUser) {
        EnrollmentResponse enrollment = enrollmentService.enrollStudent(request, currentUser.getId());
        return ResponseEntity.status(HttpStatus.CREATED).body(enrollment);
    }

    @DeleteMapping("/course/{courseId}")
    @PreAuthorize("hasRole('STUDENT')")
    @Operation(summary = "Unenroll from a course", description = "Unenroll the current user from a course")
    @SecurityRequirement(name = "bearerAuth")
    @ApiResponse(responseCode = "204", description = "Successfully unenrolled from course")
    @ApiResponse(responseCode = "400", description = "Cannot unenroll from this course")
    @ApiResponse(responseCode = "401", description = "Unauthorized")
    @ApiResponse(responseCode = "403", description = "Forbidden - not a student")
    @ApiResponse(responseCode = "404", description = "Enrollment not found")
    public ResponseEntity<Void> unenrollFromCourse(
            @PathVariable Long courseId,
            @Parameter(hidden = true) @CurrentUser User currentUser) {
        enrollmentService.unenrollStudent(courseId, currentUser.getId());
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/my-courses")
    @PreAuthorize("hasRole('STUDENT')")
    @Operation(summary = "Get my enrollments", description = "Get current user's course enrollments")
    @SecurityRequirement(name = "bearerAuth")
    @ApiResponse(responseCode = "200", description = "Successfully retrieved enrollments")
    public ResponseEntity<Page<EnrollmentResponse>> getMyEnrollments(
            @PageableDefault(size = 20, sort = "enrollmentDate") Pageable pageable,
            @Parameter(hidden = true) @CurrentUser User currentUser) {
        Page<EnrollmentResponse> enrollments = enrollmentService.getStudentEnrollments(currentUser.getId(), pageable);
        return ResponseEntity.ok(enrollments);
    }

    @GetMapping("/course/{courseId}")
    @PreAuthorize("hasRole('INSTRUCTOR') or hasRole('ADMIN')")
    @Operation(summary = "Get course enrollments", description = "Get all enrollments for a specific course")
    @SecurityRequirement(name = "bearerAuth")
    @ApiResponse(responseCode = "200", description = "Successfully retrieved enrollments")
    @ApiResponse(responseCode = "401", description = "Unauthorized")
    @ApiResponse(responseCode = "403", description = "Forbidden - not instructor or admin")
    @ApiResponse(responseCode = "404", description = "Course not found")
    public ResponseEntity<Page<EnrollmentResponse>> getCourseEnrollments(
            @PathVariable Long courseId,
            @PageableDefault(size = 50, sort = "enrollmentDate") Pageable pageable) {
        Page<EnrollmentResponse> enrollments = enrollmentService.getCourseEnrollments(courseId, pageable);
        return ResponseEntity.ok(enrollments);
    }

    @GetMapping("/course/{courseId}/student/{studentId}")
    @PreAuthorize("hasRole('INSTRUCTOR') or hasRole('ADMIN') or #studentId == authentication.principal.id")
    @Operation(summary = "Get specific enrollment", description = "Get enrollment details for a specific student and course")
    @SecurityRequirement(name = "bearerAuth")
    @ApiResponse(responseCode = "200", description = "Successfully retrieved enrollment")
    @ApiResponse(responseCode = "401", description = "Unauthorized")
    @ApiResponse(responseCode = "403", description = "Forbidden")
    @ApiResponse(responseCode = "404", description = "Enrollment not found")
    public ResponseEntity<EnrollmentResponse> getEnrollment(
            @PathVariable Long courseId,
            @PathVariable Long studentId) {
        EnrollmentResponse enrollment = enrollmentService.getEnrollment(courseId, studentId);
        return ResponseEntity.ok(enrollment);
    }

    @PutMapping("/course/{courseId}/progress")
    @PreAuthorize("hasRole('STUDENT')")
    @Operation(summary = "Update progress", description = "Update current user's progress in a course")
    @SecurityRequirement(name = "bearerAuth")
    @ApiResponse(responseCode = "200", description = "Progress updated successfully")
    @ApiResponse(responseCode = "400", description = "Invalid progress value")
    @ApiResponse(responseCode = "401", description = "Unauthorized")
    @ApiResponse(responseCode = "403", description = "Forbidden - not enrolled in course")
    @ApiResponse(responseCode = "404", description = "Enrollment not found")
    public ResponseEntity<EnrollmentResponse> updateProgress(
            @PathVariable Long courseId,
            @RequestParam Double progress,
            @Parameter(hidden = true) @CurrentUser User currentUser) {
        EnrollmentResponse enrollment = enrollmentService.updateProgress(courseId, currentUser.getId(), progress);
        return ResponseEntity.ok(enrollment);
    }

    @GetMapping("/course/{courseId}/is-enrolled")
    @PreAuthorize("hasRole('STUDENT')")
    @Operation(summary = "Check enrollment status", description = "Check if current user is enrolled in a course")
    @SecurityRequirement(name = "bearerAuth")
    @ApiResponse(responseCode = "200", description = "Enrollment status checked")
    public ResponseEntity<Boolean> isEnrolled(
            @PathVariable Long courseId,
            @Parameter(hidden = true) @CurrentUser User currentUser) {
        boolean isEnrolled = enrollmentService.isStudentEnrolled(courseId, currentUser.getId());
        return ResponseEntity.ok(isEnrolled);
    }

    @GetMapping("/completed")
    @PreAuthorize("hasRole('STUDENT')")
    @Operation(summary = "Get completed courses", description = "Get current user's completed courses")
    @SecurityRequirement(name = "bearerAuth")
    @ApiResponse(responseCode = "200", description = "Successfully retrieved completed courses")
    public ResponseEntity<List<EnrollmentResponse>> getCompletedCourses(
            @Parameter(hidden = true) @CurrentUser User currentUser) {
        List<EnrollmentResponse> completedCourses = enrollmentService.getCompletedCourses(currentUser.getId());
        return ResponseEntity.ok(completedCourses);
    }

    @GetMapping("/stats/total")
    @Operation(summary = "Get total enrollments", description = "Get total number of active enrollments")
    @ApiResponse(responseCode = "200", description = "Successfully retrieved count")
    public ResponseEntity<Long> getTotalEnrollments() {
        long totalEnrollments = enrollmentService.getTotalEnrollments();
        return ResponseEntity.ok(totalEnrollments);
    }

    @GetMapping("/stats/student/{studentId}/count")
    @PreAuthorize("hasRole('ADMIN') or hasRole('INSTRUCTOR') or #studentId == authentication.principal.id")
    @Operation(summary = "Get student enrollment count", description = "Get number of active enrollments for a student")
    @SecurityRequirement(name = "bearerAuth")
    @ApiResponse(responseCode = "200", description = "Successfully retrieved count")
    public ResponseEntity<Long> getStudentEnrollmentCount(@PathVariable Long studentId) {
        long enrollmentCount = enrollmentService.getStudentEnrollmentCount(studentId);
        return ResponseEntity.ok(enrollmentCount);
    }

    @GetMapping("/stats/course/{courseId}/count")
    @Operation(summary = "Get course enrollment count", description = "Get number of active enrollments for a course")
    @ApiResponse(responseCode = "200", description = "Successfully retrieved count")
    public ResponseEntity<Long> getCourseEnrollmentCount(@PathVariable Long courseId) {
        long enrollmentCount = enrollmentService.getCourseEnrollmentCount(courseId);
        return ResponseEntity.ok(enrollmentCount);
    }

    @GetMapping("/stats/average-progress")
    @PreAuthorize("hasRole('STUDENT')")
    @Operation(summary = "Get average progress", description = "Get current user's average progress across all courses")
    @SecurityRequirement(name = "bearerAuth")
    @ApiResponse(responseCode = "200", description = "Successfully retrieved average progress")
    public ResponseEntity<Double> getAverageProgress(
            @Parameter(hidden = true) @CurrentUser User currentUser) {
        double averageProgress = enrollmentService.getStudentAverageProgress(currentUser.getId());
        return ResponseEntity.ok(averageProgress);
    }
}
