# Medical Care System - Multi-Stage Dockerfile
# .NET Core API + Blazor WebAssembly Frontend
# Optimized for production with HIPAA compliance

# Backend Build Stage  
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS backend-builder
WORKDIR /app/backend

# Copy project file
COPY backend/MedicalCareSystem.API/*.csproj ./MedicalCareSystem.API/

# Restore dependencies
RUN dotnet restore MedicalCareSystem.API/MedicalCareSystem.API.csproj

# Copy source code
COPY backend/ ./

# Build and publish backend
RUN dotnet publish MedicalCareSystem.API/MedicalCareSystem.API.csproj \
    -c Release \
    -o out \
    --no-restore

# Frontend Build Stage (Blazor WebAssembly)
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS frontend-builder
WORKDIR /app/frontend

# Copy frontend project
COPY frontend/MedicalCareSystem.Frontend/*.csproj ./MedicalCareSystem.Frontend/
RUN dotnet restore MedicalCareSystem.Frontend/MedicalCareSystem.Frontend.csproj

# Copy frontend source
COPY frontend/ ./

# Build and publish frontend
RUN dotnet publish MedicalCareSystem.Frontend/MedicalCareSystem.Frontend.csproj -c Release -o out

# Production Runtime Stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS production
WORKDIR /app

# Create non-root user for security
RUN addgroup -g 1001 -S medicaluser && \
    adduser -S medicaluser -u 1001 -G medicaluser && \
    apk add --no-cache curl ca-certificates

# Copy backend application
COPY --from=backend-builder /app/backend/out ./

# Copy frontend build to wwwroot
COPY --from=frontend-builder /app/frontend/out/wwwroot ./wwwroot

# Create necessary directories
RUN mkdir -p logs uploads && \
    chown -R medicaluser:medicaluser /app

# Switch to non-root user
USER medicaluser

# Environment variables
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:5170
ENV DOTNET_RUNNING_IN_CONTAINER=true

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:5170/health || exit 1

# Expose port
EXPOSE 5170

# Start application
ENTRYPOINT ["dotnet", "MedicalCareSystem.API.dll"]