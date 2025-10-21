package com.edplatform.repository;

import com.edplatform.entity.Module;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ModuleRepository extends JpaRepository<Module, Long> {

    List<Module> findByCourseId(Long courseId);
    
    List<Module> findByCourseIdOrderByModuleOrder(Long courseId);
    
    @Query("SELECT m FROM Module m WHERE m.course.id = :courseId AND m.isPublished = true ORDER BY m.moduleOrder")
    List<Module> findPublishedModulesByCourse(@Param("courseId") Long courseId);
    
    @Query("SELECT COUNT(m) FROM Module m WHERE m.course.id = :courseId")
    long countByCourseId(@Param("courseId") Long courseId);
    
    @Query("SELECT COUNT(m) FROM Module m WHERE m.course.id = :courseId AND m.isPublished = true")
    long countPublishedByCourseId(@Param("courseId") Long courseId);
    
    @Query("SELECT SUM(m.estimatedDurationHours) FROM Module m WHERE m.course.id = :courseId AND m.isPublished = true")
    Integer getTotalDurationByCourseId(@Param("courseId") Long courseId);
    
    @Query("SELECT m FROM Module m WHERE m.title LIKE %:keyword% OR m.description LIKE %:keyword%")
    List<Module> searchByKeyword(@Param("keyword") String keyword);
    
    @Query("SELECT MAX(m.moduleOrder) FROM Module m WHERE m.course.id = :courseId")
    Integer getMaxModuleOrderByCourseId(@Param("courseId") Long courseId);
    
    @Query("SELECT m FROM Module m WHERE m.course.id = :courseId AND m.moduleOrder = :moduleOrder")
    List<Module> findByCourseIdAndModuleOrder(@Param("courseId") Long courseId, @Param("moduleOrder") Integer moduleOrder);
    
    @Query("SELECT m FROM Module m WHERE m.course.instructor.id = :instructorId")
    List<Module> findModulesByInstructorId(@Param("instructorId") Long instructorId);
}
