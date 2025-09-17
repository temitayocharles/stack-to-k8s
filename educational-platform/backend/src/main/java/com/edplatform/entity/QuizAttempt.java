package com.edplatform.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Objects;
import java.util.Set;

@Entity
@Table(name = "quiz_attempts")
public class QuizAttempt extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "quiz_id", nullable = false)
    private Quiz quiz;

    @Column(name = "attempt_number", nullable = false)
    private Integer attemptNumber;

    @Column(name = "start_time", nullable = false)
    private LocalDateTime startTime;

    @Column(name = "end_time")
    private LocalDateTime endTime;

    @Column(name = "time_taken_minutes")
    private Integer timeTakenMinutes;

    @Column(name = "score", precision = 5, scale = 2)
    private BigDecimal score;

    @Column(name = "max_score", precision = 5, scale = 2)
    private BigDecimal maxScore;

    @Column(name = "percentage", precision = 5, scale = 2)
    private BigDecimal percentage;

    @NotNull(message = "Attempt status is required")
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private AttemptStatus status = AttemptStatus.IN_PROGRESS;

    @Column(name = "is_late_submission", nullable = false)
    private Boolean isLateSubmission = false;

    @Column(name = "ip_address")
    private String ipAddress;

    @Column(name = "user_agent", length = 500)
    private String userAgent;

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;

    @Column(name = "graded_by_instructor", nullable = false)
    private Boolean gradedByInstructor = false;

    @Column(name = "instructor_feedback", columnDefinition = "TEXT")
    private String instructorFeedback;

    // Relationships
    @OneToMany(mappedBy = "quizAttempt", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private Set<QuizAnswer> answers = new HashSet<>();

    // Constructors
    public QuizAttempt() {
        this.startTime = LocalDateTime.now();
    }

    public QuizAttempt(User user, Quiz quiz, Integer attemptNumber) {
        this();
        this.user = user;
        this.quiz = quiz;
        this.attemptNumber = attemptNumber;
    }

    // Business methods
    public boolean isInProgress() {
        return status == AttemptStatus.IN_PROGRESS;
    }

    public boolean isCompleted() {
        return status == AttemptStatus.COMPLETED;
    }

    public boolean isAbandoned() {
        return status == AttemptStatus.ABANDONED;
    }

    public boolean isTimedOut() {
        return status == AttemptStatus.TIMED_OUT;
    }

    public boolean isPassed() {
        if (quiz.getPassingScore() == null || percentage == null) {
            return false;
        }
        return percentage.compareTo(quiz.getPassingScore()) >= 0;
    }

    public boolean isGraded() {
        return status == AttemptStatus.COMPLETED && score != null;
    }

    public void completeAttempt() {
        this.endTime = LocalDateTime.now();
        this.status = AttemptStatus.COMPLETED;
        
        if (this.startTime != null) {
            long minutes = java.time.Duration.between(this.startTime, this.endTime).toMinutes();
            this.timeTakenMinutes = (int) minutes;
        }
        
        calculateScore();
    }

    public void timeoutAttempt() {
        this.endTime = LocalDateTime.now();
        this.status = AttemptStatus.TIMED_OUT;
        
        if (this.startTime != null) {
            long minutes = java.time.Duration.between(this.startTime, this.endTime).toMinutes();
            this.timeTakenMinutes = (int) minutes;
        }
        
        calculateScore();
    }

    public void abandonAttempt() {
        this.endTime = LocalDateTime.now();
        this.status = AttemptStatus.ABANDONED;
        
        if (this.startTime != null) {
            long minutes = java.time.Duration.between(this.startTime, this.endTime).toMinutes();
            this.timeTakenMinutes = (int) minutes;
        }
    }

    private void calculateScore() {
        if (answers.isEmpty()) {
            this.score = BigDecimal.ZERO;
            this.percentage = BigDecimal.ZERO;
            return;
        }

        BigDecimal totalEarned = answers.stream()
                .map(QuizAnswer::getPointsEarned)
                .filter(Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal totalPossible = quiz.getTotalPoints() != null ? 
                BigDecimal.valueOf(quiz.getTotalPoints()) : 
                quiz.getQuestions().stream()
                        .map(q -> BigDecimal.valueOf(q.getPoints()))
                        .reduce(BigDecimal.ZERO, BigDecimal::add);

        this.score = totalEarned;
        this.maxScore = totalPossible;

        if (totalPossible.compareTo(BigDecimal.ZERO) > 0) {
            this.percentage = totalEarned.divide(totalPossible, 4, BigDecimal.ROUND_HALF_UP)
                    .multiply(BigDecimal.valueOf(100));
        } else {
            this.percentage = BigDecimal.ZERO;
        }
    }

    public boolean isTimeExceeded() {
        if (quiz.getTimeLimitMinutes() == null || startTime == null) {
            return false;
        }
        
        LocalDateTime deadline = startTime.plusMinutes(quiz.getTimeLimitMinutes());
        return LocalDateTime.now().isAfter(deadline);
    }

    public long getRemainingTimeMinutes() {
        if (quiz.getTimeLimitMinutes() == null || startTime == null) {
            return -1; // No time limit
        }
        
        LocalDateTime deadline = startTime.plusMinutes(quiz.getTimeLimitMinutes());
        LocalDateTime now = LocalDateTime.now();
        
        if (now.isAfter(deadline)) {
            return 0; // Time expired
        }
        
        return java.time.Duration.between(now, deadline).toMinutes();
    }

    // Getters and Setters
    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Quiz getQuiz() {
        return quiz;
    }

    public void setQuiz(Quiz quiz) {
        this.quiz = quiz;
    }

    public Integer getAttemptNumber() {
        return attemptNumber;
    }

    public void setAttemptNumber(Integer attemptNumber) {
        this.attemptNumber = attemptNumber;
    }

    public LocalDateTime getStartTime() {
        return startTime;
    }

    public void setStartTime(LocalDateTime startTime) {
        this.startTime = startTime;
    }

    public LocalDateTime getEndTime() {
        return endTime;
    }

    public void setEndTime(LocalDateTime endTime) {
        this.endTime = endTime;
    }

    public Integer getTimeTakenMinutes() {
        return timeTakenMinutes;
    }

    public void setTimeTakenMinutes(Integer timeTakenMinutes) {
        this.timeTakenMinutes = timeTakenMinutes;
    }

    public BigDecimal getScore() {
        return score;
    }

    public void setScore(BigDecimal score) {
        this.score = score;
    }

    public BigDecimal getMaxScore() {
        return maxScore;
    }

    public void setMaxScore(BigDecimal maxScore) {
        this.maxScore = maxScore;
    }

    public BigDecimal getPercentage() {
        return percentage;
    }

    public void setPercentage(BigDecimal percentage) {
        this.percentage = percentage;
    }

    public AttemptStatus getStatus() {
        return status;
    }

    public void setStatus(AttemptStatus status) {
        this.status = status;
    }

    public Boolean getIsLateSubmission() {
        return isLateSubmission;
    }

    public void setIsLateSubmission(Boolean isLateSubmission) {
        this.isLateSubmission = isLateSubmission;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    public String getUserAgent() {
        return userAgent;
    }

    public void setUserAgent(String userAgent) {
        this.userAgent = userAgent;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public Boolean getGradedByInstructor() {
        return gradedByInstructor;
    }

    public void setGradedByInstructor(Boolean gradedByInstructor) {
        this.gradedByInstructor = gradedByInstructor;
    }

    public String getInstructorFeedback() {
        return instructorFeedback;
    }

    public void setInstructorFeedback(String instructorFeedback) {
        this.instructorFeedback = instructorFeedback;
    }

    public Set<QuizAnswer> getAnswers() {
        return answers;
    }

    public void setAnswers(Set<QuizAnswer> answers) {
        this.answers = answers;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof QuizAttempt)) return false;
        QuizAttempt that = (QuizAttempt) o;
        return Objects.equals(user, that.user) && 
               Objects.equals(quiz, that.quiz) && 
               Objects.equals(attemptNumber, that.attemptNumber);
    }

    @Override
    public int hashCode() {
        return Objects.hash(user, quiz, attemptNumber);
    }

    @Override
    public String toString() {
        return "QuizAttempt{" +
                "id=" + getId() +
                ", user=" + (user != null ? user.getFullName() : "null") +
                ", quiz=" + (quiz != null ? quiz.getTitle() : "null") +
                ", attemptNumber=" + attemptNumber +
                ", status=" + status +
                ", score=" + score +
                '}';
    }
}
