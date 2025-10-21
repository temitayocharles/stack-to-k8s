using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MedicalCareSystem.API.Models
{
    public class Room
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [StringLength(20)]
        public string RoomNumber { get; set; } = string.Empty;

        [Required]
        [StringLength(50)]
        public string RoomType { get; set; } = string.Empty; // Consultation, Surgery, ICU, etc.

        [Required]
        public int Floor { get; set; }

        [StringLength(50)]
        public string Building { get; set; } = string.Empty;

        [Required]
        public int DepartmentId { get; set; }

        public int Capacity { get; set; } = 1;

        [StringLength(1000)]
        public string Equipment { get; set; } = string.Empty;

        [StringLength(500)]
        public string Notes { get; set; } = string.Empty;

        public bool IsAvailable { get; set; } = true;
        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        // Navigation properties
        [ForeignKey("DepartmentId")]
        public virtual Department? Department { get; set; }

        public virtual ICollection<Appointment>? Appointments { get; set; }
    }
}
