# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

# Set the working directory
WORKDIR /app

# Copy the project files
COPY MedicalCareSystem.Frontend/*.csproj ./MedicalCareSystem.Frontend/
RUN dotnet restore MedicalCareSystem.Frontend/MedicalCareSystem.Frontend.csproj

# Copy the source code
COPY MedicalCareSystem.Frontend/ ./MedicalCareSystem.Frontend/

# Build the application
RUN dotnet publish MedicalCareSystem.Frontend/MedicalCareSystem.Frontend.csproj -c Release -o out

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime

# Set the working directory
WORKDIR /app

# Copy the published application
COPY --from=build /app/out .

# Expose the port
EXPOSE 3000

# Set environment variables
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:3000

# Create a non-root user
RUN groupadd -r blazor && useradd -r -g blazor blazor
USER blazor

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:3000 || exit 1

# Start the application
ENTRYPOINT ["dotnet", "MedicalCareSystem.Frontend.dll"]