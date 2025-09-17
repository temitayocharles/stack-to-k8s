using System.ComponentModel.DataAnnotations;

namespace MedicalCareSystem.API.Models
{
    public class Department
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [StringLength(100)]
        public string Name { get; set; } = string.Empty;

        [Required]
        [StringLength(10)]
        public string Code { get; set; } = string.Empty;

        [StringLength(500)]
        public string Description { get; set; } = string.Empty;

        [StringLength(200)]
        public string Location { get; set; } = string.Empty;

        [StringLength(20)]
        public string PhoneNumber { get; set; } = string.Empty;

        [EmailAddress]
        [StringLength(255)]
        public string Email { get; set; } = string.Empty;

        public int? HeadDoctorId { get; set; }

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        // Navigation properties
        public virtual ICollection<Doctor>? Doctors { get; set; }
        public virtual ICollection<Room>? Rooms { get; set; }
    }
}
