#!/bin/bash

# Task Management Application Deployment Script
# This script deploys the complete Task Management stack to Kubernetes

set -euo pipefail

# Configuration
NAMESPACE="task-management"
DOCKER_REGISTRY="${DOCKER_REGISTRY:-ghcr.io/your-org}"
ENVIRONMENT="${ENVIRONMENT:-production}"
DOMAIN="${DOMAIN:-task-management.example.com}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    
    # Check if helm is installed
    if ! command -v helm &> /dev/null; then
        log_error "helm is not installed. Please install helm first."
        exit 1
    fi
    
    # Check kubectl connection
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

# Create namespace if it doesn't exist
create_namespace() {
    log_info "Creating namespace: $NAMESPACE"
    
    if kubectl get namespace "$NAMESPACE" &> /dev/null; then
        log_warning "Namespace $NAMESPACE already exists"
    else
        kubectl create namespace "$NAMESPACE"
        log_success "Namespace $NAMESPACE created"
    fi
}

# Apply secrets
apply_secrets() {
    log_info "Applying secrets..."
    
    # Check if secrets exist
    if kubectl get secret task-management-secrets -n "$NAMESPACE" &> /dev/null; then
        log_warning "Secrets already exist. Skipping creation."
        return
    fi
    
    # Generate random passwords if not provided
    COUCHDB_USER="${COUCHDB_USER:-admin}"
    COUCHDB_PASSWORD="${COUCHDB_PASSWORD:-$(openssl rand -base64 32)}"
    JWT_SECRET="${JWT_SECRET:-$(openssl rand -base64 64)}"
    
    # Create secret
    kubectl create secret generic task-management-secrets \
        --from-literal=COUCHDB_USER="$COUCHDB_USER" \
        --from-literal=COUCHDB_PASSWORD="$COUCHDB_PASSWORD" \
        --from-literal=JWT_SECRET="$JWT_SECRET" \
        -n "$NAMESPACE"
    
    log_success "Secrets applied"
    log_info "CouchDB credentials: $COUCHDB_USER / $COUCHDB_PASSWORD"
}

# Deploy CouchDB
deploy_couchdb() {
    log_info "Deploying CouchDB..."
    
    # Add CouchDB Helm repository
    helm repo add couchdb https://apache.github.io/couchdb-helm
    helm repo update
    
    # Create CouchDB values file
    cat > /tmp/couchdb-values.yaml << EOF
clusterSize: 3
couchdbConfig:
  couchdb:
    uuid: $(openssl rand -hex 32)
adminUsername: admin
adminPassword: $COUCHDB_PASSWORD
cookieAuthSecret: $(openssl rand -hex 32)

persistentVolume:
  enabled: true
  size: 10Gi
  storageClass: "standard"

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

service:
  type: ClusterIP
  port: 5984

ingress:
  enabled: false

nodeSelector: {}
tolerations: []
affinity: {}

podSecurityContext:
  fsGroup: 5984

securityContext:
  runAsUser: 5984
  runAsGroup: 5984
  runAsNonRoot: true

livenessProbe:
  enabled: true
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3

readinessProbe:
  enabled: true
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 3
EOF

    # Deploy CouchDB
    helm upgrade --install couchdb couchdb/couchdb \
        --namespace "$NAMESPACE" \
        --values /tmp/couchdb-values.yaml \
        --wait \
        --timeout 10m
    
    # Clean up
    rm /tmp/couchdb-values.yaml
    
    log_success "CouchDB deployed"
}

# Build and push images
build_images() {
    log_info "Building and pushing images..."
    
    # Get current git commit
    GIT_COMMIT=$(git rev-parse --short HEAD)
    TAG="${ENVIRONMENT}-${GIT_COMMIT}"
    
    # Build backend image
    log_info "Building backend image..."
    docker build -t "${DOCKER_REGISTRY}/task-management-backend:${TAG}" backend/
    docker push "${DOCKER_REGISTRY}/task-management-backend:${TAG}"
    
    # Build frontend image
    log_info "Building frontend image..."
    docker build -t "${DOCKER_REGISTRY}/task-management-frontend:${TAG}" frontend/
    docker push "${DOCKER_REGISTRY}/task-management-frontend:${TAG}"
    
    # Update image tags in deployment manifest
    sed -i.bak "s|task-management-backend:latest|${DOCKER_REGISTRY}/task-management-backend:${TAG}|g" k8s/deployment.yaml
    sed -i.bak "s|task-management-frontend:latest|${DOCKER_REGISTRY}/task-management-frontend:${TAG}|g" k8s/deployment.yaml
    
    log_success "Images built and pushed with tag: $TAG"
}

# Apply Kubernetes manifests
apply_manifests() {
    log_info "Applying Kubernetes manifests..."
    
    # Update domain in ingress
    sed -i.bak "s|task-management.example.com|$DOMAIN|g" k8s/deployment.yaml
    
    # Apply all manifests
    kubectl apply -f k8s/ -n "$NAMESPACE"
    
    log_success "Manifests applied"
}

# Wait for deployments
wait_for_deployments() {
    log_info "Waiting for deployments to be ready..."
    
    # Wait for CouchDB
    kubectl wait --for=condition=available --timeout=600s deployment/couchdb -n "$NAMESPACE" || true
    
    # Wait for backend
    kubectl wait --for=condition=available --timeout=300s deployment/task-management-backend -n "$NAMESPACE"
    
    # Wait for frontend
    kubectl wait --for=condition=available --timeout=300s deployment/task-management-frontend -n "$NAMESPACE"
    
    log_success "All deployments are ready"
}

# Initialize database
initialize_database() {
    log_info "Initializing database..."
    
    # Wait for CouchDB to be ready
    kubectl wait --for=condition=ready pod -l app=couchdb -n "$NAMESPACE" --timeout=300s
    
    # Create database
    kubectl exec -n "$NAMESPACE" deployment/couchdb -- curl -X PUT http://admin:$COUCHDB_PASSWORD@localhost:5984/tasks
    
    # Create indexes
    kubectl exec -n "$NAMESPACE" deployment/task-management-backend -- curl -X POST http://localhost:8080/api/setup
    
    log_success "Database initialized"
}

# Run health checks
health_checks() {
    log_info "Running health checks..."
    
    # Check backend health
    kubectl exec -n "$NAMESPACE" deployment/task-management-backend -- curl -f http://localhost:8080/health
    
    # Check frontend accessibility
    kubectl exec -n "$NAMESPACE" deployment/task-management-frontend -- curl -f http://localhost:3000/
    
    # Check database connectivity
    kubectl exec -n "$NAMESPACE" deployment/task-management-backend -- curl -f http://couchdb:5984/
    
    log_success "Health checks passed"
}

# Display deployment information
show_deployment_info() {
    log_info "Deployment Information:"
    echo "========================"
    echo "Namespace: $NAMESPACE"
    echo "Environment: $ENVIRONMENT"
    echo "Domain: $DOMAIN"
    echo ""
    
    # Get service information
    log_info "Services:"
    kubectl get services -n "$NAMESPACE" -o wide
    echo ""
    
    # Get pod information
    log_info "Pods:"
    kubectl get pods -n "$NAMESPACE" -o wide
    echo ""
    
    # Get ingress information
    log_info "Ingress:"
    kubectl get ingress -n "$NAMESPACE"
    echo ""
    
    # Show access URLs
    INGRESS_IP=$(kubectl get ingress task-management-ingress -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
    
    log_success "Deployment completed successfully!"
    echo ""
    echo "Access URLs:"
    echo "  Application: https://$DOMAIN"
    echo "  API: https://$DOMAIN/api"
    if [ "$INGRESS_IP" != "pending" ]; then
        echo "  Direct IP: http://$INGRESS_IP"
    fi
    echo ""
    echo "Credentials:"
    echo "  CouchDB: $COUCHDB_USER / $COUCHDB_PASSWORD"
    echo ""
    echo "To access CouchDB admin interface:"
    echo "  kubectl port-forward -n $NAMESPACE service/couchdb 5984:5984"
    echo "  Then visit: http://localhost:5984/_utils"
}

# Cleanup function
cleanup() {
    log_info "Cleaning up temporary files..."
    rm -f k8s/deployment.yaml.bak
}

# Rollback function
rollback() {
    log_warning "Rolling back deployment..."
    kubectl rollout undo deployment/task-management-backend -n "$NAMESPACE"
    kubectl rollout undo deployment/task-management-frontend -n "$NAMESPACE"
    log_success "Rollback completed"
}

# Main deployment function
main() {
    log_info "Starting Task Management Application deployment..."
    
    # Set trap for cleanup
    trap cleanup EXIT
    
    # Check if rollback is requested
    if [ "${1:-}" = "rollback" ]; then
        rollback
        exit 0
    fi
    
    # Run deployment steps
    check_prerequisites
    create_namespace
    apply_secrets
    
    # Skip image building if using existing images
    if [ "${SKIP_BUILD:-false}" != "true" ]; then
        build_images
    fi
    
    deploy_couchdb
    apply_manifests
    wait_for_deployments
    initialize_database
    health_checks
    show_deployment_info
    
    log_success "Task Management Application deployed successfully! 🚀"
}

# Help function
show_help() {
    echo "Task Management Application Deployment Script"
    echo ""
    echo "Usage: $0 [options] [command]"
    echo ""
    echo "Commands:"
    echo "  deploy    Deploy the application (default)"
    echo "  rollback  Rollback to previous deployment"
    echo "  help      Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  NAMESPACE        Kubernetes namespace (default: task-management)"
    echo "  DOCKER_REGISTRY  Docker registry URL (default: ghcr.io/your-org)"
    echo "  ENVIRONMENT      Environment name (default: production)"
    echo "  DOMAIN           Application domain (default: task-management.example.com)"
    echo "  COUCHDB_USER     CouchDB username (default: admin)"
    echo "  COUCHDB_PASSWORD CouchDB password (auto-generated if not provided)"
    echo "  JWT_SECRET       JWT secret key (auto-generated if not provided)"
    echo "  SKIP_BUILD       Skip image building (default: false)"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Deploy with defaults"
    echo "  ENVIRONMENT=staging $0                # Deploy to staging"
    echo "  SKIP_BUILD=true $0                    # Deploy without building images"
    echo "  $0 rollback                           # Rollback deployment"
}

# Parse command line arguments
case "${1:-deploy}" in
    deploy)
        main
        ;;
    rollback)
        main rollback
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        log_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
