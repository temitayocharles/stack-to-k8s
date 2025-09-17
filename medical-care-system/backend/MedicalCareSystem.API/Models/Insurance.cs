using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MedicalCareSystem.API.Models
{
    public class Insurance
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int PatientId { get; set; }

        [Required]
        [StringLength(200)]
        public string ProviderName { get; set; } = string.Empty;

        [Required]
        [StringLength(100)]
        public string PolicyNumber { get; set; } = string.Empty;

        [StringLength(100)]
        public string GroupNumber { get; set; } = string.Empty;

        [StringLength(100)]
        public string PlanType { get; set; } = string.Empty;

        [StringLength(2000)]
        public string CoverageDetails { get; set; } = string.Empty;

        [Column(TypeName = "decimal(5,2)")]
        public decimal CoveragePercentage { get; set; } = 0;

        [Column(TypeName = "decimal(10,2)")]
        public decimal Deductible { get; set; } = 0;

        [Column(TypeName = "decimal(10,2)")]
        public decimal MaxCoverage { get; set; } = 0;

        public DateTime EffectiveDate { get; set; }
        public DateTime? ExpiryDate { get; set; }

        public bool IsActive { get; set; } = true;
        public bool IsPrimary { get; set; } = true;

        [StringLength(500)]
        public string Notes { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        // Navigation properties
        [ForeignKey("PatientId")]
        public virtual Patient? Patient { get; set; }

        public virtual ICollection<Billing>? Billings { get; set; }
    }
}
