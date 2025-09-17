package com.edplatform.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.HashSet;
import java.util.Objects;
import java.util.Set;

@Entity
@Table(name = "modules")
public class Module extends BaseEntity {

    @NotBlank(message = "Module title is required")
    @Size(max = 200, message = "Module title must not exceed 200 characters")
    @Column(name = "title", nullable = false, length = 200)
    private String title;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @NotNull(message = "Module order is required")
    @Column(name = "module_order", nullable = false)
    private Integer moduleOrder;

    @Column(name = "estimated_duration_hours")
    private Integer estimatedDurationHours;

    @Column(name = "learning_objectives", columnDefinition = "TEXT")
    private String learningObjectives;

    @Column(name = "is_published", nullable = false)
    private Boolean isPublished = false;

    // Relationships
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    @OneToMany(mappedBy = "module", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @OrderBy("lessonOrder ASC")
    private Set<Lesson> lessons = new HashSet<>();

    // Constructors
    public Module() {}

    public Module(String title, Course course, Integer moduleOrder) {
        this.title = title;
        this.course = course;
        this.moduleOrder = moduleOrder;
    }

    // Business methods
    public int getTotalLessons() {
        return lessons.size();
    }

    public int getPublishedLessons() {
        // Assuming lessons have a published status, otherwise return all
        return lessons.size();
    }

    public boolean hasLessons() {
        return !lessons.isEmpty();
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

    public Integer getModuleOrder() {
        return moduleOrder;
    }

    public void setModuleOrder(Integer moduleOrder) {
        this.moduleOrder = moduleOrder;
    }

    public Integer getEstimatedDurationHours() {
        return estimatedDurationHours;
    }

    public void setEstimatedDurationHours(Integer estimatedDurationHours) {
        this.estimatedDurationHours = estimatedDurationHours;
    }

    public String getLearningObjectives() {
        return learningObjectives;
    }

    public void setLearningObjectives(String learningObjectives) {
        this.learningObjectives = learningObjectives;
    }

    public Boolean getIsPublished() {
        return isPublished;
    }

    public void setIsPublished(Boolean isPublished) {
        this.isPublished = isPublished;
    }

    public Course getCourse() {
        return course;
    }

    public void setCourse(Course course) {
        this.course = course;
    }

    public Set<Lesson> getLessons() {
        return lessons;
    }

    public void setLessons(Set<Lesson> lessons) {
        this.lessons = lessons;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Module)) return false;
        Module module = (Module) o;
        return Objects.equals(course, module.course) && Objects.equals(moduleOrder, module.moduleOrder);
    }

    @Override
    public int hashCode() {
        return Objects.hash(course, moduleOrder);
    }

    @Override
    public String toString() {
        return "Module{" +
                "id=" + getId() +
                ", title='" + title + '\'' +
                ", moduleOrder=" + moduleOrder +
                ", course=" + (course != null ? course.getTitle() : "null") +
                '}';
    }
}
