package com.edplatform.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;
import java.util.Objects;

@Entity
@Table(name = "course_reviews")
public class CourseReview extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @NotNull(message = "Rating is required")
    @Min(value = 1, message = "Rating must be at least 1")
    @Max(value = 5, message = "Rating must be at most 5")
    @Column(name = "rating", nullable = false)
    private Integer rating;

    @Size(max = 1000, message = "Review text must not exceed 1000 characters")
    @Column(name = "review_text", length = 1000)
    private String reviewText;

    @Column(name = "review_date", nullable = false)
    private LocalDateTime reviewDate;

    @Column(name = "is_anonymous", nullable = false)
    private Boolean isAnonymous = false;

    @Column(name = "is_verified_purchase", nullable = false)
    private Boolean isVerifiedPurchase = false;

    @Column(name = "helpful_votes", nullable = false)
    private Integer helpfulVotes = 0;

    @Column(name = "total_votes", nullable = false)
    private Integer totalVotes = 0;

    @Column(name = "is_featured", nullable = false)
    private Boolean isFeatured = false;

    @Column(name = "instructor_response", columnDefinition = "TEXT")
    private String instructorResponse;

    @Column(name = "instructor_response_date")
    private LocalDateTime instructorResponseDate;

    // Constructors
    public CourseReview() {
        this.reviewDate = LocalDateTime.now();
    }

    public CourseReview(Course course, User user, Integer rating) {
        this();
        this.course = course;
        this.user = user;
        this.rating = rating;
    }

    public CourseReview(Course course, User user, Integer rating, String reviewText) {
        this(course, user, rating);
        this.reviewText = reviewText;
    }

    // Business methods
    public boolean hasText() {
        return reviewText != null && !reviewText.trim().isEmpty();
    }

    public boolean hasInstructorResponse() {
        return instructorResponse != null && !instructorResponse.trim().isEmpty();
    }

    public double getHelpfulnessRatio() {
        if (totalVotes == 0) return 0.0;
        return (double) helpfulVotes / totalVotes;
    }

    public void addHelpfulVote() {
        this.helpfulVotes++;
        this.totalVotes++;
    }

    public void addUnhelpfulVote() {
        this.totalVotes++;
    }

    public void addInstructorResponse(String response) {
        this.instructorResponse = response;
        this.instructorResponseDate = LocalDateTime.now();
    }

    public boolean isHighRating() {
        return rating >= 4;
    }

    public boolean isLowRating() {
        return rating <= 2;
    }

    // Getters and Setters
    public Course getCourse() {
        return course;
    }

    public void setCourse(Course course) {
        this.course = course;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Integer getRating() {
        return rating;
    }

    public void setRating(Integer rating) {
        this.rating = rating;
    }

    public String getReviewText() {
        return reviewText;
    }

    public void setReviewText(String reviewText) {
        this.reviewText = reviewText;
    }

    public LocalDateTime getReviewDate() {
        return reviewDate;
    }

    public void setReviewDate(LocalDateTime reviewDate) {
        this.reviewDate = reviewDate;
    }

    public Boolean getIsAnonymous() {
        return isAnonymous;
    }

    public void setIsAnonymous(Boolean isAnonymous) {
        this.isAnonymous = isAnonymous;
    }

    public Boolean getIsVerifiedPurchase() {
        return isVerifiedPurchase;
    }

    public void setIsVerifiedPurchase(Boolean isVerifiedPurchase) {
        this.isVerifiedPurchase = isVerifiedPurchase;
    }

    public Integer getHelpfulVotes() {
        return helpfulVotes;
    }

    public void setHelpfulVotes(Integer helpfulVotes) {
        this.helpfulVotes = helpfulVotes;
    }

    public Integer getTotalVotes() {
        return totalVotes;
    }

    public void setTotalVotes(Integer totalVotes) {
        this.totalVotes = totalVotes;
    }

    public Boolean getIsFeatured() {
        return isFeatured;
    }

    public void setIsFeatured(Boolean isFeatured) {
        this.isFeatured = isFeatured;
    }

    public String getInstructorResponse() {
        return instructorResponse;
    }

    public void setInstructorResponse(String instructorResponse) {
        this.instructorResponse = instructorResponse;
    }

    public LocalDateTime getInstructorResponseDate() {
        return instructorResponseDate;
    }

    public void setInstructorResponseDate(LocalDateTime instructorResponseDate) {
        this.instructorResponseDate = instructorResponseDate;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof CourseReview)) return false;
        CourseReview that = (CourseReview) o;
        return Objects.equals(course, that.course) && Objects.equals(user, that.user);
    }

    @Override
    public int hashCode() {
        return Objects.hash(course, user);
    }

    @Override
    public String toString() {
        return "CourseReview{" +
                "id=" + getId() +
                ", course=" + (course != null ? course.getTitle() : "null") +
                ", user=" + (user != null ? user.getFullName() : "null") +
                ", rating=" + rating +
                ", reviewDate=" + reviewDate +
                '}';
    }
}
