package com.edplatform.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.HashSet;
import java.util.Objects;
import java.util.Set;

@Entity
@Table(name = "questions")
public class Question extends BaseEntity {

    @NotBlank(message = "Question text is required")
    @Column(name = "question_text", nullable = false, columnDefinition = "TEXT")
    private String questionText;

    @NotNull(message = "Question type is required")
    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false)
    private QuestionType type;

    @NotNull(message = "Question order is required")
    @Column(name = "question_order", nullable = false)
    private Integer questionOrder;

    @Column(name = "points", nullable = false)
    private Integer points = 1;

    @Column(name = "explanation", columnDefinition = "TEXT")
    private String explanation;

    @Column(name = "image_url")
    private String imageUrl;

    @Column(name = "is_required", nullable = false)
    private Boolean isRequired = true;

    @Column(name = "difficulty_level")
    @Enumerated(EnumType.STRING)
    private DifficultyLevel difficultyLevel = DifficultyLevel.MEDIUM;

    // For fill-in-the-blank and short answer questions
    @Column(name = "correct_answer")
    private String correctAnswer;

    // For case-sensitive text answers
    @Column(name = "case_sensitive", nullable = false)
    private Boolean caseSensitive = false;

    // Relationships
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "quiz_id", nullable = false)
    private Quiz quiz;

    @OneToMany(mappedBy = "question", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @OrderBy("optionOrder ASC")
    private Set<QuestionOption> options = new HashSet<>();

    @OneToMany(mappedBy = "question", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private Set<QuizAnswer> answers = new HashSet<>();

    // Constructors
    public Question() {}

    public Question(String questionText, QuestionType type, Quiz quiz, Integer questionOrder) {
        this.questionText = questionText;
        this.type = type;
        this.quiz = quiz;
        this.questionOrder = questionOrder;
    }

    // Business methods
    public boolean isMultipleChoice() {
        return type == QuestionType.MULTIPLE_CHOICE;
    }

    public boolean isMultipleSelect() {
        return type == QuestionType.MULTIPLE_SELECT;
    }

    public boolean isTrueFalse() {
        return type == QuestionType.TRUE_FALSE;
    }

    public boolean isShortAnswer() {
        return type == QuestionType.SHORT_ANSWER;
    }

    public boolean isEssay() {
        return type == QuestionType.ESSAY;
    }

    public boolean isFillInTheBlank() {
        return type == QuestionType.FILL_IN_THE_BLANK;
    }

    public boolean isMatching() {
        return type == QuestionType.MATCHING;
    }

    public boolean hasOptions() {
        return isMultipleChoice() || isMultipleSelect() || isTrueFalse() || isMatching();
    }

    public Set<QuestionOption> getCorrectOptions() {
        return options.stream()
                .filter(QuestionOption::getIsCorrect)
                .collect(java.util.stream.Collectors.toSet());
    }

    public boolean hasCorrectAnswer() {
        if (hasOptions()) {
            return !getCorrectOptions().isEmpty();
        } else {
            return correctAnswer != null && !correctAnswer.trim().isEmpty();
        }
    }

    public boolean isAnswerCorrect(String userAnswer) {
        if (userAnswer == null) return false;

        if (isTrueFalse() || isMultipleChoice()) {
            // For these types, check against correct options
            return getCorrectOptions().stream()
                    .anyMatch(option -> option.getOptionText().equals(userAnswer));
        } else if (isShortAnswer() || isFillInTheBlank()) {
            // For text-based answers
            if (caseSensitive) {
                return correctAnswer != null && correctAnswer.equals(userAnswer.trim());
            } else {
                return correctAnswer != null && correctAnswer.equalsIgnoreCase(userAnswer.trim());
            }
        }
        
        return false; // For essay and other types that require manual grading
    }

    // Getters and Setters
    public String getQuestionText() {
        return questionText;
    }

    public void setQuestionText(String questionText) {
        this.questionText = questionText;
    }

    public QuestionType getType() {
        return type;
    }

    public void setType(QuestionType type) {
        this.type = type;
    }

    public Integer getQuestionOrder() {
        return questionOrder;
    }

    public void setQuestionOrder(Integer questionOrder) {
        this.questionOrder = questionOrder;
    }

    public Integer getPoints() {
        return points;
    }

    public void setPoints(Integer points) {
        this.points = points;
    }

    public String getExplanation() {
        return explanation;
    }

    public void setExplanation(String explanation) {
        this.explanation = explanation;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public Boolean getIsRequired() {
        return isRequired;
    }

    public void setIsRequired(Boolean isRequired) {
        this.isRequired = isRequired;
    }

    public DifficultyLevel getDifficultyLevel() {
        return difficultyLevel;
    }

    public void setDifficultyLevel(DifficultyLevel difficultyLevel) {
        this.difficultyLevel = difficultyLevel;
    }

    public String getCorrectAnswer() {
        return correctAnswer;
    }

    public void setCorrectAnswer(String correctAnswer) {
        this.correctAnswer = correctAnswer;
    }

    public Boolean getCaseSensitive() {
        return caseSensitive;
    }

    public void setCaseSensitive(Boolean caseSensitive) {
        this.caseSensitive = caseSensitive;
    }

    public Quiz getQuiz() {
        return quiz;
    }

    public void setQuiz(Quiz quiz) {
        this.quiz = quiz;
    }

    public Set<QuestionOption> getOptions() {
        return options;
    }

    public void setOptions(Set<QuestionOption> options) {
        this.options = options;
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
        if (!(o instanceof Question)) return false;
        Question question = (Question) o;
        return Objects.equals(quiz, question.quiz) && Objects.equals(questionOrder, question.questionOrder);
    }

    @Override
    public int hashCode() {
        return Objects.hash(quiz, questionOrder);
    }

    @Override
    public String toString() {
        return "Question{" +
                "id=" + getId() +
                ", questionOrder=" + questionOrder +
                ", type=" + type +
                ", points=" + points +
                ", quiz=" + (quiz != null ? quiz.getTitle() : "null") +
                '}';
    }
}
