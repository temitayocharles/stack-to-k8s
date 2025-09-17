using System.ComponentModel.DataAnnotations;

namespace MedicalCareSystem.API.Models
{
    public class Medication
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [StringLength(200)]
        public string Name { get; set; } = string.Empty;

        [StringLength(200)]
        public string GenericName { get; set; } = string.Empty;

        [StringLength(200)]
        public string Manufacturer { get; set; } = string.Empty;

        [Required]
        [StringLength(50)]
        public string Form { get; set; } = string.Empty; // Tablet, Capsule, Liquid, etc.

        [StringLength(50)]
        public string Strength { get; set; } = string.Empty;

        [StringLength(2000)]
        public string SideEffects { get; set; } = string.Empty;

        [StringLength(2000)]
        public string Warnings { get; set; } = string.Empty;

        [StringLength(2000)]
        public string Contraindications { get; set; } = string.Empty;

        [StringLength(1000)]
        public string StorageInstructions { get; set; } = string.Empty;

        public decimal Price { get; set; } = 0;

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        // Navigation properties
        public virtual ICollection<Prescription>? Prescriptions { get; set; }
    }
}
