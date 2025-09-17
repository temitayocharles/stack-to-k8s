using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MedicalCareSystem.API.Models
{
    public class Lab
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int PatientId { get; set; }

        [Required]
        public int DoctorId { get; set; }

        public int? MedicalRecordId { get; set; }

        [Required]
        [StringLength(200)]
        public string TestName { get; set; } = string.Empty;

        [StringLength(50)]
        public string TestCode { get; set; } = string.Empty;

        [StringLength(100)]
        public string Category { get; set; } = string.Empty; // Blood, Urine, Imaging, etc.

        [StringLength(1000)]
        public string Result { get; set; } = string.Empty;

        [StringLength(200)]
        public string ReferenceRange { get; set; } = string.Empty;

        [StringLength(50)]
        public string Units { get; set; } = string.Empty;

        [Required]
        [StringLength(20)]
        public string Status { get; set; } = "Ordered"; // Ordered, In Progress, Completed, Cancelled

        public bool IsAbnormal { get; set; } = false;
        public bool IsCritical { get; set; } = false;

        [StringLength(20)]
        public string Priority { get; set; } = "Normal"; // Urgent, STAT, Normal

        public DateTime OrderedDate { get; set; } = DateTime.UtcNow;
        public DateTime? CollectedDate { get; set; }
        public DateTime? CompletedDate { get; set; }

        [StringLength(100)]
        public string PerformedBy { get; set; } = string.Empty;
        [StringLength(100)]
        public string ReviewedBy { get; set; } = string.Empty;

        [StringLength(1000)]
        public string Notes { get; set; } = string.Empty;

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
