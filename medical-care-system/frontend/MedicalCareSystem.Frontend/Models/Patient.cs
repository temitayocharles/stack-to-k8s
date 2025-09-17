using System.ComponentModel.DataAnnotations;

namespace MedicalCareSystem.Frontend.Models
{
    public class Patient
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
        public DateTime DateOfBirth { get; set; }

        [StringLength(10)]
        public string? Gender { get; set; }

        [StringLength(500)]
        public string? Address { get; set; }

        [StringLength(50)]
        public string? EmergencyContact { get; set; }

        [Phone]
        public string? EmergencyContactPhone { get; set; }

        [StringLength(20)]
        public string? BloodType { get; set; }

        [StringLength(500)]
        public string? Allergies { get; set; }

        [StringLength(500)]
        public string? MedicalConditions { get; set; }

        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }

        // Navigation properties
        public List<Appointment>? Appointments { get; set; }
        public List<MedicalRecord>? MedicalRecords { get; set; }

        // Computed properties
        public string FullName => $"{FirstName} {LastName}";
        public int Age => DateTime.Now.Year - DateOfBirth.Year -
                         (DateTime.Now.DayOfYear < DateOfBirth.DayOfYear ? 1 : 0);
    }
}
