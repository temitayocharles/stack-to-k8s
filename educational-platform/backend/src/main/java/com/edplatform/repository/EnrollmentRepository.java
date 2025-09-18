package com.edplatform.repository;

import com.edplatform.entity.Enrollment;
import com.edplatform.entity.EnrollmentStatus;
import com.edplatform.entity.User;
import com.edplatform.entity.Course;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface EnrollmentRepository extends JpaRepository<Enrollment, Long> {

    Optional<Enrollment> findByStudentIdAndCourseId(Long studentId, Long courseId);
    
    Optional<Enrollment> findByStudentAndCourse(User student, Course course);
    
    boolean existsByStudentIdAndCourseId(Long studentId, Long courseId);
    
    boolean existsByStudentAndCourse(User student, Course course);
    
    boolean existsByStudentAndCourseAndStatus(User student, Course course, EnrollmentStatus status);
    
    List<Enrollment> findByStudentId(Long studentId);
    
    List<Enrollment> findByCourseId(Long courseId);
    
    List<Enrollment> findByStatus(EnrollmentStatus status);
    
    Page<Enrollment> findByStudentAndStatus(User student, EnrollmentStatus status, Pageable pageable);
    
    List<Enrollment> findByStudentAndStatus(User student, EnrollmentStatus status);
    
    Page<Enrollment> findByCourseAndStatus(Course course, EnrollmentStatus status, Pageable pageable);
    
    long countByStatus(EnrollmentStatus status);
    
    long countByStudentIdAndStatus(Long studentId, EnrollmentStatus status);
    
    long countByCourseIdAndStatus(Long courseId, EnrollmentStatus status);
    
    @Query("SELECT e FROM Enrollment e WHERE e.student.id = :studentId AND e.status = :status")
    List<Enrollment> findByStudentIdAndStatus(@Param("studentId") Long studentId, @Param("status") EnrollmentStatus status);
    
    @Query("SELECT e FROM Enrollment e WHERE e.course.id = :courseId AND e.status = :status")
    List<Enrollment> findByCourseIdAndStatus(@Param("courseId") Long courseId, @Param("status") EnrollmentStatus status);
    
    @Query("SELECT e FROM Enrollment e WHERE e.student.id = :studentId AND e.status = 'ACTIVE'")
    List<Enrollment> findActiveEnrollmentsByStudent(@Param("studentId") Long studentId);
    
    @Query("SELECT e FROM Enrollment e WHERE e.course.id = :courseId AND e.status = 'ACTIVE'")
    List<Enrollment> findActiveEnrollmentsByCourse(@Param("courseId") Long courseId);
    
    @Query("SELECT e FROM Enrollment e WHERE e.status = 'COMPLETED' AND e.certificateIssued = false")
    List<Enrollment> findCompletedEnrollmentsWithoutCertificate();
    
    @Query("SELECT e FROM Enrollment e WHERE e.progressPercentage >= :percentage")
    List<Enrollment> findEnrollmentsWithProgressAbove(@Param("percentage") Double percentage);
    
    @Query("SELECT e FROM Enrollment e WHERE e.lastAccessed < :date AND e.status = 'ACTIVE'")
    List<Enrollment> findInactiveEnrollments(@Param("date") LocalDateTime date);
    
    @Query("SELECT COUNT(e) FROM Enrollment e WHERE e.course.id = :courseId AND e.status = 'ACTIVE'")
    long countActiveByCourseId(@Param("courseId") Long courseId);
    
    @Query("SELECT COUNT(e) FROM Enrollment e WHERE e.student.id = :studentId AND e.status = 'COMPLETED'")
    long countCompletedByStudentId(@Param("studentId") Long studentId);
    
    @Query("SELECT AVG(e.progressPercentage) FROM Enrollment e WHERE e.course.id = :courseId AND e.status = 'ACTIVE'")
    Double getAverageProgressByCourseId(@Param("courseId") Long courseId);
    
    @Query("SELECT e FROM Enrollment e WHERE e.enrollmentDate BETWEEN :startDate AND :endDate")
    List<Enrollment> findEnrollmentsBetweenDates(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT e FROM Enrollment e WHERE e.paymentStatus = 'PENDING'")
    List<Enrollment> findPendingPayments();
    
    @Query("SELECT e FROM Enrollment e WHERE e.finalGrade IS NOT NULL ORDER BY e.finalGrade DESC")
    List<Enrollment> findEnrollmentsWithGrades();
    
    @Query("SELECT e FROM Enrollment e WHERE e.student.id = :studentId AND e.progressPercentage = 100.0")
    List<Enrollment> findCompletedCoursesByStudent(@Param("studentId") Long studentId);
}
