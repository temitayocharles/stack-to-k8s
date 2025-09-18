# Multi-stage Dockerfile for .NET API
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy csproj files and restore dependencies
COPY ["MedicalCareSystem.API.csproj", "./"]
RUN dotnet restore "./MedicalCareSystem.API.csproj"

# Copy everything else and build
COPY . .
RUN dotnet build "MedicalCareSystem.API.csproj" -c Release -o /app/build

# Publish the application
FROM build AS publish
RUN dotnet publish "MedicalCareSystem.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app

# Install curl for health checks
USER root
RUN apt-get update \
    && apt-get install -y curl netcat-traditional \
    && rm -rf /var/lib/apt/lists/*

COPY --from=publish /app/publish .

# Copy and set up entrypoint script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Create non-root user
RUN adduser --disabled-password --gecos '' appuser && chown -R appuser:appuser /app

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

EXPOSE 8080
EXPOSE 8081

ENTRYPOINT ["/app/entrypoint.sh"]
