using System.ComponentModel.DataAnnotations;

namespace MedicalCareSystem.API.Models
{
    public class HealthAnalytics
    {
        [Key]
        public int Id { get; set; }
        
        public int PatientId { get; set; }
        public Patient Patient { get; set; } = null!;
        
        // Health Score Information
        public double HealthScore { get; set; } // 0-100 scale
        public string HealthGrade { get; set; } = string.Empty; // A, B, C, D, F
        public string HealthStatus { get; set; } = string.Empty; // Excellent, Good, Fair, Poor, Critical
        
        // Risk Assessment
        public double CardiovascularRisk { get; set; }
        public double DiabetesRisk { get; set; }
        public double HospitalizationRisk { get; set; }
        public double MortalityRisk { get; set; }
        public string RiskFactors { get; set; } = string.Empty; // JSON array of risk factors
        
        // Trend Analysis
        public double TrendScore { get; set; } // Improving, Stable, Declining
        public string TrendDirection { get; set; } = string.Empty; // Improving, Stable, Declining
        public string TrendAnalysis { get; set; } = string.Empty;
        public double TrendConfidence { get; set; } // 0-1 confidence level
        
        // Predictions
        public string PredictiveAnalytics { get; set; } = string.Empty; // JSON object
        public DateTime? PredictedRiskDate { get; set; }
        public string RecommendedInterventions { get; set; } = string.Empty;
        public string PreventiveMeasures { get; set; } = string.Empty;
        
        // Data Sources and Metadata
        public string DataSources { get; set; } = string.Empty; // VitalSigns, Labs, Medications, etc.
        public int DataPointsAnalyzed { get; set; }
        public DateTime AnalysisDateRange_Start { get; set; }
        public DateTime AnalysisDateRange_End { get; set; }
        
        // Model Information
        public string MLModel { get; set; } = string.Empty;
        public string ModelVersion { get; set; } = string.Empty;
        public double ModelConfidence { get; set; }
        public string ModelAccuracy { get; set; } = string.Empty;
        
        // Comparative Analysis
        public double PopulationPercentile { get; set; }
        public string AgeGroupComparison { get; set; } = string.Empty;
        public string GenderComparison { get; set; } = string.Empty;
        public string ConditionComparison { get; set; } = string.Empty;
        
        // Action Items
        public string RecommendedActions { get; set; } = string.Empty; // JSON array
        public bool RequiresImmediateAttention { get; set; } = false;
        public string UrgentActions { get; set; } = string.Empty;
        public DateTime? NextReviewDate { get; set; }
        
        // Provider Insights
        public string ProviderNotes { get; set; } = string.Empty;
        public bool ReviewedByProvider { get; set; } = false;
        public DateTime? ReviewedAt { get; set; }
        public string ReviewedBy { get; set; } = string.Empty;
        
        // Quality Metrics
        public string DataQuality { get; set; } = "Good"; // Excellent, Good, Fair, Poor
        public bool IsReliable { get; set; } = true;
        public string LimitationsNoted { get; set; } = string.Empty;
        public string ConfidenceInterval { get; set; } = string.Empty;
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? ExpiresAt { get; set; }
    }
}