package com.edplatform.dto;

import com.edplatform.entity.CourseCategory;
import com.edplatform.entity.CourseLevel;
import com.edplatform.entity.CourseStatus;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class CourseResponse {

    private Long id;
    private String courseCode;
    private String title;
    private String description;
    private CourseCategory category;
    private CourseLevel level;
    private Integer creditHours;
    private BigDecimal price;
    private String thumbnailUrl;
    private String videoPreviewUrl;
    private CourseStatus status;
    private LocalDate startDate;
    private LocalDate endDate;
    private LocalDate enrollmentDeadline;
    private Integer maxStudents;
    private String prerequisites;
    private String learningObjectives;
    private String syllabus;
    private Integer estimatedDurationHours;
    private String language;
    private Boolean certificateEnabled;
    private Boolean isFeatured;
    private BigDecimal rating;
    private Integer totalRatings;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Instructor information
    private Long instructorId;
    private String instructorName;
    private String instructorLastName;

    // Computed fields
    private Integer enrollmentCount;
    private Integer lessonCount;
    private Integer quizCount;
    private Integer assignmentCount;
    private Boolean canEnroll;

    // Constructors
    public CourseResponse() {}

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getCourseCode() {
        return courseCode;
    }

    public void setCourseCode(String courseCode) {
        this.courseCode = courseCode;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public CourseCategory getCategory() {
        return category;
    }

    public void setCategory(CourseCategory category) {
        this.category = category;
    }

    public CourseLevel getLevel() {
        return level;
    }

    public void setLevel(CourseLevel level) {
        this.level = level;
    }

    public Integer getCreditHours() {
        return creditHours;
    }

    public void setCreditHours(Integer creditHours) {
        this.creditHours = creditHours;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public String getThumbnailUrl() {
        return thumbnailUrl;
    }

    public void setThumbnailUrl(String thumbnailUrl) {
        this.thumbnailUrl = thumbnailUrl;
    }

    public String getVideoPreviewUrl() {
        return videoPreviewUrl;
    }

    public void setVideoPreviewUrl(String videoPreviewUrl) {
        this.videoPreviewUrl = videoPreviewUrl;
    }

    public CourseStatus getStatus() {
        return status;
    }

    public void setStatus(CourseStatus status) {
        this.status = status;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }

    public LocalDate getEnrollmentDeadline() {
        return enrollmentDeadline;
    }

    public void setEnrollmentDeadline(LocalDate enrollmentDeadline) {
        this.enrollmentDeadline = enrollmentDeadline;
    }

    public Integer getMaxStudents() {
        return maxStudents;
    }

    public void setMaxStudents(Integer maxStudents) {
        this.maxStudents = maxStudents;
    }

    public String getPrerequisites() {
        return prerequisites;
    }

    public void setPrerequisites(String prerequisites) {
        this.prerequisites = prerequisites;
    }

    public String getLearningObjectives() {
        return learningObjectives;
    }

    public void setLearningObjectives(String learningObjectives) {
        this.learningObjectives = learningObjectives;
    }

    public String getSyllabus() {
        return syllabus;
    }

    public void setSyllabus(String syllabus) {
        this.syllabus = syllabus;
    }

    public Integer getEstimatedDurationHours() {
        return estimatedDurationHours;
    }

    public void setEstimatedDurationHours(Integer estimatedDurationHours) {
        this.estimatedDurationHours = estimatedDurationHours;
    }

    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public Boolean getCertificateEnabled() {
        return certificateEnabled;
    }

    public void setCertificateEnabled(Boolean certificateEnabled) {
        this.certificateEnabled = certificateEnabled;
    }

    public Boolean getIsFeatured() {
        return isFeatured;
    }

    public void setIsFeatured(Boolean isFeatured) {
        this.isFeatured = isFeatured;
    }

    public BigDecimal getRating() {
        return rating;
    }

    public void setRating(BigDecimal rating) {
        this.rating = rating;
    }

    public Integer getTotalRatings() {
        return totalRatings;
    }

    public void setTotalRatings(Integer totalRatings) {
        this.totalRatings = totalRatings;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Long getInstructorId() {
        return instructorId;
    }

    public void setInstructorId(Long instructorId) {
        this.instructorId = instructorId;
    }

    public String getInstructorName() {
        return instructorName;
    }

    public void setInstructorName(String instructorName) {
        this.instructorName = instructorName;
    }

    public String getInstructorLastName() {
        return instructorLastName;
    }

    public void setInstructorLastName(String instructorLastName) {
        this.instructorLastName = instructorLastName;
    }

    public Integer getEnrollmentCount() {
        return enrollmentCount;
    }

    public void setEnrollmentCount(Integer enrollmentCount) {
        this.enrollmentCount = enrollmentCount;
    }

    public Integer getLessonCount() {
        return lessonCount;
    }

    public void setLessonCount(Integer lessonCount) {
        this.lessonCount = lessonCount;
    }

    public Integer getQuizCount() {
        return quizCount;
    }

    public void setQuizCount(Integer quizCount) {
        this.quizCount = quizCount;
    }

    public Integer getAssignmentCount() {
        return assignmentCount;
    }

    public void setAssignmentCount(Integer assignmentCount) {
        this.assignmentCount = assignmentCount;
    }

    public Boolean getCanEnroll() {
        return canEnroll;
    }

    public void setCanEnroll(Boolean canEnroll) {
        this.canEnroll = canEnroll;
    }

    // Helper methods
    public String getInstructorFullName() {
        return instructorName + " " + instructorLastName;
    }

    public Double getRatingAsDouble() {
        return rating != null ? rating.doubleValue() : 0.0;
    }

    public boolean isFree() {
        return price == null || price.compareTo(BigDecimal.ZERO) == 0;
    }

    public boolean isPublished() {
        return status == CourseStatus.PUBLISHED;
    }

    public boolean isDraft() {
        return status == CourseStatus.DRAFT;
    }

    public boolean isArchived() {
        return status == CourseStatus.ARCHIVED;
    }
}
