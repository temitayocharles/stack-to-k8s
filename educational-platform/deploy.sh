#!/bin/bash

# Educational Platform Deployment Script
# This script helps deploy all applications for Kubernetes/GitOps practice

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="educational-platform"
COMPOSE_FILE="docker-compose.yml"
K8S_DIR="k8s/base"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    local missing_deps=()
    
    if ! command_exists docker; then
        missing_deps+=("docker")
    fi
    
    if ! command_exists docker-compose; then
        missing_deps+=("docker-compose")
    fi
    
    if ! command_exists kubectl; then
        missing_deps+=("kubectl")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_error "Please install the missing dependencies and try again."
        exit 1
    fi
    
    print_success "All prerequisites are installed"
}

# Function to build Docker images
build_images() {
    print_status "Building Docker images..."
    
    # Build backend image
    print_status "Building backend image..."
    if cd backend && docker build -t educational-platform/backend:latest .; then
        print_success "Backend image built successfully"
        cd ..
    else
        print_error "Failed to build backend image"
        exit 1
    fi
    
    # Build frontend image
    print_status "Building frontend image..."
    if cd frontend && docker build -t educational-platform/frontend:latest .; then
        print_success "Frontend image built successfully"
        cd ..
    else
        print_error "Failed to build frontend image"
        exit 1
    fi
}

# Function to deploy with Docker Compose
deploy_docker_compose() {
    print_status "Deploying with Docker Compose..."
    
    if [ ! -f "$COMPOSE_FILE" ]; then
        print_error "Docker Compose file not found: $COMPOSE_FILE"
        exit 1
    fi
    
    # Create necessary directories
    mkdir -p data/postgres data/redis uploads logs
    
    # Deploy base services
    print_status "Starting base services (PostgreSQL, Redis)..."
    docker-compose up -d postgres redis
    
    # Wait for databases to be ready
    print_status "Waiting for databases to be ready..."
    sleep 30
    
    # Deploy backend
    print_status "Starting backend service..."
    docker-compose up -d backend
    
    # Wait for backend to be ready
    print_status "Waiting for backend to be ready..."
    sleep 45
    
    # Deploy frontend
    print_status "Starting frontend service..."
    docker-compose up -d frontend
    
    print_success "Docker Compose deployment completed!"
    print_status "Services are starting up. You can check the status with:"
    echo "  docker-compose ps"
    echo "  docker-compose logs -f"
    echo ""
    print_status "Access the application at:"
    echo "  Frontend: http://localhost"
    echo "  Backend API: http://localhost:8080"
    echo "  PostgreSQL: localhost:5432"
    echo "  Redis: localhost:6379"
}

# Function to deploy with Docker Compose (with monitoring)
deploy_docker_compose_full() {
    print_status "Deploying with Docker Compose (Full Stack + Monitoring)..."
    
    deploy_docker_compose
    
    # Deploy monitoring stack
    print_status "Starting monitoring services..."
    docker-compose --profile monitoring up -d prometheus grafana
    
    # Deploy search stack (optional)
    print_status "Starting search services..."
    docker-compose --profile search up -d elasticsearch kibana
    
    print_success "Full stack deployment completed!"
    print_status "Additional services:"
    echo "  Prometheus: http://localhost:9090"
    echo "  Grafana: http://localhost:3000 (admin/admin)"
    echo "  Elasticsearch: http://localhost:9200"
    echo "  Kibana: http://localhost:5601"
}

# Function to deploy to Kubernetes
deploy_kubernetes() {
    print_status "Deploying to Kubernetes..."
    
    # Check if kubectl can connect to cluster
    if ! kubectl cluster-info >/dev/null 2>&1; then
        print_error "Cannot connect to Kubernetes cluster"
        print_error "Please ensure kubectl is configured correctly"
        exit 1
    fi
    
    # Check if K8s manifests exist
    if [ ! -d "$K8S_DIR" ]; then
        print_error "Kubernetes manifests directory not found: $K8S_DIR"
        exit 1
    fi
    
    # Load images to cluster (for local development)
    if command_exists kind && kind get clusters 2>/dev/null | grep -q "kind"; then
        print_status "Loading images to kind cluster..."
        kind load docker-image educational-platform/backend:latest
        kind load docker-image educational-platform/frontend:latest
    elif command_exists minikube && minikube status >/dev/null 2>&1; then
        print_status "Loading images to minikube..."
        minikube image load educational-platform/backend:latest
        minikube image load educational-platform/frontend:latest
    fi
    
    # Apply Kubernetes manifests
    print_status "Applying Kubernetes manifests..."
    kubectl apply -f "$K8S_DIR/"
    
    # Wait for deployments to be ready
    print_status "Waiting for deployments to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/postgres -n "$NAMESPACE"
    kubectl wait --for=condition=available --timeout=300s deployment/redis -n "$NAMESPACE"
    kubectl wait --for=condition=available --timeout=600s deployment/backend -n "$NAMESPACE"
    kubectl wait --for=condition=available --timeout=300s deployment/frontend -n "$NAMESPACE"
    
    print_success "Kubernetes deployment completed!"
    
    # Get service information
    print_status "Service information:"
    kubectl get services -n "$NAMESPACE"
    
    # Get ingress information
    if kubectl get ingress -n "$NAMESPACE" >/dev/null 2>&1; then
        print_status "Ingress information:"
        kubectl get ingress -n "$NAMESPACE"
    fi
    
    # Port forwarding instructions
    print_status "To access the application locally, run:"
    echo "  kubectl port-forward -n $NAMESPACE service/frontend-service 8080:80"
    echo "  kubectl port-forward -n $NAMESPACE service/backend-service 8081:8080"
}

# Function to show status
show_status() {
    if command_exists docker-compose && docker-compose ps | grep -q "Up"; then
        print_status "Docker Compose Status:"
        docker-compose ps
        echo ""
    fi
    
    if command_exists kubectl && kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
        print_status "Kubernetes Status:"
        kubectl get pods -n "$NAMESPACE"
        echo ""
        kubectl get services -n "$NAMESPACE"
        echo ""
    fi
}

# Function to cleanup
cleanup() {
    print_status "Cleaning up deployments..."
    
    # Docker Compose cleanup
    if [ -f "$COMPOSE_FILE" ]; then
        print_status "Stopping Docker Compose services..."
        docker-compose down -v --remove-orphans
        print_success "Docker Compose services stopped"
    fi
    
    # Kubernetes cleanup
    if command_exists kubectl && kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
        print_status "Deleting Kubernetes resources..."
        kubectl delete namespace "$NAMESPACE" --ignore-not-found=true
        print_success "Kubernetes resources deleted"
    fi
    
    # Docker cleanup
    print_status "Cleaning up Docker images..."
    docker image prune -f
    
    print_success "Cleanup completed!"
}

# Function to show help
show_help() {
    echo "Educational Platform Deployment Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  build                 Build Docker images"
    echo "  docker               Deploy with Docker Compose (minimal)"
    echo "  docker-full          Deploy with Docker Compose (full stack)"
    echo "  kubernetes           Deploy to Kubernetes"
    echo "  k8s                  Alias for kubernetes"
    echo "  status               Show deployment status"
    echo "  cleanup              Clean up all deployments"
    echo "  help                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build && $0 docker"
    echo "  $0 build && $0 kubernetes"
    echo "  $0 status"
    echo "  $0 cleanup"
    echo ""
    echo "Prerequisites:"
    echo "  - Docker"
    echo "  - Docker Compose"
    echo "  - kubectl (for Kubernetes deployment)"
    echo "  - kind or minikube (for local Kubernetes)"
}

# Main script logic
main() {
    case "${1:-help}" in
        "build")
            check_prerequisites
            build_images
            ;;
        "docker")
            check_prerequisites
            build_images
            deploy_docker_compose
            ;;
        "docker-full")
            check_prerequisites
            build_images
            deploy_docker_compose_full
            ;;
        "kubernetes"|"k8s")
            check_prerequisites
            build_images
            deploy_kubernetes
            ;;
        "status")
            show_status
            ;;
        "cleanup")
            cleanup
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Run main function with all arguments
main "$@"
