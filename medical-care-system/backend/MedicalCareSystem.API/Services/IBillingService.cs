using MedicalCareSystem.API.Models;

namespace MedicalCareSystem.API.Services
{
    public interface IBillingService
    {
        Task<IEnumerable<Billing>> GetAllBillingsAsync();
        Task<IEnumerable<Billing>> GetAllBillingsAsync(int page, int pageSize);
        Task<Billing?> GetBillingByIdAsync(int id);
        Task<Billing?> GetBillingByNumberAsync(string billingNumber);
        Task<Billing> CreateBillingAsync(Billing billing);
        Task<Billing?> UpdateBillingAsync(int id, Billing billing);
        Task<bool> DeleteBillingAsync(int id);
        Task<IEnumerable<Billing>> GetBillingsByPatientAsync(int patientId);
        Task<IEnumerable<Billing>> GetUnpaidBillingsAsync();
        Task<IEnumerable<Billing>> GetOverdueBillingsAsync();
        Task<IEnumerable<Billing>> GetOverdueBillingsAsync(int daysOverdue);
        Task<bool> ApplyInsuranceAsync(int billingId, int insuranceId);
        Task<bool> ProcessPaymentAsync(int billingId, decimal amount, string paymentMethod);
        Task<bool> ApplyInsurancePaymentAsync(int billingId, decimal insuranceAmount);
        Task<decimal> CalculateOutstandingBalanceAsync(int patientId);
        Task<decimal> GetTotalRevenueAsync(DateTime? startDate = null, DateTime? endDate = null);
        Task<IEnumerable<Billing>> SearchBillingsAsync(string searchTerm);
        Task<object> GetBillingStatusStatsAsync();
        Task<object> GetRevenueStatsAsync();
        Task<byte[]> GenerateBillingReportAsync(DateTime startDate, DateTime endDate);
        Task<bool> SendBillingReminderAsync(int billingId);
        Task<bool> WriteOffDebtAsync(int billingId, string reason);
    }
}
