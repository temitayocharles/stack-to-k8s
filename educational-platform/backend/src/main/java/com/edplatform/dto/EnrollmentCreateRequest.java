package com.edplatform.dto;

import jakarta.validation.constraints.NotNull;

public class EnrollmentCreateRequest {

    @NotNull(message = "Course ID is required")
    private Long courseId;

    // Constructors
    public EnrollmentCreateRequest() {}

    public EnrollmentCreateRequest(Long courseId) {
        this.courseId = courseId;
    }

    // Getters and Setters
    public Long getCourseId() {
        return courseId;
    }

    public void setCourseId(Long courseId) {
        this.courseId = courseId;
    }
}
