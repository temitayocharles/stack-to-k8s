package com.edplatform.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDateTime;
import java.util.Objects;

@Entity
@Table(name = "enrollments")
public class Enrollment extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_id", nullable = false)
    private User student;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    @NotNull(message = "Enrollment status is required")
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private EnrollmentStatus status = EnrollmentStatus.ACTIVE;

    @Column(name = "enrollment_date", nullable = false)
    private LocalDateTime enrollmentDate;

    @Column(name = "completion_date")
    private LocalDateTime completionDate;

    @Column(name = "progress_percentage", nullable = false)
    private Double progressPercentage = 0.0;

    @Column(name = "last_accessed")
    private LocalDateTime lastAccessed;

    @Column(name = "certificate_issued", nullable = false)
    private Boolean certificateIssued = false;

    @Column(name = "certificate_url")
    private String certificateUrl;

    @Column(name = "final_grade")
    private Double finalGrade;

    @Column(name = "payment_status", nullable = false)
    @Enumerated(EnumType.STRING)
    private PaymentStatus paymentStatus = PaymentStatus.PENDING;

    @Column(name = "payment_amount", precision = 10, scale = 2)
    private java.math.BigDecimal paymentAmount;

    @Column(name = "payment_date")
    private LocalDateTime paymentDate;

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;

    // Constructors
    public Enrollment() {
        this.enrollmentDate = LocalDateTime.now();
    }

    public Enrollment(User student, Course course) {
        this();
        this.student = student;
        this.course = course;
        this.paymentAmount = course.getPrice();
    }

    // Business methods
    public boolean isActive() {
        return status == EnrollmentStatus.ACTIVE;
    }

    public boolean isCompleted() {
        return status == EnrollmentStatus.COMPLETED;
    }

    public boolean isDropped() {
        return status == EnrollmentStatus.DROPPED;
    }

    public boolean isSuspended() {
        return status == EnrollmentStatus.SUSPENDED;
    }

    public boolean isPaid() {
        return paymentStatus == PaymentStatus.PAID;
    }

    public boolean isPaymentPending() {
        return paymentStatus == PaymentStatus.PENDING;
    }

    public void markAsCompleted() {
        this.status = EnrollmentStatus.COMPLETED;
        this.completionDate = LocalDateTime.now();
        this.progressPercentage = 100.0;
    }

    public void markAsPaid(java.math.BigDecimal amount) {
        this.paymentStatus = PaymentStatus.PAID;
        this.paymentAmount = amount;
        this.paymentDate = LocalDateTime.now();
    }

    public void updateProgress(double percentage) {
        if (percentage < 0.0) percentage = 0.0;
        if (percentage > 100.0) percentage = 100.0;
        
        this.progressPercentage = percentage;
        this.lastAccessed = LocalDateTime.now();
        
        if (percentage >= 100.0 && !isCompleted()) {
            markAsCompleted();
        }
    }

    public void issueCertificate(String certificateUrl) {
        this.certificateIssued = true;
        this.certificateUrl = certificateUrl;
    }

    // Getters and Setters
    public User getStudent() {
        return student;
    }

    public void setStudent(User student) {
        this.student = student;
    }

    public Course getCourse() {
        return course;
    }

    public void setCourse(Course course) {
        this.course = course;
    }

    public EnrollmentStatus getStatus() {
        return status;
    }

    public void setStatus(EnrollmentStatus status) {
        this.status = status;
    }

    public LocalDateTime getEnrollmentDate() {
        return enrollmentDate;
    }

    public void setEnrollmentDate(LocalDateTime enrollmentDate) {
        this.enrollmentDate = enrollmentDate;
    }

    public LocalDateTime getCompletionDate() {
        return completionDate;
    }

    public void setCompletionDate(LocalDateTime completionDate) {
        this.completionDate = completionDate;
    }

    public Double getProgressPercentage() {
        return progressPercentage;
    }

    public void setProgressPercentage(Double progressPercentage) {
        this.progressPercentage = progressPercentage;
    }

    public LocalDateTime getLastAccessed() {
        return lastAccessed;
    }

    public void setLastAccessed(LocalDateTime lastAccessed) {
        this.lastAccessed = lastAccessed;
    }

    public Boolean getCertificateIssued() {
        return certificateIssued;
    }

    public void setCertificateIssued(Boolean certificateIssued) {
        this.certificateIssued = certificateIssued;
    }

    public String getCertificateUrl() {
        return certificateUrl;
    }

    public void setCertificateUrl(String certificateUrl) {
        this.certificateUrl = certificateUrl;
    }

    public Double getFinalGrade() {
        return finalGrade;
    }

    public void setFinalGrade(Double finalGrade) {
        this.finalGrade = finalGrade;
    }

    public PaymentStatus getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(PaymentStatus paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public java.math.BigDecimal getPaymentAmount() {
        return paymentAmount;
    }

    public void setPaymentAmount(java.math.BigDecimal paymentAmount) {
        this.paymentAmount = paymentAmount;
    }

    public LocalDateTime getPaymentDate() {
        return paymentDate;
    }

    public void setPaymentDate(LocalDateTime paymentDate) {
        this.paymentDate = paymentDate;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Enrollment)) return false;
        Enrollment that = (Enrollment) o;
        return Objects.equals(student, that.student) && Objects.equals(course, that.course);
    }

    @Override
    public int hashCode() {
        return Objects.hash(student, course);
    }

    @Override
    public String toString() {
        return "Enrollment{" +
                "id=" + getId() +
                ", student=" + (student != null ? student.getFullName() : "null") +
                ", course=" + (course != null ? course.getTitle() : "null") +
                ", status=" + status +
                ", progressPercentage=" + progressPercentage +
                '}';
    }
}
