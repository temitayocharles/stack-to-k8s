using System.Net.Http.Json;
using MedicalCareSystem.Frontend.Models;

namespace MedicalCareSystem.Frontend.Services
{
    public class ApiService
    {
        private readonly HttpClient _httpClient;

        public ApiService(HttpClient httpClient)
        {
            _httpClient = httpClient;
            // Base address is configured in Program.cs from appsettings.json
        }

        #region Patient Operations
        public async Task<List<Patient>> GetPatientsAsync()
        {
            try
            {
                var response = await _httpClient.GetAsync("patients");
                if (response.IsSuccessStatusCode)
                {
                    return await response.Content.ReadFromJsonAsync<List<Patient>>() ?? new List<Patient>();
                }
                return new List<Patient>();
            }
            catch (Exception)
            {
                return new List<Patient>();
            }
        }

        public async Task<Patient?> GetPatientAsync(int id)
        {
            try
            {
                return await _httpClient.GetFromJsonAsync<Patient>($"patients/{id}");
            }
            catch (Exception)
            {
                return null;
            }
        }

        public async Task<bool> CreatePatientAsync(Patient patient)
        {
            try
            {
                var response = await _httpClient.PostAsJsonAsync("patients", patient);
                return response.IsSuccessStatusCode;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public async Task<bool> UpdatePatientAsync(int id, Patient patient)
        {
            try
            {
                var response = await _httpClient.PutAsJsonAsync($"patients/{id}", patient);
                return response.IsSuccessStatusCode;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public async Task<bool> DeletePatientAsync(int id)
        {
            try
            {
                var response = await _httpClient.DeleteAsync($"patients/{id}");
                return response.IsSuccessStatusCode;
            }
            catch (Exception)
            {
                return false;
            }
        }
        #endregion

        #region Appointment Operations
        public async Task<List<Appointment>> GetAppointmentsAsync()
        {
            try
            {
                var response = await _httpClient.GetAsync("appointments");
                if (response.IsSuccessStatusCode)
                {
                    return await response.Content.ReadFromJsonAsync<List<Appointment>>() ?? new List<Appointment>();
                }
                return new List<Appointment>();
            }
            catch (Exception)
            {
                return new List<Appointment>();
            }
        }

        public async Task<Appointment?> GetAppointmentAsync(int id)
        {
            try
            {
                return await _httpClient.GetFromJsonAsync<Appointment>($"appointments/{id}");
            }
            catch (Exception)
            {
                return null;
            }
        }

        public async Task<bool> CreateAppointmentAsync(Appointment appointment)
        {
            try
            {
                var response = await _httpClient.PostAsJsonAsync("appointments", appointment);
                return response.IsSuccessStatusCode;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public async Task<bool> UpdateAppointmentAsync(int id, Appointment appointment)
        {
            try
            {
                var response = await _httpClient.PutAsJsonAsync($"appointments/{id}", appointment);
                return response.IsSuccessStatusCode;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public async Task<bool> DeleteAppointmentAsync(int id)
        {
            try
            {
                var response = await _httpClient.DeleteAsync($"appointments/{id}");
                return response.IsSuccessStatusCode;
            }
            catch (Exception)
            {
                return false;
            }
        }
        #endregion

        #region Doctor Operations
        public async Task<List<Doctor>> GetDoctorsAsync()
        {
            try
            {
                var response = await _httpClient.GetAsync("doctors");
                if (response.IsSuccessStatusCode)
                {
                    return await response.Content.ReadFromJsonAsync<List<Doctor>>() ?? new List<Doctor>();
                }
                return new List<Doctor>();
            }
            catch (Exception)
            {
                return new List<Doctor>();
            }
        }

        public async Task<Doctor?> GetDoctorAsync(int id)
        {
            try
            {
                return await _httpClient.GetFromJsonAsync<Doctor>($"doctors/{id}");
            }
            catch (Exception)
            {
                return null;
            }
        }

        public async Task<bool> CreateDoctorAsync(Doctor doctor)
        {
            try
            {
                var response = await _httpClient.PostAsJsonAsync("doctors", doctor);
                return response.IsSuccessStatusCode;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public async Task<bool> UpdateDoctorAsync(int id, Doctor doctor)
        {
            try
            {
                var response = await _httpClient.PutAsJsonAsync($"doctors/{id}", doctor);
                return response.IsSuccessStatusCode;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public async Task<bool> DeleteDoctorAsync(int id)
        {
            try
            {
                var response = await _httpClient.DeleteAsync($"doctors/{id}");
                return response.IsSuccessStatusCode;
            }
            catch (Exception)
            {
                return false;
            }
        }
        #endregion

        #region Medical Record Operations
        public async Task<List<MedicalRecord>> GetMedicalRecordsAsync(int patientId)
        {
            try
            {
                var response = await _httpClient.GetAsync($"medicalrecords/patient/{patientId}");
                if (response.IsSuccessStatusCode)
                {
                    return await response.Content.ReadFromJsonAsync<List<MedicalRecord>>() ?? new List<MedicalRecord>();
                }
                return new List<MedicalRecord>();
            }
            catch (Exception)
            {
                return new List<MedicalRecord>();
            }
        }

        public async Task<List<MedicalRecord>> GetAllMedicalRecordsAsync()
        {
            try
            {
                var response = await _httpClient.GetAsync("medicalrecords");
                if (response.IsSuccessStatusCode)
                {
                    return await response.Content.ReadFromJsonAsync<List<MedicalRecord>>() ?? new List<MedicalRecord>();
                }
                return new List<MedicalRecord>();
            }
            catch (Exception)
            {
                return new List<MedicalRecord>();
            }
        }

        public async Task<MedicalRecord?> GetMedicalRecordAsync(int id)
        {
            try
            {
                return await _httpClient.GetFromJsonAsync<MedicalRecord>($"medicalrecords/{id}");
            }
            catch (Exception)
            {
                return null;
            }
        }

        public async Task<bool> CreateMedicalRecordAsync(MedicalRecord record)
        {
            try
            {
                var response = await _httpClient.PostAsJsonAsync("medicalrecords", record);
                return response.IsSuccessStatusCode;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public async Task<bool> UpdateMedicalRecordAsync(int id, MedicalRecord record)
        {
            try
            {
                var response = await _httpClient.PutAsJsonAsync($"medicalrecords/{id}", record);
                return response.IsSuccessStatusCode;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public async Task<bool> DeleteMedicalRecordAsync(int id)
        {
            try
            {
                var response = await _httpClient.DeleteAsync($"medicalrecords/{id}");
                return response.IsSuccessStatusCode;
            }
            catch (Exception)
            {
                return false;
            }
        }
        #endregion
    }
}
