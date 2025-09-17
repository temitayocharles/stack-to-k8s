package com.edplatform.service;

import com.edplatform.dto.CourseCreateRequest;
import com.edplatform.dto.CourseResponse;
import com.edplatform.dto.CourseUpdateRequest;
import com.edplatform.entity.*;
import com.edplatform.exception.ResourceNotFoundException;
import com.edplatform.exception.UnauthorizedException;
import com.edplatform.repository.CourseRepository;
import com.edplatform.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class CourseService {

    @Autowired
    private CourseRepository courseRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private CourseMapper courseMapper;

    public Page<CourseResponse> getAllCourses(Pageable pageable) {
        return courseRepository.findByStatus(CourseStatus.PUBLISHED, pageable)
                .map(courseMapper::toResponse);
    }

    public Page<CourseResponse> getCoursesByCategory(CourseCategory category, Pageable pageable) {
        return courseRepository.findByCategoryAndStatus(category, CourseStatus.PUBLISHED, pageable)
                .map(courseMapper::toResponse);
    }

    public Page<CourseResponse> getCoursesByLevel(CourseLevel level, Pageable pageable) {
        return courseRepository.findByLevelAndStatus(level, CourseStatus.PUBLISHED, pageable)
                .map(courseMapper::toResponse);
    }

    public Page<CourseResponse> searchCourses(String keyword, Pageable pageable) {
        return courseRepository.findByTitleContainingIgnoreCaseAndStatus(keyword, CourseStatus.PUBLISHED, pageable)
                .map(courseMapper::toResponse);
    }

    public CourseResponse getCourseById(Long courseId) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new ResourceNotFoundException("Course not found with id: " + courseId));
        
        return courseMapper.toResponse(course);
    }

    public CourseResponse getCourseByCode(String courseCode) {
        Course course = courseRepository.findByCourseCode(courseCode)
                .orElseThrow(() -> new ResourceNotFoundException("Course not found with code: " + courseCode));
        
        return courseMapper.toResponse(course);
    }

    public Page<CourseResponse> getCoursesByInstructor(Long instructorId, Pageable pageable) {
        User instructor = userRepository.findById(instructorId)
                .orElseThrow(() -> new ResourceNotFoundException("Instructor not found with id: " + instructorId));
        
        return courseRepository.findByInstructor(instructor, pageable)
                .map(courseMapper::toResponse);
    }

    public List<CourseResponse> getFeaturedCourses() {
        return courseRepository.findByIsFeaturedTrueAndStatus(CourseStatus.PUBLISHED)
                .stream()
                .map(courseMapper::toResponse)
                .collect(Collectors.toList());
    }

    public List<CourseResponse> getTopRatedCourses(int limit) {
        return courseRepository.findTopRatedCourses(Pageable.ofSize(limit))
                .stream()
                .map(courseMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public CourseResponse createCourse(CourseCreateRequest request, Long instructorId) {
        User instructor = userRepository.findById(instructorId)
                .orElseThrow(() -> new ResourceNotFoundException("Instructor not found with id: " + instructorId));

        if (!instructor.hasRole(Role.INSTRUCTOR) && !instructor.hasRole(Role.ADMIN)) {
            throw new UnauthorizedException("User is not authorized to create courses");
        }

        Course course = courseMapper.toEntity(request);
        course.setInstructor(instructor);
        course.setStatus(CourseStatus.DRAFT);

        Course savedCourse = courseRepository.save(course);
        return courseMapper.toResponse(savedCourse);
    }

    @Transactional
    public CourseResponse updateCourse(Long courseId, CourseUpdateRequest request, Long instructorId) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new ResourceNotFoundException("Course not found with id: " + courseId));

        User instructor = userRepository.findById(instructorId)
                .orElseThrow(() -> new ResourceNotFoundException("Instructor not found with id: " + instructorId));

        // Check if the instructor owns this course or is an admin
        if (!course.getInstructor().getId().equals(instructorId) && !instructor.hasRole(Role.ADMIN)) {
            throw new UnauthorizedException("User is not authorized to update this course");
        }

        courseMapper.updateEntity(course, request);
        Course updatedCourse = courseRepository.save(course);
        
        return courseMapper.toResponse(updatedCourse);
    }

    @Transactional
    public void deleteCourse(Long courseId, Long instructorId) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new ResourceNotFoundException("Course not found with id: " + courseId));

        User instructor = userRepository.findById(instructorId)
                .orElseThrow(() -> new ResourceNotFoundException("Instructor not found with id: " + instructorId));

        // Check if the instructor owns this course or is an admin
        if (!course.getInstructor().getId().equals(instructorId) && !instructor.hasRole(Role.ADMIN)) {
            throw new UnauthorizedException("User is not authorized to delete this course");
        }

        // Archive the course instead of deleting to preserve data integrity
        course.setStatus(CourseStatus.ARCHIVED);
        courseRepository.save(course);
    }

    @Transactional
    public CourseResponse publishCourse(Long courseId, Long instructorId) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new ResourceNotFoundException("Course not found with id: " + courseId));

        User instructor = userRepository.findById(instructorId)
                .orElseThrow(() -> new ResourceNotFoundException("Instructor not found with id: " + instructorId));

        // Check if the instructor owns this course or is an admin
        if (!course.getInstructor().getId().equals(instructorId) && !instructor.hasRole(Role.ADMIN)) {
            throw new UnauthorizedException("User is not authorized to publish this course");
        }

        // Validate course is ready for publishing
        validateCourseForPublishing(course);

        course.setStatus(CourseStatus.PUBLISHED);
        Course publishedCourse = courseRepository.save(course);
        
        return courseMapper.toResponse(publishedCourse);
    }

    @Transactional
    public CourseResponse unpublishCourse(Long courseId, Long instructorId) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new ResourceNotFoundException("Course not found with id: " + courseId));

        User instructor = userRepository.findById(instructorId)
                .orElseThrow(() -> new ResourceNotFoundException("Instructor not found with id: " + instructorId));

        // Check if the instructor owns this course or is an admin
        if (!course.getInstructor().getId().equals(instructorId) && !instructor.hasRole(Role.ADMIN)) {
            throw new UnauthorizedException("User is not authorized to unpublish this course");
        }

        course.setStatus(CourseStatus.DRAFT);
        Course unpublishedCourse = courseRepository.save(course);
        
        return courseMapper.toResponse(unpublishedCourse);
    }

    public boolean canUserEnrollInCourse(Long courseId, Long userId) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new ResourceNotFoundException("Course not found with id: " + courseId));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));

        // Check if course is available for enrollment
        if (!course.canEnroll()) {
            return false;
        }

        // Check if user is already enrolled
        return course.getEnrollments().stream()
                .noneMatch(enrollment -> enrollment.getStudent().getId().equals(userId) 
                    && enrollment.getStatus() == EnrollmentStatus.ACTIVE);
    }

    private void validateCourseForPublishing(Course course) {
        if (course.getTitle() == null || course.getTitle().trim().isEmpty()) {
            throw new IllegalStateException("Course title is required for publishing");
        }
        
        if (course.getDescription() == null || course.getDescription().trim().isEmpty()) {
            throw new IllegalStateException("Course description is required for publishing");
        }
        
        if (course.getLessons().isEmpty()) {
            throw new IllegalStateException("Course must have at least one lesson for publishing");
        }
        
        if (course.getStartDate() == null) {
            throw new IllegalStateException("Course start date is required for publishing");
        }
        
        if (course.getStartDate().isBefore(LocalDate.now())) {
            throw new IllegalStateException("Course start date cannot be in the past");
        }
    }

    public long getTotalCourses() {
        return courseRepository.countByStatus(CourseStatus.PUBLISHED);
    }

    public long getTotalCoursesByInstructor(Long instructorId) {
        return courseRepository.countByInstructorId(instructorId);
    }

    public double getAverageRating(Long courseId) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new ResourceNotFoundException("Course not found with id: " + courseId));
        
        return course.getRating() != null ? course.getRating().doubleValue() : 0.0;
    }
}
