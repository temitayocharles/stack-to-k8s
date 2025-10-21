package com.edplatform.repository;

import com.edplatform.entity.Question;
import com.edplatform.entity.QuestionType;
import com.edplatform.entity.DifficultyLevel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuestionRepository extends JpaRepository<Question, Long> {

    List<Question> findByQuizId(Long quizId);
    
    List<Question> findByQuizIdOrderByQuestionOrder(Long quizId);
    
    List<Question> findByType(QuestionType type);
    
    List<Question> findByDifficultyLevel(DifficultyLevel difficultyLevel);
    
    @Query("SELECT q FROM Question q WHERE q.quiz.id = :quizId AND q.type = :type ORDER BY q.questionOrder")
    List<Question> findByQuizIdAndType(@Param("quizId") Long quizId, @Param("type") QuestionType type);
    
    @Query("SELECT q FROM Question q WHERE q.quiz.id = :quizId AND q.difficultyLevel = :level ORDER BY q.questionOrder")
    List<Question> findByQuizIdAndDifficultyLevel(@Param("quizId") Long quizId, @Param("level") DifficultyLevel level);
    
    @Query("SELECT q FROM Question q WHERE q.questionText LIKE %:keyword%")
    List<Question> searchByKeyword(@Param("keyword") String keyword);
    
    @Query("SELECT COUNT(q) FROM Question q WHERE q.quiz.id = :quizId")
    long countByQuizId(@Param("quizId") Long quizId);
    
    @Query("SELECT SUM(q.points) FROM Question q WHERE q.quiz.id = :quizId")
    Integer getTotalPointsByQuizId(@Param("quizId") Long quizId);
    
    @Query("SELECT AVG(q.points) FROM Question q WHERE q.quiz.id = :quizId")
    Double getAveragePointsByQuizId(@Param("quizId") Long quizId);
    
    @Query("SELECT MAX(q.questionOrder) FROM Question q WHERE q.quiz.id = :quizId")
    Integer getMaxQuestionOrderByQuizId(@Param("quizId") Long quizId);
    
    @Query("SELECT q FROM Question q WHERE q.quiz.id = :quizId AND q.questionOrder = :questionOrder")
    List<Question> findByQuizIdAndQuestionOrder(@Param("quizId") Long quizId, @Param("questionOrder") Integer questionOrder);
    
    @Query("SELECT q FROM Question q WHERE q.quiz.course.instructor.id = :instructorId")
    List<Question> findQuestionsByInstructorId(@Param("instructorId") Long instructorId);
    
    @Query("SELECT q FROM Question q WHERE q.imageUrl IS NOT NULL AND q.imageUrl != ''")
    List<Question> findQuestionsWithImages();
    
    @Query("SELECT q FROM Question q WHERE q.isRequired = true AND q.quiz.id = :quizId")
    List<Question> findRequiredQuestionsByQuizId(@Param("quizId") Long quizId);
    
    @Query("SELECT q FROM Question q WHERE q.correctAnswer IS NOT NULL AND q.correctAnswer != ''")
    List<Question> findQuestionsWithCorrectAnswers();
    
    @Query("SELECT q FROM Question q WHERE q.explanation IS NOT NULL AND q.explanation != ''")
    List<Question> findQuestionsWithExplanations();
    
    @Query("SELECT q FROM Question q WHERE q.quiz.id = :quizId ORDER BY RANDOM()")
    List<Question> findRandomQuestionsByQuizId(@Param("quizId") Long quizId);
}
