package com.edplatform.repository;

import com.edplatform.entity.Quiz;
import com.edplatform.entity.QuizType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface QuizRepository extends JpaRepository<Quiz, Long> {

    List<Quiz> findByCourseId(Long courseId);
    
    List<Quiz> findByLessonId(Long lessonId);
    
    List<Quiz> findByType(QuizType type);
    
    @Query("SELECT q FROM Quiz q WHERE q.course.id = :courseId AND q.isPublished = true")
    List<Quiz> findPublishedQuizzesByCourse(@Param("courseId") Long courseId);
    
    @Query("SELECT q FROM Quiz q WHERE q.availableFrom <= :now AND " +
           "(q.availableUntil IS NULL OR q.availableUntil >= :now) AND q.isPublished = true")
    List<Quiz> findAvailableQuizzes(@Param("now") LocalDateTime now);
    
    @Query("SELECT q FROM Quiz q WHERE q.course.id = :courseId AND q.type = :type")
    List<Quiz> findByCourseIdAndType(@Param("courseId") Long courseId, @Param("type") QuizType type);
    
    @Query("SELECT q FROM Quiz q WHERE q.title LIKE %:keyword% OR q.description LIKE %:keyword%")
    List<Quiz> searchByKeyword(@Param("keyword") String keyword);
    
    @Query("SELECT COUNT(q) FROM Quiz q WHERE q.course.id = :courseId")
    long countByCourseId(@Param("courseId") Long courseId);
    
    @Query("SELECT COUNT(q) FROM Quiz q WHERE q.course.id = :courseId AND q.isPublished = true")
    long countPublishedByCourseId(@Param("courseId") Long courseId);
    
    @Query("SELECT q FROM Quiz q WHERE q.course.instructor.id = :instructorId")
    List<Quiz> findQuizzesByInstructorId(@Param("instructorId") Long instructorId);
    
    @Query("SELECT q FROM Quiz q WHERE q.timeLimitMinutes IS NOT NULL AND q.timeLimitMinutes > 0")
    List<Quiz> findTimedQuizzes();
    
    @Query("SELECT q FROM Quiz q WHERE q.maxAttempts IS NOT NULL AND q.maxAttempts > 0")
    List<Quiz> findQuizzesWithAttemptLimits();
    
    @Query("SELECT q FROM Quiz q WHERE q.passingScore IS NOT NULL")
    List<Quiz> findQuizzesWithPassingScore();
    
    @Query("SELECT AVG(qa.score) FROM QuizAttempt qa WHERE qa.quiz.id = :quizId AND qa.status = 'COMPLETED'")
    Double getAverageScoreByQuizId(@Param("quizId") Long quizId);
    
    @Query("SELECT q FROM Quiz q WHERE q.availableUntil < :now AND q.isPublished = true")
    List<Quiz> findExpiredQuizzes(@Param("now") LocalDateTime now);
    
    @Query("SELECT q FROM Quiz q WHERE q.course.id = :courseId AND q.isRandomized = true")
    List<Quiz> findRandomizedQuizzesByCourse(@Param("courseId") Long courseId);
}
