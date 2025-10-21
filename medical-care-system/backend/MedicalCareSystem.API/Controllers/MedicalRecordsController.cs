using MedicalCareSystem.API.Models;
using MedicalCareSystem.API.Services;
using Microsoft.AspNetCore.Mvc;

namespace MedicalCareSystem.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class MedicalRecordsController : ControllerBase
    {
        private readonly IMedicalRecordService _medicalRecordService;
        private readonly ILogger<MedicalRecordsController> _logger;

        public MedicalRecordsController(IMedicalRecordService medicalRecordService, ILogger<MedicalRecordsController> logger)
        {
            _medicalRecordService = medicalRecordService;
            _logger = logger;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<MedicalRecord>>> GetMedicalRecords([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
        {
            try
            {
                var records = await _medicalRecordService.GetAllMedicalRecordsAsync(page, pageSize);
                return Ok(records);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving medical records");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<MedicalRecord>> GetMedicalRecord(int id)
        {
            try
            {
                var record = await _medicalRecordService.GetMedicalRecordByIdAsync(id);
                if (record == null)
                {
                    return NotFound($"Medical record with ID {id} not found");
                }
                return Ok(record);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving medical record with ID {MedicalRecordId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost]
        public async Task<ActionResult<MedicalRecord>> CreateMedicalRecord([FromBody] MedicalRecord medicalRecord)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var createdRecord = await _medicalRecordService.CreateMedicalRecordAsync(medicalRecord);
                return CreatedAtAction(nameof(GetMedicalRecord), new { id = createdRecord.Id }, createdRecord);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating medical record");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<MedicalRecord>> UpdateMedicalRecord(int id, [FromBody] MedicalRecord medicalRecord)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var updatedRecord = await _medicalRecordService.UpdateMedicalRecordAsync(id, medicalRecord);
                if (updatedRecord == null)
                {
                    return NotFound($"Medical record with ID {id} not found");
                }
                return Ok(updatedRecord);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating medical record with ID {MedicalRecordId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> DeleteMedicalRecord(int id)
        {
            try
            {
                var deleted = await _medicalRecordService.DeleteMedicalRecordAsync(id);
                if (!deleted)
                {
                    return NotFound($"Medical record with ID {id} not found");
                }
                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting medical record with ID {MedicalRecordId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("patient/{patientId}")]
        public async Task<ActionResult<IEnumerable<MedicalRecord>>> GetMedicalRecordsByPatient(int patientId)
        {
            try
            {
                var records = await _medicalRecordService.GetMedicalRecordsByPatientAsync(patientId);
                return Ok(records);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving medical records for patient {PatientId}", patientId);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("search")]
        public async Task<ActionResult<IEnumerable<MedicalRecord>>> SearchMedicalRecords([FromQuery] string searchTerm)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(searchTerm))
                {
                    return BadRequest("Search term is required");
                }

                var records = await _medicalRecordService.SearchMedicalRecordsAsync(searchTerm);
                return Ok(records);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching medical records");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("patient/{patientId}/summary")]
        public async Task<ActionResult<string>> GenerateMedicalSummary(int patientId)
        {
            try
            {
                var summary = await _medicalRecordService.GenerateMedicalSummaryAsync(patientId);
                return Ok(new { Summary = summary });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating medical summary for patient {PatientId}", patientId);
                return StatusCode(500, "Internal server error");
            }
        }
    }
}
