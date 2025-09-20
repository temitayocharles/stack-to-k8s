using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MedicalCareSystem.API.Models
{
    public class Appointment
    {
        [Key]
        public int Id { get; set; }

        [StringLength(20)]
        public string AppointmentNumber { get; set; } = string.Empty;

        [Required]
        public int PatientId { get; set; }

        [Required]
        public int DoctorId { get; set; }

        public int? RoomId { get; set; }

        [Required]
        public DateTime AppointmentDate { get; set; }

        [Required]
        public TimeSpan Duration { get; set; } = TimeSpan.FromMinutes(30);

        [Required]
        [StringLength(50)]
        public string Type { get; set; } = "Consultation"; // Consultation, Follow-up, Emergency, etc.

        [Required]
        [StringLength(20)]
        public string Status { get; set; } = "Scheduled"; // Scheduled, Confirmed, Completed, Cancelled, No-Show

        [StringLength(500)]
        public string Reason { get; set; } = string.Empty;

        [StringLength(1000)]
        public string Notes { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        // Navigation properties
        [ForeignKey("PatientId")]
        public virtual Patient? Patient { get; set; }

        [ForeignKey("DoctorId")]
        public virtual Doctor? Doctor { get; set; }

        [ForeignKey("RoomId")]
        public virtual Room? Room { get; set; }

        public virtual ICollection<MedicalRecord>? MedicalRecords { get; set; }
        public virtual ICollection<Billing>? Billings { get; set; }
    }
}
