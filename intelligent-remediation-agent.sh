#!/bin/bash
# 🤖 INTELLIGENT APPLICATION REMEDIATION AGENT
# Automatically diagnoses and fixes application issues
# Following copilot-instructions zero tolerance policy

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Remediation tracking
TOTAL_ISSUES_FOUND=0
TOTAL_ISSUES_FIXED=0
declare -a REMEDIATION_LOG=()

log_remediation() {
    local action="$1"
    local result="$2"
    REMEDIATION_LOG+=("$(date): $action - $result")
    echo "   📝 Logged: $action - $result"
}

# Intelligent diagnosis and auto-fix for each application
fix_ecommerce_app() {
    echo "${CYAN}🔧 DIAGNOSING & FIXING E-COMMERCE APP${NC}"
    echo "============================================"
    
    # Check if containers are running
    if ! docker-compose -f /Volumes/512-B/Documents/PERSONAL/full-stack-apps/ecommerce-app/docker-compose.yml ps | grep -q "Up"; then
        echo "   🚨 Issue: E-commerce containers not running"
        ((TOTAL_ISSUES_FOUND++))
        
        echo "   🔄 Fixing: Restarting E-commerce services..."
        cd /Volumes/512-B/Documents/PERSONAL/full-stack-apps/ecommerce-app
        docker-compose down -v
        docker-compose up -d --build
        sleep 15
        
        if docker-compose ps | grep -q "Up"; then
            echo "   ✅ Fixed: E-commerce services restarted successfully"
            ((TOTAL_ISSUES_FIXED++))
            log_remediation "E-commerce container restart" "SUCCESS"
        else
            echo "   ❌ Failed: Could not restart E-commerce services"
            log_remediation "E-commerce container restart" "FAILED"
        fi
    fi
    
    # Check database seeding
    echo "   🔍 Checking: Database seed data..."
    if ! docker-compose exec -T mongodb mongosh ecommerce --eval "db.products.countDocuments()" | grep -E "[1-9][0-9]*"; then
        echo "   🚨 Issue: No products in database"
        ((TOTAL_ISSUES_FOUND++))
        
        echo "   🔄 Fixing: Seeding database with sample data..."
        docker-compose exec -T mongodb mongosh ecommerce --eval "
        db.products.insertMany([
            {name: 'Laptop Pro', price: 1299.99, category: 'Electronics', description: 'High-performance laptop'},
            {name: 'Wireless Mouse', price: 29.99, category: 'Electronics', description: 'Ergonomic wireless mouse'},
            {name: 'Coffee Maker', price: 89.99, category: 'Appliances', description: 'Automatic coffee maker'},
            {name: 'Running Shoes', price: 79.99, category: 'Sports', description: 'Comfortable running shoes'},
            {name: 'Bluetooth Speaker', price: 49.99, category: 'Electronics', description: 'Portable bluetooth speaker'}
        ]);
        db.categories.insertMany([
            {name: 'Electronics', description: 'Electronic devices and gadgets'},
            {name: 'Appliances', description: 'Home and kitchen appliances'},
            {name: 'Sports', description: 'Sports and fitness equipment'}
        ]);"
        
        if docker-compose exec -T mongodb mongosh ecommerce --eval "db.products.countDocuments()" | grep -E "[1-9][0-9]*"; then
            echo "   ✅ Fixed: Database seeded with sample data"
            ((TOTAL_ISSUES_FIXED++))
            log_remediation "E-commerce database seeding" "SUCCESS"
        else
            echo "   ❌ Failed: Could not seed database"
            log_remediation "E-commerce database seeding" "FAILED"
        fi
    fi
    
    # Test API endpoints
    echo "   🔍 Testing: API endpoints..."
    sleep 10  # Allow services to fully start
    
    if ! curl -s http://localhost:5000/health | grep -q "OK"; then
        echo "   🚨 Issue: Backend API not responding"
        ((TOTAL_ISSUES_FOUND++))
        
        echo "   🔄 Fixing: Rebuilding backend service..."
        docker-compose build backend --no-cache
        docker-compose restart backend
        sleep 15
        
        if curl -s http://localhost:5000/health | grep -q "OK"; then
            echo "   ✅ Fixed: Backend API is now responding"
            ((TOTAL_ISSUES_FIXED++))
            log_remediation "E-commerce backend API fix" "SUCCESS"
        else
            echo "   ❌ Failed: Backend API still not responding"
            log_remediation "E-commerce backend API fix" "FAILED"
        fi
    fi
    
    cd /Volumes/512-B/Documents/PERSONAL/full-stack-apps
}

fix_educational_platform() {
    echo "${CYAN}🔧 DIAGNOSING & FIXING EDUCATIONAL PLATFORM${NC}"
    echo "================================================"
    
    # Check Spring Boot backend
    if ! curl -s http://localhost:8080/health 2>/dev/null | grep -q "UP"; then
        echo "   🚨 Issue: Spring Boot backend not healthy"
        ((TOTAL_ISSUES_FOUND++))
        
        echo "   🔄 Fixing: Rebuilding Spring Boot application..."
        cd /Volumes/512-B/Documents/PERSONAL/full-stack-apps/educational-platform
        docker-compose build backend --no-cache
        docker-compose restart backend
        sleep 20
        
        if curl -s http://localhost:8080/health 2>/dev/null | grep -q "UP"; then
            echo "   ✅ Fixed: Spring Boot backend is healthy"
            ((TOTAL_ISSUES_FIXED++))
            log_remediation "Educational platform backend fix" "SUCCESS"
        else
            echo "   ❌ Failed: Spring Boot backend still unhealthy"
            log_remediation "Educational platform backend fix" "FAILED"
        fi
    fi
    
    # Check database connection and seed data
    echo "   🔍 Checking: Database connection and data..."
    if ! docker-compose exec -T postgres psql -U postgres -d educational_platform -c "SELECT COUNT(*) FROM courses;" 2>/dev/null | grep -E "[0-9]+"; then
        echo "   🚨 Issue: Database connection or missing data"
        ((TOTAL_ISSUES_FOUND++))
        
        echo "   🔄 Fixing: Setting up database schema and data..."
        docker-compose exec -T postgres psql -U postgres -d educational_platform -c "
        CREATE TABLE IF NOT EXISTS courses (
            id SERIAL PRIMARY KEY,
            title VARCHAR(255) NOT NULL,
            description TEXT,
            instructor_id INTEGER,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        CREATE TABLE IF NOT EXISTS students (
            id SERIAL PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            email VARCHAR(255) UNIQUE NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        CREATE TABLE IF NOT EXISTS instructors (
            id SERIAL PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            email VARCHAR(255) UNIQUE NOT NULL,
            specialty VARCHAR(255),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        INSERT INTO courses (title, description) VALUES 
            ('Introduction to Programming', 'Learn the basics of programming'),
            ('Web Development', 'Build modern web applications'),
            ('Data Science', 'Analyze data and build models'),
            ('Machine Learning', 'Introduction to ML concepts'),
            ('Database Design', 'Design efficient databases');
        INSERT INTO instructors (name, email, specialty) VALUES
            ('Dr. Smith', 'smith@edu.com', 'Computer Science'),
            ('Prof. Johnson', 'johnson@edu.com', 'Data Science'),
            ('Dr. Williams', 'williams@edu.com', 'Web Development');
        INSERT INTO students (name, email) VALUES
            ('Alice Cooper', 'alice@student.edu'),
            ('Bob Wilson', 'bob@student.edu'),
            ('Carol Davis', 'carol@student.edu');"
        
        if docker-compose exec -T postgres psql -U postgres -d educational_platform -c "SELECT COUNT(*) FROM courses;" | grep -E "[1-9][0-9]*"; then
            echo "   ✅ Fixed: Database schema and data created"
            ((TOTAL_ISSUES_FIXED++))
            log_remediation "Educational platform database setup" "SUCCESS"
        else
            echo "   ❌ Failed: Could not set up database"
            log_remediation "Educational platform database setup" "FAILED"
        fi
    fi
    
    cd /Volumes/512-B/Documents/PERSONAL/full-stack-apps
}

fix_medical_care_system() {
    echo "${CYAN}🔧 DIAGNOSING & FIXING MEDICAL CARE SYSTEM${NC}"
    echo "==============================================="
    
    # Check frontend (already fixed with custom interface)
    if ! curl -s http://localhost:5171 | grep -q "Medical Care System"; then
        echo "   🚨 Issue: Medical Care frontend not accessible"
        ((TOTAL_ISSUES_FOUND++))
        
        echo "   🔄 Fixing: Rebuilding frontend with custom interface..."
        cd /Volumes/512-B/Documents/PERSONAL/full-stack-apps/medical-care-system
        docker-compose build medical-care-frontend --no-cache
        docker-compose restart medical-care-frontend
        sleep 10
        
        if curl -s http://localhost:5171 | grep -q "Medical Care System"; then
            echo "   ✅ Fixed: Medical Care frontend is accessible"
            ((TOTAL_ISSUES_FIXED++))
            log_remediation "Medical Care frontend fix" "SUCCESS"
        else
            echo "   ❌ Failed: Frontend still not accessible"
            log_remediation "Medical Care frontend fix" "FAILED"
        fi
    fi
    
    # Check .NET backend
    if ! curl -s http://localhost:5170/health 2>/dev/null; then
        echo "   🚨 Issue: .NET backend not responding"
        ((TOTAL_ISSUES_FOUND++))
        
        echo "   🔄 Fixing: Rebuilding .NET backend..."
        docker-compose build medical-care-backend --no-cache
        docker-compose restart medical-care-backend
        sleep 20
        
        if curl -s http://localhost:5170/health 2>/dev/null; then
            echo "   ✅ Fixed: .NET backend is responding"
            ((TOTAL_ISSUES_FIXED++))
            log_remediation "Medical Care backend fix" "SUCCESS"
        else
            echo "   ❌ Failed: Backend still not responding"
            log_remediation "Medical Care backend fix" "FAILED"
        fi
    fi
    
    cd /Volumes/512-B/Documents/PERSONAL/full-stack-apps
}

fix_task_management_app() {
    echo "${CYAN}🔧 DIAGNOSING & FIXING TASK MANAGEMENT APP${NC}"
    echo "==============================================="
    
    # Check Go backend
    if ! curl -s http://localhost:8000/health 2>/dev/null; then
        echo "   🚨 Issue: Go backend not responding"
        ((TOTAL_ISSUES_FOUND++))
        
        echo "   🔄 Fixing: Rebuilding Go backend..."
        cd /Volumes/512-B/Documents/PERSONAL/full-stack-apps/task-management-app
        docker-compose build backend --no-cache
        docker-compose restart backend
        sleep 15
        
        if curl -s http://localhost:8000/health 2>/dev/null; then
            echo "   ✅ Fixed: Go backend is responding"
            ((TOTAL_ISSUES_FIXED++))
            log_remediation "Task Management backend fix" "SUCCESS"
        else
            echo "   ❌ Failed: Backend still not responding"
            log_remediation "Task Management backend fix" "FAILED"
        fi
    fi
    
    # Check CouchDB and seed data
    if ! curl -s http://localhost:5984/_up | grep -q "ok"; then
        echo "   🚨 Issue: CouchDB not accessible"
        ((TOTAL_ISSUES_FOUND++))
        
        echo "   🔄 Fixing: Restarting CouchDB..."
        docker-compose restart couchdb
        sleep 10
        
        if curl -s http://localhost:5984/_up | grep -q "ok"; then
            echo "   ✅ Fixed: CouchDB is accessible"
            ((TOTAL_ISSUES_FIXED++))
            log_remediation "Task Management CouchDB fix" "SUCCESS"
        else
            echo "   ❌ Failed: CouchDB still not accessible"
            log_remediation "Task Management CouchDB fix" "FAILED"
        fi
    fi
    
    # Create sample tasks database
    echo "   🔄 Setting up: Sample tasks database..."
    curl -s -X PUT http://localhost:5984/tasks
    curl -s -X POST http://localhost:5984/tasks -H "Content-Type: application/json" -d '{"title": "Sample Task", "description": "This is a sample task", "status": "pending", "priority": "medium"}'
    
    cd /Volumes/512-B/Documents/PERSONAL/full-stack-apps
}

fix_weather_app() {
    echo "${CYAN}🔧 DIAGNOSING & FIXING WEATHER APP${NC}"
    echo "======================================="
    
    # Check Python Flask backend
    if ! curl -s http://localhost:5002/health 2>/dev/null; then
        echo "   🚨 Issue: Flask backend not responding"
        ((TOTAL_ISSUES_FOUND++))
        
        echo "   🔄 Fixing: Rebuilding Flask backend..."
        cd /Volumes/512-B/Documents/PERSONAL/full-stack-apps/weather-app
        docker-compose build backend --no-cache
        docker-compose restart backend
        sleep 15
        
        if curl -s http://localhost:5002/health 2>/dev/null; then
            echo "   ✅ Fixed: Flask backend is responding"
            ((TOTAL_ISSUES_FIXED++))
            log_remediation "Weather App backend fix" "SUCCESS"
        else
            echo "   ❌ Failed: Backend still not responding"
            log_remediation "Weather App backend fix" "FAILED"
        fi
    fi
    
    # Check Redis
    if ! docker-compose exec -T redis redis-cli ping 2>/dev/null | grep -q "PONG"; then
        echo "   🚨 Issue: Redis not responding"
        ((TOTAL_ISSUES_FOUND++))
        
        echo "   🔄 Fixing: Restarting Redis..."
        docker-compose restart redis
        sleep 10
        
        if docker-compose exec -T redis redis-cli ping 2>/dev/null | grep -q "PONG"; then
            echo "   ✅ Fixed: Redis is responding"
            ((TOTAL_ISSUES_FIXED++))
            log_remediation "Weather App Redis fix" "SUCCESS"
        else
            echo "   ❌ Failed: Redis still not responding"
            log_remediation "Weather App Redis fix" "FAILED"
        fi
    fi
    
    cd /Volumes/512-B/Documents/PERSONAL/full-stack-apps
}

fix_social_media_platform() {
    echo "${CYAN}🔧 DIAGNOSING & FIXING SOCIAL MEDIA PLATFORM${NC}"
    echo "================================================"
    
    # Check Ruby Sinatra backend
    if ! curl -s http://localhost:3005/health 2>/dev/null; then
        echo "   🚨 Issue: Ruby Sinatra backend not responding"
        ((TOTAL_ISSUES_FOUND++))
        
        echo "   🔄 Fixing: Rebuilding Ruby backend..."
        cd /Volumes/512-B/Documents/PERSONAL/full-stack-apps/social-media-platform
        docker-compose build backend --no-cache
        docker-compose restart backend
        sleep 15
        
        if curl -s http://localhost:3005/health 2>/dev/null; then
            echo "   ✅ Fixed: Ruby backend is responding"
            ((TOTAL_ISSUES_FIXED++))
            log_remediation "Social Media backend fix" "SUCCESS"
        else
            echo "   ❌ Failed: Backend still not responding"
            log_remediation "Social Media backend fix" "FAILED"
        fi
    fi
    
    # Check PostgreSQL and seed data
    if ! docker-compose exec -T postgres psql -U postgres -d social_media -c "SELECT COUNT(*) FROM users;" 2>/dev/null | grep -E "[0-9]+"; then
        echo "   🚨 Issue: PostgreSQL connection or missing data"
        ((TOTAL_ISSUES_FOUND++))
        
        echo "   🔄 Fixing: Setting up database schema and data..."
        docker-compose exec -T postgres psql -U postgres -d social_media -c "
        CREATE TABLE IF NOT EXISTS users (
            id SERIAL PRIMARY KEY,
            username VARCHAR(255) UNIQUE NOT NULL,
            email VARCHAR(255) UNIQUE NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        CREATE TABLE IF NOT EXISTS posts (
            id SERIAL PRIMARY KEY,
            user_id INTEGER REFERENCES users(id),
            content TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        INSERT INTO users (username, email) VALUES 
            ('john_doe', 'john@example.com'),
            ('jane_smith', 'jane@example.com'),
            ('bob_wilson', 'bob@example.com');
        INSERT INTO posts (user_id, content) VALUES
            (1, 'Hello world! This is my first post.'),
            (2, 'Just finished an amazing project!'),
            (3, 'Beautiful sunset today.');"
        
        if docker-compose exec -T postgres psql -U postgres -d social_media -c "SELECT COUNT(*) FROM users;" | grep -E "[1-9][0-9]*"; then
            echo "   ✅ Fixed: Database schema and data created"
            ((TOTAL_ISSUES_FIXED++))
            log_remediation "Social Media database setup" "SUCCESS"
        else
            echo "   ❌ Failed: Could not set up database"
            log_remediation "Social Media database setup" "FAILED"
        fi
    fi
    
    cd /Volumes/512-B/Documents/PERSONAL/full-stack-apps
}

# Main remediation function
main() {
    echo "${PURPLE}🤖 INTELLIGENT APPLICATION REMEDIATION AGENT${NC}"
    echo "${PURPLE}==============================================${NC}"
    echo "🎯 Mission: Auto-diagnose and fix application issues"
    echo "⚡ Policy: Zero tolerance for failures"
    echo "🔧 Approach: Systematic diagnosis and remediation"
    echo ""
    
    # Run remediation for all applications
    fix_ecommerce_app
    fix_educational_platform
    fix_medical_care_system
    fix_task_management_app
    fix_weather_app
    fix_social_media_platform
    
    # Final remediation report
    echo ""
    echo "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "${PURPLE}🤖 REMEDIATION AGENT EXECUTION REPORT${NC}"
    echo "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "📊 Total Issues Found: $TOTAL_ISSUES_FOUND"
    echo "${GREEN}✅ Issues Fixed: $TOTAL_ISSUES_FIXED${NC}"
    echo "${RED}❌ Issues Remaining: $((TOTAL_ISSUES_FOUND - TOTAL_ISSUES_FIXED))${NC}"
    echo ""
    
    if [ $TOTAL_ISSUES_FIXED -lt $TOTAL_ISSUES_FOUND ]; then
        echo "${RED}⚠️ Some issues could not be automatically resolved${NC}"
        echo "${YELLOW}📋 Manual intervention may be required${NC}"
    else
        echo "${GREEN}🎉 All identified issues have been resolved!${NC}"
        echo "${GREEN}✅ Applications should now be fully functional${NC}"
    fi
    
    echo ""
    echo "${CYAN}📝 REMEDIATION LOG:${NC}"
    for log_entry in "${REMEDIATION_LOG[@]}"; do
        echo "  • $log_entry"
    done
    
    echo ""
    echo "${GREEN}🤖 REMEDIATION AGENT COMPLETE${NC}"
    echo "${YELLOW}🔄 Recommendation: Run functionality tests to validate fixes${NC}"
}

# Execute main function
main "$@"