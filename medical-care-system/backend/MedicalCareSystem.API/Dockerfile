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

# Install curl and SQL Server tools for health checks and database operations
USER root
RUN apt-get update \
    && apt-get install -y curl gnupg \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y mssql-tools unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Entity Framework CLI tools for database migrations
RUN dotnet tool install --global dotnet-ef --version 9.0.9
ENV PATH="$PATH:/root/.dotnet/tools"

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
