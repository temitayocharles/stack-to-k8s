using System.ComponentModel.DataAnnotations;

namespace MedicalCareSystem.API.Models
{
    public class AIAnalysis
    {
        [Key]
        public int Id { get; set; }
        
        public int PatientId { get; set; }
        public Patient Patient { get; set; } = null!;
        
        public string Symptoms { get; set; } = string.Empty;
        public string Diagnosis { get; set; } = string.Empty;
        public double ConfidenceScore { get; set; }
        public string RecommendedActions { get; set; } = string.Empty;
        public string RiskLevel { get; set; } = string.Empty; // Low, Medium, High, Critical
        
        public DateTime AnalysisDate { get; set; } = DateTime.UtcNow;
        public string AnalysisType { get; set; } = string.Empty; // Symptom, Image, Lab
        public bool IsVerifiedByDoctor { get; set; } = false;
        public int? VerifiedByDoctorId { get; set; }
        public DateTime? VerificationDate { get; set; }
        
        public string MetaData { get; set; } = string.Empty; // JSON for additional analysis data
    }
}