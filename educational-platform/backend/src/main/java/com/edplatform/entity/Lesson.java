package com.edplatform.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.Objects;

@Entity
@Table(name = "lessons")
public class Lesson extends BaseEntity {

    @NotBlank(message = "Lesson title is required")
    @Size(max = 200, message = "Lesson title must not exceed 200 characters")
    @Column(name = "title", nullable = false, length = 200)
    private String title;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "content", columnDefinition = "TEXT")
    private String content;

    @NotNull(message = "Lesson order is required")
    @Column(name = "lesson_order", nullable = false)
    private Integer lessonOrder;

    @NotNull(message = "Lesson type is required")
    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false)
    private LessonType type;

    @Column(name = "video_url")
    private String videoUrl;

    @Column(name = "video_duration_seconds")
    private Integer videoDurationSeconds;

    @Column(name = "document_url")
    private String documentUrl;

    @Column(name = "external_link")
    private String externalLink;

    @Column(name = "is_preview", nullable = false)
    private Boolean isPreview = false;

    @Column(name = "is_mandatory", nullable = false)
    private Boolean isMandatory = true;

    @Column(name = "estimated_duration_minutes")
    private Integer estimatedDurationMinutes;

    @Column(name = "points_value")
    private Integer pointsValue = 0;

    @Column(name = "transcript", columnDefinition = "TEXT")
    private String transcript;

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;

    // Relationships
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "module_id")
    private Module module;

    // Constructors
    public Lesson() {}

    public Lesson(String title, Course course, Integer lessonOrder, LessonType type) {
        this.title = title;
        this.course = course;
        this.lessonOrder = lessonOrder;
        this.type = type;
    }

    // Business methods
    public boolean isVideoLesson() {
        return type == LessonType.VIDEO;
    }

    public boolean isTextLesson() {
        return type == LessonType.TEXT;
    }

    public boolean isQuizLesson() {
        return type == LessonType.QUIZ;
    }

    public boolean isAssignmentLesson() {
        return type == LessonType.ASSIGNMENT;
    }

    public boolean isExternalLesson() {
        return type == LessonType.EXTERNAL_LINK;
    }

    public boolean hasVideo() {
        return videoUrl != null && !videoUrl.trim().isEmpty();
    }

    public boolean hasDocument() {
        return documentUrl != null && !documentUrl.trim().isEmpty();
    }

    public String getFormattedDuration() {
        if (videoDurationSeconds == null) return "N/A";
        
        int hours = videoDurationSeconds / 3600;
        int minutes = (videoDurationSeconds % 3600) / 60;
        int seconds = videoDurationSeconds % 60;
        
        if (hours > 0) {
            return String.format("%d:%02d:%02d", hours, minutes, seconds);
        } else {
            return String.format("%d:%02d", minutes, seconds);
        }
    }

    public String getEstimatedDurationFormatted() {
        if (estimatedDurationMinutes == null) return "N/A";
        
        if (estimatedDurationMinutes >= 60) {
            int hours = estimatedDurationMinutes / 60;
            int minutes = estimatedDurationMinutes % 60;
            return hours + "h " + minutes + "m";
        } else {
            return estimatedDurationMinutes + "m";
        }
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

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public Integer getLessonOrder() {
        return lessonOrder;
    }

    public void setLessonOrder(Integer lessonOrder) {
        this.lessonOrder = lessonOrder;
    }

    public LessonType getType() {
        return type;
    }

    public void setType(LessonType type) {
        this.type = type;
    }

    public String getVideoUrl() {
        return videoUrl;
    }

    public void setVideoUrl(String videoUrl) {
        this.videoUrl = videoUrl;
    }

    public Integer getVideoDurationSeconds() {
        return videoDurationSeconds;
    }

    public void setVideoDurationSeconds(Integer videoDurationSeconds) {
        this.videoDurationSeconds = videoDurationSeconds;
    }

    public String getDocumentUrl() {
        return documentUrl;
    }

    public void setDocumentUrl(String documentUrl) {
        this.documentUrl = documentUrl;
    }

    public String getExternalLink() {
        return externalLink;
    }

    public void setExternalLink(String externalLink) {
        this.externalLink = externalLink;
    }

    public Boolean getIsPreview() {
        return isPreview;
    }

    public void setIsPreview(Boolean isPreview) {
        this.isPreview = isPreview;
    }

    public Boolean getIsMandatory() {
        return isMandatory;
    }

    public void setIsMandatory(Boolean isMandatory) {
        this.isMandatory = isMandatory;
    }

    public Integer getEstimatedDurationMinutes() {
        return estimatedDurationMinutes;
    }

    public void setEstimatedDurationMinutes(Integer estimatedDurationMinutes) {
        this.estimatedDurationMinutes = estimatedDurationMinutes;
    }

    public Integer getPointsValue() {
        return pointsValue;
    }

    public void setPointsValue(Integer pointsValue) {
        this.pointsValue = pointsValue;
    }

    public String getTranscript() {
        return transcript;
    }

    public void setTranscript(String transcript) {
        this.transcript = transcript;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public Course getCourse() {
        return course;
    }

    public void setCourse(Course course) {
        this.course = course;
    }

    public Module getModule() {
        return module;
    }

    public void setModule(Module module) {
        this.module = module;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Lesson)) return false;
        Lesson lesson = (Lesson) o;
        return Objects.equals(course, lesson.course) && Objects.equals(lessonOrder, lesson.lessonOrder);
    }

    @Override
    public int hashCode() {
        return Objects.hash(course, lessonOrder);
    }

    @Override
    public String toString() {
        return "Lesson{" +
                "id=" + getId() +
                ", title='" + title + '\'' +
                ", lessonOrder=" + lessonOrder +
                ", type=" + type +
                ", course=" + (course != null ? course.getTitle() : "null") +
                '}';
    }
}
