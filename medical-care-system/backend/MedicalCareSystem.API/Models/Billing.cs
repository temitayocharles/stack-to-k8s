using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MedicalCareSystem.API.Models
{
    public class Billing
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [StringLength(20)]
        public string BillNumber { get; set; } = string.Empty;

        [Required]
        public int PatientId { get; set; }

        public int? InsuranceId { get; set; }

        public int? AppointmentId { get; set; }

        [Column(TypeName = "decimal(10,2)")]
        public decimal TotalAmount { get; set; } = 0;

        [Column(TypeName = "decimal(10,2)")]
        public decimal PaidAmount { get; set; } = 0;

        [Column(TypeName = "decimal(10,2)")]
        public decimal OutstandingAmount { get; set; } = 0;

        [Column(TypeName = "decimal(10,2)")]
        public decimal InsuranceCoverage { get; set; } = 0;

        [Required]
        [StringLength(20)]
        public string Status { get; set; } = "Pending"; // Pending, Paid, Partial, Overdue

        [StringLength(50)]
        public string PaymentMethod { get; set; } = string.Empty; // Cash, Card, Insurance, etc.

        public DateTime BillDate { get; set; } = DateTime.UtcNow;
        public DateTime? DueDate { get; set; }
        public DateTime? PaidDate { get; set; }

        [StringLength(1000)]
        public string Notes { get; set; } = string.Empty;

        [StringLength(500)]
        public string Services { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        // Navigation properties
        [ForeignKey("PatientId")]
        public virtual Patient? Patient { get; set; }

        [ForeignKey("InsuranceId")]
        public virtual Insurance? Insurance { get; set; }

        [ForeignKey("AppointmentId")]
        public virtual Appointment? Appointment { get; set; }
    }
}
