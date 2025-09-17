package com.edplatform.repository;

import com.edplatform.entity.QuizAttempt;
import com.edplatform.entity.AttemptStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface QuizAttemptRepository extends JpaRepository<QuizAttempt, Long> {

    List<QuizAttempt> findByUserId(Long userId);
    
    List<QuizAttempt> findByQuizId(Long quizId);
    
    List<QuizAttempt> findByStatus(AttemptStatus status);
    
    @Query("SELECT qa FROM QuizAttempt qa WHERE qa.user.id = :userId AND qa.quiz.id = :quizId ORDER BY qa.attemptNumber DESC")
    List<QuizAttempt> findByUserIdAndQuizId(@Param("userId") Long userId, @Param("quizId") Long quizId);
    
    @Query("SELECT qa FROM QuizAttempt qa WHERE qa.user.id = :userId AND qa.quiz.id = :quizId AND qa.status = :status")
    List<QuizAttempt> findByUserIdAndQuizIdAndStatus(@Param("userId") Long userId, @Param("quizId") Long quizId, @Param("status") AttemptStatus status);
    
    @Query("SELECT qa FROM QuizAttempt qa WHERE qa.user.id = :userId AND qa.quiz.id = :quizId AND qa.status = 'IN_PROGRESS'")
    Optional<QuizAttempt> findActiveAttempt(@Param("userId") Long userId, @Param("quizId") Long quizId);
    
    @Query("SELECT qa FROM QuizAttempt qa WHERE qa.user.id = :userId AND qa.quiz.id = :quizId AND qa.status = 'COMPLETED' ORDER BY qa.score DESC LIMIT 1")
    Optional<QuizAttempt> findBestAttempt(@Param("userId") Long userId, @Param("quizId") Long quizId);
    
    @Query("SELECT qa FROM QuizAttempt qa WHERE qa.user.id = :userId AND qa.quiz.id = :quizId ORDER BY qa.startTime DESC LIMIT 1")
    Optional<QuizAttempt> findLatestAttempt(@Param("userId") Long userId, @Param("quizId") Long quizId);
    
    @Query("SELECT COUNT(qa) FROM QuizAttempt qa WHERE qa.user.id = :userId AND qa.quiz.id = :quizId")
    long countAttemptsByUserAndQuiz(@Param("userId") Long userId, @Param("quizId") Long quizId);
    
    @Query("SELECT COUNT(qa) FROM QuizAttempt qa WHERE qa.quiz.id = :quizId AND qa.status = 'COMPLETED'")
    long countCompletedAttemptsByQuiz(@Param("quizId") Long quizId);
    
    @Query("SELECT AVG(qa.score) FROM QuizAttempt qa WHERE qa.quiz.id = :quizId AND qa.status = 'COMPLETED'")
    BigDecimal getAverageScoreByQuiz(@Param("quizId") Long quizId);
    
    @Query("SELECT MAX(qa.score) FROM QuizAttempt qa WHERE qa.quiz.id = :quizId AND qa.status = 'COMPLETED'")
    BigDecimal getHighestScoreByQuiz(@Param("quizId") Long quizId);
    
    @Query("SELECT MIN(qa.score) FROM QuizAttempt qa WHERE qa.quiz.id = :quizId AND qa.status = 'COMPLETED'")
    BigDecimal getLowestScoreByQuiz(@Param("quizId") Long quizId);
    
    @Query("SELECT qa FROM QuizAttempt qa WHERE qa.quiz.id = :quizId AND qa.status = 'COMPLETED' ORDER BY qa.score DESC")
    List<QuizAttempt> findTopScoresByQuiz(@Param("quizId") Long quizId);
    
    @Query("SELECT qa FROM QuizAttempt qa WHERE qa.status = 'IN_PROGRESS' AND " +
           "qa.startTime < :timeoutThreshold")
    List<QuizAttempt> findTimedOutAttempts(@Param("timeoutThreshold") LocalDateTime timeoutThreshold);
    
    @Query("SELECT qa FROM QuizAttempt qa WHERE qa.user.id = :userId AND qa.status = 'COMPLETED' " +
           "ORDER BY qa.endTime DESC")
    List<QuizAttempt> findCompletedAttemptsByUser(@Param("userId") Long userId);
    
    @Query("SELECT qa FROM QuizAttempt qa WHERE qa.quiz.course.instructor.id = :instructorId")
    List<QuizAttempt> findAttemptsByInstructorId(@Param("instructorId") Long instructorId);
    
    @Query("SELECT qa FROM QuizAttempt qa WHERE qa.isLateSubmission = true")
    List<QuizAttempt> findLateSubmissions();
    
    @Query("SELECT qa FROM QuizAttempt qa WHERE qa.gradedByInstructor = false AND qa.status = 'COMPLETED'")
    List<QuizAttempt> findAttemptsNeedingGrading();
    
    @Query("SELECT AVG(qa.timeTakenMinutes) FROM QuizAttempt qa WHERE qa.quiz.id = :quizId AND qa.status = 'COMPLETED'")
    Double getAverageTimeTakenByQuiz(@Param("quizId") Long quizId);
    
    @Query("SELECT qa FROM QuizAttempt qa WHERE qa.quiz.id = :quizId AND qa.percentage >= :passingScore")
    List<QuizAttempt> findPassingAttemptsByQuiz(@Param("quizId") Long quizId, @Param("passingScore") BigDecimal passingScore);
    
    @Query("SELECT qa FROM QuizAttempt qa WHERE qa.startTime BETWEEN :startDate AND :endDate")
    List<QuizAttempt> findAttemptsBetweenDates(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
}
