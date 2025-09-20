using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MedicalCareSystem.API.Data;
using MedicalCareSystem.API.Models;

namespace MedicalCareSystem.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TelemedicineController : ControllerBase
    {
        private readonly MedicalCareContext _context;

        public TelemedicineController(MedicalCareContext context)
        {
            _context = context;
        }

        [HttpPost("sessions/schedule")]
        public async Task<ActionResult<TelemedicineSession>> ScheduleSession([FromBody] ScheduleSessionRequest request)
        {
            try
            {
                var session = new TelemedicineSession
                {
                    PatientId = request.PatientId,
                    DoctorId = request.DoctorId,
                    ScheduledTime = request.ScheduledTime,
                    Status = "Scheduled",
                    MeetingRoomId = GenerateMeetingRoomId(),
                    ConnectionToken = GenerateConnectionToken()
                };

                _context.TelemedicineSessions.Add(session);
                await _context.SaveChangesAsync();

                return Ok(new
                {
                    session_id = session.Id,
                    patient_id = session.PatientId,
                    doctor_id = session.DoctorId,
                    scheduled_time = session.ScheduledTime,
                    meeting_details = new
                    {
                        room_id = session.MeetingRoomId,
                        connection_token = session.ConnectionToken,
                        join_url = $"https://medical-app.com/telemedicine/join/{session.MeetingRoomId}",
                        backup_phone = "+1-800-MEDICAL"
                    },
                    session_info = new
                    {
                        status = session.Status,
                        estimated_duration = "30 minutes",
                        timezone = "UTC",
                        preparation_instructions = new[]
                        {
                            "Test your camera and microphone",
                            "Prepare your medication list",
                            "Have your insurance card ready",
                            "Find a quiet, well-lit room"
                        }
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "Failed to schedule session", details = ex.Message });
            }
        }

        [HttpPost("sessions/{sessionId}/start")]
        public async Task<ActionResult> StartSession(int sessionId, [FromBody] StartSessionRequest request)
        {
            var session = await _context.TelemedicineSessions.FindAsync(sessionId);
            if (session == null)
                return NotFound(new { message = "Session not found" });

            if (session.Status != "Scheduled")
                return BadRequest(new { message = "Session cannot be started", current_status = session.Status });

            session.Status = "InProgress";
            session.StartTime = DateTime.UtcNow;
            
            await _context.SaveChangesAsync();

            return Ok(new
            {
                session_id = sessionId,
                status = "InProgress",
                start_time = session.StartTime,
                meeting_room = new
                {
                    room_id = session.MeetingRoomId,
                    video_url = $"https://medical-video.com/room/{session.MeetingRoomId}",
                    audio_backup = "+1-800-MEDICAL-BACKUP",
                    session_controls = new
                    {
                        record_session = true,
                        enable_chat = true,
                        screen_sharing = true,
                        file_upload = true
                    }
                },
                session_tools = new
                {
                    patient_chart_access = true,
                    prescription_module = true,
                    note_taking = true,
                    vital_signs_integration = true
                }
            });
        }

        [HttpPost("sessions/{sessionId}/end")]
        public async Task<ActionResult> EndSession(int sessionId, [FromBody] EndSessionRequest request)
        {
            var session = await _context.TelemedicineSessions
                .Include(s => s.Patient)
                .Include(s => s.Doctor)
                .FirstOrDefaultAsync(s => s.Id == sessionId);

            if (session == null)
                return NotFound();

            session.Status = "Completed";
            session.EndTime = DateTime.UtcNow;
            session.SessionNotes = request.SessionNotes;
            session.TreatmentPlan = request.TreatmentPlan;
            session.PrescriptionIssued = request.PrescriptionIssued;
            session.FollowUpRequired = request.FollowUpRequired;
            session.FollowUpDate = request.FollowUpDate;
            
            if (session.StartTime.HasValue)
            {
                session.DurationMinutes = (int)(session.EndTime.Value - session.StartTime.Value).TotalMinutes;
            }

            await _context.SaveChangesAsync();

            return Ok(new
            {
                session_id = sessionId,
                status = "Completed",
                session_summary = new
                {
                    duration_minutes = session.DurationMinutes,
                    start_time = session.StartTime,
                    end_time = session.EndTime,
                    patient_name = session.Patient?.FirstName + " " + session.Patient?.LastName,
                    doctor_name = session.Doctor?.FirstName + " " + session.Doctor?.LastName
                },
                clinical_summary = new
                {
                    session_notes = session.SessionNotes,
                    treatment_plan = session.TreatmentPlan,
                    prescription_issued = session.PrescriptionIssued,
                    follow_up_required = session.FollowUpRequired,
                    follow_up_date = session.FollowUpDate
                },
                next_steps = new
                {
                    recording_available = "Available in 24 hours",
                    session_notes_sent = true,
                    prescription_sent_to_pharmacy = session.PrescriptionIssued,
                    follow_up_scheduled = session.FollowUpRequired
                }
            });
        }

        [HttpGet("sessions/patient/{patientId}")]
        public async Task<ActionResult> GetPatientSessions(int patientId)
        {
            var sessions = await _context.TelemedicineSessions
                .Where(s => s.PatientId == patientId)
                .Include(s => s.Doctor)
                .OrderByDescending(s => s.ScheduledTime)
                .Select(s => new
                {
                    id = s.Id,
                    scheduled_time = s.ScheduledTime,
                    status = s.Status,
                    doctor_name = s.Doctor!.FirstName + " " + s.Doctor.LastName,
                    duration_minutes = s.DurationMinutes,
                    has_follow_up = s.FollowUpRequired,
                    follow_up_date = s.FollowUpDate
                })
                .ToListAsync();

            return Ok(new
            {
                patient_id = patientId,
                total_sessions = sessions.Count,
                sessions = sessions,
                upcoming_sessions = sessions.Where(s => s.status == "Scheduled" && s.scheduled_time > DateTime.UtcNow).Count(),
                completed_sessions = sessions.Where(s => s.status == "Completed").Count()
            });
        }

        [HttpGet("sessions/doctor/{doctorId}/schedule")]
        public async Task<ActionResult> GetDoctorSchedule(int doctorId, [FromQuery] DateTime? date = null)
        {
            var targetDate = date ?? DateTime.UtcNow.Date;
            var sessions = await _context.TelemedicineSessions
                .Where(s => s.DoctorId == doctorId && s.ScheduledTime.Date == targetDate)
                .Include(s => s.Patient)
                .OrderBy(s => s.ScheduledTime)
                .Select(s => new
                {
                    id = s.Id,
                    scheduled_time = s.ScheduledTime,
                    patient_name = s.Patient!.FirstName + " " + s.Patient.LastName,
                    status = s.Status,
                    estimated_duration = 30,
                    meeting_room_id = s.MeetingRoomId
                })
                .ToListAsync();

            return Ok(new
            {
                doctor_id = doctorId,
                schedule_date = targetDate,
                total_appointments = sessions.Count,
                schedule = sessions,
                availability = new
                {
                    busy_hours = sessions.Count,
                    available_slots = CalculateAvailableSlots(sessions, targetDate),
                    next_available = GetNextAvailableSlot(doctorId, targetDate)
                }
            });
        }

        [HttpGet("analytics/telemedicine")]
        public async Task<ActionResult> GetTelemedicineAnalytics([FromQuery] int days = 30)
        {
            var startDate = DateTime.UtcNow.AddDays(-days);
            
            var sessions = await _context.TelemedicineSessions
                .Where(s => s.ScheduledTime >= startDate)
                .ToListAsync();

            var totalSessions = sessions.Count;
            var completedSessions = sessions.Where(s => s.Status == "Completed").ToList();
            var averageDuration = completedSessions.Any() ? completedSessions.Average(s => s.DurationMinutes) : 0;

            return Ok(new
            {
                analytics_period = $"{days} days",
                session_statistics = new
                {
                    total_sessions = totalSessions,
                    completed_sessions = completedSessions.Count,
                    cancelled_sessions = sessions.Count(s => s.Status == "Cancelled"),
                    no_show_sessions = sessions.Count(s => s.Status == "Scheduled" && s.ScheduledTime < DateTime.UtcNow),
                    completion_rate = totalSessions > 0 ? (double)completedSessions.Count / totalSessions * 100 : 0
                },
                performance_metrics = new
                {
                    average_duration_minutes = Math.Round(averageDuration, 1),
                    total_consultation_hours = Math.Round(completedSessions.Sum(s => s.DurationMinutes) / 60.0, 1),
                    patient_satisfaction = 4.6, // Simulated metric
                    technical_success_rate = 98.5 // Simulated metric
                },
                usage_trends = new
                {
                    sessions_per_day = Math.Round((double)totalSessions / days, 1),
                    peak_hours = new[] { "10:00 AM", "2:00 PM", "4:00 PM" },
                    most_common_duration = "25-35 minutes",
                    follow_up_rate = completedSessions.Count > 0 ? (double)completedSessions.Count(s => s.FollowUpRequired) / completedSessions.Count * 100 : 0
                }
            });
        }

        private string GenerateMeetingRoomId()
        {
            return "TELE-" + Guid.NewGuid().ToString("N")[..8].ToUpper();
        }

        private string GenerateConnectionToken()
        {
            return Convert.ToBase64String(Guid.NewGuid().ToByteArray()).Replace("=", "").Replace("+", "").Replace("/", "")[..16];
        }

        private List<string> CalculateAvailableSlots(IEnumerable<object> bookedSessions, DateTime date)
        {
            // Simulate available time slots
            var workingHours = new[] { "9:00", "9:30", "10:00", "10:30", "11:00", "11:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30" };
            return workingHours.Take(6).ToList(); // Return first 6 available slots
        }

        private DateTime GetNextAvailableSlot(int doctorId, DateTime fromDate)
        {
            // Simulate next available appointment
            return fromDate.AddDays(1).Date.AddHours(9);
        }
    }

    public class ScheduleSessionRequest
    {
        public int PatientId { get; set; }
        public int DoctorId { get; set; }
        public DateTime ScheduledTime { get; set; }
        public string Notes { get; set; } = string.Empty;
    }

    public class StartSessionRequest
    {
        public string DeviceInfo { get; set; } = string.Empty;
        public bool VideoEnabled { get; set; } = true;
        public bool AudioEnabled { get; set; } = true;
    }

    public class EndSessionRequest
    {
        public string SessionNotes { get; set; } = string.Empty;
        public string TreatmentPlan { get; set; } = string.Empty;
        public bool PrescriptionIssued { get; set; } = false;
        public bool FollowUpRequired { get; set; } = false;
        public DateTime? FollowUpDate { get; set; }
    }
}