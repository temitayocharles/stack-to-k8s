using MedicalCareSystem.API.Models;
using MedicalCareSystem.API.Services;
using Microsoft.AspNetCore.Mvc;

namespace MedicalCareSystem.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PatientsController : ControllerBase
    {
        private readonly IPatientService _patientService;
        private readonly ILogger<PatientsController> _logger;

        public PatientsController(IPatientService patientService, ILogger<PatientsController> logger)
        {
            _patientService = patientService;
            _logger = logger;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Patient>>> GetPatients([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
        {
            try
            {
                var patients = await _patientService.GetAllPatientsAsync(page, pageSize);
                return Ok(patients);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving patients");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<Patient>> GetPatient(int id)
        {
            try
            {
                var patient = await _patientService.GetPatientByIdAsync(id);
                if (patient == null)
                {
                    return NotFound($"Patient with ID {id} not found");
                }
                return Ok(patient);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving patient with ID {PatientId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("number/{patientNumber}")]
        public async Task<ActionResult<Patient>> GetPatientByNumber(string patientNumber)
        {
            try
            {
                var patient = await _patientService.GetPatientByNumberAsync(patientNumber);
                if (patient == null)
                {
                    return NotFound($"Patient with number {patientNumber} not found");
                }
                return Ok(patient);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving patient with number {PatientNumber}", patientNumber);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("{id}/details")]
        public async Task<ActionResult<Patient>> GetPatientWithDetails(int id)
        {
            try
            {
                var patient = await _patientService.GetPatientWithDetailsAsync(id);
                if (patient == null)
                {
                    return NotFound($"Patient with ID {id} not found");
                }
                return Ok(patient);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving patient details for ID {PatientId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost]
        public async Task<ActionResult<Patient>> CreatePatient([FromBody] Patient patient)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var createdPatient = await _patientService.CreatePatientAsync(patient);
                return CreatedAtAction(nameof(GetPatient), new { id = createdPatient.Id }, createdPatient);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating patient");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<Patient>> UpdatePatient(int id, [FromBody] Patient patient)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var updatedPatient = await _patientService.UpdatePatientAsync(id, patient);
                if (updatedPatient == null)
                {
                    return NotFound($"Patient with ID {id} not found");
                }
                return Ok(updatedPatient);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating patient with ID {PatientId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> DeletePatient(int id)
        {
            try
            {
                var deleted = await _patientService.DeletePatientAsync(id);
                if (!deleted)
                {
                    return NotFound($"Patient with ID {id} not found");
                }
                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting patient with ID {PatientId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("search")]
        public async Task<ActionResult<IEnumerable<Patient>>> SearchPatients([FromQuery] string searchTerm)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(searchTerm))
                {
                    return BadRequest("Search term is required");
                }

                var patients = await _patientService.SearchPatientsAsync(searchTerm);
                return Ok(patients);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching patients");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("gender/{gender}")]
        public async Task<ActionResult<IEnumerable<Patient>>> GetPatientsByGender(string gender)
        {
            try
            {
                var patients = await _patientService.GetPatientsByGenderAsync(gender);
                return Ok(patients);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving patients by gender");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("age-range")]
        public async Task<ActionResult<IEnumerable<Patient>>> GetPatientsByAgeRange([FromQuery] int minAge, [FromQuery] int maxAge)
        {
            try
            {
                var patients = await _patientService.GetPatientsByAgeRangeAsync(minAge, maxAge);
                return Ok(patients);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving patients by age range");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("{id}/appointments")]
        public async Task<ActionResult<IEnumerable<Appointment>>> GetPatientAppointments(int id)
        {
            try
            {
                var appointments = await _patientService.GetPatientAppointmentsAsync(id);
                return Ok(appointments);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving appointments for patient {PatientId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("{id}/medical-records")]
        public async Task<ActionResult<IEnumerable<MedicalRecord>>> GetPatientMedicalRecords(int id)
        {
            try
            {
                var records = await _patientService.GetPatientMedicalRecordsAsync(id);
                return Ok(records);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving medical records for patient {PatientId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("{id}/prescriptions")]
        public async Task<ActionResult<IEnumerable<Prescription>>> GetPatientPrescriptions(int id)
        {
            try
            {
                var prescriptions = await _patientService.GetPatientPrescriptionsAsync(id);
                return Ok(prescriptions);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving prescriptions for patient {PatientId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("count")]
        public async Task<ActionResult<int>> GetTotalPatientsCount()
        {
            try
            {
                var count = await _patientService.GetTotalPatientsCountAsync();
                return Ok(count);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting total patients count");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("statistics")]
        public async Task<ActionResult> GetPatientStatistics()
        {
            try
            {
                var genderStats = await _patientService.GetPatientGenderStatsAsync();
                var ageGroupStats = await _patientService.GetPatientAgeGroupStatsAsync();
                
                var statistics = new
                {
                    GenderStats = genderStats,
                    AgeGroupStats = ageGroupStats
                };

                return Ok(statistics);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting patient statistics");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("today")]
        public async Task<ActionResult<IEnumerable<Patient>>> GetTodaysPatients()
        {
            try
            {
                var patients = await _patientService.GetTodaysPatients();
                return Ok(patients);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving today's patients");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("recent")]
        public async Task<ActionResult<IEnumerable<Patient>>> GetRecentPatients([FromQuery] int days = 30)
        {
            try
            {
                var patients = await _patientService.GetRecentPatientsAsync(days);
                return Ok(patients);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving recent patients");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("{id}/summary")]
        public async Task<ActionResult<string>> GetPatientSummary(int id)
        {
            try
            {
                var summary = await _patientService.GeneratePatientSummaryAsync(id);
                return Ok(new { Summary = summary });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating summary for patient {PatientId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("exists/{id}")]
        public async Task<ActionResult<bool>> PatientExists(int id)
        {
            try
            {
                var exists = await _patientService.PatientExistsAsync(id);
                return Ok(exists);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking if patient exists");
                return StatusCode(500, "Internal server error");
            }
        }
    }
}
