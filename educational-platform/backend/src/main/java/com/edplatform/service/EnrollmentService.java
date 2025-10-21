package com.edplatform.service;

import com.edplatform.dto.EnrollmentCreateRequest;
import com.edplatform.dto.EnrollmentResponse;
import com.edplatform.entity.*;
import com.edplatform.exception.BusinessException;
import com.edplatform.exception.ResourceNotFoundException;
import com.edplatform.repository.CourseRepository;
import com.edplatform.repository.EnrollmentRepository;
import com.edplatform.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class EnrollmentService {

    @Autowired
    private EnrollmentRepository enrollmentRepository;

    @Autowired
    private CourseRepository courseRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private EnrollmentMapper enrollmentMapper;

    @Transactional
    public EnrollmentResponse enrollStudent(EnrollmentCreateRequest request, Long studentId) {
        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with id: " + studentId));

        Course course = courseRepository.findById(request.getCourseId())
                .orElseThrow(() -> new ResourceNotFoundException("Course not found with id: " + request.getCourseId()));

        // Validate enrollment eligibility
        validateEnrollmentEligibility(student, course);

        // Check if already enrolled
        if (enrollmentRepository.existsByStudentAndCourse(student, course)) {
            throw new BusinessException("Student is already enrolled in this course");
        }

        Enrollment enrollment = new Enrollment();
        enrollment.setStudent(student);
        enrollment.setCourse(course);
        enrollment.setEnrollmentDate(LocalDateTime.now());
        enrollment.setStatus(EnrollmentStatus.ACTIVE);
        enrollment.setProgress(0.0);

        Enrollment savedEnrollment = enrollmentRepository.save(enrollment);
        return enrollmentMapper.toResponse(savedEnrollment);
    }

    @Transactional
    public void unenrollStudent(Long courseId, Long studentId) {
        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with id: " + studentId));

        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new ResourceNotFoundException("Course not found with id: " + courseId));

        Enrollment enrollment = enrollmentRepository.findByStudentAndCourse(student, course)
                .orElseThrow(() -> new ResourceNotFoundException("Enrollment not found"));

        // Don't allow unenrollment if course has started and student has significant progress
        if (course.getStartDate().isBefore(LocalDate.now()) && enrollment.getProgress() > 20.0) {
            throw new BusinessException("Cannot unenroll from course after significant progress has been made");
        }

        enrollment.setStatus(EnrollmentStatus.WITHDRAWN);
        enrollment.setWithdrawalDate(LocalDateTime.now());
        enrollmentRepository.save(enrollment);
    }

    public Page<EnrollmentResponse> getStudentEnrollments(Long studentId, Pageable pageable) {
        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with id: " + studentId));

        return enrollmentRepository.findByStudentAndStatus(student, EnrollmentStatus.ACTIVE, pageable)
                .map(enrollmentMapper::toResponse);
    }

    public Page<EnrollmentResponse> getCourseEnrollments(Long courseId, Pageable pageable) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new ResourceNotFoundException("Course not found with id: " + courseId));

        return enrollmentRepository.findByCourseAndStatus(course, EnrollmentStatus.ACTIVE, pageable)
                .map(enrollmentMapper::toResponse);
    }

    public EnrollmentResponse getEnrollment(Long courseId, Long studentId) {
        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with id: " + studentId));

        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new ResourceNotFoundException("Course not found with id: " + courseId));

        Enrollment enrollment = enrollmentRepository.findByStudentAndCourse(student, course)
                .orElseThrow(() -> new ResourceNotFoundException("Enrollment not found"));

        return enrollmentMapper.toResponse(enrollment);
    }

    @Transactional
    public EnrollmentResponse updateProgress(Long courseId, Long studentId, Double progress) {
        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with id: " + studentId));

        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new ResourceNotFoundException("Course not found with id: " + courseId));

        Enrollment enrollment = enrollmentRepository.findByStudentAndCourse(student, course)
                .orElseThrow(() -> new ResourceNotFoundException("Enrollment not found"));

        if (progress < 0 || progress > 100) {
            throw new BusinessException("Progress must be between 0 and 100");
        }

        enrollment.setProgress(progress);
        
        // Auto-complete if progress reaches 100%
        if (progress >= 100.0 && enrollment.getStatus() == EnrollmentStatus.ACTIVE) {
            enrollment.setStatus(EnrollmentStatus.COMPLETED);
            enrollment.setCompletionDate(LocalDateTime.now());
        }

        Enrollment updatedEnrollment = enrollmentRepository.save(enrollment);
        return enrollmentMapper.toResponse(updatedEnrollment);
    }

    public boolean isStudentEnrolled(Long courseId, Long studentId) {
        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with id: " + studentId));

        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new ResourceNotFoundException("Course not found with id: " + courseId));

        return enrollmentRepository.existsByStudentAndCourseAndStatus(student, course, EnrollmentStatus.ACTIVE);
    }

    public List<EnrollmentResponse> getCompletedCourses(Long studentId) {
        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with id: " + studentId));

        return enrollmentRepository.findByStudentAndStatus(student, EnrollmentStatus.COMPLETED)
                .stream()
                .map(enrollmentMapper::toResponse)
                .collect(Collectors.toList());
    }

    public long getTotalEnrollments() {
        return enrollmentRepository.countByStatus(EnrollmentStatus.ACTIVE);
    }

    public long getStudentEnrollmentCount(Long studentId) {
        return enrollmentRepository.countByStudentIdAndStatus(studentId, EnrollmentStatus.ACTIVE);
    }

    public long getCourseEnrollmentCount(Long courseId) {
        return enrollmentRepository.countByCourseIdAndStatus(courseId, EnrollmentStatus.ACTIVE);
    }

    public double getStudentAverageProgress(Long studentId) {
        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found with id: " + studentId));

        List<Enrollment> enrollments = enrollmentRepository.findByStudentAndStatus(student, EnrollmentStatus.ACTIVE);
        
        if (enrollments.isEmpty()) {
            return 0.0;
        }

        double totalProgress = enrollments.stream()
                .mapToDouble(Enrollment::getProgress)
                .sum();

        return totalProgress / enrollments.size();
    }

    private void validateEnrollmentEligibility(User student, Course course) {
        // Check if student has required role
        if (!student.hasRole(Role.STUDENT)) {
            throw new BusinessException("User must have student role to enroll in courses");
        }

        // Check if course is published
        if (!course.isPublished()) {
            throw new BusinessException("Cannot enroll in unpublished course");
        }

        // Check enrollment deadline
        if (!course.isEnrollmentOpen()) {
            throw new BusinessException("Enrollment deadline has passed for this course");
        }

        // Check course capacity
        if (!course.hasCapacity()) {
            throw new BusinessException("Course has reached maximum capacity");
        }

        // Check if course has started
        LocalDate now = LocalDate.now();
        if (course.getStartDate() != null && course.getStartDate().isBefore(now)) {
            throw new BusinessException("Cannot enroll in course that has already started");
        }
    }
}
