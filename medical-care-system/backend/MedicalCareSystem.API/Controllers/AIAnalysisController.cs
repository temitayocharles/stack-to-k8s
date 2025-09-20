using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MedicalCareSystem.API.Data;
using MedicalCareSystem.API.Models;
using Microsoft.ML;
using Microsoft.ML.Data;

namespace MedicalCareSystem.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AIAnalysisController : ControllerBase
    {
        private readonly MedicalCareContext _context;
        private readonly MLContext _mlContext;

        public AIAnalysisController(MedicalCareContext context)
        {
            _context = context;
            _mlContext = new MLContext(seed: 0);
        }

        [HttpPost("analyze-symptoms")]
        public async Task<ActionResult<AIAnalysis>> AnalyzeSymptoms([FromBody] SymptomAnalysisRequest request)
        {
            try
            {
                // AI symptom analysis logic
                var analysis = new AIAnalysis
                {
                    PatientId = request.PatientId,
                    Symptoms = request.Symptoms,
                    AnalysisType = "Symptom",
                    AnalysisDate = DateTime.UtcNow
                };

                // Simulate AI analysis
                var (diagnosis, confidence, riskLevel, recommendations) = PerformSymptomAnalysis(request.Symptoms);
                
                analysis.Diagnosis = diagnosis;
                analysis.ConfidenceScore = confidence;
                analysis.RiskLevel = riskLevel;
                analysis.RecommendedActions = recommendations;

                _context.AIAnalyses.Add(analysis);
                await _context.SaveChangesAsync();

                return Ok(new
                {
                    analysis_id = analysis.Id,
                    patient_id = analysis.PatientId,
                    diagnosis = new
                    {
                        primary = analysis.Diagnosis,
                        confidence_score = analysis.ConfidenceScore,
                        risk_level = analysis.RiskLevel
                    },
                    recommendations = analysis.RecommendedActions.Split(';').Where(r => !string.IsNullOrEmpty(r)),
                    analysis_metadata = new
                    {
                        analysis_date = analysis.AnalysisDate,
                        analysis_type = analysis.AnalysisType,
                        requires_doctor_verification = analysis.ConfidenceScore < 0.8
                    },
                    ai_insights = new
                    {
                        symptoms_analyzed = request.Symptoms.Split(',').Length,
                        processing_time_ms = 1200,
                        model_version = "Medical-AI-v2.1",
                        differential_diagnoses = GetDifferentialDiagnoses(request.Symptoms)
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "AI analysis failed", details = ex.Message });
            }
        }

        [HttpGet("patient/{patientId}/analyses")]
        public async Task<ActionResult> GetPatientAnalyses(int patientId)
        {
            var analyses = await _context.AIAnalyses
                .Where(a => a.PatientId == patientId)
                .OrderByDescending(a => a.AnalysisDate)
                .Select(a => new
                {
                    id = a.Id,
                    analysis_date = a.AnalysisDate,
                    diagnosis = a.Diagnosis,
                    confidence_score = a.ConfidenceScore,
                    risk_level = a.RiskLevel,
                    is_verified = a.IsVerifiedByDoctor,
                    analysis_type = a.AnalysisType
                })
                .ToListAsync();

            return Ok(new
            {
                patient_id = patientId,
                total_analyses = analyses.Count,
                analyses = analyses,
                risk_summary = new
                {
                    high_risk_count = analyses.Count(a => a.risk_level == "High" || a.risk_level == "Critical"),
                    pending_verification = analyses.Count(a => !a.is_verified),
                    latest_analysis = analyses.FirstOrDefault()?.analysis_date
                }
            });
        }

        [HttpPost("{analysisId}/verify")]
        public async Task<ActionResult> VerifyAnalysis(int analysisId, [FromBody] VerificationRequest request)
        {
            var analysis = await _context.AIAnalyses.FindAsync(analysisId);
            if (analysis == null)
                return NotFound();

            analysis.IsVerifiedByDoctor = true;
            analysis.VerifiedByDoctorId = request.DoctorId;
            analysis.VerificationDate = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return Ok(new
            {
                analysis_id = analysisId,
                verified = true,
                verified_by = request.DoctorId,
                verification_date = analysis.VerificationDate
            });
        }

        private (string diagnosis, double confidence, string riskLevel, string recommendations) PerformSymptomAnalysis(string symptoms)
        {
            // Simulate AI analysis based on symptoms
            var symptomList = symptoms.ToLower().Split(',').Select(s => s.Trim()).ToList();
            
            // Simple rule-based analysis for demonstration
            var diagnosis = "General Assessment";
            var confidence = 0.75;
            var riskLevel = "Medium";
            var recommendations = new List<string>();

            if (symptomList.Any(s => s.Contains("chest pain") || s.Contains("shortness of breath")))
            {
                diagnosis = "Possible Cardiac Event";
                confidence = 0.85;
                riskLevel = "High";
                recommendations.AddRange(new[] { "Immediate ECG", "Cardiac enzymes", "Emergency consultation" });
            }
            else if (symptomList.Any(s => s.Contains("fever") || s.Contains("cough")))
            {
                diagnosis = "Upper Respiratory Infection";
                confidence = 0.80;
                riskLevel = "Low";
                recommendations.AddRange(new[] { "Rest", "Fluids", "Monitor temperature", "Consider antivirals" });
            }
            else if (symptomList.Any(s => s.Contains("headache") || s.Contains("nausea")))
            {
                diagnosis = "Possible Migraine or Tension Headache";
                confidence = 0.70;
                riskLevel = "Medium";
                recommendations.AddRange(new[] { "Pain management", "Rest in dark room", "Monitor symptoms" });
            }
            else
            {
                diagnosis = "General Health Assessment Required";
                confidence = 0.60;
                riskLevel = "Low";
                recommendations.AddRange(new[] { "Comprehensive examination", "Basic vital signs", "Patient history review" });
            }

            return (diagnosis, confidence, riskLevel, string.Join(";", recommendations));
        }

        private List<string> GetDifferentialDiagnoses(string symptoms)
        {
            // Return possible alternative diagnoses
            return new List<string>
            {
                "Viral infection",
                "Bacterial infection",
                "Allergic reaction",
                "Stress-related condition",
                "Nutritional deficiency"
            };
        }
    }

    public class SymptomAnalysisRequest
    {
        public int PatientId { get; set; }
        public string Symptoms { get; set; } = string.Empty;
        public string Duration { get; set; } = string.Empty;
        public string Severity { get; set; } = string.Empty;
    }

    public class VerificationRequest
    {
        public int DoctorId { get; set; }
        public string Notes { get; set; } = string.Empty;
    }
}