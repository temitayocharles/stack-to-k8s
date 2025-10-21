using MedicalCareSystem.API.Models;
using MedicalCareSystem.API.Services;
using Microsoft.AspNetCore.Mvc;

namespace MedicalCareSystem.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class BillingsController : ControllerBase
    {
        private readonly IBillingService _billingService;
        private readonly ILogger<BillingsController> _logger;

        public BillingsController(IBillingService billingService, ILogger<BillingsController> logger)
        {
            _billingService = billingService;
            _logger = logger;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Billing>>> GetBillings([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
        {
            try
            {
                var billings = await _billingService.GetAllBillingsAsync(page, pageSize);
                return Ok(billings);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving billings");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<Billing>> GetBilling(int id)
        {
            try
            {
                var billing = await _billingService.GetBillingByIdAsync(id);
                if (billing == null)
                {
                    return NotFound($"Billing with ID {id} not found");
                }
                return Ok(billing);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving billing with ID {BillingId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("number/{billNumber}")]
        public async Task<ActionResult<Billing>> GetBillingByNumber(string billNumber)
        {
            try
            {
                var billing = await _billingService.GetBillingByNumberAsync(billNumber);
                if (billing == null)
                {
                    return NotFound($"Billing with number {billNumber} not found");
                }
                return Ok(billing);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving billing with number {BillNumber}", billNumber);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost]
        public async Task<ActionResult<Billing>> CreateBilling([FromBody] Billing billing)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var createdBilling = await _billingService.CreateBillingAsync(billing);
                return CreatedAtAction(nameof(GetBilling), new { id = createdBilling.Id }, createdBilling);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating billing");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<Billing>> UpdateBilling(int id, [FromBody] Billing billing)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var updatedBilling = await _billingService.UpdateBillingAsync(id, billing);
                if (updatedBilling == null)
                {
                    return NotFound($"Billing with ID {id} not found");
                }
                return Ok(updatedBilling);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating billing with ID {BillingId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> DeleteBilling(int id)
        {
            try
            {
                var deleted = await _billingService.DeleteBillingAsync(id);
                if (!deleted)
                {
                    return NotFound($"Billing with ID {id} not found");
                }
                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting billing with ID {BillingId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("patient/{patientId}")]
        public async Task<ActionResult<IEnumerable<Billing>>> GetBillingsByPatient(int patientId)
        {
            try
            {
                var billings = await _billingService.GetBillingsByPatientAsync(patientId);
                return Ok(billings);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving billings for patient {PatientId}", patientId);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("unpaid")]
        public async Task<ActionResult<IEnumerable<Billing>>> GetUnpaidBillings()
        {
            try
            {
                var billings = await _billingService.GetUnpaidBillingsAsync();
                return Ok(billings);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving unpaid billings");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("overdue")]
        public async Task<ActionResult<IEnumerable<Billing>>> GetOverdueBillings([FromQuery] int days = 30)
        {
            try
            {
                var billings = await _billingService.GetOverdueBillingsAsync(days);
                return Ok(billings);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving overdue billings");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost("{id}/payment")]
        public async Task<ActionResult> ProcessPayment(int id, [FromBody] PaymentRequest request)
        {
            try
            {
                var success = await _billingService.ProcessPaymentAsync(id, request.Amount, request.PaymentMethod);
                if (!success)
                {
                    return NotFound($"Billing with ID {id} not found");
                }
                return Ok();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing payment for billing {BillingId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost("{id}/insurance")]
        public async Task<ActionResult> ApplyInsurance(int id, [FromBody] InsuranceRequest request)
        {
            try
            {
                // For now, using the existing ApplyInsurancePaymentAsync method instead
                var success = await _billingService.ApplyInsurancePaymentAsync(id, request.InsuranceAmount);
                if (!success)
                {
                    return NotFound($"Billing with ID {id} not found");
                }
                return Ok();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error applying insurance for billing {BillingId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("patient/{patientId}/balance")]
        public async Task<ActionResult<decimal>> GetOutstandingBalance(int patientId)
        {
            try
            {
                var balance = await _billingService.CalculateOutstandingBalanceAsync(patientId);
                return Ok(new { OutstandingBalance = balance });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error calculating outstanding balance for patient {PatientId}", patientId);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("search")]
        public async Task<ActionResult<IEnumerable<Billing>>> SearchBillings([FromQuery] string searchTerm)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(searchTerm))
                {
                    return BadRequest("Search term is required");
                }

                var billings = await _billingService.SearchBillingsAsync(searchTerm);
                return Ok(billings);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching billings");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("statistics")]
        public async Task<ActionResult> GetBillingStatistics()
        {
            try
            {
                var statusStats = await _billingService.GetBillingStatusStatsAsync();
                var revenueStats = await _billingService.GetRevenueStatsAsync();
                
                var statistics = new
                {
                    StatusStats = statusStats,
                    RevenueStats = revenueStats
                };

                return Ok(statistics);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting billing statistics");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("revenue")]
        public async Task<ActionResult<decimal>> GetTotalRevenue([FromQuery] DateTime? startDate = null, [FromQuery] DateTime? endDate = null)
        {
            try
            {
                var revenue = await _billingService.GetTotalRevenueAsync(startDate, endDate);
                return Ok(new { TotalRevenue = revenue });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error calculating total revenue");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("patient/{patientId}/report")]
        public async Task<ActionResult<string>> GenerateBillingReport(int patientId)
        {
            try
            {
                // Generate report for the current year by default
                var startDate = new DateTime(DateTime.UtcNow.Year, 1, 1);
                var endDate = DateTime.UtcNow;
                var report = await _billingService.GenerateBillingReportAsync(startDate, endDate);
                return Ok(new { Report = report });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating billing report for patient {PatientId}", patientId);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost("{id}/reminder")]
        public async Task<ActionResult> SendBillingReminder(int id)
        {
            try
            {
                var success = await _billingService.SendBillingReminderAsync(id);
                if (!success)
                {
                    return BadRequest("Cannot send reminder - billing not found or no amount due");
                }
                return Ok();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending billing reminder for billing {BillingId}", id);
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost("{id}/writeoff")]
        public async Task<ActionResult> WriteOffDebt(int id, [FromBody] WriteOffRequest request)
        {
            try
            {
                var success = await _billingService.WriteOffDebtAsync(id, request.Reason);
                if (!success)
                {
                    return NotFound($"Billing with ID {id} not found");
                }
                return Ok();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error writing off debt for billing {BillingId}", id);
                return StatusCode(500, "Internal server error");
            }
        }
    }

    public class PaymentRequest
    {
        public decimal Amount { get; set; }
        public string PaymentMethod { get; set; } = string.Empty;
    }

    public class InsuranceRequest
    {
        public decimal InsuranceAmount { get; set; }
    }

    public class WriteOffRequest
    {
        public string Reason { get; set; } = string.Empty;
    }
}
