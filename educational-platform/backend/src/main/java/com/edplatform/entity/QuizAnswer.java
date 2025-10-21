package com.edplatform.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Objects;

@Entity
@Table(name = "quiz_answers")
public class QuizAnswer extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "quiz_attempt_id", nullable = false)
    private QuizAttempt quizAttempt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "question_id", nullable = false)
    private Question question;

    // For text-based answers (short answer, essay, fill-in-the-blank)
    @Column(name = "answer_text", columnDefinition = "TEXT")
    private String answerText;

    // For multiple choice questions - stores the selected option ID
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "selected_option_id")
    private QuestionOption selectedOption;

    // For multiple select questions - stores JSON array of selected option IDs
    @Column(name = "selected_options", columnDefinition = "TEXT")
    private String selectedOptions;

    @Column(name = "points_earned", precision = 5, scale = 2)
    private BigDecimal pointsEarned;

    @Column(name = "is_correct")
    private Boolean isCorrect;

    @Column(name = "answer_time", nullable = false)
    private LocalDateTime answerTime;

    @Column(name = "time_spent_seconds")
    private Integer timeSpentSeconds;

    @Column(name = "is_flagged", nullable = false)
    private Boolean isFlagged = false;

    @Column(name = "instructor_feedback", columnDefinition = "TEXT")
    private String instructorFeedback;

    @Column(name = "auto_graded", nullable = false)
    private Boolean autoGraded = true;

    // Constructors
    public QuizAnswer() {
        this.answerTime = LocalDateTime.now();
    }

    public QuizAnswer(QuizAttempt quizAttempt, Question question) {
        this();
        this.quizAttempt = quizAttempt;
        this.question = question;
    }

    // Business methods
    public boolean isGraded() {
        return pointsEarned != null;
    }

    public boolean requiresManualGrading() {
        return question.isEssay() || 
               (question.isShortAnswer() && !autoGraded) ||
               (!autoGraded && pointsEarned == null);
    }

    public void autoGrade() {
        if (question.isMultipleChoice() || question.isTrueFalse()) {
            gradeMultipleChoiceAnswer();
        } else if (question.isShortAnswer() || question.isFillInTheBlank()) {
            gradeTextAnswer();
        } else if (question.isMultipleSelect()) {
            gradeMultipleSelectAnswer();
        }
        this.autoGraded = true;
    }

    private void gradeMultipleChoiceAnswer() {
        if (selectedOption != null && selectedOption.getIsCorrect()) {
            this.pointsEarned = BigDecimal.valueOf(question.getPoints());
            this.isCorrect = true;
        } else {
            this.pointsEarned = BigDecimal.ZERO;
            this.isCorrect = false;
        }
    }

    private void gradeTextAnswer() {
        if (answerText != null && question.isAnswerCorrect(answerText)) {
            this.pointsEarned = BigDecimal.valueOf(question.getPoints());
            this.isCorrect = true;
        } else {
            this.pointsEarned = BigDecimal.ZERO;
            this.isCorrect = false;
        }
    }

    private void gradeMultipleSelectAnswer() {
        // For multiple select, this would require parsing selectedOptions JSON
        // and comparing with correct options - simplified implementation
        // This should be implemented based on how selectedOptions is stored
        this.pointsEarned = BigDecimal.ZERO;
        this.isCorrect = false;
        // TODO: Implement proper multiple select grading
    }

    public void manualGrade(BigDecimal points, String feedback) {
        this.pointsEarned = points;
        this.instructorFeedback = feedback;
        this.autoGraded = false;
        
        // Determine if correct based on points earned vs maximum possible
        BigDecimal maxPoints = BigDecimal.valueOf(question.getPoints());
        this.isCorrect = points.compareTo(maxPoints) >= 0;
    }

    public double getPercentageScore() {
        if (pointsEarned == null) return 0.0;
        BigDecimal maxPoints = BigDecimal.valueOf(question.getPoints());
        if (maxPoints.compareTo(BigDecimal.ZERO) == 0) return 0.0;
        
        return pointsEarned.divide(maxPoints, 4, BigDecimal.ROUND_HALF_UP)
                .multiply(BigDecimal.valueOf(100))
                .doubleValue();
    }

    // Getters and Setters
    public QuizAttempt getQuizAttempt() {
        return quizAttempt;
    }

    public void setQuizAttempt(QuizAttempt quizAttempt) {
        this.quizAttempt = quizAttempt;
    }

    public Question getQuestion() {
        return question;
    }

    public void setQuestion(Question question) {
        this.question = question;
    }

    public String getAnswerText() {
        return answerText;
    }

    public void setAnswerText(String answerText) {
        this.answerText = answerText;
    }

    public QuestionOption getSelectedOption() {
        return selectedOption;
    }

    public void setSelectedOption(QuestionOption selectedOption) {
        this.selectedOption = selectedOption;
    }

    public String getSelectedOptions() {
        return selectedOptions;
    }

    public void setSelectedOptions(String selectedOptions) {
        this.selectedOptions = selectedOptions;
    }

    public BigDecimal getPointsEarned() {
        return pointsEarned;
    }

    public void setPointsEarned(BigDecimal pointsEarned) {
        this.pointsEarned = pointsEarned;
    }

    public Boolean getIsCorrect() {
        return isCorrect;
    }

    public void setIsCorrect(Boolean isCorrect) {
        this.isCorrect = isCorrect;
    }

    public LocalDateTime getAnswerTime() {
        return answerTime;
    }

    public void setAnswerTime(LocalDateTime answerTime) {
        this.answerTime = answerTime;
    }

    public Integer getTimeSpentSeconds() {
        return timeSpentSeconds;
    }

    public void setTimeSpentSeconds(Integer timeSpentSeconds) {
        this.timeSpentSeconds = timeSpentSeconds;
    }

    public Boolean getIsFlagged() {
        return isFlagged;
    }

    public void setIsFlagged(Boolean isFlagged) {
        this.isFlagged = isFlagged;
    }

    public String getInstructorFeedback() {
        return instructorFeedback;
    }

    public void setInstructorFeedback(String instructorFeedback) {
        this.instructorFeedback = instructorFeedback;
    }

    public Boolean getAutoGraded() {
        return autoGraded;
    }

    public void setAutoGraded(Boolean autoGraded) {
        this.autoGraded = autoGraded;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof QuizAnswer)) return false;
        QuizAnswer that = (QuizAnswer) o;
        return Objects.equals(quizAttempt, that.quizAttempt) && Objects.equals(question, that.question);
    }

    @Override
    public int hashCode() {
        return Objects.hash(quizAttempt, question);
    }

    @Override
    public String toString() {
        return "QuizAnswer{" +
                "id=" + getId() +
                ", question=" + (question != null ? question.getId() : "null") +
                ", pointsEarned=" + pointsEarned +
                ", isCorrect=" + isCorrect +
                '}';
    }
}
