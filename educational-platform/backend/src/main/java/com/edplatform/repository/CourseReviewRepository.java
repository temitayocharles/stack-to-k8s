package com.edplatform.repository;

import com.edplatform.entity.CourseReview;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface CourseReviewRepository extends JpaRepository<CourseReview, Long> {

    List<CourseReview> findByCourseId(Long courseId);
    
    List<CourseReview> findByUserId(Long userId);
    
    Optional<CourseReview> findByCourseIdAndUserId(Long courseId, Long userId);
    
    boolean existsByCourseIdAndUserId(Long courseId, Long userId);
    
    @Query("SELECT r FROM CourseReview r WHERE r.course.id = :courseId ORDER BY r.reviewDate DESC")
    List<CourseReview> findByCourseIdOrderByDateDesc(@Param("courseId") Long courseId);
    
    @Query("SELECT r FROM CourseReview r WHERE r.course.id = :courseId AND r.rating = :rating")
    List<CourseReview> findByCourseIdAndRating(@Param("courseId") Long courseId, @Param("rating") Integer rating);
    
    @Query("SELECT r FROM CourseReview r WHERE r.course.id = :courseId AND r.rating >= :minRating")
    List<CourseReview> findByCourseIdAndRatingGreaterThanEqual(@Param("courseId") Long courseId, @Param("minRating") Integer minRating);
    
    @Query("SELECT r FROM CourseReview r WHERE r.isFeatured = true")
    List<CourseReview> findFeaturedReviews();
    
    @Query("SELECT r FROM CourseReview r WHERE r.reviewText IS NOT NULL AND r.reviewText != ''")
    List<CourseReview> findReviewsWithText();
    
    @Query("SELECT r FROM CourseReview r WHERE r.instructorResponse IS NOT NULL AND r.instructorResponse != ''")
    List<CourseReview> findReviewsWithInstructorResponse();
    
    @Query("SELECT r FROM CourseReview r WHERE r.isVerifiedPurchase = true")
    List<CourseReview> findVerifiedPurchaseReviews();
    
    @Query("SELECT r FROM CourseReview r WHERE r.isAnonymous = true")
    List<CourseReview> findAnonymousReviews();
    
    @Query("SELECT AVG(r.rating) FROM CourseReview r WHERE r.course.id = :courseId")
    Double getAverageRatingByCourseId(@Param("courseId") Long courseId);
    
    @Query("SELECT COUNT(r) FROM CourseReview r WHERE r.course.id = :courseId")
    long countByCourseId(@Param("courseId") Long courseId);
    
    @Query("SELECT COUNT(r) FROM CourseReview r WHERE r.course.id = :courseId AND r.rating = :rating")
    long countByCourseIdAndRating(@Param("courseId") Long courseId, @Param("rating") Integer rating);
    
    @Query("SELECT r FROM CourseReview r WHERE r.course.id = :courseId ORDER BY r.helpfulVotes DESC")
    List<CourseReview> findMostHelpfulByCourseId(@Param("courseId") Long courseId);
    
    @Query("SELECT r FROM CourseReview r WHERE r.course.id = :courseId AND r.totalVotes > 0 ORDER BY (r.helpfulVotes * 1.0 / r.totalVotes) DESC")
    List<CourseReview> findHighestRatedHelpfulnessByCourseId(@Param("courseId") Long courseId);
    
    @Query("SELECT r FROM CourseReview r WHERE r.reviewDate BETWEEN :startDate AND :endDate")
    List<CourseReview> findReviewsBetweenDates(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT r FROM CourseReview r WHERE r.course.instructor.id = :instructorId")
    List<CourseReview> findReviewsByInstructorId(@Param("instructorId") Long instructorId);
    
    @Query("SELECT r FROM CourseReview r WHERE r.reviewText LIKE %:keyword%")
    List<CourseReview> searchByKeyword(@Param("keyword") String keyword);
    
    @Query("SELECT r.rating, COUNT(r) FROM CourseReview r WHERE r.course.id = :courseId GROUP BY r.rating ORDER BY r.rating DESC")
    List<Object[]> getRatingDistributionByCourseId(@Param("courseId") Long courseId);
    
    @Query("SELECT r FROM CourseReview r WHERE r.course.id = :courseId AND r.rating >= 4 ORDER BY r.reviewDate DESC")
    List<CourseReview> findPositiveReviewsByCourseId(@Param("courseId") Long courseId);
    
    @Query("SELECT r FROM CourseReview r WHERE r.course.id = :courseId AND r.rating <= 2 ORDER BY r.reviewDate DESC")
    List<CourseReview> findNegativeReviewsByCourseId(@Param("courseId") Long courseId);
    
    @Query("SELECT r FROM CourseReview r WHERE r.helpfulVotes > :threshold ORDER BY r.helpfulVotes DESC")
    List<CourseReview> findMostHelpfulReviews(@Param("threshold") Integer threshold);
}
