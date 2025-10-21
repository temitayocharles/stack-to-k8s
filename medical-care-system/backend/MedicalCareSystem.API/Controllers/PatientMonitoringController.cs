using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MedicalCareSystem.API.Data;
using MedicalCareSystem.API.Models;

namespace MedicalCareSystem.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PatientMonitoringController : ControllerBase
    {
        private readonly MedicalCareContext _context;

        public PatientMonitoringController(MedicalCareContext context)
        {
            _context = context;
        }

        [HttpPost("vital-signs")]
        public async Task<ActionResult<PatientMonitoring>> RecordVitalSigns([FromBody] VitalSignsRequest request)
        {
            try
            {
                var monitoring = new PatientMonitoring
                {
                    PatientId = request.PatientId,
                    HeartRate = request.HeartRate,
                    BloodPressureSystolic = request.BloodPressureSystolic,
                    BloodPressureDiastolic = request.BloodPressureDiastolic,
                    Temperature = request.Temperature,
                    OxygenSaturation = request.OxygenSaturation,
                    RespiratoryRate = request.RespiratoryRate,
                    DeviceId = request.DeviceId,
                    Location = request.Location,
                    Timestamp = DateTime.UtcNow
                };

                // Analyze vital signs for abnormalities
                var (isAbnormal, alertLevel, alerts) = AnalyzeVitalSigns(monitoring);
                monitoring.IsAbnormal = isAbnormal;
                monitoring.AlertLevel = alertLevel;

                _context.PatientMonitorings.Add(monitoring);

                // Create alerts if necessary
                if (isAbnormal && alerts.Any())
                {
                    foreach (var alert in alerts)
                    {
                        var medicalAlert = new MedicalAlert
                        {
                            PatientId = request.PatientId,
                            AlertType = "VitalSigns",
                            Severity = alert.Severity,
                            Title = alert.Title,
                            Description = alert.Description,
                            TriggerData = System.Text.Json.JsonSerializer.Serialize(monitoring)
                        };
                        _context.MedicalAlerts.Add(medicalAlert);
                    }
                }

                await _context.SaveChangesAsync();

                return Ok(new
                {
                    monitoring_id = monitoring.Id,
                    patient_id = monitoring.PatientId,
                    timestamp = monitoring.Timestamp,
                    vital_signs = new
                    {
                        heart_rate = monitoring.HeartRate,
                        blood_pressure = $"{monitoring.BloodPressureSystolic}/{monitoring.BloodPressureDiastolic}",
                        temperature = monitoring.Temperature,
                        oxygen_saturation = monitoring.OxygenSaturation,
                        respiratory_rate = monitoring.RespiratoryRate
                    },
                    analysis = new
                    {
                        is_abnormal = monitoring.IsAbnormal,
                        alert_level = monitoring.AlertLevel,
                        alerts_generated = alerts.Count,
                        device_id = monitoring.DeviceId,
                        location = monitoring.Location
                    },
                    trends = await GetVitalSignsTrends(request.PatientId)
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "Failed to record vital signs", details = ex.Message });
            }
        }

        [HttpGet("patient/{patientId}/current")]
        public async Task<ActionResult> GetCurrentVitalSigns(int patientId)
        {
            var latestVitals = await _context.PatientMonitorings
                .Where(pm => pm.PatientId == patientId)
                .OrderByDescending(pm => pm.Timestamp)
                .FirstOrDefaultAsync();

            if (latestVitals == null)
                return NotFound(new { message = "No vital signs recorded for this patient" });

            return Ok(new
            {
                patient_id = patientId,
                current_vitals = new
                {
                    timestamp = latestVitals.Timestamp,
                    heart_rate = latestVitals.HeartRate,
                    blood_pressure = $"{latestVitals.BloodPressureSystolic}/{latestVitals.BloodPressureDiastolic}",
                    temperature = latestVitals.Temperature,
                    oxygen_saturation = latestVitals.OxygenSaturation,
                    respiratory_rate = latestVitals.RespiratoryRate,
                    alert_level = latestVitals.AlertLevel,
                    location = latestVitals.Location
                },
                trends = await GetVitalSignsTrends(patientId),
                active_alerts = await GetActiveAlerts(patientId)
            });
        }

        [HttpGet("patient/{patientId}/history")]
        public async Task<ActionResult> GetPatientMonitoringHistory(int patientId, [FromQuery] int hours = 24)
        {
            var startTime = DateTime.UtcNow.AddHours(-hours);
            
            var history = await _context.PatientMonitorings
                .Where(pm => pm.PatientId == patientId && pm.Timestamp >= startTime)
                .OrderByDescending(pm => pm.Timestamp)
                .Select(pm => new
                {
                    id = pm.Id,
                    timestamp = pm.Timestamp,
                    heart_rate = pm.HeartRate,
                    blood_pressure_systolic = pm.BloodPressureSystolic,
                    blood_pressure_diastolic = pm.BloodPressureDiastolic,
                    temperature = pm.Temperature,
                    oxygen_saturation = pm.OxygenSaturation,
                    respiratory_rate = pm.RespiratoryRate,
                    alert_level = pm.AlertLevel,
                    location = pm.Location,
                    device_id = pm.DeviceId
                })
                .ToListAsync();

            return Ok(new
            {
                patient_id = patientId,
                period_hours = hours,
                total_readings = history.Count,
                monitoring_history = history,
                summary = new
                {
                    avg_heart_rate = history.Any() ? history.Average(h => h.heart_rate) : 0,
                    avg_temperature = history.Any() ? history.Average(h => h.temperature) : 0,
                    avg_oxygen_saturation = history.Any() ? history.Average(h => h.oxygen_saturation) : 0,
                    critical_alerts = history.Count(h => h.alert_level == "Critical"),
                    warning_alerts = history.Count(h => h.alert_level == "Warning")
                }
            });
        }

        [HttpGet("dashboard/overview")]
        public async Task<ActionResult> GetMonitoringDashboard()
        {
            var activePatients = await _context.PatientMonitorings
                .Where(pm => pm.Timestamp >= DateTime.UtcNow.AddHours(-1))
                .Select(pm => pm.PatientId)
                .Distinct()
                .CountAsync();

            var criticalAlerts = await _context.MedicalAlerts
                .Where(ma => !ma.IsResolved && ma.Severity == "Critical")
                .CountAsync();

            var recentReadings = await _context.PatientMonitorings
                .Where(pm => pm.Timestamp >= DateTime.UtcNow.AddMinutes(-30))
                .CountAsync();

            return Ok(new
            {
                dashboard_data = new
                {
                    active_patients = activePatients,
                    critical_alerts = criticalAlerts,
                    recent_readings = recentReadings,
                    monitoring_status = activePatients > 0 ? "Active" : "Inactive"
                },
                real_time_stats = new
                {
                    patients_with_abnormal_vitals = await _context.PatientMonitorings
                        .Where(pm => pm.IsAbnormal && pm.Timestamp >= DateTime.UtcNow.AddHours(-1))
                        .Select(pm => pm.PatientId)
                        .Distinct()
                        .CountAsync(),
                    average_readings_per_hour = await CalculateAverageReadingsPerHour(),
                    system_uptime = "99.8%",
                    last_updated = DateTime.UtcNow
                }
            });
        }

        private (bool isAbnormal, string alertLevel, List<AlertInfo> alerts) AnalyzeVitalSigns(PatientMonitoring monitoring)
        {
            var alerts = new List<AlertInfo>();
            var isAbnormal = false;
            var alertLevel = "Normal";

            // Heart Rate Analysis
            if (monitoring.HeartRate < 60 || monitoring.HeartRate > 100)
            {
                isAbnormal = true;
                alertLevel = monitoring.HeartRate < 50 || monitoring.HeartRate > 120 ? "Critical" : "Warning";
                alerts.Add(new AlertInfo
                {
                    Severity = alertLevel,
                    Title = "Abnormal Heart Rate",
                    Description = $"Heart rate: {monitoring.HeartRate} bpm (Normal: 60-100 bpm)"
                });
            }

            // Blood Pressure Analysis
            if (monitoring.BloodPressureSystolic > 140 || monitoring.BloodPressureDiastolic > 90)
            {
                isAbnormal = true;
                var severity = monitoring.BloodPressureSystolic > 180 || monitoring.BloodPressureDiastolic > 110 ? "Critical" : "Warning";
                if (alertLevel != "Critical") alertLevel = severity;
                alerts.Add(new AlertInfo
                {
                    Severity = severity,
                    Title = "High Blood Pressure",
                    Description = $"BP: {monitoring.BloodPressureSystolic}/{monitoring.BloodPressureDiastolic} mmHg"
                });
            }

            // Temperature Analysis
            if (monitoring.Temperature < 36.0 || monitoring.Temperature > 37.5)
            {
                isAbnormal = true;
                var severity = monitoring.Temperature < 35.0 || monitoring.Temperature > 39.0 ? "Critical" : "Warning";
                if (alertLevel != "Critical") alertLevel = severity;
                alerts.Add(new AlertInfo
                {
                    Severity = severity,
                    Title = "Abnormal Temperature",
                    Description = $"Temperature: {monitoring.Temperature}°C (Normal: 36.0-37.5°C)"
                });
            }

            // Oxygen Saturation Analysis
            if (monitoring.OxygenSaturation < 95)
            {
                isAbnormal = true;
                var severity = monitoring.OxygenSaturation < 90 ? "Critical" : "Warning";
                alertLevel = "Critical";
                alerts.Add(new AlertInfo
                {
                    Severity = severity,
                    Title = "Low Oxygen Saturation",
                    Description = $"SpO2: {monitoring.OxygenSaturation}% (Normal: >95%)"
                });
            }

            return (isAbnormal, alertLevel, alerts);
        }

        private async Task<object> GetVitalSignsTrends(int patientId)
        {
            var recentReadings = await _context.PatientMonitorings
                .Where(pm => pm.PatientId == patientId && pm.Timestamp >= DateTime.UtcNow.AddHours(-24))
                .OrderBy(pm => pm.Timestamp)
                .ToListAsync();

            if (!recentReadings.Any())
                return new { trend = "No data available" };

            var first = recentReadings.First();
            var last = recentReadings.Last();

            return new
            {
                heart_rate_trend = CalculateTrend(first.HeartRate, last.HeartRate),
                blood_pressure_trend = CalculateTrend(first.BloodPressureSystolic, last.BloodPressureSystolic),
                temperature_trend = CalculateTrend(first.Temperature, last.Temperature),
                readings_count = recentReadings.Count
            };
        }

        private async Task<List<object>> GetActiveAlerts(int patientId)
        {
            var alerts = await _context.MedicalAlerts
                .Where(ma => ma.PatientId == patientId && !ma.IsResolved)
                .Select(ma => new
                {
                    id = ma.Id,
                    type = ma.AlertType,
                    severity = ma.Severity,
                    title = ma.Title,
                    created_date = ma.CreatedDate
                })
                .ToListAsync();
                
            return alerts.Cast<object>().ToList();
        }

        private async Task<double> CalculateAverageReadingsPerHour()
        {
            var hoursBack = 24;
            var readings = await _context.PatientMonitorings
                .Where(pm => pm.Timestamp >= DateTime.UtcNow.AddHours(-hoursBack))
                .CountAsync();

            return (double)readings / hoursBack;
        }

        private string CalculateTrend(double oldValue, double newValue)
        {
            var change = ((newValue - oldValue) / oldValue) * 100;
            if (Math.Abs(change) < 5) return "Stable";
            return change > 0 ? "Increasing" : "Decreasing";
        }
    }

    public class VitalSignsRequest
    {
        public int PatientId { get; set; }
        public double HeartRate { get; set; }
        public double BloodPressureSystolic { get; set; }
        public double BloodPressureDiastolic { get; set; }
        public double Temperature { get; set; }
        public double OxygenSaturation { get; set; }
        public double RespiratoryRate { get; set; }
        public string DeviceId { get; set; } = string.Empty;
        public string Location { get; set; } = string.Empty;
    }

    public class AlertInfo
    {
        public string Severity { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
    }
}