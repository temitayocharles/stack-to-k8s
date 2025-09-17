#!/bin/bash

# Medical Care System Kubernetes Deployment Script

set -e

echo "🏥 Deploying Medical Care System to Kubernetes..."

# Build Docker images
echo "📦 Building Docker images..."

# Build backend API
echo "Building Medical Care API..."
cd backend/MedicalCareSystem.API
docker build -t medical-care-api:latest .
cd ../..

# Build frontend
echo "Building Medical Care Frontend..."
cd frontend/MedicalCareSystem.Frontend
docker build -t medical-care-frontend:latest .
cd ../..

# Apply Kubernetes manifests
echo "🚀 Deploying to Kubernetes..."

# Create namespace
kubectl apply -f k8s/namespace.yaml

# Deploy SQL Server
echo "Deploying SQL Server database..."
kubectl apply -f k8s/sql-server-secret.yaml
kubectl apply -f k8s/sql-server-pvc.yaml
kubectl apply -f k8s/sql-server-deployment.yaml
kubectl apply -f k8s/sql-server-service.yaml

# Wait for SQL Server to be ready
echo "⏳ Waiting for SQL Server to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/sql-server -n medical-care-system

# Deploy backend API
echo "Deploying Medical Care API..."
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml

# Wait for backend to be ready
echo "⏳ Waiting for API to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/medical-care-api -n medical-care-system

# Deploy frontend
echo "Deploying Medical Care Frontend..."
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml

# Deploy ingress
echo "Deploying Ingress..."
kubectl apply -f k8s/ingress.yaml

echo "✅ Medical Care System deployed successfully!"

# Show deployment status
echo "📊 Deployment Status:"
kubectl get all -n medical-care-system

echo ""
echo "🌐 Access the application:"
echo "Frontend: http://medical-care.local"
echo "API: http://medical-care.local/api"

echo ""
echo "📝 Next steps:"
echo "1. Add medical-care.local to your /etc/hosts file"
echo "2. Configure your ingress controller if needed"
echo "3. Monitor the application with: kubectl logs -f deployment/medical-care-api -n medical-care-system"
