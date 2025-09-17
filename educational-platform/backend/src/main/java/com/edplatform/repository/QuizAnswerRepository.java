package com.edplatform.repository;

import com.edplatform.entity.QuizAnswer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Repository
public interface QuizAnswerRepository extends JpaRepository<QuizAnswer, Long> {

    List<QuizAnswer> findByQuizAttemptId(Long quizAttemptId);
    
    List<QuizAnswer> findByQuestionId(Long questionId);
    
    Optional<QuizAnswer> findByQuizAttemptIdAndQuestionId(Long quizAttemptId, Long questionId);
    
    @Query("SELECT qa FROM QuizAnswer qa WHERE qa.quizAttempt.id = :quizAttemptId ORDER BY qa.question.questionOrder")
    List<QuizAnswer> findByQuizAttemptIdOrderByQuestionOrder(@Param("quizAttemptId") Long quizAttemptId);
    
    @Query("SELECT qa FROM QuizAnswer qa WHERE qa.isCorrect = true AND qa.quizAttempt.id = :quizAttemptId")
    List<QuizAnswer> findCorrectAnswersByAttemptId(@Param("quizAttemptId") Long quizAttemptId);
    
    @Query("SELECT qa FROM QuizAnswer qa WHERE qa.isCorrect = false AND qa.quizAttempt.id = :quizAttemptId")
    List<QuizAnswer> findIncorrectAnswersByAttemptId(@Param("quizAttemptId") Long quizAttemptId);
    
    @Query("SELECT qa FROM QuizAnswer qa WHERE qa.isFlagged = true")
    List<QuizAnswer> findFlaggedAnswers();
    
    @Query("SELECT qa FROM QuizAnswer qa WHERE qa.autoGraded = false")
    List<QuizAnswer> findManuallyGradedAnswers();
    
    @Query("SELECT qa FROM QuizAnswer qa WHERE qa.pointsEarned IS NULL")
    List<QuizAnswer> findUngradedAnswers();
    
    @Query("SELECT qa FROM QuizAnswer qa WHERE qa.instructorFeedback IS NOT NULL AND qa.instructorFeedback != ''")
    List<QuizAnswer> findAnswersWithInstructorFeedback();
    
    @Query("SELECT COUNT(qa) FROM QuizAnswer qa WHERE qa.quizAttempt.id = :quizAttemptId AND qa.isCorrect = true")
    long countCorrectAnswersByAttemptId(@Param("quizAttemptId") Long quizAttemptId);
    
    @Query("SELECT COUNT(qa) FROM QuizAnswer qa WHERE qa.question.id = :questionId AND qa.isCorrect = true")
    long countCorrectAnswersByQuestionId(@Param("questionId") Long questionId);
    
    @Query("SELECT SUM(qa.pointsEarned) FROM QuizAnswer qa WHERE qa.quizAttempt.id = :quizAttemptId")
    BigDecimal getTotalPointsByAttemptId(@Param("quizAttemptId") Long quizAttemptId);
    
    @Query("SELECT AVG(qa.pointsEarned) FROM QuizAnswer qa WHERE qa.question.id = :questionId AND qa.pointsEarned IS NOT NULL")
    BigDecimal getAveragePointsByQuestionId(@Param("questionId") Long questionId);
    
    @Query("SELECT qa FROM QuizAnswer qa WHERE qa.question.quiz.course.instructor.id = :instructorId")
    List<QuizAnswer> findAnswersByInstructorId(@Param("instructorId") Long instructorId);
    
    @Query("SELECT qa FROM QuizAnswer qa WHERE qa.answerText LIKE %:keyword%")
    List<QuizAnswer> searchByAnswerText(@Param("keyword") String keyword);
    
    @Query("SELECT qa FROM QuizAnswer qa WHERE qa.selectedOption IS NOT NULL")
    List<QuizAnswer> findMultipleChoiceAnswers();
    
    @Query("SELECT qa FROM QuizAnswer qa WHERE qa.answerText IS NOT NULL AND qa.answerText != ''")
    List<QuizAnswer> findTextAnswers();
    
    @Query("SELECT qa FROM QuizAnswer qa WHERE qa.timeSpentSeconds IS NOT NULL ORDER BY qa.timeSpentSeconds DESC")
    List<QuizAnswer> findAnswersOrderByTimeSpent();
    
    @Query("SELECT AVG(qa.timeSpentSeconds) FROM QuizAnswer qa WHERE qa.question.id = :questionId AND qa.timeSpentSeconds IS NOT NULL")
    Double getAverageTimeSpentByQuestionId(@Param("questionId") Long questionId);
    
    @Query("SELECT qa.question.id, COUNT(qa), AVG(CAST(qa.isCorrect AS int)) " +
           "FROM QuizAnswer qa WHERE qa.quizAttempt.quiz.id = :quizId " +
           "GROUP BY qa.question.id")
    List<Object[]> getQuestionStatisticsByQuizId(@Param("quizId") Long quizId);
}
