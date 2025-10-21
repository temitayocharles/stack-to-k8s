using Microsoft.EntityFrameworkCore;
using MedicalCareSystem.API.Data;
using MedicalCareSystem.API.Models;

namespace MedicalCareSystem.API.Services
{
    public class BillingService : IBillingService
    {
        private readonly MedicalCareContext _context;
        private readonly ILogger<BillingService> _logger;

        public BillingService(MedicalCareContext context, ILogger<BillingService> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<IEnumerable<Billing>> GetAllBillingsAsync()
        {
            try
            {
                return await _context.Billings
                    .Include(b => b.Patient)
                    .Include(b => b.Insurance)
                    .Include(b => b.Appointment)
                    .OrderByDescending(b => b.BillDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving all billings");
                throw;
            }
        }

        public async Task<Billing?> GetBillingByIdAsync(int id)
        {
            try
            {
                return await _context.Billings
                    .Include(b => b.Patient)
                    .Include(b => b.Insurance)
                    .Include(b => b.Appointment)
                        .ThenInclude(a => a.Doctor)
                    .FirstOrDefaultAsync(b => b.Id == id);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving billing with ID {BillingId}", id);
                throw;
            }
        }

        public async Task<IEnumerable<Billing>> GetBillingsByPatientIdAsync(int patientId)
        {
            try
            {
                return await _context.Billings
                    .Include(b => b.Patient)
                    .Include(b => b.Insurance)
                    .Include(b => b.Appointment)
                    .Where(b => b.PatientId == patientId)
                    .OrderByDescending(b => b.BillDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving billings for patient {PatientId}", patientId);
                throw;
            }
        }

        public async Task<Billing> CreateBillingAsync(Billing billing)
        {
            try
            {
                // Validate patient exists
                var patient = await _context.Patients.FindAsync(billing.PatientId);
                if (patient == null)
                {
                    throw new ArgumentException($"Patient with ID {billing.PatientId} not found");
                }

                // Generate bill number if not provided
                if (string.IsNullOrEmpty(billing.BillNumber))
                {
                    billing.BillNumber = $"BILL-{DateTime.UtcNow:yyyyMMdd}-{DateTime.UtcNow.Ticks % 10000:D4}";
                }

                // Set timestamps
                billing.BillDate = DateTime.UtcNow;
                billing.CreatedAt = DateTime.UtcNow;
                
                // Set initial status
                if (string.IsNullOrEmpty(billing.Status))
                {
                    billing.Status = "Pending";
                }

                // Calculate outstanding amount
                billing.OutstandingAmount = billing.TotalAmount - billing.InsuranceCoverage - billing.PaidAmount;

                _context.Billings.Add(billing);
                await _context.SaveChangesAsync();

                _logger.LogInformation("Created new billing with ID {BillingId} for patient {PatientId}", 
                    billing.Id, billing.PatientId);
                return billing;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while creating billing for patient {PatientId}", billing.PatientId);
                throw;
            }
        }

        public async Task<Billing> UpdateBillingAsync(Billing billing)
        {
            try
            {
                var existingBilling = await _context.Billings.FindAsync(billing.Id);
                if (existingBilling == null)
                {
                    throw new ArgumentException($"Billing with ID {billing.Id} not found");
                }

                // Update properties
                existingBilling.TotalAmount = billing.TotalAmount;
                existingBilling.PaidAmount = billing.PaidAmount;
                existingBilling.InsuranceCoverage = billing.InsuranceCoverage;
                existingBilling.Status = billing.Status;
                existingBilling.PaymentMethod = billing.PaymentMethod;
                existingBilling.Notes = billing.Notes;
                existingBilling.Services = billing.Services;
                existingBilling.DueDate = billing.DueDate;
                existingBilling.UpdatedAt = DateTime.UtcNow;

                // Recalculate outstanding amount
                existingBilling.OutstandingAmount = existingBilling.TotalAmount - existingBilling.InsuranceCoverage - existingBilling.PaidAmount;

                await _context.SaveChangesAsync();

                _logger.LogInformation("Updated billing with ID {BillingId}", billing.Id);
                return existingBilling;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while updating billing with ID {BillingId}", billing.Id);
                throw;
            }
        }

        public async Task<bool> DeleteBillingAsync(int id)
        {
            try
            {
                var billing = await _context.Billings.FindAsync(id);
                if (billing == null)
                {
                    return false;
                }

                _context.Billings.Remove(billing);
                await _context.SaveChangesAsync();

                _logger.LogInformation("Deleted billing with ID {BillingId}", id);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while deleting billing with ID {BillingId}", id);
                throw;
            }
        }

        public async Task<bool> ProcessPaymentAsync(int billingId, decimal amount, string paymentMethod)
        {
            try
            {
                var billing = await _context.Billings.FindAsync(billingId);
                if (billing == null)
                {
                    return false;
                }

                billing.PaidAmount += amount;
                billing.PaymentMethod = paymentMethod;
                billing.PaidDate = DateTime.UtcNow;
                billing.OutstandingAmount = billing.TotalAmount - billing.InsuranceCoverage - billing.PaidAmount;
                billing.UpdatedAt = DateTime.UtcNow;

                // Update status based on payment
                if (billing.OutstandingAmount <= 0)
                {
                    billing.Status = "Paid";
                }
                else if (billing.PaidAmount > 0)
                {
                    billing.Status = "Partial";
                }

                await _context.SaveChangesAsync();

                _logger.LogInformation("Processed payment of {Amount} for billing ID {BillingId}", amount, billingId);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while processing payment for billing ID {BillingId}", billingId);
                throw;
            }
        }

        public async Task<decimal> GetTotalRevenueAsync(DateTime? startDate = null, DateTime? endDate = null)
        {
            try
            {
                var query = _context.Billings.AsQueryable();

                if (startDate.HasValue)
                {
                    query = query.Where(b => b.BillDate >= startDate.Value);
                }

                if (endDate.HasValue)
                {
                    query = query.Where(b => b.BillDate <= endDate.Value);
                }

                return await query.SumAsync(b => b.PaidAmount);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while calculating total revenue");
                throw;
            }
        }

        public async Task<IEnumerable<Billing>> GetOutstandingBillingsAsync()
        {
            try
            {
                return await _context.Billings
                    .Include(b => b.Patient)
                    .Where(b => b.OutstandingAmount > 0)
                    .OrderByDescending(b => b.OutstandingAmount)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving outstanding billings");
                throw;
            }
        }

        public async Task<IEnumerable<Billing>> GetBillingsByDateRangeAsync(DateTime startDate, DateTime endDate)
        {
            try
            {
                return await _context.Billings
                    .Include(b => b.Patient)
                    .Include(b => b.Insurance)
                    .Where(b => b.BillDate >= startDate && b.BillDate <= endDate)
                    .OrderByDescending(b => b.BillDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving billings by date range");
                throw;
            }
        }

        public async Task<decimal> GetPatientOutstandingAmountAsync(int patientId)
        {
            try
            {
                return await _context.Billings
                    .Where(b => b.PatientId == patientId)
                    .SumAsync(b => b.OutstandingAmount);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while calculating outstanding amount for patient {PatientId}", patientId);
                throw;
            }
        }

        public async Task<bool> ApplyInsurancePaymentAsync(int billingId, decimal insuranceAmount)
        {
            try
            {
                var billing = await _context.Billings.FindAsync(billingId);
                if (billing == null)
                {
                    return false;
                }

                billing.InsuranceCoverage = insuranceAmount;
                billing.OutstandingAmount = billing.TotalAmount - billing.InsuranceCoverage - billing.PaidAmount;
                billing.UpdatedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();

                _logger.LogInformation("Applied insurance payment of {Amount} for billing ID {BillingId}", insuranceAmount, billingId);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while applying insurance payment for billing ID {BillingId}", billingId);
                throw;
            }
        }

        public async Task<IEnumerable<Billing>> GetRecentBillingsAsync(int count = 10)
        {
            try
            {
                return await _context.Billings
                    .Include(b => b.Patient)
                    .OrderByDescending(b => b.CreatedAt)
                    .Take(count)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving recent billings");
                throw;
            }
        }

        public async Task<object> GetBillingStatsAsync()
        {
            try
            {
                var totalRevenue = await _context.Billings.SumAsync(b => b.PaidAmount);
                var totalOutstanding = await _context.Billings.SumAsync(b => b.OutstandingAmount);
                var totalBills = await _context.Billings.CountAsync();
                var paidBills = await _context.Billings.CountAsync(b => b.Status == "Paid");
                var overdueBills = await _context.Billings.CountAsync(b => b.Status == "Overdue");

                return new
                {
                    TotalRevenue = totalRevenue,
                    TotalOutstanding = totalOutstanding,
                    TotalBills = totalBills,
                    PaidBills = paidBills,
                    OverdueBills = overdueBills,
                    PaymentRate = totalBills > 0 ? (decimal)paidBills / totalBills * 100 : 0
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving billing statistics");
                throw;
            }
        }

        public async Task<Billing?> GetBillingByNumberAsync(string billingNumber)
        {
            try
            {
                return await _context.Billings
                    .Include(b => b.Patient)
                    .Include(b => b.Insurance)
                    .FirstOrDefaultAsync(b => b.BillNumber == billingNumber);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving billing by number: {BillingNumber}", billingNumber);
                throw;
            }
        }

        public async Task<IEnumerable<Billing>> GetBillingsByPatientAsync(int patientId)
        {
            return await GetBillingsByPatientIdAsync(patientId);
        }

        public async Task<Billing?> UpdateBillingAsync(int id, Billing billing)
        {
            try
            {
                var existingBilling = await _context.Billings.FindAsync(id);
                if (existingBilling == null)
                    return null;

                existingBilling.TotalAmount = billing.TotalAmount;
                existingBilling.Services = billing.Services;
                existingBilling.Status = billing.Status;
                existingBilling.DueDate = billing.DueDate;
                existingBilling.UpdatedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();
                return existingBilling;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while updating billing: {BillingId}", id);
                throw;
            }
        }

        public async Task<IEnumerable<Billing>> GetUnpaidBillingsAsync()
        {
            return await GetOutstandingBillingsAsync();
        }

        public async Task<IEnumerable<Billing>> GetOverdueBillingsAsync()
        {
            try
            {
                return await _context.Billings
                    .Include(b => b.Patient)
                    .Include(b => b.Insurance)
                    .Where(b => b.Status != "Paid" && b.DueDate < DateTime.UtcNow)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving overdue billings");
                throw;
            }
        }

        public async Task<decimal> CalculateOutstandingBalanceAsync(int patientId)
        {
            return await GetPatientOutstandingAmountAsync(patientId);
        }

        public async Task<bool> ApplyInsuranceAsync(int billingId, int insuranceId)
        {
            try
            {
                var billing = await _context.Billings.FindAsync(billingId);
                if (billing == null)
                    return false;

                billing.InsuranceId = insuranceId;
                billing.UpdatedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while applying insurance to billing: {BillingId}", billingId);
                return false;
            }
        }

        public async Task<IEnumerable<Billing>> SearchBillingsAsync(string searchTerm)
        {
            try
            {
                return await _context.Billings
                    .Include(b => b.Patient)
                    .Include(b => b.Insurance)
                    .Where(b => b.BillNumber.Contains(searchTerm) ||
                               b.Services.Contains(searchTerm) ||
                               b.Patient.FirstName.Contains(searchTerm) ||
                               b.Patient.LastName.Contains(searchTerm))
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while searching billings with term: {SearchTerm}", searchTerm);
                throw;
            }
        }

        public async Task<object> GetBillingStatusStatsAsync()
        {
            try
            {
                var totalBills = await _context.Billings.CountAsync();
                var paidBills = await _context.Billings.CountAsync(b => b.Status == "Paid");
                var pendingBills = await _context.Billings.CountAsync(b => b.Status == "Pending");
                var overdueBills = await _context.Billings.CountAsync(b => b.Status == "Overdue");

                return new
                {
                    TotalBills = totalBills,
                    PaidBills = paidBills,
                    PendingBills = pendingBills,
                    OverdueBills = overdueBills
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving billing status stats");
                throw;
            }
        }

        public async Task<object> GetRevenueStatsAsync()
        {
            try
            {
                var totalRevenue = await _context.Billings
                    .Where(b => b.Status == "Paid")
                    .SumAsync(b => b.TotalAmount);

                var monthlyRevenue = await _context.Billings
                    .Where(b => b.Status == "Paid" && b.CreatedAt.Month == DateTime.UtcNow.Month)
                    .SumAsync(b => b.TotalAmount);

                return new
                {
                    TotalRevenue = totalRevenue,
                    MonthlyRevenue = monthlyRevenue
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving revenue stats");
                throw;
            }
        }

        public async Task<byte[]> GenerateBillingReportAsync(DateTime startDate, DateTime endDate)
        {
            try
            {
                // This would typically generate a PDF or Excel report
                // For now, return placeholder byte array
                var reportData = $"Billing Report from {startDate:yyyy-MM-dd} to {endDate:yyyy-MM-dd}";
                return System.Text.Encoding.UTF8.GetBytes(reportData);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while generating billing report");
                throw;
            }
        }

        public async Task<bool> SendBillingReminderAsync(int billingId)
        {
            try
            {
                var billing = await _context.Billings
                    .Include(b => b.Patient)
                    .FirstOrDefaultAsync(b => b.Id == billingId);

                if (billing == null)
                    return false;

                // In a real application, this would send an email or SMS
                _logger.LogInformation("Billing reminder sent for billing {BillingId} to patient {PatientName}",
                    billingId, $"{billing.Patient.FirstName} {billing.Patient.LastName}");

                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while sending billing reminder: {BillingId}", billingId);
                return false;
            }
        }

        public async Task<bool> WriteOffDebtAsync(int billingId, string reason)
        {
            try
            {
                var billing = await _context.Billings.FindAsync(billingId);
                if (billing == null)
                    return false;

                billing.Status = "Written Off";
                billing.UpdatedAt = DateTime.UtcNow;
                // In a real application, you might add a notes field for the reason

                await _context.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while writing off debt for billing: {BillingId}", billingId);
                return false;
            }
        }

        public async Task<IEnumerable<Billing>> GetAllBillingsAsync(int page, int pageSize)
        {
            try
            {
                return await _context.Billings
                    .Include(b => b.Patient)
                    .Include(b => b.Insurance)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving billings with pagination");
                throw;
            }
        }

        public async Task<IEnumerable<Billing>> GetOverdueBillingsAsync(int daysOverdue)
        {
            try
            {
                var overdueDate = DateTime.UtcNow.AddDays(-daysOverdue);
                return await _context.Billings
                    .Include(b => b.Patient)
                    .Include(b => b.Insurance)
                    .Where(b => b.Status != "Paid" && b.DueDate < overdueDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving overdue billings for {DaysOverdue} days", daysOverdue);
                throw;
            }
        }
    }
}
