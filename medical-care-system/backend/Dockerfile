# Use the official .NET SDK image for building
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

# Set the working directory
WORKDIR /app

# Copy the project files
COPY MedicalCareSystem.API/*.csproj ./MedicalCareSystem.API/
RUN dotnet restore MedicalCareSystem.API/MedicalCareSystem.API.csproj

# Copy the source code
COPY MedicalCareSystem.API/ ./MedicalCareSystem.API/

# Build the application
RUN dotnet publish MedicalCareSystem.API/MedicalCareSystem.API.csproj -c Release -o out

# Use the official ASP.NET Core runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime

# Set the working directory
WORKDIR /app

# Copy the published application
COPY --from=build /app/out .

# Expose the port
EXPOSE 5000
EXPOSE 5001

# Set environment variables
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:5000

# Create a non-root user
RUN groupadd -r medical && useradd -r -g medical medical
USER medical

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:5000/health || exit 1

# Start the application
ENTRYPOINT ["dotnet", "MedicalCareSystem.API.dll"]