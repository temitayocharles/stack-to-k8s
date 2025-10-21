# Multi-stage Dockerfile for Blazor WebAssembly
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy csproj files and restore dependencies
COPY ["MedicalCareSystem.Frontend.csproj", "./"]
RUN dotnet restore "./MedicalCareSystem.Frontend.csproj"

# Copy everything else and build
COPY . .
RUN dotnet build "MedicalCareSystem.Frontend.csproj" -c Release -o /app/build

# Publish the application
FROM build AS publish
# Use container-specific configuration for production
RUN cp wwwroot/appsettings.container.json wwwroot/appsettings.json
RUN dotnet publish "MedicalCareSystem.Frontend.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage - use nginx to serve static files
FROM nginx:alpine AS final
WORKDIR /usr/share/nginx/html

# Copy published Blazor files
COPY --from=publish /app/publish/wwwroot .

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
