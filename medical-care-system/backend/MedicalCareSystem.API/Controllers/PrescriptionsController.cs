using MedicalCareSystem.API.Models;
using MedicalCareSystem.API.Services;
using Microsoft.AspNetCore.Mvc;

namespace MedicalCareSystem.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PrescriptionsController : ControllerBase
    {
        private readonly IPrescriptionService _prescriptionService;
        private readonly ILogger<PrescriptionsController> _logger;

        public PrescriptionsController(IPrescriptionService prescriptionService, ILogger<PrescriptionsController> logger)
        {
            _prescriptionService = prescriptionService;
            _logger = logger;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Prescription>>> GetPrescriptions([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
        {
            try
            {
                var prescriptions = await _prescriptionService.GetAllPrescriptionsAsync(page, pageSize);
                return Ok(prescriptions);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving prescriptions");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<Prescription>> GetPrescription(int id)
        {
            try
            {
                var prescription = await _prescriptionService.GetPrescriptionByIdAsync(id);
                if (prescription == null)
                {
                    return NotFound($"Prescription with ID {id} not found");
                }
                return Ok(prescription);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving prescription with ID {PrescriptionId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost]
        public async Task<ActionResult<Prescription>> CreatePrescription([FromBody] Prescription prescription)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var createdPrescription = await _prescriptionService.CreatePrescriptionAsync(prescription);
                return CreatedAtAction(nameof(GetPrescription), new { id = createdPrescription.Id }, createdPrescription);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating prescription");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<Prescription>> UpdatePrescription(int id, [FromBody] Prescription prescription)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var updatedPrescription = await _prescriptionService.UpdatePrescriptionAsync(id, prescription);
                if (updatedPrescription == null)
                {
                    return NotFound($"Prescription with ID {id} not found");
                }
                return Ok(updatedPrescription);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating prescription with ID {PrescriptionId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> DeletePrescription(int id)
        {
            try
            {
                var deleted = await _prescriptionService.DeletePrescriptionAsync(id);
                if (!deleted)
                {
                    return NotFound($"Prescription with ID {id} not found");
                }
                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting prescription with ID {PrescriptionId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("patient/{patientId}")]
        public async Task<ActionResult<IEnumerable<Prescription>>> GetPrescriptionsByPatient(int patientId)
        {
            try
            {
                var prescriptions = await _prescriptionService.GetPrescriptionsByPatientAsync(patientId);
                return Ok(prescriptions);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving prescriptions for patient {PatientId}", patientId);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("patient/{patientId}/active")]
        public async Task<ActionResult<IEnumerable<Prescription>>> GetActivePrescriptions(int patientId)
        {
            try
            {
                var prescriptions = await _prescriptionService.GetActivePrescriptionsAsync(patientId);
                return Ok(prescriptions);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving active prescriptions for patient {PatientId}", patientId);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost("{id}/refill")]
        public async Task<ActionResult> RefillPrescription(int id, [FromBody] RefillRequest request)
        {
            try
            {
                var success = await _prescriptionService.RefillPrescriptionAsync(id, DateTime.UtcNow);
                if (!success)
                {
                    return BadRequest("Cannot refill prescription - no refills remaining or prescription not found");
                }
                return Ok();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error refilling prescription {PrescriptionId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost("{id}/discontinue")]
        public async Task<ActionResult> DiscontinuePrescription(int id, [FromBody] DiscontinueRequest request)
        {
            try
            {
                var success = await _prescriptionService.DiscontinuePrescriptionAsync(id, request.Reason);
                if (!success)
                {
                    return NotFound($"Prescription with ID {id} not found");
                }
                return Ok();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error discontinuing prescription {PrescriptionId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("search")]
        public async Task<ActionResult<IEnumerable<Prescription>>> SearchPrescriptions([FromQuery] string searchTerm)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(searchTerm))
                {
                    return BadRequest("Search term is required");
                }

                var prescriptions = await _prescriptionService.SearchPrescriptionsAsync(searchTerm);
                return Ok(prescriptions);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching prescriptions");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("due-for-refill")]
        public async Task<ActionResult<IEnumerable<Prescription>>> GetPrescriptionsDueForRefill([FromQuery] int daysAhead = 7)
        {
            try
            {
                var prescriptions = await _prescriptionService.GetPrescriptionsDueForRefillAsync(daysAhead);
                return Ok(prescriptions);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving prescriptions due for refill");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("patient/{patientId}/interactions")]
        public async Task<ActionResult<IEnumerable<Prescription>>> GetDrugInteractions(int patientId)
        {
            try
            {
                var interactions = await _prescriptionService.GetDrugInteractionsAsync(patientId);
                return Ok(interactions);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking drug interactions for patient {PatientId}", patientId);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("{id}/cost")]
        public async Task<ActionResult<decimal>> CalculatePrescriptionCost(int id)
        {
            try
            {
                var cost = await _prescriptionService.CalculatePrescriptionCostAsync(id);
                return Ok(new { Cost = cost });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error calculating cost for prescription {PrescriptionId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("patient/{patientId}/report")]
        public async Task<ActionResult<string>> GeneratePrescriptionReport(int patientId)
        {
            try
            {
                var report = await _prescriptionService.GeneratePrescriptionReportAsync(patientId);
                return Ok(new { Report = report });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating prescription report for patient {PatientId}", patientId);
                return StatusCode(500, "Internal server error");
            }
        }
    }

    public class RefillRequest
    {
        public int RefillsRemaining { get; set; }
    }

    public class DiscontinueRequest
    {
        public string Reason { get; set; } = string.Empty;
    }
}
