package com.edplatform.dto.course;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Course Data Transfer Object
 * Used for transferring course information between layers
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CourseDto {

    private Long id;

    @NotBlank(message = "Course title is required")
    @Size(min = 3, max = 100, message = "Course title must be between 3 and 100 characters")
    private String title;

    @NotBlank(message = "Course description is required")
    @Size(min = 10, max = 1000, message = "Course description must be between 10 and 1000 characters")
    private String description;

    @NotNull(message = "Category is required")
    private String category;

    @NotNull(message = "Difficulty level is required")
    private String difficultyLevel;

    private String imageUrl;

    @NotNull(message = "Price is required")
    private Double price;

    private Integer duration; // in hours

    @NotNull(message = "Instructor ID is required")
    private Long instructorId;

    private String instructorName;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    private Boolean isPublished;

    private List<LessonDto> lessons;

    private Integer enrollmentCount;

    private Double averageRating;

    private List<String> tags;

    private String requirements;

    private String whatYouWillLearn;

    /**
     * Nested DTO for lesson information
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class LessonDto {
        private Long id;
        private String title;
        private String description;
        private Integer orderNumber;
        private Integer duration; // in minutes
        private String videoUrl;
        private String contentType;
        private Boolean isCompleted;
    }
}
