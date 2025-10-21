package com.edplatform.repository;

import com.edplatform.entity.Lesson;
import com.edplatform.entity.LessonType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface LessonRepository extends JpaRepository<Lesson, Long> {

    List<Lesson> findByCourseId(Long courseId);
    
    List<Lesson> findByCourseIdOrderByLessonOrder(Long courseId);
    
    List<Lesson> findByModuleId(Long moduleId);
    
    List<Lesson> findByModuleIdOrderByLessonOrder(Long moduleId);
    
    List<Lesson> findByType(LessonType type);
    
    @Query("SELECT l FROM Lesson l WHERE l.course.id = :courseId AND l.type = :type ORDER BY l.lessonOrder")
    List<Lesson> findByCourseIdAndType(@Param("courseId") Long courseId, @Param("type") LessonType type);
    
    @Query("SELECT l FROM Lesson l WHERE l.course.id = :courseId AND l.isPreview = true ORDER BY l.lessonOrder")
    List<Lesson> findPreviewLessonsByCourse(@Param("courseId") Long courseId);
    
    @Query("SELECT l FROM Lesson l WHERE l.course.id = :courseId AND l.isMandatory = true ORDER BY l.lessonOrder")
    List<Lesson> findMandatoryLessonsByCourse(@Param("courseId") Long courseId);
    
    @Query("SELECT l FROM Lesson l WHERE l.title LIKE %:keyword% OR l.description LIKE %:keyword%")
    List<Lesson> searchByKeyword(@Param("keyword") String keyword);
    
    @Query("SELECT COUNT(l) FROM Lesson l WHERE l.course.id = :courseId")
    long countByCourseId(@Param("courseId") Long courseId);
    
    @Query("SELECT COUNT(l) FROM Lesson l WHERE l.module.id = :moduleId")
    long countByModuleId(@Param("moduleId") Long moduleId);
    
    @Query("SELECT SUM(l.estimatedDurationMinutes) FROM Lesson l WHERE l.course.id = :courseId")
    Integer getTotalDurationByCourseId(@Param("courseId") Long courseId);
    
    @Query("SELECT l FROM Lesson l WHERE l.course.id = :courseId AND l.lessonOrder = :lessonOrder")
    List<Lesson> findByCourseIdAndLessonOrder(@Param("courseId") Long courseId, @Param("lessonOrder") Integer lessonOrder);
    
    @Query("SELECT MAX(l.lessonOrder) FROM Lesson l WHERE l.course.id = :courseId")
    Integer getMaxLessonOrderByCourseId(@Param("courseId") Long courseId);
    
    @Query("SELECT l FROM Lesson l WHERE l.course.id = :courseId AND l.lessonOrder > :currentOrder ORDER BY l.lessonOrder LIMIT 1")
    Lesson findNextLesson(@Param("courseId") Long courseId, @Param("currentOrder") Integer currentOrder);
    
    @Query("SELECT l FROM Lesson l WHERE l.course.id = :courseId AND l.lessonOrder < :currentOrder ORDER BY l.lessonOrder DESC LIMIT 1")
    Lesson findPreviousLesson(@Param("courseId") Long courseId, @Param("currentOrder") Integer currentOrder);
    
    @Query("SELECT l FROM Lesson l WHERE l.videoUrl IS NOT NULL AND l.videoUrl != ''")
    List<Lesson> findLessonsWithVideo();
    
    @Query("SELECT l FROM Lesson l WHERE l.course.instructor.id = :instructorId")
    List<Lesson> findLessonsByInstructorId(@Param("instructorId") Long instructorId);
}
