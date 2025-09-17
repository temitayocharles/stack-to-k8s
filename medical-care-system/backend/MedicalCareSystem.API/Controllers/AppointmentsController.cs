using MedicalCareSystem.API.Models;
using MedicalCareSystem.API.Services;
using Microsoft.AspNetCore.Mvc;

namespace MedicalCareSystem.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AppointmentsController : ControllerBase
    {
        private readonly IAppointmentService _appointmentService;
        private readonly ILogger<AppointmentsController> _logger;

        public AppointmentsController(IAppointmentService appointmentService, ILogger<AppointmentsController> logger)
        {
            _appointmentService = appointmentService;
            _logger = logger;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Appointment>>> GetAppointments(
            [FromQuery] int page = 1, 
            [FromQuery] int pageSize = 10, 
            [FromQuery] DateTime? date = null)
        {
            try
            {
                var appointments = await _appointmentService.GetAllAppointmentsAsync(page, pageSize, date);
                return Ok(appointments);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving appointments");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<Appointment>> GetAppointment(int id)
        {
            try
            {
                var appointment = await _appointmentService.GetAppointmentByIdAsync(id);
                if (appointment == null)
                {
                    return NotFound($"Appointment with ID {id} not found");
                }
                return Ok(appointment);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving appointment with ID {AppointmentId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("number/{appointmentNumber}")]
        public async Task<ActionResult<Appointment>> GetAppointmentByNumber(string appointmentNumber)
        {
            try
            {
                var appointment = await _appointmentService.GetAppointmentByNumberAsync(appointmentNumber);
                if (appointment == null)
                {
                    return NotFound($"Appointment with number {appointmentNumber} not found");
                }
                return Ok(appointment);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving appointment with number {AppointmentNumber}", appointmentNumber);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("{id}/details")]
        public async Task<ActionResult<Appointment>> GetAppointmentWithDetails(int id)
        {
            try
            {
                var appointment = await _appointmentService.GetAppointmentWithDetailsAsync(id);
                if (appointment == null)
                {
                    return NotFound($"Appointment with ID {id} not found");
                }
                return Ok(appointment);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving appointment details for ID {AppointmentId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost]
        public async Task<ActionResult<Appointment>> CreateAppointment([FromBody] Appointment appointment)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var createdAppointment = await _appointmentService.CreateAppointmentAsync(appointment);
                return CreatedAtAction(nameof(GetAppointment), new { id = createdAppointment.Id }, createdAppointment);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating appointment");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<Appointment>> UpdateAppointment(int id, [FromBody] Appointment appointment)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var updatedAppointment = await _appointmentService.UpdateAppointmentAsync(id, appointment);
                if (updatedAppointment == null)
                {
                    return NotFound($"Appointment with ID {id} not found");
                }
                return Ok(updatedAppointment);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating appointment with ID {AppointmentId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> DeleteAppointment(int id)
        {
            try
            {
                var deleted = await _appointmentService.DeleteAppointmentAsync(id);
                if (!deleted)
                {
                    return NotFound($"Appointment with ID {id} not found");
                }
                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting appointment with ID {AppointmentId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost("{id}/cancel")]
        public async Task<ActionResult> CancelAppointment(int id, [FromBody] CancelRequest request)
        {
            try
            {
                var cancelled = await _appointmentService.CancelAppointmentAsync(id, request.Reason);
                if (!cancelled)
                {
                    return NotFound($"Appointment with ID {id} not found");
                }
                return Ok();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error cancelling appointment with ID {AppointmentId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost("{id}/confirm")]
        public async Task<ActionResult> ConfirmAppointment(int id)
        {
            try
            {
                var confirmed = await _appointmentService.ConfirmAppointmentAsync(id);
                if (!confirmed)
                {
                    return NotFound($"Appointment with ID {id} not found");
                }
                return Ok();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error confirming appointment with ID {AppointmentId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost("{id}/checkin")]
        public async Task<ActionResult> CheckInPatient(int id)
        {
            try
            {
                var checkedIn = await _appointmentService.CheckInPatientAsync(id);
                if (!checkedIn)
                {
                    return NotFound($"Appointment with ID {id} not found");
                }
                return Ok();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking in patient for appointment {AppointmentId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost("{id}/complete")]
        public async Task<ActionResult> CompleteAppointment(int id)
        {
            try
            {
                var completed = await _appointmentService.CompleteAppointmentAsync(id);
                if (!completed)
                {
                    return NotFound($"Appointment with ID {id} not found");
                }
                return Ok();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error completing appointment with ID {AppointmentId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("patient/{patientId}")]
        public async Task<ActionResult<IEnumerable<Appointment>>> GetAppointmentsByPatient(int patientId)
        {
            try
            {
                var appointments = await _appointmentService.GetAppointmentsByPatientAsync(patientId);
                return Ok(appointments);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving appointments for patient {PatientId}", patientId);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("doctor/{doctorId}")]
        public async Task<ActionResult<IEnumerable<Appointment>>> GetAppointmentsByDoctor(int doctorId, [FromQuery] DateTime? date = null)
        {
            try
            {
                var appointments = await _appointmentService.GetAppointmentsByDoctorAsync(doctorId, date);
                return Ok(appointments);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving appointments for doctor {DoctorId}", doctorId);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("date/{date}")]
        public async Task<ActionResult<IEnumerable<Appointment>>> GetAppointmentsByDate(DateTime date)
        {
            try
            {
                var appointments = await _appointmentService.GetAppointmentsByDateAsync(date);
                return Ok(appointments);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving appointments for date {Date}", date);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("upcoming")]
        public async Task<ActionResult<IEnumerable<Appointment>>> GetUpcomingAppointments([FromQuery] int days = 7)
        {
            try
            {
                var appointments = await _appointmentService.GetUpcomingAppointmentsAsync(days);
                return Ok(appointments);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving upcoming appointments");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("today")]
        public async Task<ActionResult<IEnumerable<Appointment>>> GetTodaysAppointments()
        {
            try
            {
                var appointments = await _appointmentService.GetTodaysAppointmentsAsync();
                return Ok(appointments);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving today's appointments");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("overdue")]
        public async Task<ActionResult<IEnumerable<Appointment>>> GetOverdueAppointments()
        {
            try
            {
                var appointments = await _appointmentService.GetOverdueAppointmentsAsync();
                return Ok(appointments);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving overdue appointments");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("search")]
        public async Task<ActionResult<IEnumerable<Appointment>>> SearchAppointments([FromQuery] string searchTerm)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(searchTerm))
                {
                    return BadRequest("Search term is required");
                }

                var appointments = await _appointmentService.SearchAppointmentsAsync(searchTerm);
                return Ok(appointments);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching appointments");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("available-slots")]
        public async Task<ActionResult<IEnumerable<DateTime>>> GetAvailableSlots(
            [FromQuery] int doctorId, 
            [FromQuery] DateTime date, 
            [FromQuery] int durationMinutes = 30)
        {
            try
            {
                var duration = TimeSpan.FromMinutes(durationMinutes);
                var slots = await _appointmentService.GetAvailableSlotsAsync(doctorId, date, duration);
                return Ok(slots);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving available slots");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost("check-availability")]
        public async Task<ActionResult<bool>> CheckTimeSlotAvailability([FromBody] AvailabilityCheckRequest request)
        {
            try
            {
                var duration = TimeSpan.FromMinutes(request.DurationMinutes);
                var isAvailable = await _appointmentService.IsTimeSlotAvailableAsync(
                    request.DoctorId, 
                    request.AppointmentDate, 
                    duration, 
                    request.ExcludeAppointmentId);
                
                return Ok(new { IsAvailable = isAvailable });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking time slot availability");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("count")]
        public async Task<ActionResult<int>> GetTotalAppointmentsCount()
        {
            try
            {
                var count = await _appointmentService.GetTotalAppointmentsCountAsync();
                return Ok(count);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting total appointments count");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("statistics")]
        public async Task<ActionResult> GetAppointmentStatistics()
        {
            try
            {
                var statusStats = await _appointmentService.GetAppointmentStatusStatsAsync();
                
                var statistics = new
                {
                    StatusStats = statusStats
                };

                return Ok(statistics);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting appointment statistics");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("exists/{id}")]
        public async Task<ActionResult<bool>> AppointmentExists(int id)
        {
            try
            {
                var exists = await _appointmentService.AppointmentExistsAsync(id);
                return Ok(exists);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking if appointment exists");
                return StatusCode(500, "Internal server error");
            }
        }
    }

    public class CancelRequest
    {
        public string Reason { get; set; } = string.Empty;
    }

    public class AvailabilityCheckRequest
    {
        public int DoctorId { get; set; }
        public DateTime AppointmentDate { get; set; }
        public int DurationMinutes { get; set; } = 30;
        public int? ExcludeAppointmentId { get; set; }
    }
}
