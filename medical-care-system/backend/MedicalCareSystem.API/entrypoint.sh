#!/bin/bash

echo "Starting Medical Care System API..."

# Wait for SQL Server to be ready
echo "Waiting for SQL Server to be ready..."
while ! /opt/mssql-tools/bin/sqlcmd -S medical-care-db -U sa -P MedicalCare2025! -Q "SELECT 1" > /dev/null 2>&1; do
    echo "SQL Server is not ready yet. Waiting..."
    sleep 5
done

echo "SQL Server is ready. Running database migrations..."

# Run Entity Framework migrations
dotnet ef database update --no-build

echo "Database migrations completed. Starting the application..."

# Start the application
exec dotnet MedicalCareSystem.API.dll
