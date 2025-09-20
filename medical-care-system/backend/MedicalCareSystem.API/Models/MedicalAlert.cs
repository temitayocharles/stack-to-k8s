using System.ComponentModel.DataAnnotations;

namespace MedicalCareSystem.API.Models
{
    public class MedicalAlert
    {
        [Key]
        public int Id { get; set; }
        
        public int PatientId { get; set; }
        public Patient Patient { get; set; } = null!;
        
        // Alert Classification
        public string AlertType { get; set; } = string.Empty; // VitalSigns, Medication, Allergy, Critical, Emergency
        public string Severity { get; set; } = string.Empty; // Low, Medium, High, Critical
        public string Priority { get; set; } = string.Empty; // Routine, Urgent, Emergency
        
        // Alert Content
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string DetailedMessage { get; set; } = string.Empty;
        
        // Source Information
        public string Source { get; set; } = string.Empty; // System, Device, Manual, AI
        public string SourceDetails { get; set; } = string.Empty;
        public string TriggerData { get; set; } = string.Empty; // For controller compatibility - JSON data that triggered the alert
        public string TriggerValue { get; set; } = string.Empty;
        public string NormalRange { get; set; } = string.Empty;
        
        // Timing
        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
        public DateTime? AcknowledgedAt { get; set; }
        public DateTime? ResolvedAt { get; set; }
        public DateTime? EscalatedAt { get; set; }
        
        // Status and Resolution
        public bool IsAcknowledged { get; set; } = false;
        public bool IsResolved { get; set; } = false;
        public bool IsEscalated { get; set; } = false;
        public string ResolutionNotes { get; set; } = string.Empty;
        public string ActionTaken { get; set; } = string.Empty;
        
        // Assignment and Responsibility
        public string AssignedTo { get; set; } = string.Empty;
        public string AssignedRole { get; set; } = string.Empty; // Doctor, Nurse, Technician
        public string AcknowledgedBy { get; set; } = string.Empty;
        public string ResolvedBy { get; set; } = string.Empty;
        
        // Related Information
        public int? RelatedAppointmentId { get; set; }
        public int? RelatedMonitoringId { get; set; }
        public string RelatedMedication { get; set; } = string.Empty;
        public string RelatedProcedure { get; set; } = string.Empty;
        
        // Communication
        public bool NotificationSent { get; set; } = false;
        public DateTime? NotificationSentAt { get; set; }
        public string NotificationMethod { get; set; } = string.Empty; // Email, SMS, Call, InApp
        public string NotificationRecipients { get; set; } = string.Empty;
        
        // Auto-resolution
        public bool CanAutoResolve { get; set; } = false;
        public DateTime? AutoResolveAt { get; set; }
        public string AutoResolveCondition { get; set; } = string.Empty;
        
        // Escalation Rules
        public int EscalationLevel { get; set; } = 0;
        public DateTime? NextEscalationAt { get; set; }
        public string EscalationPath { get; set; } = string.Empty;
        
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}