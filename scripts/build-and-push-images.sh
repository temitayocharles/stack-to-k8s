#!/bin/bash
# 🚀 BUILD AND PUSH ALL APPLICATION IMAGES TO DOCKER HUB
# Author: Temitayo Charles Akinniranye | TCA-InfraForge
# Docker Hub Username: temitayocharles

set -e

echo "🐳 Building and pushing all applications to Docker Hub (Username: temitayocharles)"

# 📦 Applications to build
APPLICATIONS=(
    "ecommerce-app"
    "educational-platform" 
    "medical-care-system"
    "task-management-app"
    "weather-app"
    "social-media-platform"
)

# Simple build and push function
for app in "${APPLICATIONS[@]}"; do
    if [[ -d "$app" ]]; then
        echo "📦 Building $app..."
        cd "$app"
        
        if [[ -f "Dockerfile" ]]; then
            docker build -t temitayocharles/$app:latest .
            echo "✅ Built temitayocharles/$app:latest"
            
            echo "🚀 Pushing to Docker Hub..."
            docker push temitayocharles/$app:latest
            echo "✅ Pushed temitayocharles/$app:latest"
        else
            echo "❌ No Dockerfile found in $app"
        fi
        
        cd ..
    else
        echo "❌ Directory not found: $app"
    fi
done

echo "� Build and push complete!"
echo "� To use these images, run: docker pull temitayocharles/[app-name]:latest"