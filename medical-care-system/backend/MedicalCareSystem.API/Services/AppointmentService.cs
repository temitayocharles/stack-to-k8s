using MedicalCareSystem.API.Data;
using MedicalCareSystem.API.Models;
using Microsoft.EntityFrameworkCore;

namespace MedicalCareSystem.API.Services
{
    public interface IAppointmentService
    {
        Task<IEnumerable<Appointment>> GetAllAppointmentsAsync(int page = 1, int pageSize = 10, DateTime? date = null);
        Task<Appointment?> GetAppointmentByIdAsync(int id);
        Task<Appointment?> GetAppointmentByNumberAsync(string appointmentNumber);
        Task<Appointment> CreateAppointmentAsync(Appointment appointment);
        Task<Appointment?> UpdateAppointmentAsync(int id, Appointment appointment);
        Task<bool> DeleteAppointmentAsync(int id);
        Task<bool> CancelAppointmentAsync(int id, string reason);
        Task<bool> AppointmentExistsAsync(int id);
        Task<IEnumerable<Appointment>> GetAppointmentsByPatientAsync(int patientId);
        Task<IEnumerable<Appointment>> GetAppointmentsByDoctorAsync(int doctorId, DateTime? date = null);
        Task<IEnumerable<Appointment>> GetAppointmentsByDateAsync(DateTime date);
        Task<IEnumerable<Appointment>> GetUpcomingAppointmentsAsync(int days = 7);
        Task<IEnumerable<Appointment>> GetTodaysAppointmentsAsync();
        Task<bool> IsTimeSlotAvailableAsync(int doctorId, DateTime appointmentDate, TimeSpan duration, int? excludeAppointmentId = null);
        Task<IEnumerable<DateTime>> GetAvailableSlotsAsync(int doctorId, DateTime date, TimeSpan duration);
        Task<bool> ConfirmAppointmentAsync(int id);
        Task<bool> CheckInPatientAsync(int id);
        Task<bool> CompleteAppointmentAsync(int id);
        Task<IEnumerable<Appointment>> SearchAppointmentsAsync(string searchTerm);
        Task<int> GetTotalAppointmentsCountAsync();
        Task<Appointment?> GetAppointmentWithDetailsAsync(int id);
        Task<Dictionary<string, int>> GetAppointmentStatusStatsAsync();
        Task<IEnumerable<Appointment>> GetOverdueAppointmentsAsync();
    }

    public class AppointmentService : IAppointmentService
    {
        private readonly MedicalCareContext _context;
        private readonly ILogger<AppointmentService> _logger;

        public AppointmentService(MedicalCareContext context, ILogger<AppointmentService> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<IEnumerable<Appointment>> GetAllAppointmentsAsync(int page = 1, int pageSize = 10, DateTime? date = null)
        {
            try
            {
                var query = _context.Appointments
                    .Include(a => a.Patient)
                    .Include(a => a.Doctor)
                    .Include(a => a.Room)
                    .AsQueryable();

                if (date.HasValue)
                {
                    query = query.Where(a => a.AppointmentDate.Date == date.Value.Date);
                }

                return await query
                    .OrderBy(a => a.AppointmentDate)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving appointments");
                throw;
            }
        }

        public async Task<Appointment?> GetAppointmentByIdAsync(int id)
        {
            try
            {
                return await _context.Appointments
                    .Include(a => a.Patient)
                    .Include(a => a.Doctor)
                    .Include(a => a.Room)
                    .FirstOrDefaultAsync(a => a.Id == id);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving appointment with ID {AppointmentId}", id);
                throw;
            }
        }

        public async Task<Appointment?> GetAppointmentByNumberAsync(string appointmentNumber)
        {
            try
            {
                return await _context.Appointments
                    .Include(a => a.Patient)
                    .Include(a => a.Doctor)
                    .Include(a => a.Room)
                    .FirstOrDefaultAsync(a => a.AppointmentNumber == appointmentNumber);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving appointment with number {AppointmentNumber}", appointmentNumber);
                throw;
            }
        }

        public async Task<Appointment?> GetAppointmentWithDetailsAsync(int id)
        {
            try
            {
                return await _context.Appointments
                    .Include(a => a.Patient)
                    .Include(a => a.Doctor)
                        .ThenInclude(d => d.Department)
                    .Include(a => a.Room)
                    .Include(a => a.MedicalRecords)
                        .ThenInclude(mr => mr.Prescriptions)
                            .ThenInclude(p => p.Medication)
                    .FirstOrDefaultAsync(a => a.Id == id);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving appointment details for ID {AppointmentId}", id);
                throw;
            }
        }

        public async Task<Appointment> CreateAppointmentAsync(Appointment appointment)
        {
            try
            {
                // Generate appointment number
                appointment.AppointmentNumber = await GenerateAppointmentNumberAsync();
                appointment.CreatedAt = DateTime.UtcNow;

                // Validate appointment time
                if (!await IsTimeSlotAvailableAsync(appointment.DoctorId, appointment.AppointmentDate, appointment.Duration))
                {
                    throw new InvalidOperationException("The selected time slot is not available");
                }

                _context.Appointments.Add(appointment);
                await _context.SaveChangesAsync();

                _logger.LogInformation("Created new appointment with ID {AppointmentId}", appointment.Id);
                return appointment;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating appointment");
                throw;
            }
        }

        public async Task<Appointment?> UpdateAppointmentAsync(int id, Appointment appointment)
        {
            try
            {
                var existingAppointment = await _context.Appointments.FindAsync(id);
                if (existingAppointment == null)
                    return null;

                // Validate new appointment time if changed
                if (existingAppointment.DoctorId != appointment.DoctorId || 
                    existingAppointment.AppointmentDate != appointment.AppointmentDate ||
                    existingAppointment.Duration != appointment.Duration)
                {
                    if (!await IsTimeSlotAvailableAsync(appointment.DoctorId, appointment.AppointmentDate, appointment.Duration, id))
                    {
                        throw new InvalidOperationException("The selected time slot is not available");
                    }
                }

                // Update properties
                existingAppointment.PatientId = appointment.PatientId;
                existingAppointment.DoctorId = appointment.DoctorId;
                existingAppointment.RoomId = appointment.RoomId;
                existingAppointment.AppointmentDate = appointment.AppointmentDate;
                existingAppointment.Duration = appointment.Duration;
                existingAppointment.Type = appointment.Type;
                existingAppointment.Status = appointment.Status;
                existingAppointment.Reason = appointment.Reason;
                existingAppointment.Notes = appointment.Notes;
                existingAppointment.UpdatedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();

                _logger.LogInformation("Updated appointment with ID {AppointmentId}", id);
                return existingAppointment;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating appointment with ID {AppointmentId}", id);
                throw;
            }
        }

        public async Task<bool> DeleteAppointmentAsync(int id)
        {
            try
            {
                var appointment = await _context.Appointments.FindAsync(id);
                if (appointment == null)
                    return false;

                _context.Appointments.Remove(appointment);
                await _context.SaveChangesAsync();

                _logger.LogInformation("Deleted appointment with ID {AppointmentId}", id);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting appointment with ID {AppointmentId}", id);
                throw;
            }
        }

        public async Task<bool> CancelAppointmentAsync(int id, string reason)
        {
            try
            {
                var appointment = await _context.Appointments.FindAsync(id);
                if (appointment == null)
                    return false;

                appointment.Status = "Cancelled";
                appointment.Notes = $"{appointment.Notes}\nCancellation Reason: {reason}";
                appointment.UpdatedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();

                _logger.LogInformation("Cancelled appointment with ID {AppointmentId}", id);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error cancelling appointment with ID {AppointmentId}", id);
                throw;
            }
        }

        public async Task<bool> AppointmentExistsAsync(int id)
        {
            try
            {
                return await _context.Appointments.AnyAsync(a => a.Id == id);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking if appointment exists with ID {AppointmentId}", id);
                throw;
            }
        }

        public async Task<IEnumerable<Appointment>> GetAppointmentsByPatientAsync(int patientId)
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

        public async Task<IEnumerable<Appointment>> GetAppointmentsByDoctorAsync(int doctorId, DateTime? date = null)
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

        public async Task<IEnumerable<Appointment>> GetAppointmentsByDateAsync(DateTime date)
        {
            try
            {
                return await _context.Appointments
                    .Include(a => a.Patient)
                    .Include(a => a.Doctor)
                    .Include(a => a.Room)
                    .Where(a => a.AppointmentDate.Date == date.Date)
                    .OrderBy(a => a.AppointmentDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving appointments for date {Date}", date);
                throw;
            }
        }

        public async Task<IEnumerable<Appointment>> GetUpcomingAppointmentsAsync(int days = 7)
        {
            try
            {
                var endDate = DateTime.Today.AddDays(days);
                
                return await _context.Appointments
                    .Include(a => a.Patient)
                    .Include(a => a.Doctor)
                    .Include(a => a.Room)
                    .Where(a => a.AppointmentDate >= DateTime.Now && a.AppointmentDate <= endDate)
                    .Where(a => a.Status != "Cancelled" && a.Status != "Completed")
                    .OrderBy(a => a.AppointmentDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving upcoming appointments");
                throw;
            }
        }

        public async Task<IEnumerable<Appointment>> GetTodaysAppointmentsAsync()
        {
            try
            {
                var today = DateTime.Today;
                
                return await _context.Appointments
                    .Include(a => a.Patient)
                    .Include(a => a.Doctor)
                    .Include(a => a.Room)
                    .Where(a => a.AppointmentDate.Date == today)
                    .OrderBy(a => a.AppointmentDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving today's appointments");
                throw;
            }
        }

        public async Task<bool> IsTimeSlotAvailableAsync(int doctorId, DateTime appointmentDate, TimeSpan duration, int? excludeAppointmentId = null)
        {
            try
            {
                var endTime = appointmentDate.Add(duration);
                
                // Use a more SQL-friendly approach by getting appointments and checking overlap in memory
                var existingAppointments = await _context.Appointments
                    .Where(a => a.DoctorId == doctorId)
                    .Where(a => a.Status != "Cancelled")
                    .Where(a => a.AppointmentDate.Date == appointmentDate.Date) // Only get appointments on the same day
                    .Select(a => new { a.Id, a.AppointmentDate, a.Duration })
                    .ToListAsync();

                if (excludeAppointmentId.HasValue)
                {
                    existingAppointments = existingAppointments.Where(a => a.Id != excludeAppointmentId.Value).ToList();
                }

                // Check for time overlap in memory
                var hasConflict = existingAppointments.Any(a => 
                {
                    var appointmentEndTime = a.AppointmentDate.Add(a.Duration);
                    return (a.AppointmentDate < endTime && appointmentEndTime > appointmentDate);
                });

                return !hasConflict;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking time slot availability");
                throw;
            }
        }

        public async Task<IEnumerable<DateTime>> GetAvailableSlotsAsync(int doctorId, DateTime date, TimeSpan duration)
        {
            try
            {
                var slots = new List<DateTime>();
                var startTime = new DateTime(date.Year, date.Month, date.Day, 8, 0, 0); // 8 AM
                var endTime = new DateTime(date.Year, date.Month, date.Day, 17, 0, 0); // 5 PM
                var slotDuration = TimeSpan.FromMinutes(30); // 30-minute slots

                var currentTime = startTime;
                while (currentTime.Add(duration) <= endTime)
                {
                    if (await IsTimeSlotAvailableAsync(doctorId, currentTime, duration))
                    {
                        slots.Add(currentTime);
                    }
                    currentTime = currentTime.Add(slotDuration);
                }

                return slots;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting available slots for doctor {DoctorId} on {Date}", doctorId, date);
                throw;
            }
        }

        public async Task<bool> ConfirmAppointmentAsync(int id)
        {
            try
            {
                var appointment = await _context.Appointments.FindAsync(id);
                if (appointment == null)
                    return false;

                appointment.Status = "Confirmed";
                appointment.UpdatedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error confirming appointment with ID {AppointmentId}", id);
                throw;
            }
        }

        public async Task<bool> CheckInPatientAsync(int id)
        {
            try
            {
                var appointment = await _context.Appointments.FindAsync(id);
                if (appointment == null)
                    return false;

                appointment.Status = "Checked-In";
                appointment.UpdatedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking in patient for appointment {AppointmentId}", id);
                throw;
            }
        }

        public async Task<bool> CompleteAppointmentAsync(int id)
        {
            try
            {
                var appointment = await _context.Appointments.FindAsync(id);
                if (appointment == null)
                    return false;

                appointment.Status = "Completed";
                appointment.UpdatedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error completing appointment with ID {AppointmentId}", id);
                throw;
            }
        }

        public async Task<IEnumerable<Appointment>> SearchAppointmentsAsync(string searchTerm)
        {
            try
            {
                return await _context.Appointments
                    .Include(a => a.Patient)
                    .Include(a => a.Doctor)
                    .Where(a => 
                        a.AppointmentNumber.Contains(searchTerm) ||
                        a.Patient.FirstName.Contains(searchTerm) ||
                        a.Patient.LastName.Contains(searchTerm) ||
                        a.Doctor.FirstName.Contains(searchTerm) ||
                        a.Doctor.LastName.Contains(searchTerm) ||
                        a.Type.Contains(searchTerm))
                    .OrderByDescending(a => a.AppointmentDate)
                    .Take(50)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching appointments with term: {SearchTerm}", searchTerm);
                throw;
            }
        }

        public async Task<int> GetTotalAppointmentsCountAsync()
        {
            try
            {
                return await _context.Appointments.CountAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting total appointments count");
                throw;
            }
        }

        public async Task<Dictionary<string, int>> GetAppointmentStatusStatsAsync()
        {
            try
            {
                return await _context.Appointments
                    .GroupBy(a => a.Status)
                    .ToDictionaryAsync(g => g.Key, g => g.Count());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting appointment status statistics");
                throw;
            }
        }

        public async Task<IEnumerable<Appointment>> GetOverdueAppointmentsAsync()
        {
            try
            {
                var now = DateTime.Now;
                
                return await _context.Appointments
                    .Include(a => a.Patient)
                    .Include(a => a.Doctor)
                    .Where(a => a.AppointmentDate < now)
                    .Where(a => a.Status == "Scheduled" || a.Status == "Confirmed")
                    .OrderBy(a => a.AppointmentDate)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving overdue appointments");
                throw;
            }
        }

        private async Task<string> GenerateAppointmentNumberAsync()
        {
            var year = DateTime.UtcNow.Year.ToString();
            var month = DateTime.UtcNow.Month.ToString("D2");
            var lastAppointment = await _context.Appointments
                .Where(a => a.AppointmentNumber.StartsWith($"APT{year}{month}"))
                .OrderByDescending(a => a.AppointmentNumber)
                .FirstOrDefaultAsync();

            int nextNumber = 1;
            if (lastAppointment != null && lastAppointment.AppointmentNumber.Length >= 11)
            {
                if (int.TryParse(lastAppointment.AppointmentNumber.Substring(9), out int lastNumber))
                {
                    nextNumber = lastNumber + 1;
                }
            }

            return $"APT{year}{month}{nextNumber:D4}";
        }
    }
}
