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
@Table(name = "quizzes")
public class Quiz extends BaseEntity {

    @NotBlank(message = "Quiz title is required")
    @Size(max = 200, message = "Quiz title must not exceed 200 characters")
    @Column(name = "title", nullable = false, length = 200)
    private String title;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "instructions", columnDefinition = "TEXT")
    private String instructions;

    @NotNull(message = "Quiz type is required")
    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false)
    private QuizType type;

    @Column(name = "time_limit_minutes")
    private Integer timeLimitMinutes;

    @Column(name = "max_attempts")
    private Integer maxAttempts;

    @Column(name = "passing_score", precision = 5, scale = 2)
    private BigDecimal passingScore;

    @Column(name = "total_points")
    private Integer totalPoints;

    @Column(name = "is_published", nullable = false)
    private Boolean isPublished = false;

    @Column(name = "is_randomized", nullable = false)
    private Boolean isRandomized = false;

    @Column(name = "show_correct_answers", nullable = false)
    private Boolean showCorrectAnswers = true;

    @Column(name = "show_score_immediately", nullable = false)
    private Boolean showScoreImmediately = true;

    @Column(name = "available_from")
    private LocalDateTime availableFrom;

    @Column(name = "available_until")
    private LocalDateTime availableUntil;

    @Column(name = "late_submission_penalty", precision = 5, scale = 2)
    private BigDecimal lateSubmissionPenalty;

    @Column(name = "weight_percentage", precision = 5, scale = 2)
    private BigDecimal weightPercentage;

    // Relationships
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lesson_id")
    private Lesson lesson;

    @OneToMany(mappedBy = "quiz", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @OrderBy("questionOrder ASC")
    private Set<Question> questions = new HashSet<>();

    @OneToMany(mappedBy = "quiz", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private Set<QuizAttempt> attempts = new HashSet<>();

    // Constructors
    public Quiz() {}

    public Quiz(String title, Course course, QuizType type) {
        this.title = title;
        this.course = course;
        this.type = type;
    }

    // Business methods
    public boolean isAvailable() {
        LocalDateTime now = LocalDateTime.now();
        if (availableFrom != null && now.isBefore(availableFrom)) {
            return false;
        }
        if (availableUntil != null && now.isAfter(availableUntil)) {
            return false;
        }
        return isPublished;
    }

    public boolean hasTimeLimit() {
        return timeLimitMinutes != null && timeLimitMinutes > 0;
    }

    public boolean hasAttemptsLimit() {
        return maxAttempts != null && maxAttempts > 0;
    }

    public boolean isPassingScoreSet() {
        return passingScore != null;
    }

    public int getTotalQuestions() {
        return questions.size();
    }

    public boolean canUserAttempt(User user) {
        if (!isAvailable()) return false;
        
        if (hasAttemptsLimit()) {
            long userAttempts = attempts.stream()
                    .filter(attempt -> attempt.getUser().equals(user))
                    .count();
            return userAttempts < maxAttempts;
        }
        
        return true;
    }

    public int getUserAttemptCount(User user) {
        return (int) attempts.stream()
                .filter(attempt -> attempt.getUser().equals(user))
                .count();
    }

    public QuizAttempt getBestAttemptForUser(User user) {
        return attempts.stream()
                .filter(attempt -> attempt.getUser().equals(user) && attempt.isCompleted())
                .max((a1, a2) -> a1.getScore().compareTo(a2.getScore()))
                .orElse(null);
    }

    public QuizAttempt getLatestAttemptForUser(User user) {
        return attempts.stream()
                .filter(attempt -> attempt.getUser().equals(user))
                .max((a1, a2) -> a1.getStartTime().compareTo(a2.getStartTime()))
                .orElse(null);
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

    public QuizType getType() {
        return type;
    }

    public void setType(QuizType type) {
        this.type = type;
    }

    public Integer getTimeLimitMinutes() {
        return timeLimitMinutes;
    }

    public void setTimeLimitMinutes(Integer timeLimitMinutes) {
        this.timeLimitMinutes = timeLimitMinutes;
    }

    public Integer getMaxAttempts() {
        return maxAttempts;
    }

    public void setMaxAttempts(Integer maxAttempts) {
        this.maxAttempts = maxAttempts;
    }

    public BigDecimal getPassingScore() {
        return passingScore;
    }

    public void setPassingScore(BigDecimal passingScore) {
        this.passingScore = passingScore;
    }

    public Integer getTotalPoints() {
        return totalPoints;
    }

    public void setTotalPoints(Integer totalPoints) {
        this.totalPoints = totalPoints;
    }

    public Boolean getIsPublished() {
        return isPublished;
    }

    public void setIsPublished(Boolean isPublished) {
        this.isPublished = isPublished;
    }

    public Boolean getIsRandomized() {
        return isRandomized;
    }

    public void setIsRandomized(Boolean isRandomized) {
        this.isRandomized = isRandomized;
    }

    public Boolean getShowCorrectAnswers() {
        return showCorrectAnswers;
    }

    public void setShowCorrectAnswers(Boolean showCorrectAnswers) {
        this.showCorrectAnswers = showCorrectAnswers;
    }

    public Boolean getShowScoreImmediately() {
        return showScoreImmediately;
    }

    public void setShowScoreImmediately(Boolean showScoreImmediately) {
        this.showScoreImmediately = showScoreImmediately;
    }

    public LocalDateTime getAvailableFrom() {
        return availableFrom;
    }

    public void setAvailableFrom(LocalDateTime availableFrom) {
        this.availableFrom = availableFrom;
    }

    public LocalDateTime getAvailableUntil() {
        return availableUntil;
    }

    public void setAvailableUntil(LocalDateTime availableUntil) {
        this.availableUntil = availableUntil;
    }

    public BigDecimal getLateSubmissionPenalty() {
        return lateSubmissionPenalty;
    }

    public void setLateSubmissionPenalty(BigDecimal lateSubmissionPenalty) {
        this.lateSubmissionPenalty = lateSubmissionPenalty;
    }

    public BigDecimal getWeightPercentage() {
        return weightPercentage;
    }

    public void setWeightPercentage(BigDecimal weightPercentage) {
        this.weightPercentage = weightPercentage;
    }

    public Course getCourse() {
        return course;
    }

    public void setCourse(Course course) {
        this.course = course;
    }

    public Lesson getLesson() {
        return lesson;
    }

    public void setLesson(Lesson lesson) {
        this.lesson = lesson;
    }

    public Set<Question> getQuestions() {
        return questions;
    }

    public void setQuestions(Set<Question> questions) {
        this.questions = questions;
    }

    public Set<QuizAttempt> getAttempts() {
        return attempts;
    }

    public void setAttempts(Set<QuizAttempt> attempts) {
        this.attempts = attempts;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Quiz)) return false;
        Quiz quiz = (Quiz) o;
        return Objects.equals(title, quiz.title) && Objects.equals(course, quiz.course);
    }

    @Override
    public int hashCode() {
        return Objects.hash(title, course);
    }

    @Override
    public String toString() {
        return "Quiz{" +
                "id=" + getId() +
                ", title='" + title + '\'' +
                ", type=" + type +
                ", course=" + (course != null ? course.getTitle() : "null") +
                '}';
    }
}
