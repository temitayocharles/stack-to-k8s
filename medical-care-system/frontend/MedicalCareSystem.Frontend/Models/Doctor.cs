using System.ComponentModel.DataAnnotations;

namespace MedicalCareSystem.Frontend.Models
{
    public class Doctor
    {
        public int Id { get; set; }

        [Required]
        [StringLength(100)]
        public string? FirstName { get; set; }

        [Required]
        [StringLength(100)]
        public string? LastName { get; set; }

        [Required]
        [EmailAddress]
        public string? Email { get; set; }

        [Phone]
        public string? PhoneNumber { get; set; }

        [Required]
        [StringLength(100)]
        public string? Specialty { get; set; }

        [Required]
        [StringLength(50)]
        public string? LicenseNumber { get; set; }

        [StringLength(500)]
        public string? Qualifications { get; set; }

        public int YearsOfExperience { get; set; }

        [StringLength(500)]
        public string? Bio { get; set; }

        public bool IsAvailable { get; set; } = true;

        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }

        // Navigation properties
        public List<Appointment>? Appointments { get; set; }
        public List<MedicalRecord>? MedicalRecords { get; set; }

        // Computed properties
        public string FullName => $"{FirstName} {LastName}";
        public string DisplaySpecialty => $"{Specialty} ({YearsOfExperience} years exp.)";
    }
}
