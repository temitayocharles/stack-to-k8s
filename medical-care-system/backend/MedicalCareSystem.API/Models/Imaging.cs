using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MedicalCareSystem.API.Models
{
    public class Imaging
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int PatientId { get; set; }

        [Required]
        public int DoctorId { get; set; }

        public int? MedicalRecordId { get; set; }

        [Required]
        [StringLength(100)]
        public string StudyType { get; set; } = string.Empty; // X-Ray, CT, MRI, Ultrasound, etc.

        [Required]
        [StringLength(100)]
        public string BodyPart { get; set; } = string.Empty;

        [StringLength(200)]
        public string StudyDescription { get; set; } = string.Empty;

        [StringLength(2000)]
        public string Findings { get; set; } = string.Empty;

        [StringLength(1000)]
        public string Impression { get; set; } = string.Empty;

        [Required]
        [StringLength(20)]
        public string Status { get; set; } = "Ordered"; // Ordered, In Progress, Completed, Cancelled

        [StringLength(20)]
        public string Priority { get; set; } = "Normal"; // Urgent, STAT, Normal

        [StringLength(500)]
        public string ImageUrl { get; set; } = string.Empty;

        [StringLength(500)]
        public string ReportUrl { get; set; } = string.Empty;

        public DateTime OrderedDate { get; set; } = DateTime.UtcNow;
        public DateTime? ScheduledDate { get; set; }
        public DateTime? CompletedDate { get; set; }

        [StringLength(100)]
        public string Technician { get; set; } = string.Empty;

        [StringLength(100)]
        public string Radiologist { get; set; } = string.Empty;

        [StringLength(100)]
        public string Equipment { get; set; } = string.Empty;

        [StringLength(1000)]
        public string Notes { get; set; } = string.Empty;

        public bool IsUrgent { get; set; } = false;
        public bool RequiresContrast { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        // Navigation properties
        [ForeignKey("PatientId")]
        public virtual Patient? Patient { get; set; }

        [ForeignKey("DoctorId")]
        public virtual Doctor? Doctor { get; set; }

        [ForeignKey("MedicalRecordId")]
        public virtual MedicalRecord? MedicalRecord { get; set; }
    }
}
