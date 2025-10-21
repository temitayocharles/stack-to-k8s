package com.edplatform.service;

import com.edplatform.dto.EnrollmentResponse;
import com.edplatform.entity.Enrollment;
import org.mapstruct.*;

@Mapper(componentModel = "spring")
public interface EnrollmentMapper {

    @Mapping(target = "studentId", source = "student.id")
    @Mapping(target = "studentName", expression = "java(enrollment.getStudent().getFullName())")
    @Mapping(target = "studentEmail", source = "student.email")
    @Mapping(target = "courseId", source = "course.id")
    @Mapping(target = "courseCode", source = "course.courseCode")
    @Mapping(target = "courseTitle", source = "course.title")
    @Mapping(target = "instructorName", expression = "java(enrollment.getCourse().getInstructor().getFullName())")
    EnrollmentResponse toResponse(Enrollment enrollment);
}
