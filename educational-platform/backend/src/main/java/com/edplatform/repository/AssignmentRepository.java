package com.edplatform.repository;

import com.edplatform.entity.Assignment;
import com.edplatform.entity.AssignmentType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AssignmentRepository extends JpaRepository<Assignment, Long> {

    List<Assignment> findByCourseId(Long courseId);
    
    List<Assignment> findByUserId(Long instructorId);
    
    List<Assignment> findByType(AssignmentType type);
    
    @Query("SELECT a FROM Assignment a WHERE a.course.id = :courseId AND a.isPublished = true")
    List<Assignment> findPublishedAssignmentsByCourse(@Param("courseId") Long courseId);
    
    @Query("SELECT a FROM Assignment a WHERE a.availableFrom <= :now AND a.isPublished = true")
    List<Assignment> findAvailableAssignments(@Param("now") LocalDateTime now);
    
    @Query("SELECT a FROM Assignment a WHERE a.dueDate < :now AND a.isPublished = true")
    List<Assignment> findOverdueAssignments(@Param("now") LocalDateTime now);
    
    @Query("SELECT a FROM Assignment a WHERE a.dueDate >= :now AND a.dueDate <= :soon AND a.isPublished = true")
    List<Assignment> findUpcomingAssignments(@Param("now") LocalDateTime now, @Param("soon") LocalDateTime soon);
    
    @Query("SELECT a FROM Assignment a WHERE a.course.id = :courseId AND a.type = :type")
    List<Assignment> findByCourseIdAndType(@Param("courseId") Long courseId, @Param("type") AssignmentType type);
    
    @Query("SELECT a FROM Assignment a WHERE a.title LIKE %:keyword% OR a.description LIKE %:keyword%")
    List<Assignment> searchByKeyword(@Param("keyword") String keyword);
    
    @Query("SELECT COUNT(a) FROM Assignment a WHERE a.course.id = :courseId")
    long countByCourseId(@Param("courseId") Long courseId);
    
    @Query("SELECT COUNT(a) FROM Assignment a WHERE a.course.id = :courseId AND a.isPublished = true")
    long countPublishedByCourseId(@Param("courseId") Long courseId);
    
    @Query("SELECT a FROM Assignment a WHERE a.isGroupAssignment = true")
    List<Assignment> findGroupAssignments();
    
    @Query("SELECT a FROM Assignment a WHERE a.peerReviewEnabled = true")
    List<Assignment> findPeerReviewAssignments();
    
    @Query("SELECT a FROM Assignment a WHERE a.plagiarismCheckEnabled = true")
    List<Assignment> findAssignmentsWithPlagiarismCheck();
    
    @Query("SELECT a FROM Assignment a WHERE a.lateSubmissionAllowed = true")
    List<Assignment> findAssignmentsAllowingLateSubmission();
    
    @Query("SELECT a FROM Assignment a JOIN a.submissions s WHERE s.needsGrading = true")
    List<Assignment> findAssignmentsWithUngraduatedSubmissions();
    
    @Query("SELECT AVG(s.grade) FROM AssignmentSubmission s WHERE s.assignment.id = :assignmentId AND s.grade IS NOT NULL")
    Double getAverageGradeByAssignmentId(@Param("assignmentId") Long assignmentId);
    
    @Query("SELECT COUNT(s) FROM AssignmentSubmission s WHERE s.assignment.id = :assignmentId")
    long getSubmissionCountByAssignmentId(@Param("assignmentId") Long assignmentId);
    
    @Query("SELECT a FROM Assignment a WHERE a.course.instructor.id = :instructorId")
    List<Assignment> findAssignmentsByInstructorId(@Param("instructorId") Long instructorId);
    
    @Query("SELECT a FROM Assignment a WHERE a.maxAttempts IS NOT NULL AND a.maxAttempts > 1")
    List<Assignment> findMultipleAttemptAssignments();
    
    @Query("SELECT a FROM Assignment a WHERE a.autoReleaseGrades = true")
    List<Assignment> findAutoGradeReleaseAssignments();
    
    @Query("SELECT a FROM Assignment a WHERE a.dueDate BETWEEN :startDate AND :endDate")
    List<Assignment> findAssignmentsDueBetween(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
}
