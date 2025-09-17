package com.edplatform.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.Objects;

@Entity
@Table(name = "question_options")
public class QuestionOption extends BaseEntity {

    @NotBlank(message = "Option text is required")
    @Column(name = "option_text", nullable = false, columnDefinition = "TEXT")
    private String optionText;

    @NotNull(message = "Option order is required")
    @Column(name = "option_order", nullable = false)
    private Integer optionOrder;

    @Column(name = "is_correct", nullable = false)
    private Boolean isCorrect = false;

    @Column(name = "explanation", columnDefinition = "TEXT")
    private String explanation;

    @Column(name = "image_url")
    private String imageUrl;

    // For matching questions - the value this option matches to
    @Column(name = "match_value")
    private String matchValue;

    // Relationships
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "question_id", nullable = false)
    private Question question;

    // Constructors
    public QuestionOption() {}

    public QuestionOption(String optionText, Integer optionOrder, Question question) {
        this.optionText = optionText;
        this.optionOrder = optionOrder;
        this.question = question;
    }

    public QuestionOption(String optionText, Integer optionOrder, Boolean isCorrect, Question question) {
        this(optionText, optionOrder, question);
        this.isCorrect = isCorrect;
    }

    // Business methods
    public boolean isCorrectAnswer() {
        return isCorrect != null && isCorrect;
    }

    // Getters and Setters
    public String getOptionText() {
        return optionText;
    }

    public void setOptionText(String optionText) {
        this.optionText = optionText;
    }

    public Integer getOptionOrder() {
        return optionOrder;
    }

    public void setOptionOrder(Integer optionOrder) {
        this.optionOrder = optionOrder;
    }

    public Boolean getIsCorrect() {
        return isCorrect;
    }

    public void setIsCorrect(Boolean isCorrect) {
        this.isCorrect = isCorrect;
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

    public String getMatchValue() {
        return matchValue;
    }

    public void setMatchValue(String matchValue) {
        this.matchValue = matchValue;
    }

    public Question getQuestion() {
        return question;
    }

    public void setQuestion(Question question) {
        this.question = question;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof QuestionOption)) return false;
        QuestionOption that = (QuestionOption) o;
        return Objects.equals(question, that.question) && Objects.equals(optionOrder, that.optionOrder);
    }

    @Override
    public int hashCode() {
        return Objects.hash(question, optionOrder);
    }

    @Override
    public String toString() {
        return "QuestionOption{" +
                "id=" + getId() +
                ", optionOrder=" + optionOrder +
                ", isCorrect=" + isCorrect +
                ", question=" + (question != null ? question.getId() : "null") +
                '}';
    }
}
