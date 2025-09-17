using Microsoft.EntityFrameworkCore;
using MedicalCareSystem.API.Data;
using MedicalCareSystem.API.Models;

namespace MedicalCareSystem.API.Services
{
    public class PrescriptionService : IPrescriptionService
    {
        private readonly MedicalCareContext _context;
        private readonly ILogger<PrescriptionService> _logger;

        public PrescriptionService(MedicalCareContext context, ILogger<PrescriptionService> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<IEnumerable<Prescription>> GetAllPrescriptionsAsync()
        {
            try
            {
                return await _context.Prescriptions
                    .Include(p => p.Patient)
                    .Include(p => p.Doctor)
                    .Include(p => p.Medication)
                    .Include(p => p.MedicalRecord)
                    .OrderByDescending(p => p.PrescribedDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving all prescriptions");
                throw;
            }
        }

        public async Task<Prescription?> GetPrescriptionByIdAsync(int id)
        {
            try
            {
                return await _context.Prescriptions
                    .Include(p => p.Patient)
                    .Include(p => p.Doctor)
                    .Include(p => p.Medication)
                    .Include(p => p.MedicalRecord)
                    .FirstOrDefaultAsync(p => p.Id == id);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving prescription with ID {PrescriptionId}", id);
                throw;
            }
        }

        public async Task<IEnumerable<Prescription>> GetPrescriptionsByPatientIdAsync(int patientId)
        {
            try
            {
                return await _context.Prescriptions
                    .Include(p => p.Patient)
                    .Include(p => p.Doctor)
                    .Include(p => p.Medication)
                    .Include(p => p.MedicalRecord)
                    .Where(p => p.PatientId == patientId)
                    .OrderByDescending(p => p.PrescribedDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving prescriptions for patient {PatientId}", patientId);
                throw;
            }
        }

        public async Task<IEnumerable<Prescription>> GetPrescriptionsByDoctorIdAsync(int doctorId)
        {
            try
            {
                return await _context.Prescriptions
                    .Include(p => p.Patient)
                    .Include(p => p.Doctor)
                    .Include(p => p.Medication)
                    .Include(p => p.MedicalRecord)
                    .Where(p => p.DoctorId == doctorId)
                    .OrderByDescending(p => p.PrescribedDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving prescriptions for doctor {DoctorId}", doctorId);
                throw;
            }
        }

        public async Task<Prescription> CreatePrescriptionAsync(Prescription prescription)
        {
            try
            {
                // Validate patient exists
                var patient = await _context.Patients.FindAsync(prescription.PatientId);
                if (patient == null)
                {
                    throw new ArgumentException($"Patient with ID {prescription.PatientId} not found");
                }

                // Validate doctor exists
                var doctor = await _context.Doctors.FindAsync(prescription.DoctorId);
                if (doctor == null)
                {
                    throw new ArgumentException($"Doctor with ID {prescription.DoctorId} not found");
                }

                // Validate medication exists
                var medication = await _context.Medications.FindAsync(prescription.MedicationId);
                if (medication == null)
                {
                    throw new ArgumentException($"Medication with ID {prescription.MedicationId} not found");
                }

                // Generate prescription number if not provided
                if (string.IsNullOrEmpty(prescription.PrescriptionNumber))
                {
                    prescription.PrescriptionNumber = $"RX-{DateTime.UtcNow:yyyyMMdd}-{DateTime.UtcNow.Ticks % 10000:D4}";
                }

                // Set timestamps
                prescription.PrescribedDate = DateTime.UtcNow;
                prescription.CreatedAt = DateTime.UtcNow;

                // Set default status if not provided
                if (string.IsNullOrEmpty(prescription.Status))
                {
                    prescription.Status = "Active";
                }

                _context.Prescriptions.Add(prescription);
                await _context.SaveChangesAsync();

                _logger.LogInformation("Created new prescription with ID {PrescriptionId} for patient {PatientId}", 
                    prescription.Id, prescription.PatientId);
                return prescription;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while creating prescription for patient {PatientId}", prescription.PatientId);
                throw;
            }
        }

        public async Task<Prescription> UpdatePrescriptionAsync(Prescription prescription)
        {
            try
            {
                var existingPrescription = await _context.Prescriptions.FindAsync(prescription.Id);
                if (existingPrescription == null)
                {
                    throw new ArgumentException($"Prescription with ID {prescription.Id} not found");
                }

                // Update properties
                existingPrescription.PatientId = prescription.PatientId;
                existingPrescription.DoctorId = prescription.DoctorId;
                existingPrescription.MedicationId = prescription.MedicationId;
                existingPrescription.MedicalRecordId = prescription.MedicalRecordId;
                existingPrescription.Dosage = prescription.Dosage;
                existingPrescription.Frequency = prescription.Frequency;
                existingPrescription.Duration = prescription.Duration;
                existingPrescription.Instructions = prescription.Instructions;
                existingPrescription.Refills = prescription.Refills;
                existingPrescription.RefillsUsed = prescription.RefillsUsed;
                existingPrescription.StartDate = prescription.StartDate;
                existingPrescription.EndDate = prescription.EndDate;
                existingPrescription.Status = prescription.Status;
                existingPrescription.UpdatedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();

                _logger.LogInformation("Updated prescription with ID {PrescriptionId}", prescription.Id);
                return existingPrescription;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while updating prescription with ID {PrescriptionId}", prescription.Id);
                throw;
            }
        }

        public async Task<bool> DeletePrescriptionAsync(int id)
        {
            try
            {
                var prescription = await _context.Prescriptions.FindAsync(id);
                if (prescription == null)
                {
                    return false;
                }

                _context.Prescriptions.Remove(prescription);
                await _context.SaveChangesAsync();

                _logger.LogInformation("Deleted prescription with ID {PrescriptionId}", id);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while deleting prescription with ID {PrescriptionId}", id);
                throw;
            }
        }

        public async Task<bool> RefillPrescriptionAsync(int prescriptionId)
        {
            try
            {
                var prescription = await _context.Prescriptions.FindAsync(prescriptionId);
                if (prescription == null)
                {
                    return false;
                }

                var refillsRemaining = prescription.Refills - prescription.RefillsUsed;
                if (refillsRemaining <= 0)
                {
                    return false;
                }

                // Record the refill
                prescription.RefillsUsed = prescription.RefillsUsed + 1;
                prescription.UpdatedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();

                _logger.LogInformation("Refilled prescription with ID {PrescriptionId}", prescriptionId);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while refilling prescription with ID {PrescriptionId}", prescriptionId);
                throw;
            }
        }

        public async Task<bool> DiscontinuePrescriptionAsync(int prescriptionId, string reason)
        {
            try
            {
                var prescription = await _context.Prescriptions.FindAsync(prescriptionId);
                if (prescription == null)
                {
                    return false;
                }

                prescription.Status = "Cancelled";
                prescription.Instructions = $"{prescription.Instructions}\nDiscontinued: {reason}";
                prescription.UpdatedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();

                _logger.LogInformation("Discontinued prescription with ID {PrescriptionId} for reason: {Reason}", 
                    prescriptionId, reason);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while discontinuing prescription with ID {PrescriptionId}", prescriptionId);
                throw;
            }
        }

        public async Task<IEnumerable<Prescription>> SearchPrescriptionsAsync(string searchTerm)
        {
            try
            {
                return await _context.Prescriptions
                    .Include(p => p.Patient)
                    .Include(p => p.Doctor)
                    .Include(p => p.Medication)
                    .Where(p => p.Patient != null && p.Patient.FirstName.Contains(searchTerm) ||
                               p.Patient != null && p.Patient.LastName.Contains(searchTerm) ||
                               p.Doctor != null && p.Doctor.FirstName.Contains(searchTerm) ||
                               p.Doctor != null && p.Doctor.LastName.Contains(searchTerm) ||
                               p.Medication != null && p.Medication.Name.Contains(searchTerm) ||
                               p.PrescriptionNumber.Contains(searchTerm))
                    .OrderByDescending(p => p.PrescribedDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while searching prescriptions with term {SearchTerm}", searchTerm);
                throw;
            }
        }

        public async Task<IEnumerable<Prescription>> GetActivePrescriptionsAsync()
        {
            try
            {
                return await _context.Prescriptions
                    .Include(p => p.Patient)
                    .Include(p => p.Doctor)
                    .Include(p => p.Medication)
                    .Where(p => p.Status == "Active")
                    .OrderByDescending(p => p.PrescribedDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving active prescriptions");
                throw;
            }
        }

        public async Task<IEnumerable<Prescription>> GetExpiredPrescriptionsAsync()
        {
            try
            {
                var today = DateTime.UtcNow.Date;
                return await _context.Prescriptions
                    .Include(p => p.Patient)
                    .Include(p => p.Doctor)
                    .Include(p => p.Medication)
                    .Where(p => p.EndDate.HasValue && p.EndDate.Value < today)
                    .OrderByDescending(p => p.EndDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving expired prescriptions");
                throw;
            }
        }

        public async Task<IEnumerable<Prescription>> GetPrescriptionsByMedicationAsync(int medicationId)
        {
            try
            {
                return await _context.Prescriptions
                    .Include(p => p.Patient)
                    .Include(p => p.Doctor)
                    .Include(p => p.Medication)
                    .Where(p => p.MedicationId == medicationId)
                    .OrderByDescending(p => p.PrescribedDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving prescriptions for medication {MedicationId}", medicationId);
                throw;
            }
        }

        public async Task<IEnumerable<Prescription>> GetRefillablePrescriptionsAsync(int patientId)
        {
            try
            {
                return await _context.Prescriptions
                    .Include(p => p.Patient)
                    .Include(p => p.Doctor)
                    .Include(p => p.Medication)
                    .Where(p => p.PatientId == patientId && 
                               p.Status == "Active" &&
                               p.Refills > p.RefillsUsed)
                    .OrderByDescending(p => p.PrescribedDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving refillable prescriptions for patient {PatientId}", patientId);
                throw;
            }
        }

        public async Task<decimal> CalculatePrescriptionCostAsync(int prescriptionId)
        {
            try
            {
                var prescription = await _context.Prescriptions
                    .Include(p => p.Medication)
                    .FirstOrDefaultAsync(p => p.Id == prescriptionId);

                if (prescription?.Medication == null)
                {
                    return 0;
                }

                // For demo purposes, calculate a basic cost
                // In a real system, this would involve complex pricing calculations
                var baseCost = 50.0m; // Default medication cost
                var duration = 30; // Default to 30 days

                return baseCost * duration;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while calculating cost for prescription {PrescriptionId}", prescriptionId);
                throw;
            }
        }

        public async Task<string> GeneratePrescriptionReportAsync(int patientId)
        {
            try
            {
                var prescriptions = await GetPrescriptionsByPatientIdAsync(patientId);
                var patient = await _context.Patients.FindAsync(patientId);

                if (patient == null)
                {
                    return "Patient not found";
                }

                var report = $"Prescription Report for {patient.FirstName} {patient.LastName}\n";
                report += $"Generated: {DateTime.UtcNow:yyyy-MM-dd HH:mm:ss} UTC\n\n";

                foreach (var prescription in prescriptions)
                {
                    report += $"Prescription: {prescription.PrescriptionNumber}\n";
                    report += $"  Medication: {prescription.Medication?.Name ?? "Unknown"}\n";
                    report += $"  Dosage: {prescription.Dosage}\n";
                    report += $"  Frequency: {prescription.Frequency}\n";
                    report += $"  Duration: {prescription.Duration}\n";
                    report += $"  Status: {prescription.Status}\n";
                    report += $"  Prescribed: {prescription.PrescribedDate:yyyy-MM-dd}\n";
                    report += $"  Doctor: {prescription.Doctor?.FirstName} {prescription.Doctor?.LastName}\n";
                    var refillsRemaining = prescription.Refills - prescription.RefillsUsed;
                    report += $"  Refills Remaining: {refillsRemaining}\n\n";
                }

                return report;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while generating prescription report for patient {PatientId}", patientId);
                throw;
            }
        }

        public async Task<IEnumerable<Prescription>> GetPrescriptionsByPatientAsync(int patientId)
        {
            return await GetPrescriptionsByPatientIdAsync(patientId);
        }

        public async Task<Prescription?> UpdatePrescriptionAsync(int id, Prescription prescription)
        {
            try
            {
                var existingPrescription = await _context.Prescriptions.FindAsync(id);
                if (existingPrescription == null)
                    return null;

                existingPrescription.Dosage = prescription.Dosage;
                existingPrescription.Instructions = prescription.Instructions;
                existingPrescription.StartDate = prescription.StartDate;
                existingPrescription.EndDate = prescription.EndDate;
                existingPrescription.Refills = prescription.Refills;
                existingPrescription.UpdatedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();
                return existingPrescription;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while updating prescription: {PrescriptionId}", id);
                throw;
            }
        }

        public async Task<bool> RefillPrescriptionAsync(int prescriptionId, DateTime newStartDate)
        {
            try
            {
                var prescription = await _context.Prescriptions.FindAsync(prescriptionId);
                if (prescription == null || prescription.RefillsUsed >= prescription.Refills)
                    return false;

                prescription.RefillsUsed++;
                prescription.StartDate = newStartDate;
                prescription.EndDate = newStartDate.AddDays(30); // Assuming 30-day refill
                prescription.UpdatedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while refilling prescription: {PrescriptionId}", prescriptionId);
                return false;
            }
        }

        public async Task<IEnumerable<Prescription>> GetActivePrescriptionsAsync(int patientId)
        {
            try
            {
                return await _context.Prescriptions
                    .Include(p => p.Patient)
                    .Include(p => p.Doctor)
                    .Include(p => p.Medication)
                    .Where(p => p.PatientId == patientId && 
                               p.Status == "Active" && 
                               p.StartDate <= DateTime.UtcNow && 
                               p.EndDate >= DateTime.UtcNow)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving active prescriptions for patient: {PatientId}", patientId);
                throw;
            }
        }

        public async Task<IEnumerable<Prescription>> GetPrescriptionsDueForRefillAsync()
        {
            try
            {
                var refillDate = DateTime.UtcNow.AddDays(7); // Due for refill in next 7 days
                return await _context.Prescriptions
                    .Include(p => p.Patient)
                    .Include(p => p.Doctor)
                    .Include(p => p.Medication)
                    .Where(p => p.Status == "Active" && 
                               p.EndDate <= refillDate && 
                               p.RefillsUsed < p.Refills)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving prescriptions due for refill");
                throw;
            }
        }

        public async Task<object> GetDrugInteractionsAsync(List<int> medicationIds)
        {
            try
            {
                // In a real application, this would check against a drug interaction database
                var medications = await _context.Medications
                    .Where(m => medicationIds.Contains(m.Id))
                    .ToListAsync();

                // Placeholder implementation
                var interactions = new List<object>();
                for (int i = 0; i < medications.Count; i++)
                {
                    for (int j = i + 1; j < medications.Count; j++)
                    {
                        // Mock interaction check
                        interactions.Add(new
                        {
                            Drug1 = medications[i].Name,
                            Drug2 = medications[j].Name,
                            Severity = "Low", // Would be determined by actual drug interaction database
                            Description = $"Potential interaction between {medications[i].Name} and {medications[j].Name}"
                        });
                    }
                }

                return new
                {
                    InteractionCount = interactions.Count,
                    Interactions = interactions
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while checking drug interactions");
                throw;
            }
        }

        public async Task<object> GetDrugInteractionsAsync(int medicationId)
        {
            return await GetDrugInteractionsAsync(new List<int> { medicationId });
        }

        public async Task<IEnumerable<Prescription>> GetAllPrescriptionsAsync(int page, int pageSize)
        {
            try
            {
                return await _context.Prescriptions
                    .Include(p => p.Patient)
                    .Include(p => p.Doctor)
                    .Include(p => p.Medication)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving prescriptions with pagination");
                throw;
            }
        }

        public async Task<IEnumerable<Prescription>> GetPrescriptionsDueForRefillAsync(int daysAhead)
        {
            try
            {
                var refillDate = DateTime.UtcNow.AddDays(daysAhead);
                return await _context.Prescriptions
                    .Include(p => p.Patient)
                    .Include(p => p.Doctor)
                    .Include(p => p.Medication)
                    .Where(p => p.Status == "Active" && 
                               p.EndDate <= refillDate && 
                               p.RefillsUsed < p.Refills)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while retrieving prescriptions due for refill in {DaysAhead} days", daysAhead);
                throw;
            }
        }
    }
}
