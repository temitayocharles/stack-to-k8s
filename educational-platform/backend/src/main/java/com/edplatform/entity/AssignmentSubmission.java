package com.edplatform.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Objects;

@Entity
@Table(name = "assignment_submissions")
public class AssignmentSubmission extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assignment_id", nullable = false)
    private Assignment assignment;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "submission_text", columnDefinition = "TEXT")
    private String submissionText;

    @Column(name = "file_url")
    private String fileUrl;

    @Column(name = "file_name")
    private String fileName;

    @Column(name = "file_size_bytes")
    private Long fileSizeBytes;

    @Column(name = "file_mime_type")
    private String fileMimeType;

    @Column(name = "external_url")
    private String externalUrl;

    @Column(name = "submission_date", nullable = false)
    private LocalDateTime submissionDate;

    @NotNull(message = "Submission status is required")
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private SubmissionStatus status = SubmissionStatus.SUBMITTED;

    @Column(name = "grade", precision = 5, scale = 2)
    private BigDecimal grade;

    @Column(name = "feedback", columnDefinition = "TEXT")
    private String feedback;

    @Column(name = "graded_date")
    private LocalDateTime gradedDate;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "graded_by")
    private User gradedBy;

    @Column(name = "is_late", nullable = false)
    private Boolean isLate = false;

    @Column(name = "days_late")
    private Integer daysLate = 0;

    @Column(name = "late_penalty", precision = 5, scale = 2)
    private BigDecimal latePenalty = BigDecimal.ZERO;

    @Column(name = "attempt_number", nullable = false)
    private Integer attemptNumber = 1;

    @Column(name = "plagiarism_score", precision = 5, scale = 2)
    private BigDecimal plagiarismScore;

    @Column(name = "plagiarism_report_url")
    private String plagiarismReportUrl;

    @Column(name = "grading_rubric_scores", columnDefinition = "TEXT")
    private String gradingRubricScores; // JSON format

    @Column(name = "private_comments", columnDefinition = "TEXT")
    private String privateComments; // Comments visible only to instructors

    @Column(name = "needs_grading", nullable = false)
    private Boolean needsGrading = true;

    // Constructors
    public AssignmentSubmission() {
        this.submissionDate = LocalDateTime.now();
    }

    public AssignmentSubmission(Assignment assignment, User user) {
        this();
        this.assignment = assignment;
        this.user = user;
        this.checkIfLate();
    }

    // Business methods
    private void checkIfLate() {
        if (assignment != null && assignment.getDueDate() != null) {
            this.isLate = submissionDate.isAfter(assignment.getDueDate());
            if (isLate) {
                this.daysLate = assignment.getDaysLate();
                this.latePenalty = assignment.calculateLatePenalty();
            }
        }
    }

    public boolean isGraded() {
        return grade != null && status == SubmissionStatus.GRADED;
    }

    public boolean isReturned() {
        return status == SubmissionStatus.RETURNED;
    }

    public boolean isPlagiarismChecked() {
        return plagiarismScore != null;
    }

    public BigDecimal getFinalGrade() {
        if (grade == null) return null;
        
        BigDecimal finalGrade = grade;
        if (latePenalty != null && latePenalty.compareTo(BigDecimal.ZERO) > 0) {
            finalGrade = grade.subtract(latePenalty);
            // Ensure grade doesn't go below 0
            if (finalGrade.compareTo(BigDecimal.ZERO) < 0) {
                finalGrade = BigDecimal.ZERO;
            }
        }
        return finalGrade;
    }

    public double getPercentageGrade() {
        BigDecimal finalGrade = getFinalGrade();
        if (finalGrade == null || assignment.getMaxPoints() == null || assignment.getMaxPoints() == 0) {
            return 0.0;
        }
        
        return finalGrade.divide(BigDecimal.valueOf(assignment.getMaxPoints()), 4, BigDecimal.ROUND_HALF_UP)
                .multiply(BigDecimal.valueOf(100))
                .doubleValue();
    }

    public void grade(BigDecimal points, String feedback, User gradedBy) {
        this.grade = points;
        this.feedback = feedback;
        this.gradedBy = gradedBy;
        this.gradedDate = LocalDateTime.now();
        this.status = SubmissionStatus.GRADED;
        this.needsGrading = false;
    }

    public void returnToStudent(String feedback) {
        this.feedback = feedback;
        this.status = SubmissionStatus.RETURNED;
        this.needsGrading = true;
    }

    public boolean hasFile() {
        return fileUrl != null && !fileUrl.trim().isEmpty();
    }

    public boolean hasText() {
        return submissionText != null && !submissionText.trim().isEmpty();
    }

    public boolean hasExternalUrl() {
        return externalUrl != null && !externalUrl.trim().isEmpty();
    }

    public String getFormattedFileSize() {
        if (fileSizeBytes == null) return "N/A";
        
        if (fileSizeBytes < 1024) {
            return fileSizeBytes + " B";
        } else if (fileSizeBytes < 1024 * 1024) {
            return String.format("%.1f KB", fileSizeBytes / 1024.0);
        } else {
            return String.format("%.1f MB", fileSizeBytes / (1024.0 * 1024.0));
        }
    }

    // Getters and Setters
    public Assignment getAssignment() {
        return assignment;
    }

    public void setAssignment(Assignment assignment) {
        this.assignment = assignment;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public String getSubmissionText() {
        return submissionText;
    }

    public void setSubmissionText(String submissionText) {
        this.submissionText = submissionText;
    }

    public String getFileUrl() {
        return fileUrl;
    }

    public void setFileUrl(String fileUrl) {
        this.fileUrl = fileUrl;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public Long getFileSizeBytes() {
        return fileSizeBytes;
    }

    public void setFileSizeBytes(Long fileSizeBytes) {
        this.fileSizeBytes = fileSizeBytes;
    }

    public String getFileMimeType() {
        return fileMimeType;
    }

    public void setFileMimeType(String fileMimeType) {
        this.fileMimeType = fileMimeType;
    }

    public String getExternalUrl() {
        return externalUrl;
    }

    public void setExternalUrl(String externalUrl) {
        this.externalUrl = externalUrl;
    }

    public LocalDateTime getSubmissionDate() {
        return submissionDate;
    }

    public void setSubmissionDate(LocalDateTime submissionDate) {
        this.submissionDate = submissionDate;
    }

    public SubmissionStatus getStatus() {
        return status;
    }

    public void setStatus(SubmissionStatus status) {
        this.status = status;
    }

    public BigDecimal getGrade() {
        return grade;
    }

    public void setGrade(BigDecimal grade) {
        this.grade = grade;
    }

    public String getFeedback() {
        return feedback;
    }

    public void setFeedback(String feedback) {
        this.feedback = feedback;
    }

    public LocalDateTime getGradedDate() {
        return gradedDate;
    }

    public void setGradedDate(LocalDateTime gradedDate) {
        this.gradedDate = gradedDate;
    }

    public User getGradedBy() {
        return gradedBy;
    }

    public void setGradedBy(User gradedBy) {
        this.gradedBy = gradedBy;
    }

    public Boolean getIsLate() {
        return isLate;
    }

    public void setIsLate(Boolean isLate) {
        this.isLate = isLate;
    }

    public Integer getDaysLate() {
        return daysLate;
    }

    public void setDaysLate(Integer daysLate) {
        this.daysLate = daysLate;
    }

    public BigDecimal getLatePenalty() {
        return latePenalty;
    }

    public void setLatePenalty(BigDecimal latePenalty) {
        this.latePenalty = latePenalty;
    }

    public Integer getAttemptNumber() {
        return attemptNumber;
    }

    public void setAttemptNumber(Integer attemptNumber) {
        this.attemptNumber = attemptNumber;
    }

    public BigDecimal getPlagiarismScore() {
        return plagiarismScore;
    }

    public void setPlagiarismScore(BigDecimal plagiarismScore) {
        this.plagiarismScore = plagiarismScore;
    }

    public String getPlagiarismReportUrl() {
        return plagiarismReportUrl;
    }

    public void setPlagiarismReportUrl(String plagiarismReportUrl) {
        this.plagiarismReportUrl = plagiarismReportUrl;
    }

    public String getGradingRubricScores() {
        return gradingRubricScores;
    }

    public void setGradingRubricScores(String gradingRubricScores) {
        this.gradingRubricScores = gradingRubricScores;
    }

    public String getPrivateComments() {
        return privateComments;
    }

    public void setPrivateComments(String privateComments) {
        this.privateComments = privateComments;
    }

    public Boolean getNeedsGrading() {
        return needsGrading;
    }

    public void setNeedsGrading(Boolean needsGrading) {
        this.needsGrading = needsGrading;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof AssignmentSubmission)) return false;
        AssignmentSubmission that = (AssignmentSubmission) o;
        return Objects.equals(assignment, that.assignment) && 
               Objects.equals(user, that.user) && 
               Objects.equals(attemptNumber, that.attemptNumber);
    }

    @Override
    public int hashCode() {
        return Objects.hash(assignment, user, attemptNumber);
    }

    @Override
    public String toString() {
        return "AssignmentSubmission{" +
                "id=" + getId() +
                ", assignment=" + (assignment != null ? assignment.getTitle() : "null") +
                ", user=" + (user != null ? user.getFullName() : "null") +
                ", status=" + status +
                ", grade=" + grade +
                ", submissionDate=" + submissionDate +
                '}';
    }
}
