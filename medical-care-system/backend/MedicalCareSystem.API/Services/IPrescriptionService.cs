using MedicalCareSystem.API.Models;

namespace MedicalCareSystem.API.Services
{
    public interface IPrescriptionService
    {
        Task<IEnumerable<Prescription>> GetAllPrescriptionsAsync();
        Task<IEnumerable<Prescription>> GetAllPrescriptionsAsync(int page, int pageSize);
        Task<Prescription?> GetPrescriptionByIdAsync(int id);
        Task<Prescription> CreatePrescriptionAsync(Prescription prescription);
        Task<Prescription?> UpdatePrescriptionAsync(int id, Prescription prescription);
        Task<bool> DeletePrescriptionAsync(int id);
        Task<IEnumerable<Prescription>> GetPrescriptionsByPatientAsync(int patientId);
        Task<IEnumerable<Prescription>> GetActivePrescriptionsAsync(int patientId);
        Task<bool> RefillPrescriptionAsync(int prescriptionId, DateTime newStartDate);
        Task<bool> DiscontinuePrescriptionAsync(int prescriptionId, string reason);
        Task<IEnumerable<Prescription>> SearchPrescriptionsAsync(string searchTerm);
        Task<IEnumerable<Prescription>> GetPrescriptionsDueForRefillAsync();
        Task<IEnumerable<Prescription>> GetPrescriptionsDueForRefillAsync(int daysAhead);
        Task<decimal> CalculatePrescriptionCostAsync(int prescriptionId);
        Task<string> GeneratePrescriptionReportAsync(int patientId);
        Task<object> GetDrugInteractionsAsync(List<int> medicationIds);
        Task<object> GetDrugInteractionsAsync(int medicationId);
    }
}
