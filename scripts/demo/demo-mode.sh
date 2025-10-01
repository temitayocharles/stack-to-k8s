#!/bin/bash
# 🎮 DEMO MODE - Interactive Learning Experience
# Guided walkthrough of platform capabilities with real demonstrations

set -euo pipefail

# Colors and styling
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly RED='\033[0;31m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Configuration
readonly DEMO_APP="ecommerce-app"
readonly DEMO_TIMEOUT=30

cleanup_demo() {
    echo -e "\n${YELLOW}🧹 Cleaning up demo environment...${NC}"
    cd "$DEMO_APP" 2>/dev/null || return
    docker-compose down -v --remove-orphans 2>/dev/null || true
    cd ..
}

trap cleanup_demo EXIT

show_banner() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}🎮 KUBERNETES LEARNING PLATFORM - DEMO MODE${NC}"
    echo -e "${CYAN}║${NC} ${BLUE}Interactive walkthrough of world-class DevOps learning${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

wait_for_user() {
    local message="${1:-Press ENTER to continue...}"
    echo -e "\n${CYAN}$message${NC}"
    read -r
}

show_platform_overview() {
    show_banner
    echo -e "${PURPLE}🌟 Welcome to the Ultimate Kubernetes Learning Platform!${NC}"
    echo ""
    echo -e "${BLUE}What makes this platform special:${NC}"
    echo "   🎯 6 Real-world applications (not toy examples)"
    echo "   📈 Progressive difficulty levels (Beginner → Expert)"
    echo "   🔧 Complete DevOps toolchain"
    echo "   ☁️  Multi-cloud deployment strategies"
    echo "   🔒 Enterprise-grade security practices"
    echo "   📊 Full observability stack"
    echo "   💥 Chaos engineering scenarios"
    echo "   🚀 Advanced Kubernetes features"
    echo ""
    echo -e "${GREEN}🎓 By the end, you'll have production-ready DevOps skills${NC}"
    
    wait_for_user
}

show_applications() {
    show_banner
    echo -e "${PURPLE}🏗️  REAL-WORLD APPLICATIONS${NC}"
    echo ""
    echo -e "${BLUE}Choose from 6 production-ready applications:${NC}"
    echo ""
    echo "🛒 ${BOLD}E-commerce Platform${NC} - Complete shopping solution"
    echo "   • Node.js + React + MongoDB"
    echo "   • Payment integration, inventory management"
    echo "   • Perfect for beginners"
    echo ""
    echo "🎓 ${BOLD}Educational Platform${NC} - Online learning system"
    echo "   • Java Spring Boot + Angular + PostgreSQL"
    echo "   • Video streaming, real-time collaboration"
    echo "   • Great for intermediate learners"
    echo ""
    echo "🏥 ${BOLD}Medical Care System${NC} - Healthcare management"
    echo "   • .NET Core + Blazor + SQL Server"
    echo "   • HIPAA compliance, real-time monitoring"
    echo "   • Advanced security focus"
    echo ""
    echo "📋 ${BOLD}Task Management${NC} - Project coordination"
    echo "   • Go + Svelte + CouchDB"
    echo "   • Real-time updates, team collaboration"
    echo "   • Microservices architecture"
    echo ""
    echo "🌤️  ${BOLD}Weather Service${NC} - Meteorological platform"
    echo "   • Python Flask + Vue.js + Redis"
    echo "   • API integrations, data processing"
    echo "   • Great for data-focused learning"
    echo ""
    echo "📱 ${BOLD}Social Media Platform${NC} - Community network"
    echo "   • Ruby on Rails + React Native Web"
    echo "   • Real-time messaging, content moderation"
    echo "   • Expert-level complexity"
    
    wait_for_user
}

show_difficulty_levels() {
    show_banner
    echo -e "${PURPLE}📊 PROGRESSIVE DIFFICULTY SYSTEM${NC}"
    echo ""
    echo -e "${GREEN}🟢 LEVEL 1: BEGINNER (Foundation Building)${NC}"
    echo "   • Container basics with Docker Compose"
    echo "   • Simple Kubernetes deployments"
    echo "   • Basic monitoring setup"
    echo "   • Guided secret management"
    echo "   • Estimated time: 2-4 weeks"
    echo ""
    echo -e "${YELLOW}🟡 LEVEL 2: INTERMEDIATE (Skill Development)${NC}"
    echo "   • Advanced Kubernetes features"
    echo "   • CI/CD pipeline implementation"
    echo "   • Infrastructure as Code"
    echo "   • Security scanning and hardening"
    echo "   • Estimated time: 4-8 weeks"
    echo ""
    echo -e "${BLUE}🔵 LEVEL 3: ADVANCED (Mastery Building)${NC}"
    echo "   • Multi-cloud deployments"
    echo "   • Service mesh implementation"
    echo "   • Advanced monitoring and alerting"
    echo "   • Chaos engineering"
    echo "   • Estimated time: 8-12 weeks"
    echo ""
    echo -e "${RED}🔴 LEVEL 4: EXPERT (Production Ready)${NC}"
    echo "   • Enterprise architecture patterns"
    echo "   • Compliance and governance"
    echo "   • Performance optimization"
    echo "   • Disaster recovery planning"
    echo "   • Estimated time: 12+ weeks"
    
    wait_for_user
}

demo_application() {
    show_banner
    echo -e "${PURPLE}🚀 LIVE APPLICATION DEMONSTRATION${NC}"
    echo ""
    echo -e "${BLUE}Let's see a real application in action!${NC}"
    echo "We'll quickly deploy the e-commerce app to show you what's possible."
    echo ""
    
    wait_for_user "Ready to see some magic? Press ENTER..."
    
    echo -e "${YELLOW}📁 Entering application directory...${NC}"
    cd "$DEMO_APP" || {
        echo -e "${RED}❌ Demo application not found!${NC}"
        return 1
    }
    
    echo -e "${YELLOW}🐳 Starting application containers...${NC}"
    echo "   This will take 30-60 seconds..."
    
    if timeout $DEMO_TIMEOUT docker-compose up -d 2>/dev/null; then
        sleep 5
        
        echo -e "${GREEN}✅ Application started successfully!${NC}"
        echo ""
        echo -e "${CYAN}🌐 Application URLs:${NC}"
        echo "   • Frontend: http://localhost:3000"
        echo "   • Backend API: http://localhost:5000"
        echo "   • Admin Panel: http://localhost:3000/admin"
        echo ""
        
        # Test the application
        echo -e "${YELLOW}🧪 Testing application health...${NC}"
        
        if curl -s "http://localhost:5000/health" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Backend API is responding!${NC}"
        else
            echo -e "${YELLOW}⏳ Backend still starting up...${NC}"
        fi
        
        if curl -s "http://localhost:3000" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Frontend is serving content!${NC}"
        else
            echo -e "${YELLOW}⏳ Frontend still starting up...${NC}"
        fi
        
        echo ""
        echo -e "${GREEN}🎉 Demo application is running!${NC}"
        echo -e "${BLUE}💡 This is just the beginning - imagine this deployed to Kubernetes!${NC}"
        
    else
        echo -e "${RED}❌ Demo timed out. Don't worry - this happens sometimes!${NC}"
        echo -e "${BLUE}💡 The full setup process is more reliable with proper timing.${NC}"
    fi
    
    cd ..
    wait_for_user "Press ENTER to continue the demo..."
}

show_learning_paths() {
    show_banner
    echo -e "${PURPLE}🛤️  PERSONALIZED LEARNING PATHS${NC}"
    echo ""
    echo -e "${BLUE}Choose your adventure based on your goals:${NC}"
    echo ""
    echo -e "${GREEN}🎯 Path 1: CONTAINER MASTERY${NC}"
    echo "   Start with: E-commerce app"
    echo "   Focus: Docker, Docker Compose, basic orchestration"
    echo "   Duration: 2-3 weeks"
    echo "   Perfect for: Complete beginners"
    echo ""
    echo -e "${YELLOW}🎯 Path 2: KUBERNETES SPECIALIST${NC}"
    echo "   Start with: Task Management app"
    echo "   Focus: Advanced Kubernetes, service mesh, monitoring"
    echo "   Duration: 6-8 weeks"
    echo "   Perfect for: DevOps engineers"
    echo ""
    echo -e "${BLUE}🎯 Path 3: SECURITY EXPERT${NC}"
    echo "   Start with: Medical Care system"
    echo "   Focus: Security scanning, compliance, hardening"
    echo "   Duration: 8-10 weeks"
    echo "   Perfect for: Security professionals"
    echo ""
    echo -e "${RED}🎯 Path 4: PLATFORM ENGINEER${NC}"
    echo "   Start with: Social Media platform"
    echo "   Focus: Multi-cloud, chaos engineering, scalability"
    echo "   Duration: 12+ weeks"
    echo "   Perfect for: Senior engineers"
    
    wait_for_user
}

show_features() {
    show_banner
    echo -e "${PURPLE}🔥 ADVANCED FEATURES PREVIEW${NC}"
    echo ""
    echo -e "${BLUE}What you'll master on this platform:${NC}"
    echo ""
    echo "🐳 ${BOLD}Containerization${NC}"
    echo "   • Multi-stage Dockerfiles"
    echo "   • Container optimization"
    echo "   • Security scanning"
    echo ""
    echo "☸️  ${BOLD}Kubernetes Mastery${NC}"
    echo "   • Deployments, Services, Ingress"
    echo "   • ConfigMaps, Secrets, Volumes"
    echo "   • HPA, Network Policies, RBAC"
    echo ""
    echo "🔄 ${BOLD}CI/CD Pipelines${NC}"
    echo "   • GitHub Actions workflows"
    echo "   • Jenkins pipelines"
    echo "   • GitLab CI configurations"
    echo ""
    echo "📊 ${BOLD}Observability Stack${NC}"
    echo "   • Prometheus + Grafana"
    echo "   • Logging with ELK/Loki"
    echo "   • Distributed tracing"
    echo ""
    echo "☁️  ${BOLD}Cloud Deployment${NC}"
    echo "   • AWS EKS"
    echo "   • Azure AKS"
    echo "   • Google GKE"
    echo ""
    echo "💥 ${BOLD}Chaos Engineering${NC}"
    echo "   • Failure injection"
    echo "   • Resilience testing"
    echo "   • Disaster recovery"
    
    wait_for_user
}

show_next_steps() {
    show_banner
    echo -e "${PURPLE}🚀 READY TO START YOUR JOURNEY?${NC}"
    echo ""
    echo -e "${BLUE}Here's how to begin:${NC}"
    echo ""
    echo -e "${GREEN}1. 📋 Choose Your Path${NC}"
    echo "   • Review the applications in the main README"
    echo "   • Select based on your experience level"
    echo "   • Consider your learning goals"
    echo ""
    echo -e "${GREEN}2. 🔧 Environment Setup${NC}"
    echo "   • Run: ./scripts/setup/smart-system-optimizer.sh"
    echo "   • Or follow manual setup in docs/setup/"
    echo ""
    echo -e "${GREEN}3. 🎯 Start Learning${NC}"
    echo "   • Follow the application-specific guides"
    echo "   • Practice with real scenarios"
    echo "   • Progress through difficulty levels"
    echo ""
    echo -e "${GREEN}4. 🏆 Master Advanced Topics${NC}"
    echo "   • Implement monitoring and observability"
    echo "   • Practice chaos engineering"
    echo "   • Deploy to production environments"
    echo ""
    echo -e "${CYAN}💡 Pro Tips:${NC}"
    echo "   • Start with validation: ./scripts/validation/validate-setup.sh"
    echo "   • Join our community for support"
    echo "   • Practice regularly for best results"
    echo ""
    echo -e "${YELLOW}🎉 You're about to become a DevOps expert!${NC}"
}

# Main demo flow
main() {
    show_platform_overview
    show_applications
    show_difficulty_levels
    show_learning_paths
    demo_application
    show_features
    show_next_steps
    
    cleanup_demo
    
    echo ""
    echo -e "${GREEN}🎊 Demo complete! Welcome to your DevOps learning journey!${NC}"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo "   1. ./scripts/validation/validate-setup.sh"
    echo "   2. Choose an application from the README"
    echo "   3. Start with the GET-STARTED.md guide"
    echo ""
    echo -e "${PURPLE}Happy learning! 🚀${NC}"
}

main "$@"