using System.ComponentModel.DataAnnotations;

namespace MedicalCareSystem.Frontend.Models
{
    public class Appointment
    {
        public int Id { get; set; }

        [Required]
        public int PatientId { get; set; }

        [Required]
        public int DoctorId { get; set; }

        [Required]
        public DateTime AppointmentDateTime { get; set; }

        [Required]
        [StringLength(50)]
        public string? Status { get; set; } = "Scheduled"; // Scheduled, Confirmed, Completed, Cancelled

        [StringLength(100)]
        public string? AppointmentType { get; set; } // Consultation, Follow-up, Emergency, etc.

        [StringLength(1000)]
        public string? Reason { get; set; }

        [StringLength(500)]
        public string? Notes { get; set; }

        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }

        // Navigation properties
        public Patient? Patient { get; set; }
        public Doctor? Doctor { get; set; }

        // Computed properties
        public string FormattedDate => AppointmentDateTime.ToString("MMM dd, yyyy");
        public string FormattedTime => AppointmentDateTime.ToString("hh:mm tt");
        public string StatusColor => Status?.ToLower() switch
        {
            "scheduled" => "warning",
            "confirmed" => "success",
            "completed" => "info",
            "cancelled" => "danger",
            _ => "secondary"
        };
        public string PatientName => Patient?.FullName ?? "Unknown Patient";
        public string DoctorName => Doctor?.FullName ?? "Unknown Doctor";
    }
}
