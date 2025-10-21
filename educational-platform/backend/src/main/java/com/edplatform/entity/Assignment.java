package com.edplatform.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Objects;
import java.util.Set;

@Entity
@Table(name = "assignments")
public class Assignment extends BaseEntity {

    @NotBlank(message = "Assignment title is required")
    @Size(max = 200, message = "Assignment title must not exceed 200 characters")
    @Column(name = "title", nullable = false, length = 200)
    private String title;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "instructions", columnDefinition = "TEXT")
    private String instructions;

    @NotNull(message = "Assignment type is required")
    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false)
    private AssignmentType type;

    @Column(name = "max_points")
    private Integer maxPoints = 100;

    @Column(name = "due_date")
    private LocalDateTime dueDate;

    @Column(name = "available_from")
    private LocalDateTime availableFrom;

    @Column(name = "late_submission_allowed", nullable = false)
    private Boolean lateSubmissionAllowed = true;

    @Column(name = "late_penalty_per_day", precision = 5, scale = 2)
    private BigDecimal latePenaltyPerDay;

    @Column(name = "max_late_days")
    private Integer maxLateDays;

    @Column(name = "max_attempts")
    private Integer maxAttempts;

    @Column(name = "is_group_assignment", nullable = false)
    private Boolean isGroupAssignment = false;

    @Column(name = "max_group_size")
    private Integer maxGroupSize;

    @Column(name = "is_published", nullable = false)
    private Boolean isPublished = false;

    @Column(name = "submission_format")
    @Enumerated(EnumType.STRING)
    private SubmissionFormat submissionFormat = SubmissionFormat.FILE_UPLOAD;

    @Column(name = "allowed_file_types")
    private String allowedFileTypes; // JSON array of allowed extensions

    @Column(name = "max_file_size_mb")
    private Integer maxFileSizeMb = 10;

    @Column(name = "rubric", columnDefinition = "TEXT")
    private String rubric;

    @Column(name = "auto_release_grades", nullable = false)
    private Boolean autoReleaseGrades = false;

    @Column(name = "peer_review_enabled", nullable = false)
    private Boolean peerReviewEnabled = false;

    @Column(name = "peer_reviews_required")
    private Integer peerReviewsRequired;

    @Column(name = "plagiarism_check_enabled", nullable = false)
    private Boolean plagiarismCheckEnabled = false;

    @Column(name = "estimated_duration_hours")
    private Integer estimatedDurationHours;

    // Relationships
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user; // The instructor who created the assignment

    @OneToMany(mappedBy = "assignment", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private Set<AssignmentSubmission> submissions = new HashSet<>();

    // Constructors
    public Assignment() {}

    public Assignment(String title, Course course, User user, AssignmentType type) {
        this.title = title;
        this.course = course;
        this.user = user;
        this.type = type;
    }

    // Business methods
    public boolean isAvailable() {
        LocalDateTime now = LocalDateTime.now();
        if (availableFrom != null && now.isBefore(availableFrom)) {
            return false;
        }
        return isPublished;
    }

    public boolean isPastDue() {
        return dueDate != null && LocalDateTime.now().isAfter(dueDate);
    }

    public boolean isLateSubmissionAccepted() {
        if (!lateSubmissionAllowed) return false;
        if (maxLateDays == null) return true;
        
        if (dueDate != null) {
            LocalDateTime maxLateDate = dueDate.plusDays(maxLateDays);
            return LocalDateTime.now().isBefore(maxLateDate) || LocalDateTime.now().equals(maxLateDate);
        }
        
        return true;
    }

    public boolean canSubmit() {
        if (!isAvailable()) return false;
        if (isPastDue() && !isLateSubmissionAccepted()) return false;
        return true;
    }

    public int getDaysLate() {
        if (dueDate == null || !isPastDue()) return 0;
        return (int) java.time.Duration.between(dueDate, LocalDateTime.now()).toDays();
    }

    public BigDecimal calculateLatePenalty() {
        if (!isPastDue() || latePenaltyPerDay == null) {
            return BigDecimal.ZERO;
        }
        
        int daysLate = getDaysLate();
        return latePenaltyPerDay.multiply(BigDecimal.valueOf(daysLate));
    }

    public int getSubmissionCount() {
        return submissions.size();
    }

    public AssignmentSubmission getSubmissionByUser(User student) {
        return submissions.stream()
                .filter(sub -> sub.getUser().equals(student))
                .findFirst()
                .orElse(null);
    }

    public boolean hasUserSubmitted(User student) {
        return getSubmissionByUser(student) != null;
    }

    public double getAverageGrade() {
        return submissions.stream()
                .filter(sub -> sub.getGrade() != null)
                .mapToDouble(sub -> sub.getGrade().doubleValue())
                .average()
                .orElse(0.0);
    }

    public long getGradedSubmissionCount() {
        return submissions.stream()
                .filter(sub -> sub.getGrade() != null)
                .count();
    }

    // Getters and Setters
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

    public String getInstructions() {
        return instructions;
    }

    public void setInstructions(String instructions) {
        this.instructions = instructions;
    }

    public AssignmentType getType() {
        return type;
    }

    public void setType(AssignmentType type) {
        this.type = type;
    }

    public Integer getMaxPoints() {
        return maxPoints;
    }

    public void setMaxPoints(Integer maxPoints) {
        this.maxPoints = maxPoints;
    }

    public LocalDateTime getDueDate() {
        return dueDate;
    }

    public void setDueDate(LocalDateTime dueDate) {
        this.dueDate = dueDate;
    }

    public LocalDateTime getAvailableFrom() {
        return availableFrom;
    }

    public void setAvailableFrom(LocalDateTime availableFrom) {
        this.availableFrom = availableFrom;
    }

    public Boolean getLateSubmissionAllowed() {
        return lateSubmissionAllowed;
    }

    public void setLateSubmissionAllowed(Boolean lateSubmissionAllowed) {
        this.lateSubmissionAllowed = lateSubmissionAllowed;
    }

    public BigDecimal getLatePenaltyPerDay() {
        return latePenaltyPerDay;
    }

    public void setLatePenaltyPerDay(BigDecimal latePenaltyPerDay) {
        this.latePenaltyPerDay = latePenaltyPerDay;
    }

    public Integer getMaxLateDays() {
        return maxLateDays;
    }

    public void setMaxLateDays(Integer maxLateDays) {
        this.maxLateDays = maxLateDays;
    }

    public Integer getMaxAttempts() {
        return maxAttempts;
    }

    public void setMaxAttempts(Integer maxAttempts) {
        this.maxAttempts = maxAttempts;
    }

    public Boolean getIsGroupAssignment() {
        return isGroupAssignment;
    }

    public void setIsGroupAssignment(Boolean isGroupAssignment) {
        this.isGroupAssignment = isGroupAssignment;
    }

    public Integer getMaxGroupSize() {
        return maxGroupSize;
    }

    public void setMaxGroupSize(Integer maxGroupSize) {
        this.maxGroupSize = maxGroupSize;
    }

    public Boolean getIsPublished() {
        return isPublished;
    }

    public void setIsPublished(Boolean isPublished) {
        this.isPublished = isPublished;
    }

    public SubmissionFormat getSubmissionFormat() {
        return submissionFormat;
    }

    public void setSubmissionFormat(SubmissionFormat submissionFormat) {
        this.submissionFormat = submissionFormat;
    }

    public String getAllowedFileTypes() {
        return allowedFileTypes;
    }

    public void setAllowedFileTypes(String allowedFileTypes) {
        this.allowedFileTypes = allowedFileTypes;
    }

    public Integer getMaxFileSizeMb() {
        return maxFileSizeMb;
    }

    public void setMaxFileSizeMb(Integer maxFileSizeMb) {
        this.maxFileSizeMb = maxFileSizeMb;
    }

    public String getRubric() {
        return rubric;
    }

    public void setRubric(String rubric) {
        this.rubric = rubric;
    }

    public Boolean getAutoReleaseGrades() {
        return autoReleaseGrades;
    }

    public void setAutoReleaseGrades(Boolean autoReleaseGrades) {
        this.autoReleaseGrades = autoReleaseGrades;
    }

    public Boolean getPeerReviewEnabled() {
        return peerReviewEnabled;
    }

    public void setPeerReviewEnabled(Boolean peerReviewEnabled) {
        this.peerReviewEnabled = peerReviewEnabled;
    }

    public Integer getPeerReviewsRequired() {
        return peerReviewsRequired;
    }

    public void setPeerReviewsRequired(Integer peerReviewsRequired) {
        this.peerReviewsRequired = peerReviewsRequired;
    }

    public Boolean getPlagiarismCheckEnabled() {
        return plagiarismCheckEnabled;
    }

    public void setPlagiarismCheckEnabled(Boolean plagiarismCheckEnabled) {
        this.plagiarismCheckEnabled = plagiarismCheckEnabled;
    }

    public Integer getEstimatedDurationHours() {
        return estimatedDurationHours;
    }

    public void setEstimatedDurationHours(Integer estimatedDurationHours) {
        this.estimatedDurationHours = estimatedDurationHours;
    }

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

    public Set<AssignmentSubmission> getSubmissions() {
        return submissions;
    }

    public void setSubmissions(Set<AssignmentSubmission> submissions) {
        this.submissions = submissions;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Assignment)) return false;
        Assignment that = (Assignment) o;
        return Objects.equals(title, that.title) && Objects.equals(course, that.course);
    }

    @Override
    public int hashCode() {
        return Objects.hash(title, course);
    }

    @Override
    public String toString() {
        return "Assignment{" +
                "id=" + getId() +
                ", title='" + title + '\'' +
                ", type=" + type +
                ", course=" + (course != null ? course.getTitle() : "null") +
                ", dueDate=" + dueDate +
                '}';
    }
}
