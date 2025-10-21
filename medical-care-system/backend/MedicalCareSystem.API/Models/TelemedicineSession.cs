using System.ComponentModel.DataAnnotations;

namespace MedicalCareSystem.API.Models
{
    public class TelemedicineSession
    {
        [Key]
        public int Id { get; set; }
        
        public int PatientId { get; set; }
        public Patient Patient { get; set; } = null!;
        
        public int DoctorId { get; set; }
        public Doctor Doctor { get; set; } = null!;
        
        // Session Details
        public DateTime ScheduledAt { get; set; }
        public DateTime ScheduledTime { get; set; } // For controller compatibility
        public DateTime? StartedAt { get; set; }
        public DateTime? StartTime { get; set; } // For controller compatibility
        public DateTime? EndedAt { get; set; }
        public DateTime? EndTime { get; set; } // For controller compatibility
        public int DurationMinutes { get; set; }
        
        // Session Status
        public string Status { get; set; } = "Scheduled"; // Scheduled, InProgress, Completed, Cancelled, NoShow
        public string SessionType { get; set; } = string.Empty; // Consultation, FollowUp, Emergency, Routine
        public string Platform { get; set; } = string.Empty; // Zoom, Teams, Custom
        
        // Session Results
        public bool PrescriptionIssued { get; set; } = false; // For controller compatibility
        public bool FollowUpRequired { get; set; } = false; // For controller compatibility
        
        // Connection Details
        public string SessionUrl { get; set; } = string.Empty;
        public string SessionId { get; set; } = string.Empty;
        public string MeetingRoomId { get; set; } = string.Empty; // For controller compatibility
        public string ConnectionToken { get; set; } = string.Empty; // For controller compatibility
        public string AccessCode { get; set; } = string.Empty;
        
        // Session Content
        public string ChiefComplaint { get; set; } = string.Empty;
        public string SessionNotes { get; set; } = string.Empty;
        public string Diagnosis { get; set; } = string.Empty;
        public string TreatmentPlan { get; set; } = string.Empty;
        public string Prescriptions { get; set; } = string.Empty;
        
        // Technical Information
        public string ConnectionQuality { get; set; } = "Good"; // Excellent, Good, Fair, Poor
        public bool AudioQuality { get; set; } = true;
        public bool VideoQuality { get; set; } = true;
        public string TechnicalIssues { get; set; } = string.Empty;
        
        // Follow-up
        public bool RequiresFollowUp { get; set; } = false;
        // Note: FollowUpRequired added above for controller compatibility
        public DateTime? FollowUpDate { get; set; }
        public string FollowUpInstructions { get; set; } = string.Empty;
        
        // Billing and Documentation
        public decimal ConsultationFee { get; set; }
        public bool IsBilled { get; set; } = false;
        public bool DocumentsShared { get; set; } = false;
        public string SharedDocuments { get; set; } = string.Empty;
        
        // Ratings and Feedback
        public int? PatientRating { get; set; } // 1-5 stars
        public string PatientFeedback { get; set; } = string.Empty;
        public int? DoctorRating { get; set; } // 1-5 stars
        public string DoctorFeedback { get; set; } = string.Empty;
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}