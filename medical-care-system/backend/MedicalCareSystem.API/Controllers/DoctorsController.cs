using MedicalCareSystem.API.Models;
using MedicalCareSystem.API.Services;
using Microsoft.AspNetCore.Mvc;

namespace MedicalCareSystem.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DoctorsController : ControllerBase
    {
        private readonly IDoctorService _doctorService;
        private readonly ILogger<DoctorsController> _logger;

        public DoctorsController(IDoctorService doctorService, ILogger<DoctorsController> logger)
        {
            _doctorService = doctorService;
            _logger = logger;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Doctor>>> GetDoctors([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
        {
            try
            {
                var doctors = await _doctorService.GetAllDoctorsAsync(page, pageSize);
                return Ok(doctors);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving doctors");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<Doctor>> GetDoctor(int id)
        {
            try
            {
                var doctor = await _doctorService.GetDoctorByIdAsync(id);
                if (doctor == null)
                {
                    return NotFound($"Doctor with ID {id} not found");
                }
                return Ok(doctor);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving doctor with ID {DoctorId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("license/{licenseNumber}")]
        public async Task<ActionResult<Doctor>> GetDoctorByLicense(string licenseNumber)
        {
            try
            {
                var doctor = await _doctorService.GetDoctorByLicenseAsync(licenseNumber);
                if (doctor == null)
                {
                    return NotFound($"Doctor with license {licenseNumber} not found");
                }
                return Ok(doctor);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving doctor with license {LicenseNumber}", licenseNumber);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("{id}/details")]
        public async Task<ActionResult<Doctor>> GetDoctorWithDetails(int id)
        {
            try
            {
                var doctor = await _doctorService.GetDoctorWithDetailsAsync(id);
                if (doctor == null)
                {
                    return NotFound($"Doctor with ID {id} not found");
                }
                return Ok(doctor);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving doctor details for ID {DoctorId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost]
        public async Task<ActionResult<Doctor>> CreateDoctor([FromBody] Doctor doctor)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var createdDoctor = await _doctorService.CreateDoctorAsync(doctor);
                return CreatedAtAction(nameof(GetDoctor), new { id = createdDoctor.Id }, createdDoctor);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating doctor");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<Doctor>> UpdateDoctor(int id, [FromBody] Doctor doctor)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var updatedDoctor = await _doctorService.UpdateDoctorAsync(id, doctor);
                if (updatedDoctor == null)
                {
                    return NotFound($"Doctor with ID {id} not found");
                }
                return Ok(updatedDoctor);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating doctor with ID {DoctorId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> DeleteDoctor(int id)
        {
            try
            {
                var deleted = await _doctorService.DeleteDoctorAsync(id);
                if (!deleted)
                {
                    return NotFound($"Doctor with ID {id} not found");
                }
                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting doctor with ID {DoctorId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("search")]
        public async Task<ActionResult<IEnumerable<Doctor>>> SearchDoctors([FromQuery] string searchTerm)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(searchTerm))
                {
                    return BadRequest("Search term is required");
                }

                var doctors = await _doctorService.SearchDoctorsAsync(searchTerm);
                return Ok(doctors);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching doctors");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("specialty/{specialty}")]
        public async Task<ActionResult<IEnumerable<Doctor>>> GetDoctorsBySpecialty(string specialty)
        {
            try
            {
                var doctors = await _doctorService.GetDoctorsBySpecialtyAsync(specialty);
                return Ok(doctors);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving doctors by specialty");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("department/{departmentId}")]
        public async Task<ActionResult<IEnumerable<Doctor>>> GetDoctorsByDepartment(int departmentId)
        {
            try
            {
                var doctors = await _doctorService.GetDoctorsByDepartmentAsync(departmentId);
                return Ok(doctors);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving doctors by department");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("available")]
        public async Task<ActionResult<IEnumerable<Doctor>>> GetAvailableDoctors([FromQuery] DateTime? date = null)
        {
            try
            {
                var doctors = await _doctorService.GetAvailableDoctorsAsync(date);
                return Ok(doctors);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving available doctors");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("{id}/appointments")]
        public async Task<ActionResult<IEnumerable<Appointment>>> GetDoctorAppointments(int id, [FromQuery] DateTime? date = null)
        {
            try
            {
                var appointments = await _doctorService.GetDoctorAppointmentsAsync(id, date);
                return Ok(appointments);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving appointments for doctor {DoctorId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("{id}/patients")]
        public async Task<ActionResult<IEnumerable<Patient>>> GetDoctorPatients(int id)
        {
            try
            {
                var patients = await _doctorService.GetDoctorPatientsAsync(id);
                return Ok(patients);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving patients for doctor {DoctorId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("{id}/available-slots")]
        public async Task<ActionResult<IEnumerable<DateTime>>> GetAvailableSlots(int id, [FromQuery] DateTime date, [FromQuery] int durationMinutes = 30)
        {
            try
            {
                var slots = await _doctorService.GetAvailableSlotsAsync(id, date, durationMinutes);
                return Ok(slots);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving available slots for doctor {DoctorId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost("{id}/availability")]
        public async Task<ActionResult> SetAvailability(int id, [FromBody] AvailabilityRequest request)
        {
            try
            {
                var success = await _doctorService.SetAvailabilityAsync(id, request.StartTime, request.EndTime, request.IsAvailable);
                if (!success)
                {
                    return NotFound($"Doctor with ID {id} not found");
                }
                return Ok();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error setting availability for doctor {DoctorId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("count")]
        public async Task<ActionResult<int>> GetTotalDoctorsCount()
        {
            try
            {
                var count = await _doctorService.GetTotalDoctorsCountAsync();
                return Ok(count);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting total doctors count");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("statistics")]
        public async Task<ActionResult> GetDoctorStatistics()
        {
            try
            {
                var specialtyStats = await _doctorService.GetDoctorSpecialtyStatsAsync();
                var departmentStats = await _doctorService.GetDoctorDepartmentStatsAsync();
                
                var statistics = new
                {
                    SpecialtyStats = specialtyStats,
                    DepartmentStats = departmentStats
                };

                return Ok(statistics);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting doctor statistics");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("specialties")]
        public async Task<ActionResult<IEnumerable<string>>> GetUniqueSpecialties()
        {
            try
            {
                var specialties = await _doctorService.GetUniqueSpecialtiesAsync();
                return Ok(specialties);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving unique specialties");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("exists/{id}")]
        public async Task<ActionResult<bool>> DoctorExists(int id)
        {
            try
            {
                var exists = await _doctorService.DoctorExistsAsync(id);
                return Ok(exists);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking if doctor exists");
                return StatusCode(500, "Internal server error");
            }
        }
    }

    public class AvailabilityRequest
    {
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public bool IsAvailable { get; set; }
    }
}
