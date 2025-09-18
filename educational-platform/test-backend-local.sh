#!/bin/bash

# Educational Platform - Simple JAR Test Script
echo "📊 Educational Platform - Testing Backend Without Docker"

cd /Volumes/512-B/Documents/PERSONAL/full-stack-apps/educational-platform/backend

# Set environment variables for local testing
export SPRING_PROFILES_ACTIVE=local
export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/educational_platform
export SPRING_DATASOURCE_USERNAME=edu_user
export SPRING_DATASOURCE_PASSWORD=edu_password
export SPRING_REDIS_HOST=localhost
export SPRING_REDIS_PORT=6381
export SPRING_REDIS_PASSWORD=redis_password
export SERVER_PORT=8080

echo "✅ Environment configured for Educational Platform"
echo "📊 Database: PostgreSQL on localhost:5432"
echo "📊 Cache: Redis on localhost:6381"
echo "📊 Server Port: 8080"
echo "🔧 Note: This requires Java to be installed locally"
echo "🐳 Alternative: Use Docker for full containerized setup"