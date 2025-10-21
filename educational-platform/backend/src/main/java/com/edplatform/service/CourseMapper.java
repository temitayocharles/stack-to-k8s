package com.edplatform.service;

import com.edplatform.dto.CourseCreateRequest;
import com.edplatform.dto.CourseResponse;
import com.edplatform.dto.CourseUpdateRequest;
import com.edplatform.entity.Course;
import org.mapstruct.*;

@Mapper(componentModel = "spring")
public interface CourseMapper {

    @Mapping(target = "instructorName", source = "instructor.firstName")
    @Mapping(target = "instructorLastName", source = "instructor.lastName")
    @Mapping(target = "enrollmentCount", expression = "java(course.getCurrentEnrollmentCount())")
    @Mapping(target = "lessonCount", expression = "java(course.getTotalLessons())")
    @Mapping(target = "quizCount", expression = "java(course.getTotalQuizzes())")
    @Mapping(target = "assignmentCount", expression = "java(course.getTotalAssignments())")
    CourseResponse toResponse(Course course);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "instructor", ignore = true)
    @Mapping(target = "status", ignore = true)
    @Mapping(target = "rating", ignore = true)
    @Mapping(target = "totalRatings", ignore = true)
    @Mapping(target = "lessons", ignore = true)
    @Mapping(target = "enrollments", ignore = true)
    @Mapping(target = "quizzes", ignore = true)
    @Mapping(target = "assignments", ignore = true)
    @Mapping(target = "reviews", ignore = true)
    @Mapping(target = "tags", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    Course toEntity(CourseCreateRequest request);

    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "courseCode", ignore = true)
    @Mapping(target = "instructor", ignore = true)
    @Mapping(target = "rating", ignore = true)
    @Mapping(target = "totalRatings", ignore = true)
    @Mapping(target = "lessons", ignore = true)
    @Mapping(target = "enrollments", ignore = true)
    @Mapping(target = "quizzes", ignore = true)
    @Mapping(target = "assignments", ignore = true)
    @Mapping(target = "reviews", ignore = true)
    @Mapping(target = "tags", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    void updateEntity(@MappingTarget Course course, CourseUpdateRequest request);
}
