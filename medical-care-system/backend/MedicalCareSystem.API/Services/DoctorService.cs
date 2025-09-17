using MedicalCareSystem.API.Data;
using MedicalCareSystem.API.Models;
using Microsoft.EntityFrameworkCore;

namespace MedicalCareSystem.API.Services
{
    public interface IDoctorService
    {
        Task<IEnumerable<Doctor>> GetAllDoctorsAsync(int page = 1, int pageSize = 10, string? search = null);
        Task<Doctor?> GetDoctorByIdAsync(int id);
        Task<Doctor> CreateDoctorAsync(Doctor doctor);
        Task<Doctor?> UpdateDoctorAsync(int id, Doctor doctor);
        Task<bool> DeleteDoctorAsync(int id);
        Task<bool> DoctorExistsAsync(int id);
        Task<bool> EmailExistsAsync(string email, int? excludeId = null);
        Task<bool> LicenseExistsAsync(string licenseNumber, int? excludeId = null);
        Task<IEnumerable<Doctor>> GetDoctorsBySpecialtyAsync(string specialty);
        Task<IEnumerable<Doctor>> GetAvailableDoctorsAsync(DateTime? date = null);
        Task<IEnumerable<Doctor>> GetDoctorsByDepartmentAsync(int departmentId);
        Task<IEnumerable<Doctor>> SearchDoctorsAsync(string searchTerm);
        Task<Doctor?> GetDoctorWithDetailsAsync(int id);
        Task<IEnumerable<Appointment>> GetDoctorAppointmentsAsync(int doctorId, DateTime? date = null);
        Task<IEnumerable<string>> GetSpecialtiesAsync();
        Task<bool> SetAvailabilityAsync(int doctorId, bool isAvailable);
        Task<int> GetTotalDoctorsCountAsync();
        Task<IEnumerable<Doctor>> GetDoctorsWithUpcomingAppointmentsAsync();
        Task<Doctor?> GetDoctorByLicenseAsync(string licenseNumber);
        Task<IEnumerable<Patient>> GetDoctorPatientsAsync(int doctorId);
        Task<IEnumerable<object>> GetAvailableSlotsAsync(int doctorId, DateTime date, int duration);
        Task<bool> SetAvailabilityAsync(int doctorId, DateTime startTime, DateTime endTime, bool isAvailable);
        Task<object> GetDoctorSpecialtyStatsAsync();
        Task<object> GetDoctorDepartmentStatsAsync();
        Task<IEnumerable<string>> GetUniqueSpecialtiesAsync();
    }

    public class DoctorService : IDoctorService
    {
        private readonly MedicalCareContext _context;
        private readonly ILogger<DoctorService> _logger;

        public DoctorService(MedicalCareContext context, ILogger<DoctorService> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<IEnumerable<Doctor>> GetAllDoctorsAsync(int page = 1, int pageSize = 10, string? search = null)
        {
            try
            {
                var query = _context.Doctors
                    .Include(d => d.Department)
                    .AsQueryable();

                if (!string.IsNullOrEmpty(search))
                {
                    query = query.Where(d => 
                        d.FirstName.Contains(search) || 
                        d.LastName.Contains(search) ||
                        d.Email.Contains(search) ||
                        d.Specialty.Contains(search) ||
                        d.LicenseNumber.Contains(search));
                }

                return await query
                    .OrderBy(d => d.LastName)
                    .ThenBy(d => d.FirstName)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving doctors");
                throw;
            }
        }

        public async Task<Doctor?> GetDoctorByIdAsync(int id)
        {
            try
            {
                return await _context.Doctors
                    .Include(d => d.Department)
                    .FirstOrDefaultAsync(d => d.Id == id);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving doctor with ID {DoctorId}", id);
                throw;
            }
        }

        public async Task<Doctor?> GetDoctorWithDetailsAsync(int id)
        {
            try
            {
                return await _context.Doctors
                    .Include(d => d.Department)
                    .Include(d => d.Appointments.Where(a => a.AppointmentDate >= DateTime.Today))
                        .ThenInclude(a => a.Patient)
                    .Include(d => d.MedicalRecords.OrderByDescending(mr => mr.RecordDate).Take(10))
                        .ThenInclude(mr => mr.Patient)
                    .FirstOrDefaultAsync(d => d.Id == id);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving doctor details for ID {DoctorId}", id);
                throw;
            }
        }

        public async Task<Doctor> CreateDoctorAsync(Doctor doctor)
        {
            try
            {
                doctor.CreatedAt = DateTime.UtcNow;

                _context.Doctors.Add(doctor);
                await _context.SaveChangesAsync();

                _logger.LogInformation("Created new doctor with ID {DoctorId}", doctor.Id);
                return doctor;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating doctor");
                throw;
            }
        }

        public async Task<Doctor?> UpdateDoctorAsync(int id, Doctor doctor)
        {
            try
            {
                var existingDoctor = await _context.Doctors.FindAsync(id);
                if (existingDoctor == null)
                    return null;

                // Update properties
                existingDoctor.FirstName = doctor.FirstName;
                existingDoctor.LastName = doctor.LastName;
                existingDoctor.Email = doctor.Email;
                existingDoctor.PhoneNumber = doctor.PhoneNumber;
                existingDoctor.Specialty = doctor.Specialty;
                existingDoctor.LicenseNumber = doctor.LicenseNumber;
                existingDoctor.DepartmentId = doctor.DepartmentId;
                existingDoctor.Qualifications = doctor.Qualifications;
                existingDoctor.YearsOfExperience = doctor.YearsOfExperience;
                existingDoctor.IsAvailable = doctor.IsAvailable;
                existingDoctor.Bio = doctor.Bio;
                existingDoctor.UpdatedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();

                _logger.LogInformation("Updated doctor with ID {DoctorId}", id);
                return existingDoctor;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating doctor with ID {DoctorId}", id);
                throw;
            }
        }

        public async Task<bool> DeleteDoctorAsync(int id)
        {
            try
            {
                var doctor = await _context.Doctors.FindAsync(id);
                if (doctor == null)
                    return false;

                // Check if doctor has any appointments
                var hasAppointments = await _context.Appointments
                    .AnyAsync(a => a.DoctorId == id);

                if (hasAppointments)
                {
                    _logger.LogWarning("Cannot delete doctor with ID {DoctorId} - has existing appointments", id);
                    throw new InvalidOperationException("Cannot delete doctor with existing appointments");
                }

                _context.Doctors.Remove(doctor);
                await _context.SaveChangesAsync();

                _logger.LogInformation("Deleted doctor with ID {DoctorId}", id);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting doctor with ID {DoctorId}", id);
                throw;
            }
        }

        public async Task<bool> DoctorExistsAsync(int id)
        {
            try
            {
                return await _context.Doctors.AnyAsync(d => d.Id == id);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking if doctor exists with ID {DoctorId}", id);
                throw;
            }
        }

        public async Task<bool> EmailExistsAsync(string email, int? excludeId = null)
        {
            try
            {
                var query = _context.Doctors.Where(d => d.Email == email);
                
                if (excludeId.HasValue)
                    query = query.Where(d => d.Id != excludeId.Value);

                return await query.AnyAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking if email exists: {Email}", email);
                throw;
            }
        }

        public async Task<bool> LicenseExistsAsync(string licenseNumber, int? excludeId = null)
        {
            try
            {
                var query = _context.Doctors.Where(d => d.LicenseNumber == licenseNumber);
                
                if (excludeId.HasValue)
                    query = query.Where(d => d.Id != excludeId.Value);

                return await query.AnyAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking if license exists: {LicenseNumber}", licenseNumber);
                throw;
            }
        }

        public async Task<IEnumerable<Doctor>> GetDoctorsBySpecialtyAsync(string specialty)
        {
            try
            {
                return await _context.Doctors
                    .Include(d => d.Department)
                    .Where(d => d.Specialty.Contains(specialty) && d.IsAvailable)
                    .OrderBy(d => d.LastName)
                    .ThenBy(d => d.FirstName)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving doctors by specialty: {Specialty}", specialty);
                throw;
            }
        }

        public async Task<IEnumerable<Doctor>> GetAvailableDoctorsAsync()
        {
            try
            {
                return await _context.Doctors
                    .Include(d => d.Department)
                    .Where(d => d.IsAvailable)
                    .OrderBy(d => d.Specialty)
                    .ThenBy(d => d.LastName)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving available doctors");
                throw;
            }
        }

        public async Task<IEnumerable<Doctor>> GetDoctorsByDepartmentAsync(int departmentId)
        {
            try
            {
                return await _context.Doctors
                    .Include(d => d.Department)
                    .Where(d => d.DepartmentId == departmentId)
                    .OrderBy(d => d.LastName)
                    .ThenBy(d => d.FirstName)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving doctors by department: {DepartmentId}", departmentId);
                throw;
            }
        }

        public async Task<IEnumerable<Doctor>> SearchDoctorsAsync(string searchTerm)
        {
            try
            {
                return await _context.Doctors
                    .Include(d => d.Department)
                    .Where(d => 
                        d.FirstName.Contains(searchTerm) || 
                        d.LastName.Contains(searchTerm) ||
                        d.Email.Contains(searchTerm) ||
                        d.Specialty.Contains(searchTerm) ||
                        d.LicenseNumber.Contains(searchTerm))
                    .OrderBy(d => d.LastName)
                    .ThenBy(d => d.FirstName)
                    .Take(50)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching doctors with term: {SearchTerm}", searchTerm);
                throw;
            }
        }

        public async Task<IEnumerable<Appointment>> GetDoctorAppointmentsAsync(int doctorId, DateTime? date = null)
        {
            try
            {
                var query = _context.Appointments
                    .Include(a => a.Patient)
                    .Include(a => a.Room)
                    .Where(a => a.DoctorId == doctorId);

                if (date.HasValue)
                {
                    query = query.Where(a => a.AppointmentDate.Date == date.Value.Date);
                }
                else
                {
                    query = query.Where(a => a.AppointmentDate >= DateTime.Today);
                }

                return await query
                    .OrderBy(a => a.AppointmentDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving appointments for doctor {DoctorId}", doctorId);
                throw;
            }
        }

        public async Task<IEnumerable<string>> GetSpecialtiesAsync()
        {
            try
            {
                return await _context.Doctors
                    .Select(d => d.Specialty)
                    .Distinct()
                    .OrderBy(s => s)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving specialties");
                throw;
            }
        }

        public async Task<bool> SetAvailabilityAsync(int doctorId, bool isAvailable)
        {
            try
            {
                var doctor = await _context.Doctors.FindAsync(doctorId);
                if (doctor == null)
                    return false;

                doctor.IsAvailable = isAvailable;
                doctor.UpdatedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();

                _logger.LogInformation("Set availability for doctor {DoctorId} to {IsAvailable}", doctorId, isAvailable);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error setting availability for doctor {DoctorId}", doctorId);
                throw;
            }
        }

        public async Task<int> GetTotalDoctorsCountAsync()
        {
            try
            {
                return await _context.Doctors.CountAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting total doctors count");
                throw;
            }
        }

        public async Task<IEnumerable<Doctor>> GetDoctorsWithUpcomingAppointmentsAsync()
        {
            try
            {
                var today = DateTime.Today;
                var tomorrow = today.AddDays(1);

                return await _context.Doctors
                    .Include(d => d.Department)
                    .Where(d => d.Appointments.Any(a => a.AppointmentDate >= today && a.AppointmentDate < tomorrow))
                    .OrderBy(d => d.LastName)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving doctors with upcoming appointments");
                throw;
            }
        }

        public async Task<Doctor?> GetDoctorByLicenseAsync(string licenseNumber)
        {
            try
            {
                return await _context.Doctors
                    .Include(d => d.Department)
                    .FirstOrDefaultAsync(d => d.LicenseNumber == licenseNumber);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving doctor by license number {LicenseNumber}", licenseNumber);
                throw;
            }
        }

        public async Task<IEnumerable<Doctor>> GetAvailableDoctorsAsync(DateTime? date = null)
        {
            try
            {
                var query = _context.Doctors
                    .Include(d => d.Department)
                    .Where(d => d.IsAvailable);

                if (date.HasValue)
                {
                    // In a real system, this would check doctor availability schedules
                    // For now, return all available doctors
                    query = query.Where(d => d.IsAvailable);
                }

                return await query.OrderBy(d => d.LastName).ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving available doctors");
                throw;
            }
        }

        public async Task<IEnumerable<Patient>> GetDoctorPatientsAsync(int doctorId)
        {
            try
            {
                return await _context.Patients
                    .Where(p => p.Appointments!.Any(a => a.DoctorId == doctorId))
                    .Distinct()
                    .OrderBy(p => p.LastName)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving patients for doctor {DoctorId}", doctorId);
                throw;
            }
        }

        public async Task<IEnumerable<object>> GetAvailableSlotsAsync(int doctorId, DateTime date, int duration)
        {
            try
            {
                // This is a simplified implementation
                // In a real system, this would check actual availability schedules
                var startTime = new TimeSpan(9, 0, 0); // 9 AM
                var endTime = new TimeSpan(17, 0, 0); // 5 PM
                var slots = new List<object>();

                for (var time = startTime; time <= endTime.Subtract(TimeSpan.FromMinutes(duration)); time = time.Add(TimeSpan.FromMinutes(duration)))
                {
                    var slotDateTime = date.Date.Add(time);
                    var isBooked = await _context.Appointments
                        .AnyAsync(a => a.DoctorId == doctorId && 
                                     a.AppointmentDate.Date == date.Date &&
                                     a.AppointmentDate.TimeOfDay == time);

                    if (!isBooked)
                    {
                        slots.Add(new { Time = time, DateTime = slotDateTime, Available = true });
                    }
                }

                return slots;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving available slots for doctor {DoctorId}", doctorId);
                throw;
            }
        }

        public async Task<bool> SetAvailabilityAsync(int doctorId, DateTime startTime, DateTime endTime, bool isAvailable)
        {
            try
            {
                // In a real system, this would update availability schedules
                // For now, just return true as a placeholder
                var doctor = await _context.Doctors.FindAsync(doctorId);
                if (doctor == null) return false;

                // This is a placeholder - in reality you'd have an availability table
                _logger.LogInformation("Set availability for doctor {DoctorId} from {StartTime} to {EndTime}: {IsAvailable}", 
                    doctorId, startTime, endTime, isAvailable);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error setting availability for doctor {DoctorId}", doctorId);
                throw;
            }
        }

        public async Task<object> GetDoctorSpecialtyStatsAsync()
        {
            try
            {
                var stats = await _context.Doctors
                    .GroupBy(d => d.Specialty)
                    .Select(g => new { Specialty = g.Key, Count = g.Count() })
                    .OrderByDescending(s => s.Count)
                    .ToListAsync();

                return stats;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving doctor specialty statistics");
                throw;
            }
        }

        public async Task<object> GetDoctorDepartmentStatsAsync()
        {
            try
            {
                var stats = await _context.Doctors
                    .Include(d => d.Department)
                    .GroupBy(d => d.Department!.Name)
                    .Select(g => new { Department = g.Key, Count = g.Count() })
                    .OrderByDescending(s => s.Count)
                    .ToListAsync();

                return stats;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving doctor department statistics");
                throw;
            }
        }

        public async Task<IEnumerable<string>> GetUniqueSpecialtiesAsync()
        {
            try
            {
                return await _context.Doctors
                    .Select(d => d.Specialty)
                    .Distinct()
                    .Where(s => !string.IsNullOrEmpty(s))
                    .OrderBy(s => s)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving unique specialties");
                throw;
            }
        }
    }
}
