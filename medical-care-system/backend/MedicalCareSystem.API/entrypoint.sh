#!/bin/bash
set -e

echo "Starting Medical Care System API..."

# Wait for database to be ready (simplified check)
echo "Waiting for PostgreSQL to be ready..."
for i in {1..30}; do
    if nc -z medical-care-db 5432 2>/dev/null; then
        echo "PostgreSQL is ready!"
        break
    fi
    echo "PostgreSQL is not ready yet. Waiting... ($i/30)"
    sleep 3
done

echo "Starting the application (database will be auto-created)..."

# Start the application - EF will create the database via Program.cs
exec dotnet MedicalCareSystem.API.dll
