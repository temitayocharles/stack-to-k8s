using MedicalCareSystem.API.Data;
using MedicalCareSystem.API.Models;
using Microsoft.EntityFrameworkCore;

namespace MedicalCareSystem.API.Services
{
    public interface IPatientService
    {
        Task<IEnumerable<Patient>> GetAllPatientsAsync(int page = 1, int pageSize = 10, string? search = null);
        Task<Patient?> GetPatientByIdAsync(int id);
        Task<Patient?> GetPatientByNumberAsync(string patientNumber);
        Task<Patient> CreatePatientAsync(Patient patient);
        Task<Patient?> UpdatePatientAsync(int id, Patient patient);
        Task<bool> DeletePatientAsync(int id);
        Task<bool> PatientExistsAsync(int id);
        Task<bool> EmailExistsAsync(string email, int? excludeId = null);
        Task<IEnumerable<Patient>> SearchPatientsAsync(string searchTerm);
        Task<int> GetTotalPatientsCountAsync();
        Task<IEnumerable<Appointment>> GetPatientAppointmentsAsync(int patientId);
        Task<IEnumerable<MedicalRecord>> GetPatientMedicalRecordsAsync(int patientId);
        Task<IEnumerable<Prescription>> GetPatientPrescriptionsAsync(int patientId);
        Task<Patient?> GetPatientWithDetailsAsync(int id);
        Task<IEnumerable<Patient>> GetPatientsByGenderAsync(string gender);
        Task<IEnumerable<Patient>> GetPatientsByAgeRangeAsync(int minAge, int maxAge);
        Task<object> GetPatientGenderStatsAsync();
        Task<object> GetPatientAgeGroupStatsAsync();
        Task<IEnumerable<Patient>> GetTodaysPatients();
        Task<IEnumerable<Patient>> GetRecentPatientsAsync(int days);
        Task<object> GeneratePatientSummaryAsync(int id);
    }

    public class PatientService : IPatientService
    {
        private readonly MedicalCareContext _context;
        private readonly ILogger<PatientService> _logger;

        public PatientService(MedicalCareContext context, ILogger<PatientService> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<IEnumerable<Patient>> GetAllPatientsAsync(int page = 1, int pageSize = 10, string? search = null)
        {
            try
            {
                var query = _context.Patients.AsQueryable();

                if (!string.IsNullOrEmpty(search))
                {
                    query = query.Where(p => 
                        p.FirstName.Contains(search) || 
                        p.LastName.Contains(search) ||
                        p.Email.Contains(search) ||
                        p.PatientNumber.Contains(search));
                }

                return await query
                    .OrderBy(p => p.LastName)
                    .ThenBy(p => p.FirstName)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving patients");
                throw;
            }
        }

        public async Task<Patient?> GetPatientByIdAsync(int id)
        {
            try
            {
                return await _context.Patients
                    .FirstOrDefaultAsync(p => p.Id == id);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving patient with ID {PatientId}", id);
                throw;
            }
        }

        public async Task<Patient?> GetPatientByNumberAsync(string patientNumber)
        {
            try
            {
                return await _context.Patients
                    .FirstOrDefaultAsync(p => p.PatientNumber == patientNumber);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving patient with number {PatientNumber}", patientNumber);
                throw;
            }
        }

        public async Task<Patient?> GetPatientWithDetailsAsync(int id)
        {
            try
            {
                return await _context.Patients
                    .Include(p => p.Appointments)
                        .ThenInclude(a => a.Doctor)
                    .Include(p => p.MedicalRecords)
                        .ThenInclude(mr => mr.Doctor)
                    .Include(p => p.Prescriptions)
                        .ThenInclude(pr => pr.Medication)
                    .Include(p => p.Insurances)
                    .Include(p => p.VitalSigns)
                    .FirstOrDefaultAsync(p => p.Id == id);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving patient details for ID {PatientId}", id);
                throw;
            }
        }

        public async Task<Patient> CreatePatientAsync(Patient patient)
        {
            try
            {
                // Generate patient number
                patient.PatientNumber = await GeneratePatientNumberAsync();
                patient.CreatedAt = DateTime.UtcNow;

                _context.Patients.Add(patient);
                await _context.SaveChangesAsync();

                _logger.LogInformation("Created new patient with ID {PatientId}", patient.Id);
                return patient;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating patient");
                throw;
            }
        }

        public async Task<Patient?> UpdatePatientAsync(int id, Patient patient)
        {
            try
            {
                var existingPatient = await _context.Patients.FindAsync(id);
                if (existingPatient == null)
                    return null;

                // Update properties
                existingPatient.FirstName = patient.FirstName;
                existingPatient.LastName = patient.LastName;
                existingPatient.Email = patient.Email;
                existingPatient.PhoneNumber = patient.PhoneNumber;
                existingPatient.DateOfBirth = patient.DateOfBirth;
                existingPatient.Gender = patient.Gender;
                existingPatient.Address = patient.Address;
                existingPatient.EmergencyContact = patient.EmergencyContact;
                existingPatient.EmergencyContactPhone = patient.EmergencyContactPhone;
                existingPatient.BloodType = patient.BloodType;
                existingPatient.Allergies = patient.Allergies;
                existingPatient.MedicalConditions = patient.MedicalConditions;
                existingPatient.UpdatedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();

                _logger.LogInformation("Updated patient with ID {PatientId}", id);
                return existingPatient;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating patient with ID {PatientId}", id);
                throw;
            }
        }

        public async Task<bool> DeletePatientAsync(int id)
        {
            try
            {
                var patient = await _context.Patients.FindAsync(id);
                if (patient == null)
                    return false;

                _context.Patients.Remove(patient);
                await _context.SaveChangesAsync();

                _logger.LogInformation("Deleted patient with ID {PatientId}", id);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting patient with ID {PatientId}", id);
                throw;
            }
        }

        public async Task<bool> PatientExistsAsync(int id)
        {
            try
            {
                return await _context.Patients.AnyAsync(p => p.Id == id);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking if patient exists with ID {PatientId}", id);
                throw;
            }
        }

        public async Task<bool> EmailExistsAsync(string email, int? excludeId = null)
        {
            try
            {
                var query = _context.Patients.Where(p => p.Email == email);
                
                if (excludeId.HasValue)
                    query = query.Where(p => p.Id != excludeId.Value);

                return await query.AnyAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking if email exists: {Email}", email);
                throw;
            }
        }

        public async Task<IEnumerable<Patient>> SearchPatientsAsync(string searchTerm)
        {
            try
            {
                return await _context.Patients
                    .Where(p => 
                        p.FirstName.Contains(searchTerm) || 
                        p.LastName.Contains(searchTerm) ||
                        p.Email.Contains(searchTerm) ||
                        p.PatientNumber.Contains(searchTerm) ||
                        p.PhoneNumber.Contains(searchTerm))
                    .OrderBy(p => p.LastName)
                    .ThenBy(p => p.FirstName)
                    .Take(50)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching patients with term: {SearchTerm}", searchTerm);
                throw;
            }
        }

        public async Task<int> GetTotalPatientsCountAsync()
        {
            try
            {
                return await _context.Patients.CountAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting total patients count");
                throw;
            }
        }

        public async Task<IEnumerable<Appointment>> GetPatientAppointmentsAsync(int patientId)
        {
            try
            {
                return await _context.Appointments
                    .Include(a => a.Doctor)
                    .Include(a => a.Room)
                    .Where(a => a.PatientId == patientId)
                    .OrderByDescending(a => a.AppointmentDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving appointments for patient {PatientId}", patientId);
                throw;
            }
        }

        public async Task<IEnumerable<MedicalRecord>> GetPatientMedicalRecordsAsync(int patientId)
        {
            try
            {
                return await _context.MedicalRecords
                    .Include(mr => mr.Doctor)
                    .Include(mr => mr.Prescriptions)
                        .ThenInclude(p => p.Medication)
                    .Include(mr => mr.VitalSigns)
                    .Include(mr => mr.Labs)
                    .Include(mr => mr.Imaging)
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

        public async Task<IEnumerable<Prescription>> GetPatientPrescriptionsAsync(int patientId)
        {
            try
            {
                return await _context.Prescriptions
                    .Include(p => p.Medication)
                    .Include(p => p.Doctor)
                    .Where(p => p.PatientId == patientId)
                    .OrderByDescending(p => p.PrescribedDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving prescriptions for patient {PatientId}", patientId);
                throw;
            }
        }

        private async Task<string> GeneratePatientNumberAsync()
        {
            var year = DateTime.UtcNow.Year.ToString();
            var lastPatient = await _context.Patients
                .Where(p => p.PatientNumber.StartsWith($"PT{year}"))
                .OrderByDescending(p => p.PatientNumber)
                .FirstOrDefaultAsync();

            int nextNumber = 1;
            if (lastPatient != null && lastPatient.PatientNumber.Length >= 9)
            {
                if (int.TryParse(lastPatient.PatientNumber.Substring(6), out int lastNumber))
                {
                    nextNumber = lastNumber + 1;
                }
            }

            return $"PT{year}{nextNumber:D4}";
        }

        public async Task<IEnumerable<Patient>> GetPatientsByGenderAsync(string gender)
        {
            try
            {
                return await _context.Patients
                    .Where(p => p.Gender.ToLower() == gender.ToLower())
                    .OrderBy(p => p.LastName)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving patients by gender {Gender}", gender);
                throw;
            }
        }

        public async Task<IEnumerable<Patient>> GetPatientsByAgeRangeAsync(int minAge, int maxAge)
        {
            try
            {
                var today = DateTime.Today;
                var minBirthDate = today.AddYears(-maxAge - 1);
                var maxBirthDate = today.AddYears(-minAge);

                return await _context.Patients
                    .Where(p => p.DateOfBirth >= minBirthDate && p.DateOfBirth <= maxBirthDate)
                    .OrderBy(p => p.LastName)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving patients by age range {MinAge}-{MaxAge}", minAge, maxAge);
                throw;
            }
        }

        public async Task<object> GetPatientGenderStatsAsync()
        {
            try
            {
                var stats = await _context.Patients
                    .GroupBy(p => p.Gender)
                    .Select(g => new { Gender = g.Key, Count = g.Count() })
                    .OrderByDescending(s => s.Count)
                    .ToListAsync();

                return stats;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving patient gender statistics");
                throw;
            }
        }

        public async Task<object> GetPatientAgeGroupStatsAsync()
        {
            try
            {
                var today = DateTime.Today;
                var patients = await _context.Patients.ToListAsync();

                var ageGroups = patients
                    .GroupBy(p => {
                        var age = today.Year - p.DateOfBirth.Year;
                        if (p.DateOfBirth.Date > today.AddYears(-age)) age--;
                        
                        return age switch
                        {
                            < 18 => "Under 18",
                            >= 18 and < 30 => "18-29",
                            >= 30 and < 50 => "30-49",
                            >= 50 and < 65 => "50-64",
                            _ => "65+"
                        };
                    })
                    .Select(g => new { AgeGroup = g.Key, Count = g.Count() })
                    .OrderBy(s => s.AgeGroup)
                    .ToList();

                return ageGroups;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving patient age group statistics");
                throw;
            }
        }

        public async Task<IEnumerable<Patient>> GetTodaysPatients()
        {
            try
            {
                var today = DateTime.Today;
                var tomorrow = today.AddDays(1);

                return await _context.Patients
                    .Where(p => p.Appointments!.Any(a => a.AppointmentDate >= today && a.AppointmentDate < tomorrow))
                    .OrderBy(p => p.LastName)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving today's patients");
                throw;
            }
        }

        public async Task<IEnumerable<Patient>> GetRecentPatientsAsync(int days)
        {
            try
            {
                var cutoffDate = DateTime.Today.AddDays(-days);

                return await _context.Patients
                    .Where(p => p.CreatedAt >= cutoffDate)
                    .OrderByDescending(p => p.CreatedAt)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving recent patients for {Days} days", days);
                throw;
            }
        }

        public async Task<object> GeneratePatientSummaryAsync(int id)
        {
            try
            {
                var patient = await GetPatientWithDetailsAsync(id);
                if (patient == null)
                {
                    return new { Error = "Patient not found" };
                }

                var appointmentCount = patient.Appointments?.Count ?? 0;
                var medicalRecordCount = patient.MedicalRecords?.Count ?? 0;
                var prescriptionCount = patient.Prescriptions?.Count ?? 0;
                var billingCount = patient.Billings?.Count ?? 0;

                var lastAppointment = patient.Appointments?
                    .OrderByDescending(a => a.AppointmentDate)
                    .FirstOrDefault();

                var lastMedicalRecord = patient.MedicalRecords?
                    .OrderByDescending(mr => mr.RecordDate)
                    .FirstOrDefault();

                return new
                {
                    Patient = new
                    {
                        patient.Id,
                        patient.PatientNumber,
                        patient.FirstName,
                        patient.LastName,
                        patient.Email,
                        patient.PhoneNumber,
                        patient.DateOfBirth,
                        patient.Gender,
                        patient.BloodType,
                        patient.Allergies,
                        patient.MedicalConditions
                    },
                    Statistics = new
                    {
                        TotalAppointments = appointmentCount,
                        TotalMedicalRecords = medicalRecordCount,
                        TotalPrescriptions = prescriptionCount,
                        TotalBillings = billingCount
                    },
                    LastAppointment = lastAppointment?.AppointmentDate,
                    LastMedicalRecord = lastMedicalRecord?.RecordDate,
                    GeneratedAt = DateTime.UtcNow
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating patient summary for patient {PatientId}", id);
                throw;
            }
        }
    }
}
