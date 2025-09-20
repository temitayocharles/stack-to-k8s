using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MedicalCareSystem.API.Models
{
    public class Patient
    {
        [Key]
        public int Id { get; set; }

        [StringLength(20)]
        public string PatientNumber { get; set; } = string.Empty;

        [Required]
        [StringLength(100)]
        public string FirstName { get; set; } = string.Empty;

        [Required]
        [StringLength(100)]
        public string LastName { get; set; } = string.Empty;

        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Phone]
        public string PhoneNumber { get; set; }

        [Required]
        public DateTime DateOfBirth { get; set; }

        [StringLength(10)]
        public string Gender { get; set; }

        [StringLength(500)]
        public string Address { get; set; }

        [StringLength(50)]
        public string EmergencyContact { get; set; }

        [Phone]
        public string EmergencyContactPhone { get; set; }

        [StringLength(20)]
        public string BloodType { get; set; }

        [StringLength(500)]
        public string Allergies { get; set; }

        [StringLength(500)]
        public string MedicalConditions { get; set; }

        [StringLength(100)]
        public string Department { get; set; } = "General";

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        // Navigation properties
        public virtual ICollection<Appointment>? Appointments { get; set; }
        public virtual ICollection<MedicalRecord>? MedicalRecords { get; set; }
        public virtual ICollection<Prescription>? Prescriptions { get; set; }
        public virtual ICollection<Billing>? Billings { get; set; }
        public virtual ICollection<Insurance>? Insurances { get; set; }
        public virtual ICollection<VitalSigns>? VitalSigns { get; set; }
        public virtual ICollection<Lab>? Labs { get; set; }
        public virtual ICollection<Imaging>? Imaging { get; set; }
    }
}
