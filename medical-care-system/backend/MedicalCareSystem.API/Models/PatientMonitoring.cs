using System.ComponentModel.DataAnnotations;

namespace MedicalCareSystem.API.Models
{
    public class PatientMonitoring
    {
        [Key]
        public int Id { get; set; }
        
        public int PatientId { get; set; }
        public Patient Patient { get; set; } = null!;
        
        // Vital Signs
        public double BloodPressureSystolic { get; set; }
        public double BloodPressureDiastolic { get; set; }
        public double HeartRate { get; set; }
        public double Temperature { get; set; }
        public double RespiratoryRate { get; set; }
        public double OxygenSaturation { get; set; }
        public double BloodGlucose { get; set; }
        public double Weight { get; set; }
        
        // Monitoring Information
        public DateTime RecordedAt { get; set; } = DateTime.UtcNow;
        public DateTime Timestamp { get; set; } = DateTime.UtcNow; // For controller compatibility
        public string RecordedBy { get; set; } = string.Empty; // Staff member or device
        public string Notes { get; set; } = string.Empty;
        public string MonitoringType { get; set; } = string.Empty; // Manual, Automated, Continuous
        public string Location { get; set; } = string.Empty; // Physical location during monitoring
        
        // Alert Information
        public bool HasAlerts { get; set; } = false;
        public bool IsAbnormal { get; set; } = false; // For controller compatibility
        public string AlertLevel { get; set; } = string.Empty; // Normal, Warning, Critical
        public string AlertReason { get; set; } = string.Empty;
        
        // Device Information
        public string DeviceId { get; set; } = string.Empty;
        public string DeviceType { get; set; } = string.Empty;
        public bool IsDeviceCalibrated { get; set; } = true;
        
        // Quality Indicators
        public string DataQuality { get; set; } = "Good"; // Good, Fair, Poor
        public bool IsVerified { get; set; } = false;
        public DateTime? VerifiedAt { get; set; }
        public string VerifiedBy { get; set; } = string.Empty;
    }
}