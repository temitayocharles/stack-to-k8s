package com.edplatform.repository;

import com.edplatform.entity.Tag;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TagRepository extends JpaRepository<Tag, Long> {

    Optional<Tag> findByName(String name);
    
    boolean existsByName(String name);
    
    @Query("SELECT t FROM Tag t WHERE t.name LIKE %:keyword%")
    List<Tag> searchByKeyword(@Param("keyword") String keyword);
    
    @Query("SELECT t FROM Tag t ORDER BY t.usageCount DESC")
    List<Tag> findAllOrderByUsageCountDesc();
    
    @Query("SELECT t FROM Tag t WHERE t.usageCount >= :threshold ORDER BY t.usageCount DESC")
    List<Tag> findPopularTags(@Param("threshold") Integer threshold);
    
    @Query("SELECT t FROM Tag t WHERE t.isSystemTag = true")
    List<Tag> findSystemTags();
    
    @Query("SELECT t FROM Tag t WHERE t.isSystemTag = false")
    List<Tag> findUserTags();
    
    @Query("SELECT t FROM Tag t WHERE t.usageCount = 0")
    List<Tag> findUnusedTags();
    
    @Query("SELECT t FROM Tag t JOIN t.courses c WHERE c.id = :courseId")
    List<Tag> findTagsByCourseId(@Param("courseId") Long courseId);
    
    @Query("SELECT t FROM Tag t WHERE t.color IS NOT NULL AND t.color != ''")
    List<Tag> findTagsWithColors();
    
    @Query("SELECT t FROM Tag t WHERE SIZE(t.courses) > 0")
    List<Tag> findTagsWithCourses();
    
    @Query("SELECT t FROM Tag t ORDER BY t.name ASC")
    List<Tag> findAllOrderByName();
    
    @Query("SELECT COUNT(t) FROM Tag t WHERE t.isSystemTag = false")
    long countUserTags();
    
    @Query("SELECT AVG(t.usageCount) FROM Tag t")
    Double getAverageUsageCount();
}
