package com.edplatform.repository;

import com.edplatform.entity.QuestionOption;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuestionOptionRepository extends JpaRepository<QuestionOption, Long> {

    List<QuestionOption> findByQuestionId(Long questionId);
    
    List<QuestionOption> findByQuestionIdOrderByOptionOrder(Long questionId);
    
    @Query("SELECT qo FROM QuestionOption qo WHERE qo.question.id = :questionId AND qo.isCorrect = true")
    List<QuestionOption> findCorrectOptionsByQuestionId(@Param("questionId") Long questionId);
    
    @Query("SELECT qo FROM QuestionOption qo WHERE qo.question.id = :questionId AND qo.isCorrect = false")
    List<QuestionOption> findIncorrectOptionsByQuestionId(@Param("questionId") Long questionId);
    
    @Query("SELECT qo FROM QuestionOption qo WHERE qo.optionText LIKE %:keyword%")
    List<QuestionOption> searchByKeyword(@Param("keyword") String keyword);
    
    @Query("SELECT COUNT(qo) FROM QuestionOption qo WHERE qo.question.id = :questionId")
    long countByQuestionId(@Param("questionId") Long questionId);
    
    @Query("SELECT COUNT(qo) FROM QuestionOption qo WHERE qo.question.id = :questionId AND qo.isCorrect = true")
    long countCorrectOptionsByQuestionId(@Param("questionId") Long questionId);
    
    @Query("SELECT MAX(qo.optionOrder) FROM QuestionOption qo WHERE qo.question.id = :questionId")
    Integer getMaxOptionOrderByQuestionId(@Param("questionId") Long questionId);
    
    @Query("SELECT qo FROM QuestionOption qo WHERE qo.imageUrl IS NOT NULL AND qo.imageUrl != ''")
    List<QuestionOption> findOptionsWithImages();
    
    @Query("SELECT qo FROM QuestionOption qo WHERE qo.explanation IS NOT NULL AND qo.explanation != ''")
    List<QuestionOption> findOptionsWithExplanations();
    
    @Query("SELECT qo FROM QuestionOption qo WHERE qo.matchValue IS NOT NULL AND qo.matchValue != ''")
    List<QuestionOption> findMatchingTypeOptions();
    
    @Query("SELECT qo FROM QuestionOption qo WHERE qo.question.quiz.course.instructor.id = :instructorId")
    List<QuestionOption> findOptionsByInstructorId(@Param("instructorId") Long instructorId);
}
