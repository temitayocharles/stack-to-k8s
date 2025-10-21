using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MedicalCareSystem.API.Data;

namespace MedicalCareSystem.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class HealthController : ControllerBase
    {
        private readonly MedicalCareContext _context;
        private readonly ILogger<HealthController> _logger;

        public HealthController(MedicalCareContext context, ILogger<HealthController> logger)
        {
            _context = context;
            _logger = logger;
        }

        [HttpGet]
        public async Task<IActionResult> GetHealth()
        {
            try
            {
                var startTime = DateTime.UtcNow;
                
                // Test database connectivity
                var canConnect = await _context.Database.CanConnectAsync();
                var dbResponseTime = (DateTime.UtcNow - startTime).TotalMilliseconds;

                if (!canConnect)
                {
                    _logger.LogError("Database connection failed");
                    return StatusCode(503, new
                    {
                        status = "Unhealthy",
                        timestamp = DateTime.UtcNow,
                        service = "Medical Care System API",
                        version = "1.0.0",
                        errors = new[] { "Database connection failed" }
                    });
                }

                // Get database statistics
                var patientCount = await _context.Patients.CountAsync();
                var doctorCount = await _context.Doctors.CountAsync();
                var appointmentCount = await _context.Appointments.CountAsync();

                var healthResponse = new
                {
                    status = "Healthy",
                    timestamp = DateTime.UtcNow,
                    service = "Medical Care System API",
                    version = "1.0.0",
                    environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Production",
                    database = new
                    {
                        status = "Connected",
                        responseTime = $"{dbResponseTime:F2}ms",
                        statistics = new
                        {
                            patients = patientCount,
                            doctors = doctorCount,
                            appointments = appointmentCount
                        }
                    },
                    uptime = TimeSpan.FromMilliseconds(Environment.TickCount64).ToString(@"dd\.hh\:mm\:ss"),
                    memory = new
                    {
                        workingSet = GC.GetTotalMemory(false) / 1024 / 1024 + " MB"
                    }
                };

                _logger.LogInformation("Health check completed successfully - Database: {DbResponseTime}ms", dbResponseTime);
                
                return Ok(healthResponse);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Health check failed");
                return StatusCode(503, new
                {
                    status = "Unhealthy",
                    timestamp = DateTime.UtcNow,
                    service = "Medical Care System API",
                    version = "1.0.0",
                    errors = new[] { ex.Message }
                });
            }
        }

        [HttpGet("ready")]
        public async Task<IActionResult> GetReadiness()
        {
            try
            {
                // Check if database is ready
                var canConnect = await _context.Database.CanConnectAsync();
                
                if (!canConnect)
                {
                    return StatusCode(503, new { status = "Not Ready", reason = "Database not available" });
                }

                return Ok(new { status = "Ready", timestamp = DateTime.UtcNow });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Readiness check failed");
                return StatusCode(503, new { status = "Not Ready", reason = ex.Message });
            }
        }

        [HttpGet("live")]
        public IActionResult GetLiveness()
        {
            return Ok(new { status = "Alive", timestamp = DateTime.UtcNow });
        }
    }
}