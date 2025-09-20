using MedicalCareSystem.API.Data;
using MedicalCareSystem.API.Services;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();

// Configure CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// Configure Database Context
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") 
    ?? "Host=localhost;Port=5432;Database=MedicalCareDB;Username=medical_user;Password=MedicalCare2025!";

builder.Services.AddDbContext<MedicalCareContext>(options =>
{
    // Use PostgreSQL for all environments
    options.UseNpgsql(connectionString);
    
    options.EnableSensitiveDataLogging(builder.Environment.IsDevelopment());
    options.EnableDetailedErrors(builder.Environment.IsDevelopment());
});

// Register Application Services
builder.Services.AddScoped<IPatientService, PatientService>();
builder.Services.AddScoped<IDoctorService, DoctorService>();
builder.Services.AddScoped<IAppointmentService, AppointmentService>();
builder.Services.AddScoped<IMedicalRecordService, MedicalRecordService>();
builder.Services.AddScoped<IPrescriptionService, PrescriptionService>();
builder.Services.AddScoped<IBillingService, BillingService>();

// Configure API Documentation
builder.Services.AddEndpointsApiExplorer();

// Configure Logging
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.AddDebug();

// Configure JSON options
builder.Services.Configure<Microsoft.AspNetCore.Http.Json.JsonOptions>(options =>
{
    options.SerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
    options.SerializerOptions.WriteIndented = true;
});

var app = builder.Build();
var logger = app.Services.GetRequiredService<ILogger<Program>>();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}
else
{
    app.UseExceptionHandler("/Error");
    app.UseHsts();
}

// Security Headers
app.Use(async (context, next) =>
{
    context.Response.Headers["X-Content-Type-Options"] = "nosniff";
    context.Response.Headers["X-Frame-Options"] = "DENY";
    context.Response.Headers["X-XSS-Protection"] = "1; mode=block";
    context.Response.Headers["Referrer-Policy"] = "strict-origin-when-cross-origin";
    await next();
});

app.UseHttpsRedirection();

// Enable CORS
app.UseCors("AllowAll");

app.UseRouting();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

// Initialize Database
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<MedicalCareContext>();
    var scopedLogger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
    
    try
    {
        if (app.Environment.IsDevelopment())
        {
            // Ensure database is created for development
            await context.Database.EnsureCreatedAsync();
            scopedLogger.LogInformation("Database initialized successfully");
        }
        else
        {
            // Apply migrations for production
            await context.Database.MigrateAsync();
            scopedLogger.LogInformation("Database migrations applied successfully");
        }
    }
    catch (Exception ex)
    {
        scopedLogger.LogError(ex, "An error occurred while initializing the database");
        throw;
    }
}

logger.LogInformation("Medical Care System API started successfully");

app.Run();
