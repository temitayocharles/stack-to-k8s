using System.ComponentModel.DataAnnotations;

namespace MedicalCareSystem.Frontend.Models
{
    public class MedicalRecord
    {
        public int Id { get; set; }

        [Required]
        public int PatientId { get; set; }

        [Required]
        public int DoctorId { get; set; }

        [Required]
        public DateTime RecordDate { get; set; }

        [Required]
        [StringLength(100)]
        public string? RecordType { get; set; } // Diagnosis, Prescription, Lab Results, etc.

        [Required]
        [StringLength(1000)]
        public string? Description { get; set; }

        [StringLength(2000)]
        public string? Details { get; set; }

        [StringLength(500)]
        public string? Diagnosis { get; set; }

        [StringLength(1000)]
        public string? Treatment { get; set; }

        [StringLength(500)]
        public string? Medications { get; set; }

        [StringLength(1000)]
        public string? Notes { get; set; }

        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }

        // Navigation properties
        public Patient? Patient { get; set; }
        public Doctor? Doctor { get; set; }

        // Computed properties
        public string FormattedDate => RecordDate.ToString("MMM dd, yyyy");
        public string RecordTypeColor => RecordType?.ToLower() switch
        {
            "diagnosis" => "danger",
            "prescription" => "success",
            "lab results" => "info",
            "consultation" => "primary",
            "treatment" => "warning",
            "follow-up" => "secondary",
            _ => "secondary"
        };
        public string PatientName => Patient?.FullName ?? "Unknown Patient";
        public string DoctorName => Doctor?.FullName ?? "Unknown Doctor";
    }
}
