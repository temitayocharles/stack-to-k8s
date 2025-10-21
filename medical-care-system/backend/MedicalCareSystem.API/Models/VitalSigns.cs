using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MedicalCareSystem.API.Models
{
    public class VitalSigns
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int PatientId { get; set; }

        public int? MedicalRecordId { get; set; }

        [Column(TypeName = "decimal(4,1)")]
        public decimal? Temperature { get; set; } // in Celsius

        public int? SystolicBP { get; set; } // Systolic Blood Pressure
        public int? DiastolicBP { get; set; } // Diastolic Blood Pressure

        public int? HeartRate { get; set; } // Beats per minute
        public int? RespiratoryRate { get; set; } // Breaths per minute

        [Column(TypeName = "decimal(5,2)")]
        public decimal? Weight { get; set; } // in kg

        [Column(TypeName = "decimal(5,2)")]
        public decimal? Height { get; set; } // in cm

        [Column(TypeName = "decimal(4,1)")]
        public decimal? BMI { get; set; } // Body Mass Index

        [Column(TypeName = "decimal(4,1)")]
        public decimal? OxygenSaturation { get; set; } // SpO2 percentage

        [Column(TypeName = "decimal(4,1)")]
        public decimal? BloodGlucose { get; set; } // mg/dL

        [StringLength(500)]
        public string Notes { get; set; } = string.Empty;

        public DateTime RecordedAt { get; set; } = DateTime.UtcNow;

        [StringLength(100)]
        public string RecordedBy { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        [ForeignKey("PatientId")]
        public virtual Patient? Patient { get; set; }

        [ForeignKey("MedicalRecordId")]
        public virtual MedicalRecord? MedicalRecord { get; set; }
    }
}
