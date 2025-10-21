using MedicalCareSystem.API.Data;
using MedicalCareSystem.API.Models;
using Microsoft.EntityFrameworkCore;

namespace MedicalCareSystem.API.Services
{
    public interface IMedicalRecordService
    {
        Task<IEnumerable<MedicalRecord>> GetAllMedicalRecordsAsync(int page = 1, int pageSize = 10);
        Task<MedicalRecord?> GetMedicalRecordByIdAsync(int id);
        Task<MedicalRecord> CreateMedicalRecordAsync(MedicalRecord medicalRecord);
        Task<MedicalRecord?> UpdateMedicalRecordAsync(int id, MedicalRecord medicalRecord);
        Task<bool> DeleteMedicalRecordAsync(int id);
        Task<bool> MedicalRecordExistsAsync(int id);
        Task<IEnumerable<MedicalRecord>> GetMedicalRecordsByPatientAsync(int patientId);
        Task<IEnumerable<MedicalRecord>> GetMedicalRecordsByDoctorAsync(int doctorId);
        Task<IEnumerable<MedicalRecord>> GetMedicalRecordsByAppointmentAsync(int appointmentId);
        Task<MedicalRecord?> GetMedicalRecordWithDetailsAsync(int id);
        Task<IEnumerable<MedicalRecord>> SearchMedicalRecordsAsync(string searchTerm);
        Task<IEnumerable<MedicalRecord>> GetRecentMedicalRecordsAsync(int patientId, int days = 30);
        Task<IEnumerable<MedicalRecord>> GetMedicalRecordsByDateRangeAsync(int patientId, DateTime startDate, DateTime endDate);
        Task<string> GenerateMedicalSummaryAsync(int patientId);
        Task<IEnumerable<string>> GetUniqueConditionsAsync();
        Task<IEnumerable<string>> GetUniqueTreatmentsAsync();
        Task<int> GetTotalMedicalRecordsCountAsync();
        Task<Dictionary<string, int>> GetConditionStatsAsync();
        Task<bool> AddPrescriptionToRecordAsync(int recordId, Prescription prescription);
        Task<bool> RemovePrescriptionFromRecordAsync(int recordId, int prescriptionId);
        Task<IEnumerable<MedicalRecord>> GetCriticalMedicalRecordsAsync();
    }

    public class MedicalRecordService : IMedicalRecordService
    {
        private readonly MedicalCareContext _context;
        private readonly ILogger<MedicalRecordService> _logger;

        public MedicalRecordService(MedicalCareContext context, ILogger<MedicalRecordService> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<IEnumerable<MedicalRecord>> GetAllMedicalRecordsAsync(int page = 1, int pageSize = 10)
        {
            try
            {
                return await _context.MedicalRecords
                    .Include(mr => mr.Patient)
                    .Include(mr => mr.Doctor)
                    .Include(mr => mr.Appointment)
                    .OrderByDescending(mr => mr.RecordDate)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving medical records");
                throw;
            }
        }

        public async Task<MedicalRecord?> GetMedicalRecordByIdAsync(int id)
        {
            try
            {
                return await _context.MedicalRecords
                    .Include(mr => mr.Patient)
                    .Include(mr => mr.Doctor)
                    .Include(mr => mr.Appointment)
                    .Include(mr => mr.Prescriptions)
                        .ThenInclude(p => p.Medication)
                    .FirstOrDefaultAsync(mr => mr.Id == id);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving medical record with ID {MedicalRecordId}", id);
                throw;
            }
        }

        public async Task<MedicalRecord?> GetMedicalRecordWithDetailsAsync(int id)
        {
            try
            {
                return await _context.MedicalRecords
                    .Include(mr => mr.Patient)
                        .ThenInclude(p => p.Insurances)
                    .Include(mr => mr.Doctor)
                        .ThenInclude(d => d.Department)
                    .Include(mr => mr.Appointment)
                        .ThenInclude(a => a.Room)
                    .Include(mr => mr.Prescriptions)
                        .ThenInclude(p => p.Medication)
                    .Include(mr => mr.Labs)
                    .Include(mr => mr.Imaging)
                    .Include(mr => mr.VitalSigns)
                    .FirstOrDefaultAsync(mr => mr.Id == id);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving detailed medical record with ID {MedicalRecordId}", id);
                throw;
            }
        }

        public async Task<MedicalRecord> CreateMedicalRecordAsync(MedicalRecord medicalRecord)
        {
            try
            {
                medicalRecord.RecordDate = DateTime.UtcNow;
                medicalRecord.CreatedAt = DateTime.UtcNow;

                _context.MedicalRecords.Add(medicalRecord);
                await _context.SaveChangesAsync();

                _logger.LogInformation("Created new medical record with ID {MedicalRecordId} for patient {PatientId}", 
                    medicalRecord.Id, medicalRecord.PatientId);
                return medicalRecord;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating medical record for patient {PatientId}", medicalRecord.PatientId);
                throw;
            }
        }

        public async Task<MedicalRecord?> UpdateMedicalRecordAsync(int id, MedicalRecord medicalRecord)
        {
            try
            {
                var existingRecord = await _context.MedicalRecords.FindAsync(id);
                if (existingRecord == null)
                    return null;

                // Update properties
                existingRecord.PatientId = medicalRecord.PatientId;
                existingRecord.DoctorId = medicalRecord.DoctorId;
                existingRecord.AppointmentId = medicalRecord.AppointmentId;
                existingRecord.ChiefComplaint = medicalRecord.ChiefComplaint;
                existingRecord.HistoryOfPresentIllness = medicalRecord.HistoryOfPresentIllness;
                existingRecord.PhysicalExamination = medicalRecord.PhysicalExamination;
                existingRecord.Assessment = medicalRecord.Assessment;
                existingRecord.Plan = medicalRecord.Plan;
                existingRecord.Diagnosis = medicalRecord.Diagnosis;
                existingRecord.Treatment = medicalRecord.Treatment;
                existingRecord.Notes = medicalRecord.Notes;
                existingRecord.FollowUpDate = medicalRecord.FollowUpDate;
                existingRecord.FollowUpInstructions = medicalRecord.FollowUpInstructions;
                existingRecord.UpdatedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();

                _logger.LogInformation("Updated medical record with ID {MedicalRecordId}", id);
                return existingRecord;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating medical record with ID {MedicalRecordId}", id);
                throw;
            }
        }

        public async Task<bool> DeleteMedicalRecordAsync(int id)
        {
            try
            {
                var medicalRecord = await _context.MedicalRecords.FindAsync(id);
                if (medicalRecord == null)
                    return false;

                _context.MedicalRecords.Remove(medicalRecord);
                await _context.SaveChangesAsync();

                _logger.LogInformation("Deleted medical record with ID {MedicalRecordId}", id);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting medical record with ID {MedicalRecordId}", id);
                throw;
            }
        }

        public async Task<bool> MedicalRecordExistsAsync(int id)
        {
            try
            {
                return await _context.MedicalRecords.AnyAsync(mr => mr.Id == id);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking if medical record exists with ID {MedicalRecordId}", id);
                throw;
            }
        }

        public async Task<IEnumerable<MedicalRecord>> GetMedicalRecordsByPatientAsync(int patientId)
        {
            try
            {
                return await _context.MedicalRecords
                    .Include(mr => mr.Doctor)
                    .Include(mr => mr.Appointment)
                    .Include(mr => mr.Prescriptions)
                        .ThenInclude(p => p.Medication)
                    .Where(mr => mr.PatientId == patientId)
                    .OrderByDescending(mr => mr.RecordDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving medical records for patient {PatientId}", patientId);
                throw;
            }
        }

        public async Task<IEnumerable<MedicalRecord>> GetMedicalRecordsByDoctorAsync(int doctorId)
        {
            try
            {
                return await _context.MedicalRecords
                    .Include(mr => mr.Patient)
                    .Include(mr => mr.Appointment)
                    .Where(mr => mr.DoctorId == doctorId)
                    .OrderByDescending(mr => mr.RecordDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving medical records for doctor {DoctorId}", doctorId);
                throw;
            }
        }

        public async Task<IEnumerable<MedicalRecord>> GetMedicalRecordsByAppointmentAsync(int appointmentId)
        {
            try
            {
                return await _context.MedicalRecords
                    .Include(mr => mr.Patient)
                    .Include(mr => mr.Doctor)
                    .Include(mr => mr.Prescriptions)
                        .ThenInclude(p => p.Medication)
                    .Where(mr => mr.AppointmentId == appointmentId)
                    .OrderByDescending(mr => mr.RecordDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving medical records for appointment {AppointmentId}", appointmentId);
                throw;
            }
        }

        public async Task<IEnumerable<MedicalRecord>> SearchMedicalRecordsAsync(string searchTerm)
        {
            try
            {
                return await _context.MedicalRecords
                    .Include(mr => mr.Patient)
                    .Include(mr => mr.Doctor)
                    .Where(mr => 
                        mr.ChiefComplaint.Contains(searchTerm) ||
                        mr.Diagnosis.Contains(searchTerm) ||
                        mr.Treatment.Contains(searchTerm) ||
                        mr.Assessment.Contains(searchTerm) ||
                        mr.Patient.FirstName.Contains(searchTerm) ||
                        mr.Patient.LastName.Contains(searchTerm) ||
                        mr.Doctor.FirstName.Contains(searchTerm) ||
                        mr.Doctor.LastName.Contains(searchTerm))
                    .OrderByDescending(mr => mr.RecordDate)
                    .Take(50)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching medical records with term: {SearchTerm}", searchTerm);
                throw;
            }
        }

        public async Task<IEnumerable<MedicalRecord>> GetRecentMedicalRecordsAsync(int patientId, int days = 30)
        {
            try
            {
                var cutoffDate = DateTime.UtcNow.AddDays(-days);
                
                return await _context.MedicalRecords
                    .Include(mr => mr.Doctor)
                    .Include(mr => mr.Appointment)
                    .Include(mr => mr.Prescriptions)
                        .ThenInclude(p => p.Medication)
                    .Where(mr => mr.PatientId == patientId && mr.RecordDate >= cutoffDate)
                    .OrderByDescending(mr => mr.RecordDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving recent medical records for patient {PatientId}", patientId);
                throw;
            }
        }

        public async Task<IEnumerable<MedicalRecord>> GetMedicalRecordsByDateRangeAsync(int patientId, DateTime startDate, DateTime endDate)
        {
            try
            {
                return await _context.MedicalRecords
                    .Include(mr => mr.Doctor)
                    .Include(mr => mr.Appointment)
                    .Include(mr => mr.Prescriptions)
                        .ThenInclude(p => p.Medication)
                    .Where(mr => mr.PatientId == patientId && 
                                mr.RecordDate >= startDate && 
                                mr.RecordDate <= endDate)
                    .OrderByDescending(mr => mr.RecordDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving medical records for patient {PatientId} in date range", patientId);
                throw;
            }
        }

        public async Task<string> GenerateMedicalSummaryAsync(int patientId)
        {
            try
            {
                var records = await GetMedicalRecordsByPatientAsync(patientId);
                var patient = await _context.Patients.FindAsync(patientId);

                if (patient == null || !records.Any())
                    return "No medical records found for this patient.";

                var summary = $"Medical Summary for {patient.FirstName} {patient.LastName} (DOB: {patient.DateOfBirth:yyyy-MM-dd})\n\n";
                
                // Recent visits
                summary += "Recent Visits:\n";
                foreach (var record in records.Take(5))
                {
                    summary += $"- {record.RecordDate:yyyy-MM-dd}: {record.ChiefComplaint}\n";
                    if (!string.IsNullOrEmpty(record.Diagnosis))
                        summary += $"  Diagnosis: {record.Diagnosis}\n";
                }

                // Unique diagnoses
                var diagnoses = records.Where(r => !string.IsNullOrEmpty(r.Diagnosis))
                                     .Select(r => r.Diagnosis)
                                     .Distinct()
                                     .ToList();
                
                if (diagnoses.Any())
                {
                    summary += "\nDiagnoses History:\n";
                    foreach (var diagnosis in diagnoses.Take(10))
                    {
                        summary += $"- {diagnosis}\n";
                    }
                }

                // Current medications
                var currentPrescriptions = records.SelectMany(r => r.Prescriptions)
                                                 .Where(p => p.EndDate == null || p.EndDate > DateTime.UtcNow)
                                                 .Select(p => p.Medication?.Name)
                                                 .Distinct()
                                                 .ToList();

                if (currentPrescriptions.Any())
                {
                    summary += "\nCurrent Medications:\n";
                    foreach (var medication in currentPrescriptions)
                    {
                        summary += $"- {medication}\n";
                    }
                }

                return summary;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating medical summary for patient {PatientId}", patientId);
                throw;
            }
        }

        public async Task<IEnumerable<string>> GetUniqueConditionsAsync()
        {
            try
            {
                return await _context.MedicalRecords
                    .Where(mr => !string.IsNullOrEmpty(mr.Diagnosis))
                    .Select(mr => mr.Diagnosis)
                    .Distinct()
                    .OrderBy(d => d)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving unique conditions");
                throw;
            }
        }

        public async Task<IEnumerable<string>> GetUniqueTreatmentsAsync()
        {
            try
            {
                return await _context.MedicalRecords
                    .Where(mr => !string.IsNullOrEmpty(mr.Treatment))
                    .Select(mr => mr.Treatment)
                    .Distinct()
                    .OrderBy(t => t)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving unique treatments");
                throw;
            }
        }

        public async Task<int> GetTotalMedicalRecordsCountAsync()
        {
            try
            {
                return await _context.MedicalRecords.CountAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting total medical records count");
                throw;
            }
        }

        public async Task<Dictionary<string, int>> GetConditionStatsAsync()
        {
            try
            {
                return await _context.MedicalRecords
                    .Where(mr => !string.IsNullOrEmpty(mr.Diagnosis))
                    .GroupBy(mr => mr.Diagnosis)
                    .ToDictionaryAsync(g => g.Key, g => g.Count());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting condition statistics");
                throw;
            }
        }

        public async Task<bool> AddPrescriptionToRecordAsync(int recordId, Prescription prescription)
        {
            try
            {
                var record = await _context.MedicalRecords.FindAsync(recordId);
                if (record == null)
                    return false;

                prescription.MedicalRecordId = recordId;
                prescription.CreatedAt = DateTime.UtcNow;

                _context.Prescriptions.Add(prescription);
                await _context.SaveChangesAsync();

                _logger.LogInformation("Added prescription to medical record {RecordId}", recordId);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error adding prescription to record {RecordId}", recordId);
                throw;
            }
        }

        public async Task<bool> RemovePrescriptionFromRecordAsync(int recordId, int prescriptionId)
        {
            try
            {
                var prescription = await _context.Prescriptions
                    .FirstOrDefaultAsync(p => p.Id == prescriptionId && p.MedicalRecordId == recordId);
                
                if (prescription == null)
                    return false;

                _context.Prescriptions.Remove(prescription);
                await _context.SaveChangesAsync();

                _logger.LogInformation("Removed prescription {PrescriptionId} from medical record {RecordId}", 
                    prescriptionId, recordId);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error removing prescription {PrescriptionId} from record {RecordId}", 
                    prescriptionId, recordId);
                throw;
            }
        }

        public async Task<IEnumerable<MedicalRecord>> GetCriticalMedicalRecordsAsync()
        {
            try
            {
                // Define critical conditions (this could be configurable)
                var criticalKeywords = new[] { "critical", "emergency", "urgent", "severe", "acute", "crisis" };
                
                return await _context.MedicalRecords
                    .Include(mr => mr.Patient)
                    .Include(mr => mr.Doctor)
                    .Where(mr => criticalKeywords.Any(keyword => 
                        mr.ChiefComplaint.ToLower().Contains(keyword) ||
                        mr.Diagnosis.ToLower().Contains(keyword) ||
                        mr.Assessment.ToLower().Contains(keyword)))
                    .OrderByDescending(mr => mr.RecordDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving critical medical records");
                throw;
            }
        }
    }
}
