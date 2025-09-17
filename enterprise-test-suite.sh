#!/bin/bash

# 🚀 Enterprise-Grade Multi-Application Testing Suite
# Docker Compose + Kubernetes Ready Infrastructure Testing

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Progress tracking
TOTAL_TESTS=12
CURRENT_TEST=0

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE} $1 ${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_step() {
    CURRENT_TEST=$((CURRENT_TEST + 1))
    echo -e "${CYAN}[$CURRENT_TEST/$TOTAL_TESTS] $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${PURPLE}ℹ️ $1${NC}"
}

# Test results tracking
RESULTS_FILE="ENTERPRISE_TEST_RESULTS_$(date +%Y%m%d_%H%M%S).md"

init_results_file() {
    cat > "$RESULTS_FILE" << EOF
# 🚀 Enterprise Multi-Application Test Results
**Test Date:** $(date)
**Docker Infrastructure:** Docker Compose + Kubernetes Manifests
**Applications Tested:** 6 (E-commerce, Weather, Educational, Medical, Task Management, Social Media)
**Databases:** MongoDB, Redis, PostgreSQL, SQL Server, CouchDB

## Test Summary
EOF
}

log_result() {
    echo "- $1" >> "$RESULTS_FILE"
}

# Infrastructure Setup
test_infrastructure() {
    print_step "Testing Docker Infrastructure"
    
    # Check Docker availability
    if command -v docker &> /dev/null; then
        print_success "Docker CLI available"
        log_result "✅ Docker CLI: Available"
        
        # Test Docker daemon
        if docker info &> /dev/null; then
            print_success "Docker daemon running"
            log_result "✅ Docker Daemon: Running"
            
            # Start Docker Compose services
            print_info "Starting database containers..."
            if docker compose up -d; then
                print_success "All database containers started"
                log_result "✅ Database Containers: All started successfully"
                
                # Wait for services to be ready
                print_info "Waiting for services to initialize..."
                sleep 30
                
                # Test individual database connections
                test_database_connectivity
            else
                print_warning "Docker Compose failed, will test without containers"
                log_result "⚠️ Database Containers: Failed to start, testing without containers"
            fi
        else
            print_warning "Docker daemon not running, will test without containers"
            log_result "⚠️ Docker Daemon: Not running"
        fi
    else
        print_warning "Docker not available, will test applications in standalone mode"
        log_result "⚠️ Docker: Not available"
    fi
}

test_database_connectivity() {
    print_step "Testing Database Connectivity"
    
    # Test MongoDB
    if docker exec ecommerce-mongodb mongosh --eval "db.admin.ping()" &> /dev/null; then
        print_success "MongoDB connection successful"
        log_result "✅ MongoDB: Connected"
    else
        print_warning "MongoDB connection failed"
        log_result "⚠️ MongoDB: Connection failed"
    fi
    
    # Test Redis
    if docker exec weather-redis redis-cli ping | grep -q PONG; then
        print_success "Redis connection successful"
        log_result "✅ Redis: Connected"
    else
        print_warning "Redis connection failed"
        log_result "⚠️ Redis: Connection failed"
    fi
    
    # Test PostgreSQL
    if docker exec educational-postgresql pg_isready -U eduuser; then
        print_success "PostgreSQL connection successful"
        log_result "✅ PostgreSQL: Connected"
    else
        print_warning "PostgreSQL connection failed"
        log_result "⚠️ PostgreSQL: Connection failed"
    fi
    
    # Test SQL Server
    if docker exec medical-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P MedicalCare123! -Q "SELECT 1" &> /dev/null; then
        print_success "SQL Server connection successful"
        log_result "✅ SQL Server: Connected"
    else
        print_warning "SQL Server connection failed"
        log_result "⚠️ SQL Server: Connection failed"
    fi
    
    # Test CouchDB
    if curl -s http://localhost:5984/ | grep -q couchdb; then
        print_success "CouchDB connection successful"
        log_result "✅ CouchDB: Connected"
    else
        print_warning "CouchDB connection failed"
        log_result "⚠️ CouchDB: Connection failed"
    fi
}

test_application() {
    local app_name="$1"
    local app_dir="$2"
    local port="$3"
    local tech_stack="$4"
    
    print_step "Testing $app_name ($tech_stack)"
    
    cd "$app_dir"
    
    case "$tech_stack" in
        "nodejs")
            test_nodejs_app "$app_name" "$port"
            ;;
        "python")
            test_python_app "$app_name" "$port"
            ;;
        "java")
            test_java_app "$app_name" "$port"
            ;;
        "dotnet")
            test_dotnet_app "$app_name" "$port"
            ;;
        "go")
            test_go_app "$app_name" "$port"
            ;;
        "ruby")
            test_ruby_app "$app_name" "$port"
            ;;
    esac
    
    cd - > /dev/null
}

test_nodejs_app() {
    local app_name="$1"
    local port="$2"
    
    if [ -f "backend/package.json" ]; then
        cd backend
        
        # Install dependencies
        if npm install; then
            print_success "$app_name: Dependencies installed"
            log_result "✅ $app_name Dependencies: Installed"
            
            # Start application in background
            npm start &
            APP_PID=$!
            sleep 10
            
            # Test health endpoint
            if curl -s "http://localhost:$port/health" | grep -q "ok\|healthy\|running"; then
                print_success "$app_name: Health check passed"
                log_result "✅ $app_name Health: Passed"
            else
                print_warning "$app_name: Health check failed"
                log_result "⚠️ $app_name Health: Failed"
            fi
            
            # Stop application
            kill $APP_PID 2>/dev/null || true
        else
            print_error "$app_name: Failed to install dependencies"
            log_result "❌ $app_name Dependencies: Failed"
        fi
        
        cd ..
    else
        print_warning "$app_name: No package.json found"
        log_result "⚠️ $app_name: No package.json"
    fi
}

test_python_app() {
    local app_name="$1"
    local port="$2"
    
    if [ -f "backend/requirements.txt" ]; then
        cd backend
        
        # Create virtual environment
        python3 -m venv venv
        source venv/bin/activate
        
        # Install dependencies
        if pip install -r requirements.txt; then
            print_success "$app_name: Dependencies installed"
            log_result "✅ $app_name Dependencies: Installed"
            
            # Test syntax
            if python -m py_compile app.py; then
                print_success "$app_name: Syntax check passed"
                log_result "✅ $app_name Syntax: Valid"
            else
                print_error "$app_name: Syntax errors found"
                log_result "❌ $app_name Syntax: Invalid"
            fi
        else
            print_error "$app_name: Failed to install dependencies"
            log_result "❌ $app_name Dependencies: Failed"
        fi
        
        deactivate
        cd ..
    else
        print_warning "$app_name: No requirements.txt found"
        log_result "⚠️ $app_name: No requirements.txt"
    fi
}

test_java_app() {
    local app_name="$1"
    local port="$2"
    
    if [ -f "backend/pom.xml" ] || [ -f "backend/build.gradle" ]; then
        cd backend
        
        # Test with Maven
        if [ -f "pom.xml" ]; then
            if mvn compile; then
                print_success "$app_name: Maven compilation successful"
                log_result "✅ $app_name Compilation: Success (Maven)"
            else
                print_error "$app_name: Maven compilation failed"
                log_result "❌ $app_name Compilation: Failed (Maven)"
            fi
        fi
        
        # Test with Gradle
        if [ -f "build.gradle" ]; then
            if ./gradlew build; then
                print_success "$app_name: Gradle build successful"
                log_result "✅ $app_name Build: Success (Gradle)"
            else
                print_error "$app_name: Gradle build failed"
                log_result "❌ $app_name Build: Failed (Gradle)"
            fi
        fi
        
        cd ..
    else
        print_warning "$app_name: No Maven/Gradle configuration found"
        log_result "⚠️ $app_name: No build configuration"
    fi
}

test_dotnet_app() {
    local app_name="$1"
    local port="$2"
    
    if find . -name "*.csproj" -o -name "*.sln" | grep -q .; then
        cd backend
        
        # Restore dependencies
        if dotnet restore; then
            print_success "$app_name: Dependencies restored"
            log_result "✅ $app_name Dependencies: Restored"
            
            # Build application
            if dotnet build; then
                print_success "$app_name: Build successful"
                log_result "✅ $app_name Build: Success"
            else
                print_error "$app_name: Build failed"
                log_result "❌ $app_name Build: Failed"
            fi
        else
            print_error "$app_name: Failed to restore dependencies"
            log_result "❌ $app_name Dependencies: Failed"
        fi
        
        cd ..
    else
        print_warning "$app_name: No .NET project files found"
        log_result "⚠️ $app_name: No .NET project"
    fi
}

test_go_app() {
    local app_name="$1"
    local port="$2"
    
    if [ -f "backend/go.mod" ]; then
        cd backend
        
        # Download dependencies
        if go mod download; then
            print_success "$app_name: Dependencies downloaded"
            log_result "✅ $app_name Dependencies: Downloaded"
            
            # Build application
            if go build .; then
                print_success "$app_name: Build successful"
                log_result "✅ $app_name Build: Success"
            else
                print_error "$app_name: Build failed"
                log_result "❌ $app_name Build: Failed"
            fi
        else
            print_error "$app_name: Failed to download dependencies"
            log_result "❌ $app_name Dependencies: Failed"
        fi
        
        cd ..
    else
        print_warning "$app_name: No go.mod found"
        log_result "⚠️ $app_name: No go.mod"
    fi
}

test_ruby_app() {
    local app_name="$1"
    local port="$2"
    
    if [ -f "backend/Gemfile" ]; then
        cd backend
        
        # Install dependencies
        if bundle install; then
            print_success "$app_name: Dependencies installed"
            log_result "✅ $app_name Dependencies: Installed"
            
            # Check syntax
            if ruby -c config/application.rb; then
                print_success "$app_name: Syntax check passed"
                log_result "✅ $app_name Syntax: Valid"
            else
                print_error "$app_name: Syntax errors found"
                log_result "❌ $app_name Syntax: Invalid"
            fi
        else
            print_error "$app_name: Failed to install dependencies"
            log_result "❌ $app_name Dependencies: Failed"
        fi
        
        cd ..
    else
        print_warning "$app_name: No Gemfile found"
        log_result "⚠️ $app_name: No Gemfile"
    fi
}

# Main test execution
main() {
    print_header "🚀 ENTERPRISE MULTI-APPLICATION TEST SUITE"
    print_info "Testing 6 applications with Docker Compose + Kubernetes infrastructure"
    
    init_results_file
    
    # Infrastructure tests
    test_infrastructure
    
    # Application tests
    test_application "E-commerce" "ecommerce-app" "5000" "nodejs"
    test_application "Weather" "weather-app" "5001" "python"
    test_application "Educational" "educational-platform" "8080" "java"
    test_application "Medical Care" "medical-care-system" "8080" "dotnet"
    test_application "Task Management" "task-management-app" "8082" "go"
    test_application "Social Media" "social-media-platform" "3000" "ruby"
    
    # Kubernetes deployment test
    print_step "Testing Kubernetes Manifests"
    if kubectl version --client &> /dev/null; then
        print_success "kubectl available"
        if kubectl apply --dry-run=client -f k8s-database-manifests.yaml; then
            print_success "Kubernetes manifests are valid"
            log_result "✅ Kubernetes Manifests: Valid"
        else
            print_error "Kubernetes manifests have errors"
            log_result "❌ Kubernetes Manifests: Invalid"
        fi
    else
        print_warning "kubectl not available, skipping K8s validation"
        log_result "⚠️ Kubernetes: kubectl not available"
    fi
    
    # Security and Integration tests
    print_step "Security Validation"
    print_info "Checking environment variable security..."
    
    # Check for exposed secrets
    if grep -r "password\|secret\|key" --include="*.env" . | grep -v "your_.*_here"; then
        print_warning "Potential exposed secrets found"
        log_result "⚠️ Security: Potential secrets exposed"
    else
        print_success "No exposed secrets detected"
        log_result "✅ Security: No exposed secrets"
    fi
    
    # Final summary
    print_header "📋 TEST SUMMARY"
    echo -e "${GREEN}Test results saved to: $RESULTS_FILE${NC}"
    
    # Add final summary to results
    cat >> "$RESULTS_FILE" << EOF

## Test Completion
**Status:** Complete
**Results File:** $RESULTS_FILE
**Docker Compose:** docker-compose.yml
**Kubernetes Manifests:** k8s-database-manifests.yaml

## Next Steps
1. Deploy to staging environment
2. Run load testing
3. Execute security penetration testing
4. Deploy to production with monitoring
EOF
    
    print_success "Enterprise testing complete!"
}

# Execute main function
main "$@"
