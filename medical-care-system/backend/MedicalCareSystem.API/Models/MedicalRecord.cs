using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MedicalCareSystem.API.Models
{
    public class MedicalRecord
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [StringLength(20)]
        public string RecordNumber { get; set; } = string.Empty;

        [Required]
        public int PatientId { get; set; }

        [Required]
        public int DoctorId { get; set; }

        public int? AppointmentId { get; set; }

        [Required]
        public DateTime RecordDate { get; set; }

        [Required]
        [StringLength(50)]
        public string VisitType { get; set; } = string.Empty; // Consultation, Follow-up, Emergency, etc.

        [Required]
        [StringLength(1000)]
        public string Diagnosis { get; set; } = string.Empty;

        [StringLength(2000)]
        public string Treatment { get; set; } = string.Empty;

        [StringLength(2000)]
        public string Notes { get; set; } = string.Empty;

        [StringLength(500)]
        public string ChiefComplaint { get; set; } = string.Empty;

        [StringLength(1000)]
        public string HistoryOfPresentIllness { get; set; } = string.Empty;

        [StringLength(500)]
        public string PhysicalExamination { get; set; } = string.Empty;

        [StringLength(500)]
        public string Assessment { get; set; } = string.Empty;

        [StringLength(500)]
        public string Plan { get; set; } = string.Empty;

        public DateTime? FollowUpDate { get; set; }

        [StringLength(1000)]
        public string FollowUpInstructions { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        // Navigation properties
        [ForeignKey("PatientId")]
        public virtual Patient? Patient { get; set; }

        [ForeignKey("DoctorId")]
        public virtual Doctor? Doctor { get; set; }

        [ForeignKey("AppointmentId")]
        public virtual Appointment? Appointment { get; set; }

        public virtual ICollection<Prescription>? Prescriptions { get; set; }
        public virtual ICollection<VitalSigns>? VitalSigns { get; set; }
        public virtual ICollection<Lab>? Labs { get; set; }
        public virtual ICollection<Imaging>? Imaging { get; set; }
    }
}
