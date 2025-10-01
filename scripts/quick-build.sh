#!/bin/bash
# 🚀 QUICK DOCKER BUILD SCRIPT
# Simple script to build and push all images to Docker Hub
# Author: Temitayo Charles Akinniranye | TCA-InfraForge

set -e

DOCKER_USERNAME="temitayocharles"
APPLICATIONS=("ecommerce-app" "educational-platform" "medical-care-system" "task-management-app" "weather-app" "social-media-platform")

echo "🐳 Building and pushing all applications to Docker Hub (Username: $DOCKER_USERNAME)"

for app in "${APPLICATIONS[@]}"; do
    if [[ -d "$app" ]]; then
        echo "📦 Building $app..."
        cd "$app"
        
        # Build main application image
        if [[ -f "Dockerfile" ]]; then
            docker build -t "$DOCKER_USERNAME/$app:latest" .
            echo "✅ Built $DOCKER_USERNAME/$app:latest"
        fi
        
        cd ..
    fi
done

echo "🎉 All images built! To push to Docker Hub, run:"
for app in "${APPLICATIONS[@]}"; do
    echo "docker push $DOCKER_USERNAME/$app:latest"
done