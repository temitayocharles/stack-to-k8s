package com.edplatform.repository;

import com.edplatform.entity.AssignmentSubmission;
import com.edplatform.entity.SubmissionStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface AssignmentSubmissionRepository extends JpaRepository<AssignmentSubmission, Long> {

    List<AssignmentSubmission> findByAssignmentId(Long assignmentId);
    
    List<AssignmentSubmission> findByUserId(Long userId);
    
    List<AssignmentSubmission> findByStatus(SubmissionStatus status);
    
    Optional<AssignmentSubmission> findByAssignmentIdAndUserId(Long assignmentId, Long userId);
    
    @Query("SELECT s FROM AssignmentSubmission s WHERE s.assignment.id = :assignmentId AND s.user.id = :userId AND s.attemptNumber = :attemptNumber")
    Optional<AssignmentSubmission> findByAssignmentIdAndUserIdAndAttemptNumber(@Param("assignmentId") Long assignmentId, @Param("userId") Long userId, @Param("attemptNumber") Integer attemptNumber);
    
    @Query("SELECT s FROM AssignmentSubmission s WHERE s.assignment.id = :assignmentId AND s.status = :status")
    List<AssignmentSubmission> findByAssignmentIdAndStatus(@Param("assignmentId") Long assignmentId, @Param("status") SubmissionStatus status);
    
    @Query("SELECT s FROM AssignmentSubmission s WHERE s.user.id = :userId AND s.status = :status")
    List<AssignmentSubmission> findByUserIdAndStatus(@Param("userId") Long userId, @Param("status") SubmissionStatus status);
    
    @Query("SELECT s FROM AssignmentSubmission s WHERE s.needsGrading = true")
    List<AssignmentSubmission> findSubmissionsNeedingGrading();
    
    @Query("SELECT s FROM AssignmentSubmission s WHERE s.isLate = true")
    List<AssignmentSubmission> findLateSubmissions();
    
    @Query("SELECT s FROM AssignmentSubmission s WHERE s.plagiarismScore IS NOT NULL")
    List<AssignmentSubmission> findSubmissionsWithPlagiarismCheck();
    
    @Query("SELECT s FROM AssignmentSubmission s WHERE s.plagiarismScore > :threshold")
    List<AssignmentSubmission> findSubmissionsWithHighPlagiarismScore(@Param("threshold") BigDecimal threshold);
    
    @Query("SELECT COUNT(s) FROM AssignmentSubmission s WHERE s.assignment.id = :assignmentId")
    long countByAssignmentId(@Param("assignmentId") Long assignmentId);
    
    @Query("SELECT COUNT(s) FROM AssignmentSubmission s WHERE s.assignment.id = :assignmentId AND s.status = 'GRADED'")
    long countGradedByAssignmentId(@Param("assignmentId") Long assignmentId);
    
    @Query("SELECT AVG(s.grade) FROM AssignmentSubmission s WHERE s.assignment.id = :assignmentId AND s.grade IS NOT NULL")
    BigDecimal getAverageGradeByAssignmentId(@Param("assignmentId") Long assignmentId);
    
    @Query("SELECT MAX(s.grade) FROM AssignmentSubmission s WHERE s.assignment.id = :assignmentId AND s.grade IS NOT NULL")
    BigDecimal getHighestGradeByAssignmentId(@Param("assignmentId") Long assignmentId);
    
    @Query("SELECT MIN(s.grade) FROM AssignmentSubmission s WHERE s.assignment.id = :assignmentId AND s.grade IS NOT NULL")
    BigDecimal getLowestGradeByAssignmentId(@Param("assignmentId") Long assignmentId);
    
    @Query("SELECT s FROM AssignmentSubmission s WHERE s.assignment.id = :assignmentId ORDER BY s.grade DESC")
    List<AssignmentSubmission> findTopSubmissionsByAssignment(@Param("assignmentId") Long assignmentId);
    
    @Query("SELECT s FROM AssignmentSubmission s WHERE s.user.id = :userId AND s.grade IS NOT NULL ORDER BY s.submissionDate DESC")
    List<AssignmentSubmission> findGradedSubmissionsByUser(@Param("userId") Long userId);
    
    @Query("SELECT s FROM AssignmentSubmission s WHERE s.assignment.course.instructor.id = :instructorId")
    List<AssignmentSubmission> findSubmissionsByInstructorId(@Param("instructorId") Long instructorId);
    
    @Query("SELECT s FROM AssignmentSubmission s WHERE s.submissionDate BETWEEN :startDate AND :endDate")
    List<AssignmentSubmission> findSubmissionsBetweenDates(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT s FROM AssignmentSubmission s WHERE s.gradedDate BETWEEN :startDate AND :endDate")
    List<AssignmentSubmission> findSubmissionsGradedBetweenDates(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT s FROM AssignmentSubmission s WHERE s.fileUrl IS NOT NULL AND s.fileUrl != ''")
    List<AssignmentSubmission> findSubmissionsWithFiles();
    
    @Query("SELECT s FROM AssignmentSubmission s WHERE s.submissionText IS NOT NULL AND s.submissionText != ''")
    List<AssignmentSubmission> findSubmissionsWithText();
    
    @Query("SELECT COUNT(s) FROM AssignmentSubmission s WHERE s.user.id = :userId AND s.isLate = false")
    long countOnTimeSubmissionsByUser(@Param("userId") Long userId);
    
    @Query("SELECT MAX(s.attemptNumber) FROM AssignmentSubmission s WHERE s.assignment.id = :assignmentId AND s.user.id = :userId")
    Integer getMaxAttemptNumber(@Param("assignmentId") Long assignmentId, @Param("userId") Long userId);
}
