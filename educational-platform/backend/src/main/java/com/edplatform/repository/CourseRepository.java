package com.edplatform.repository;

import com.edplatform.entity.Course;
import com.edplatform.entity.CourseCategory;
import com.edplatform.entity.CourseLevel;
import com.edplatform.entity.CourseStatus;
import com.edplatform.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface CourseRepository extends JpaRepository<Course, Long> {

    Optional<Course> findByCourseCode(String courseCode);
    
    boolean existsByCourseCode(String courseCode);
    
    List<Course> findByStatus(CourseStatus status);
    
    Page<Course> findByStatus(CourseStatus status, Pageable pageable);
    
    List<Course> findByCategory(CourseCategory category);
    
    Page<Course> findByCategoryAndStatus(CourseCategory category, CourseStatus status, Pageable pageable);
    
    List<Course> findByLevel(CourseLevel level);
    
    Page<Course> findByLevelAndStatus(CourseLevel level, CourseStatus status, Pageable pageable);
    
    Page<Course> findByTitleContainingIgnoreCaseAndStatus(String title, CourseStatus status, Pageable pageable);
    
    List<Course> findByInstructorId(Long instructorId);
    
    Page<Course> findByInstructor(User instructor, Pageable pageable);
    
    List<Course> findByIsFeaturedTrueAndStatus(CourseStatus status);
    
    long countByStatus(CourseStatus status);
    
    long countByInstructorId(Long instructorId);
    
    @Query("SELECT c FROM Course c WHERE c.status = 'PUBLISHED'")
    List<Course> findAllPublishedCourses();
    
    @Query("SELECT c FROM Course c WHERE c.status = 'PUBLISHED' AND c.isFeatured = true")
    List<Course> findFeaturedCourses();
    
    @Query("SELECT c FROM Course c WHERE c.title LIKE %:keyword% OR c.description LIKE %:keyword%")
    List<Course> searchByKeyword(@Param("keyword") String keyword);
    
    @Query("SELECT c FROM Course c WHERE c.status = 'PUBLISHED' AND " +
           "(:category IS NULL OR c.category = :category) AND " +
           "(:level IS NULL OR c.level = :level) AND " +
           "(:minPrice IS NULL OR c.price >= :minPrice) AND " +
           "(:maxPrice IS NULL OR c.price <= :maxPrice)")
    Page<Course> findCoursesWithFilters(
        @Param("category") CourseCategory category,
        @Param("level") CourseLevel level,
        @Param("minPrice") BigDecimal minPrice,
        @Param("maxPrice") BigDecimal maxPrice,
        Pageable pageable
    );
    
    @Query("SELECT c FROM Course c WHERE c.status = 'PUBLISHED' AND c.enrollmentDeadline >= :currentDate")
    List<Course> findCoursesWithOpenEnrollment(@Param("currentDate") LocalDate currentDate);
    
    @Query("SELECT c FROM Course c WHERE c.status = 'PUBLISHED' AND " +
           "(c.maxStudents IS NULL OR SIZE(c.enrollments) < c.maxStudents)")
    List<Course> findCoursesWithAvailableSpots();
    
    @Query("SELECT c FROM Course c ORDER BY c.rating DESC")
    List<Course> findTopRatedCourses(Pageable pageable);
    
    @Query("SELECT c FROM Course c JOIN c.enrollments e " +
           "GROUP BY c ORDER BY COUNT(e) DESC")
    List<Course> findMostPopularCourses(Pageable pageable);
    
    @Query("SELECT c FROM Course c WHERE c.createdAt >= :date ORDER BY c.createdAt DESC")
    List<Course> findRecentCourses(@Param("date") LocalDate date);
    
    @Query("SELECT c FROM Course c JOIN c.tags t WHERE t.name = :tagName")
    List<Course> findCoursesByTag(@Param("tagName") String tagName);
    
    @Query("SELECT COUNT(c) FROM Course c WHERE c.instructor.id = :instructorId")
    long countCoursesByInstructor(@Param("instructorId") Long instructorId);
    
    @Query("SELECT AVG(c.rating) FROM Course c WHERE c.rating IS NOT NULL")
    Double getAverageRating();
    
    @Query("SELECT c FROM Course c WHERE c.status = 'PUBLISHED' AND " +
           "c.startDate <= :currentDate AND c.endDate >= :currentDate")
    List<Course> findActiveCoursesOnDate(@Param("currentDate") LocalDate currentDate);
    
    @Query("SELECT c FROM Course c WHERE c.price = 0")
    List<Course> findFreeCourses();
    
    @Query("SELECT c FROM Course c WHERE c.certificateEnabled = true")
    List<Course> findCoursesWithCertificates();
    
    @Query("SELECT DISTINCT c.category FROM Course c WHERE c.status = 'PUBLISHED'")
    List<CourseCategory> findAllActiveCategories();
    
    @Query("SELECT c FROM Course c JOIN c.enrollments e WHERE e.student.id = :userId")
    List<Course> findCoursesByStudentId(@Param("userId") Long userId);
    
    @Query("SELECT c FROM Course c WHERE c.language = :language AND c.status = 'PUBLISHED'")
    List<Course> findCoursesByLanguage(@Param("language") String language);
}
