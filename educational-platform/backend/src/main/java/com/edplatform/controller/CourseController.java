package com.edplatform.controller;

import com.edplatform.dto.CourseCreateRequest;
import com.edplatform.dto.CourseResponse;
import com.edplatform.dto.CourseUpdateRequest;
import com.edplatform.entity.CourseCategory;
import com.edplatform.entity.CourseLevel;
import com.edplatform.security.CurrentUser;
import com.edplatform.entity.User;
import com.edplatform.service.CourseService;
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
@RequestMapping("/api/courses")
@Tag(name = "Course Management", description = "APIs for managing courses")
public class CourseController {

    @Autowired
    private CourseService courseService;

    @GetMapping
    @Operation(summary = "Get all published courses", description = "Retrieve a paginated list of all published courses")
    @ApiResponse(responseCode = "200", description = "Successfully retrieved courses")
    public ResponseEntity<Page<CourseResponse>> getAllCourses(
            @PageableDefault(size = 20, sort = "createdAt") Pageable pageable) {
        Page<CourseResponse> courses = courseService.getAllCourses(pageable);
        return ResponseEntity.ok(courses);
    }

    @GetMapping("/search")
    @Operation(summary = "Search courses", description = "Search for courses by keyword in title")
    @ApiResponse(responseCode = "200", description = "Successfully retrieved matching courses")
    public ResponseEntity<Page<CourseResponse>> searchCourses(
            @RequestParam String keyword,
            @PageableDefault(size = 20, sort = "createdAt") Pageable pageable) {
        Page<CourseResponse> courses = courseService.searchCourses(keyword, pageable);
        return ResponseEntity.ok(courses);
    }

    @GetMapping("/category/{category}")
    @Operation(summary = "Get courses by category", description = "Retrieve courses filtered by category")
    @ApiResponse(responseCode = "200", description = "Successfully retrieved courses")
    public ResponseEntity<Page<CourseResponse>> getCoursesByCategory(
            @PathVariable CourseCategory category,
            @PageableDefault(size = 20, sort = "createdAt") Pageable pageable) {
        Page<CourseResponse> courses = courseService.getCoursesByCategory(category, pageable);
        return ResponseEntity.ok(courses);
    }

    @GetMapping("/level/{level}")
    @Operation(summary = "Get courses by level", description = "Retrieve courses filtered by difficulty level")
    @ApiResponse(responseCode = "200", description = "Successfully retrieved courses")
    public ResponseEntity<Page<CourseResponse>> getCoursesByLevel(
            @PathVariable CourseLevel level,
            @PageableDefault(size = 20, sort = "createdAt") Pageable pageable) {
        Page<CourseResponse> courses = courseService.getCoursesByLevel(level, pageable);
        return ResponseEntity.ok(courses);
    }

    @GetMapping("/featured")
    @Operation(summary = "Get featured courses", description = "Retrieve list of featured courses")
    @ApiResponse(responseCode = "200", description = "Successfully retrieved featured courses")
    public ResponseEntity<List<CourseResponse>> getFeaturedCourses() {
        List<CourseResponse> courses = courseService.getFeaturedCourses();
        return ResponseEntity.ok(courses);
    }

    @GetMapping("/top-rated")
    @Operation(summary = "Get top rated courses", description = "Retrieve list of top rated courses")
    @ApiResponse(responseCode = "200", description = "Successfully retrieved top rated courses")
    public ResponseEntity<List<CourseResponse>> getTopRatedCourses(
            @RequestParam(defaultValue = "10") int limit) {
        List<CourseResponse> courses = courseService.getTopRatedCourses(limit);
        return ResponseEntity.ok(courses);
    }

    @GetMapping("/{courseId}")
    @Operation(summary = "Get course by ID", description = "Retrieve a specific course by its ID")
    @ApiResponse(responseCode = "200", description = "Successfully retrieved course")
    @ApiResponse(responseCode = "404", description = "Course not found")
    public ResponseEntity<CourseResponse> getCourseById(@PathVariable Long courseId) {
        CourseResponse course = courseService.getCourseById(courseId);
        return ResponseEntity.ok(course);
    }

    @GetMapping("/code/{courseCode}")
    @Operation(summary = "Get course by code", description = "Retrieve a specific course by its code")
    @ApiResponse(responseCode = "200", description = "Successfully retrieved course")
    @ApiResponse(responseCode = "404", description = "Course not found")
    public ResponseEntity<CourseResponse> getCourseByCode(@PathVariable String courseCode) {
        CourseResponse course = courseService.getCourseByCode(courseCode);
        return ResponseEntity.ok(course);
    }

    @GetMapping("/instructor/{instructorId}")
    @Operation(summary = "Get courses by instructor", description = "Retrieve courses taught by a specific instructor")
    @ApiResponse(responseCode = "200", description = "Successfully retrieved courses")
    @ApiResponse(responseCode = "404", description = "Instructor not found")
    public ResponseEntity<Page<CourseResponse>> getCoursesByInstructor(
            @PathVariable Long instructorId,
            @PageableDefault(size = 20, sort = "createdAt") Pageable pageable) {
        Page<CourseResponse> courses = courseService.getCoursesByInstructor(instructorId, pageable);
        return ResponseEntity.ok(courses);
    }

    @PostMapping
    @PreAuthorize("hasRole('INSTRUCTOR') or hasRole('ADMIN')")
    @Operation(summary = "Create a new course", description = "Create a new course (instructors and admins only)")
    @SecurityRequirement(name = "bearerAuth")
    @ApiResponse(responseCode = "201", description = "Course created successfully")
    @ApiResponse(responseCode = "400", description = "Invalid course data")
    @ApiResponse(responseCode = "401", description = "Unauthorized")
    @ApiResponse(responseCode = "403", description = "Forbidden - insufficient privileges")
    public ResponseEntity<CourseResponse> createCourse(
            @Valid @RequestBody CourseCreateRequest request,
            @Parameter(hidden = true) @CurrentUser User currentUser) {
        CourseResponse course = courseService.createCourse(request, currentUser.getId());
        return ResponseEntity.status(HttpStatus.CREATED).body(course);
    }

    @PutMapping("/{courseId}")
    @PreAuthorize("hasRole('INSTRUCTOR') or hasRole('ADMIN')")
    @Operation(summary = "Update a course", description = "Update an existing course (course owner or admin only)")
    @SecurityRequirement(name = "bearerAuth")
    @ApiResponse(responseCode = "200", description = "Course updated successfully")
    @ApiResponse(responseCode = "400", description = "Invalid course data")
    @ApiResponse(responseCode = "401", description = "Unauthorized")
    @ApiResponse(responseCode = "403", description = "Forbidden - not course owner")
    @ApiResponse(responseCode = "404", description = "Course not found")
    public ResponseEntity<CourseResponse> updateCourse(
            @PathVariable Long courseId,
            @Valid @RequestBody CourseUpdateRequest request,
            @Parameter(hidden = true) @CurrentUser User currentUser) {
        CourseResponse course = courseService.updateCourse(courseId, request, currentUser.getId());
        return ResponseEntity.ok(course);
    }

    @DeleteMapping("/{courseId}")
    @PreAuthorize("hasRole('INSTRUCTOR') or hasRole('ADMIN')")
    @Operation(summary = "Delete a course", description = "Archive a course (course owner or admin only)")
    @SecurityRequirement(name = "bearerAuth")
    @ApiResponse(responseCode = "204", description = "Course archived successfully")
    @ApiResponse(responseCode = "401", description = "Unauthorized")
    @ApiResponse(responseCode = "403", description = "Forbidden - not course owner")
    @ApiResponse(responseCode = "404", description = "Course not found")
    public ResponseEntity<Void> deleteCourse(
            @PathVariable Long courseId,
            @Parameter(hidden = true) @CurrentUser User currentUser) {
        courseService.deleteCourse(courseId, currentUser.getId());
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{courseId}/publish")
    @PreAuthorize("hasRole('INSTRUCTOR') or hasRole('ADMIN')")
    @Operation(summary = "Publish a course", description = "Publish a course making it available to students")
    @SecurityRequirement(name = "bearerAuth")
    @ApiResponse(responseCode = "200", description = "Course published successfully")
    @ApiResponse(responseCode = "400", description = "Course not ready for publishing")
    @ApiResponse(responseCode = "401", description = "Unauthorized")
    @ApiResponse(responseCode = "403", description = "Forbidden - not course owner")
    @ApiResponse(responseCode = "404", description = "Course not found")
    public ResponseEntity<CourseResponse> publishCourse(
            @PathVariable Long courseId,
            @Parameter(hidden = true) @CurrentUser User currentUser) {
        CourseResponse course = courseService.publishCourse(courseId, currentUser.getId());
        return ResponseEntity.ok(course);
    }

    @PutMapping("/{courseId}/unpublish")
    @PreAuthorize("hasRole('INSTRUCTOR') or hasRole('ADMIN')")
    @Operation(summary = "Unpublish a course", description = "Unpublish a course making it unavailable to students")
    @SecurityRequirement(name = "bearerAuth")
    @ApiResponse(responseCode = "200", description = "Course unpublished successfully")
    @ApiResponse(responseCode = "401", description = "Unauthorized")
    @ApiResponse(responseCode = "403", description = "Forbidden - not course owner")
    @ApiResponse(responseCode = "404", description = "Course not found")
    public ResponseEntity<CourseResponse> unpublishCourse(
            @PathVariable Long courseId,
            @Parameter(hidden = true) @CurrentUser User currentUser) {
        CourseResponse course = courseService.unpublishCourse(courseId, currentUser.getId());
        return ResponseEntity.ok(course);
    }

    @GetMapping("/{courseId}/can-enroll")
    @PreAuthorize("hasRole('STUDENT')")
    @Operation(summary = "Check if user can enroll", description = "Check if current user can enroll in a course")
    @SecurityRequirement(name = "bearerAuth")
    @ApiResponse(responseCode = "200", description = "Enrollment eligibility checked")
    public ResponseEntity<Boolean> canEnrollInCourse(
            @PathVariable Long courseId,
            @Parameter(hidden = true) @CurrentUser User currentUser) {
        boolean canEnroll = courseService.canUserEnrollInCourse(courseId, currentUser.getId());
        return ResponseEntity.ok(canEnroll);
    }

    @GetMapping("/stats/total")
    @Operation(summary = "Get total courses count", description = "Get total number of published courses")
    @ApiResponse(responseCode = "200", description = "Successfully retrieved count")
    public ResponseEntity<Long> getTotalCourses() {
        long totalCourses = courseService.getTotalCourses();
        return ResponseEntity.ok(totalCourses);
    }

    @GetMapping("/{courseId}/rating")
    @Operation(summary = "Get course average rating", description = "Get average rating for a course")
    @ApiResponse(responseCode = "200", description = "Successfully retrieved rating")
    @ApiResponse(responseCode = "404", description = "Course not found")
    public ResponseEntity<Double> getCourseRating(@PathVariable Long courseId) {
        double rating = courseService.getAverageRating(courseId);
        return ResponseEntity.ok(rating);
    }
}
