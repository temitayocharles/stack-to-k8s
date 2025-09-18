#!/bin/bash
# 🧹 APPLICATION CLEANUP SCRIPT
# Cleans up Docker resources for this specific application

echo "🧹 Cleaning up Docker resources for Social Media Platform..."

# Stop and remove containers for this application
docker-compose down 2>/dev/null || true

# Remove application-specific containers (if any are running independently)
docker ps -a --filter "name=social" --format "{{.ID}}" | xargs -r docker rm -f

# Remove unused images for this application
docker images --filter "reference=*social*" --format "{{.ID}}" | xargs -r docker rmi -f

# Clean up unused volumes and networks
docker volume prune -f
docker network prune -f

echo "✅ Cleanup completed for Social Media Platform!"
echo "💡 Run 'docker-compose up -d' to restart the application"