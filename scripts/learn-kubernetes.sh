#!/bin/bash
# 🚀 KUBERNETES LEARNING PLATFORM - MAIN LAUNCHER
# The ultimate entry point for the best Kubernetes learning experience

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
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

show_platform_banner() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}🚀 KUBERNETES LEARNING PLATFORM - THE ULTIMATE EXPERIENCE${NC}"
    echo -e "${CYAN}║${NC}"
    echo -e "${CYAN}║${NC} ${BLUE}🎯 6 Production Applications • 4 Progressive Difficulty Levels • Complete GitOps${NC}"
    echo -e "${CYAN}║${NC} ${GREEN}📊 Comprehensive Monitoring • 🔐 Enterprise Security • ⏰ Time Tracking${NC}"
    echo -e "${CYAN}║${NC} ${PURPLE}📚 Interactive Learning • 🏆 Achievement System • 🎓 Skill Progression${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}💡 Better than the most rated Kubernetes tutorials out there!${NC}"
    echo ""
}

check_platform_readiness() {
    echo -e "${BLUE}🔍 Checking platform readiness...${NC}"
    
    local ready=true
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker not found${NC}"
        ready=false
    else
        echo -e "${GREEN}✅ Docker available${NC}"
    fi
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        echo -e "${YELLOW}⚠️  kubectl not found (recommended for advanced features)${NC}"
    else
        echo -e "${GREEN}✅ kubectl available${NC}"
    fi
    
    # Check core scripts
    local core_scripts=(
        "scripts/validation/validate-setup.sh"
        "scripts/secrets/progressive-secrets-manager.sh"
        "scripts/observability/deploy-monitoring.sh"
        "scripts/learning/learning-dashboard.sh"
        "scripts/learning/time-tracker.sh"
    )
    
    for script in "${core_scripts[@]}"; do
        if [[ -x "$WORKSPACE_ROOT/$script" ]]; then
            echo -e "${GREEN}✅ $(basename "$script") ready${NC}"
        else
            echo -e "${RED}❌ $(basename "$script") not found or not executable${NC}"
            ready=false
        fi
    done
    
    if [[ "$ready" == true ]]; then
        echo -e "${GREEN}🎉 Platform is ready for use!${NC}"
        return 0
    else
        echo -e "${RED}⚠️  Some components need attention${NC}"
        return 1
    fi
}

show_quick_start_guide() {
    echo -e "${CYAN}🚀 QUICK START GUIDE${NC}"
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo ""
    echo -e "${GREEN}📋 For Complete Beginners:${NC}"
    echo "   1. Start with Environment Validation"
    echo "   2. Set up your first application (E-commerce)"
    echo "   3. Learn progressive secrets management"
    echo "   4. Deploy monitoring stack"
    echo "   5. Track your learning progress"
    echo ""
    echo -e "${YELLOW}📈 For Intermediate Users:${NC}"
    echo "   1. Choose your difficulty level"
    echo "   2. Deploy multiple applications"
    echo "   3. Implement advanced Kubernetes features"
    echo "   4. Set up CI/CD pipelines"
    echo "   5. Monitor and optimize performance"
    echo ""
    echo -e "${RED}⚡ For Advanced Users:${NC}"
    echo "   1. Deploy complete monitoring stack"
    echo "   2. Implement security hardening"
    echo "   3. Set up multi-application orchestration"
    echo "   4. Practice disaster recovery scenarios"
    echo "   5. Contribute to platform improvements"
    echo ""
}

show_application_status() {
    echo -e "${BLUE}📱 APPLICATION STATUS OVERVIEW${NC}"
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo ""
    
    local applications=(
        "ecommerce-app:E-commerce Platform:Node.js + React + MongoDB:✅ COMPLETED"
        "educational-platform:Educational System:Java Spring + Angular + PostgreSQL:🔄 IN PROGRESS"
        "medical-care-system:Medical Care System:.NET Core + Blazor + SQL Server:⏳ READY"
        "task-management-app:Task Management:Go + Svelte + CouchDB:⏳ READY"
        "weather-app:Weather Application:Python Flask + Vue.js + Redis:⏳ READY"
        "social-media-platform:Social Media Platform:Ruby on Rails + React Native Web:⏳ READY"
    )
    
    for app_info in "${applications[@]}"; do
        IFS=':' read -r app_dir app_name tech_stack status <<< "$app_info"
        
        echo -e "${CYAN}📂 $app_name${NC}"
        echo "   🛠️  Tech Stack: $tech_stack"
        echo "   📊 Status: $status"
        
        # Check if directory exists and has content
        if [[ -d "$WORKSPACE_ROOT/$app_dir" ]]; then
            local files_count=$(find "$WORKSPACE_ROOT/$app_dir" -type f | wc -l)
            echo "   📁 Files: $files_count"
            
            # Check for key components
            local components=""
            [[ -f "$WORKSPACE_ROOT/$app_dir/docker-compose.yml" ]] && components+="🐳 Docker "
            [[ -d "$WORKSPACE_ROOT/$app_dir/k8s" ]] && components+="☸️ K8s "
            [[ -f "$WORKSPACE_ROOT/$app_dir/SECRETS-SETUP.md" ]] && components+="🔐 Secrets "
            [[ -d "$WORKSPACE_ROOT/$app_dir/docs" ]] && components+="📚 Docs "
            
            echo "   🎯 Components: $components"
        else
            echo "   ❌ Directory not found"
        fi
        echo ""
    done
}

show_learning_features() {
    echo -e "${PURPLE}🎓 LEARNING FEATURES OVERVIEW${NC}"
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo ""
    
    echo -e "${GREEN}📊 Progressive Difficulty System:${NC}"
    echo "   🟢 Beginner - Maximum guidance with screenshots"
    echo "   🟡 Intermediate - Guided learning with references"
    echo "   🔴 Advanced - Minimal guidance, self-directed"
    echo "   🟣 Expert - Innovation and optimization focus"
    echo ""
    
    echo -e "${BLUE}🔐 Intelligent Secrets Management:${NC}"
    echo "   • Interactive lab environments for each difficulty"
    echo "   • Progressive guidance reduction as skills develop"
    echo "   • Real-world credential acquisition workflows"
    echo "   • Comprehensive validation and testing"
    echo ""
    
    echo -e "${CYAN}📈 Learning Analytics:${NC}"
    echo "   • Time investment tracking per application"
    echo "   • Skill development progress monitoring"
    echo "   • Achievement unlock system"
    echo "   • Learning efficiency recommendations"
    echo ""
    
    echo -e "${YELLOW}🏆 Achievement System:${NC}"
    echo "   • 11 different achievements to unlock"
    echo "   • Progress-based unlock conditions"
    echo "   • Learning streak tracking"
    echo "   • Mastery level progression"
    echo ""
}

show_monitoring_capabilities() {
    echo -e "${GREEN}📊 MONITORING & OBSERVABILITY${NC}"
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo ""
    
    echo -e "${CYAN}🔍 Comprehensive Monitoring Stack:${NC}"
    echo "   • Prometheus metrics collection"
    echo "   • Grafana dashboards with visualizations"
    echo "   • AlertManager with email/webhook notifications"
    echo "   • Node Exporter for infrastructure monitoring"
    echo "   • Blackbox Exporter for URL health checks"
    echo ""
    
    echo -e "${BLUE}📊 Application Monitoring:${NC}"
    echo "   • Health check endpoints for all applications"
    echo "   • Custom metrics for business logic"
    echo "   • Performance tracking and optimization"
    echo "   • Error rate and response time monitoring"
    echo ""
    
    echo -e "${PURPLE}🚨 Alerting System:${NC}"
    echo "   • 25+ pre-configured alerting rules"
    echo "   • Critical, warning, and info level alerts"
    echo "   • Infrastructure and application alerts"
    echo "   • Security event monitoring"
    echo ""
    
    echo -e "${GREEN}✅ Production Ready Features:${NC}"
    echo "   • Network policies for security"
    echo "   • Ingress configuration for external access"
    echo "   • NodePort services for local development"
    echo "   • Comprehensive validation system"
    echo ""
}

launch_validation_system() {
    echo -e "${BLUE}🔍 Launching Environment Validation...${NC}"
    sleep 1
    exec "$WORKSPACE_ROOT/scripts/validation/validate-setup.sh"
}

launch_secrets_management() {
    echo -e "${BLUE}🔐 Launching Progressive Secrets Management...${NC}"
    sleep 1
    exec "$WORKSPACE_ROOT/scripts/secrets/progressive-secrets-manager.sh"
}

launch_monitoring_deployment() {
    echo -e "${BLUE}📊 Launching Monitoring Deployment...${NC}"
    sleep 1
    exec "$WORKSPACE_ROOT/scripts/observability/deploy-monitoring.sh"
}

launch_learning_dashboard() {
    echo -e "${BLUE}🎓 Launching Learning Dashboard...${NC}"
    sleep 1
    exec "$WORKSPACE_ROOT/scripts/learning/learning-dashboard.sh"
}

launch_time_tracker() {
    echo -e "${BLUE}⏰ Launching Time Tracker...${NC}"
    sleep 1
    exec "$WORKSPACE_ROOT/scripts/learning/time-tracker.sh"
}

show_application_launcher() {
    echo -e "${CYAN}🚀 APPLICATION LAUNCHER${NC}"
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo ""
    
    echo "Select an application to work with:"
    echo ""
    echo "1. 🛒 E-commerce Platform (Node.js + React)"
    echo "2. 🎓 Educational System (Java Spring + Angular)"
    echo "3. 🏥 Medical Care System (.NET Core + Blazor)"
    echo "4. 📋 Task Management App (Go + Svelte)"
    echo "5. 🌤️  Weather Application (Python Flask + Vue.js)"
    echo "6. 📱 Social Media Platform (Ruby on Rails + React Native)"
    echo ""
    echo -n "Choose application (1-6): "
    read -r app_choice
    
    case "$app_choice" in
        1)
            echo -e "${GREEN}🛒 Launching E-commerce Platform...${NC}"
            cd "$WORKSPACE_ROOT/ecommerce-app"
            echo "Current directory: $(pwd)"
            echo "Available commands:"
            echo "  • docker-compose up -d    # Start all services"
            echo "  • ./scripts/deploy.sh     # Deploy to Kubernetes"
            echo "  • cat README.md           # View documentation"
            exec bash
            ;;
        2)
            echo -e "${GREEN}🎓 Launching Educational Platform...${NC}"
            cd "$WORKSPACE_ROOT/educational-platform"
            echo "Current directory: $(pwd)"
            echo "Available commands:"
            echo "  • docker-compose up -d    # Start all services"
            echo "  • ./scripts/deploy.sh     # Deploy to Kubernetes"
            echo "  • cat README.md           # View documentation"
            exec bash
            ;;
        3)
            echo -e "${GREEN}🏥 Launching Medical Care System...${NC}"
            cd "$WORKSPACE_ROOT/medical-care-system"
            echo "Current directory: $(pwd)"
            echo "Available commands:"
            echo "  • docker-compose up -d    # Start all services"
            echo "  • cat README.md           # View documentation"
            exec bash
            ;;
        4)
            echo -e "${GREEN}📋 Launching Task Management App...${NC}"
            cd "$WORKSPACE_ROOT/task-management-app"
            echo "Current directory: $(pwd)"
            echo "Available commands:"
            echo "  • docker-compose up -d    # Start all services"
            echo "  • cat README.md           # View documentation"
            exec bash
            ;;
        5)
            echo -e "${GREEN}🌤️  Launching Weather Application...${NC}"
            cd "$WORKSPACE_ROOT/weather-app"
            echo "Current directory: $(pwd)"
            echo "Available commands:"
            echo "  • docker-compose up -d    # Start all services"
            echo "  • cat README.md           # View documentation"
            exec bash
            ;;
        6)
            echo -e "${GREEN}📱 Launching Social Media Platform...${NC}"
            cd "$WORKSPACE_ROOT/social-media-platform"
            echo "Current directory: $(pwd)"
            echo "Available commands:"
            echo "  • docker-compose up -d    # Start all services"
            echo "  • cat README.md           # View documentation"
            exec bash
            ;;
        *)
            echo "Invalid choice. Returning to main menu."
            ;;
    esac
}

show_advanced_features() {
    echo -e "${RED}⚡ ADVANCED FEATURES${NC}"
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo ""
    
    echo "1. 🔧 Deploy Comprehensive Monitoring Stack"
    echo "2. 🛡️  Security Hardening & Network Policies"
    echo "3. 📊 Performance Testing & Load Analysis"
    echo "4. 🔄 CI/CD Pipeline Setup (GitHub/Jenkins/GitLab)"
    echo "5. 🏗️  Infrastructure as Code (Terraform)"
    echo "6. 🌐 Multi-Cluster Management"
    echo "7. 🔍 Chaos Engineering & Disaster Recovery"
    echo "8. 📈 Custom Metrics & Dashboards"
    echo ""
    echo -n "Choose advanced feature (1-8): "
    read -r feature_choice
    
    case "$feature_choice" in
        1)
            launch_monitoring_deployment
            ;;
        2)
            echo -e "${BLUE}🛡️  Security hardening features coming soon...${NC}"
            echo "For now, check the k8s/advanced-features/security/ folders in each application"
            ;;
        3)
            echo -e "${BLUE}📊 Performance testing features coming soon...${NC}"
            echo "For now, use the load-test.js files in each application"
            ;;
        4)
            echo -e "${BLUE}🔄 CI/CD setup guides available in ci-cd/ folders${NC}"
            echo "Choose between GitHub Actions, Jenkins, or GitLab CI"
            ;;
        5)
            echo -e "${BLUE}🏗️  Terraform configurations available in terraform/ folders${NC}"
            echo "Deploy infrastructure with: terraform apply"
            ;;
        6)
            echo -e "${BLUE}🌐 Multi-cluster features coming soon...${NC}"
            ;;
        7)
            echo -e "${BLUE}🔍 Chaos engineering features coming soon...${NC}"
            ;;
        8)
            echo -e "${BLUE}📈 Check the monitoring/ folders for custom dashboards${NC}"
            ;;
        *)
            echo "Invalid choice. Returning to main menu."
            ;;
    esac
}

show_help_and_documentation() {
    echo -e "${CYAN}📚 HELP & DOCUMENTATION${NC}"
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo ""
    
    echo -e "${GREEN}📖 Getting Started:${NC}"
    echo "   • docs/getting-started/README.md - Complete beginner guide"
    echo "   • docs/START-HERE.md - Quick platform overview"
    echo "   • docs/SETUP-OPTIONS.md - Different setup approaches"
    echo ""
    
    echo -e "${BLUE}📱 Application Guides:${NC}"
    echo "   • Each app has complete README.md and SECRETS-SETUP.md"
    echo "   • Progressive difficulty documentation"
    echo "   • Step-by-step deployment guides"
    echo ""
    
    echo -e "${PURPLE}🛠️  Technical Documentation:${NC}"
    echo "   • docs/kubernetes/ - Kubernetes learning materials"
    echo "   • docs/containers/ - Container best practices"
    echo "   • docs/deployment/ - Deployment strategies"
    echo ""
    
    echo -e "${YELLOW}🎯 Learning Resources:${NC}"
    echo "   • docs/learning/ - Progressive learning paths"
    echo "   • Achievement system and skill tracking"
    echo "   • Time investment optimization"
    echo ""
    
    echo -e "${CYAN}🆘 Troubleshooting:${NC}"
    echo "   • docs/troubleshooting/ - Common issues and solutions"
    echo "   • Application-specific troubleshooting guides"
    echo "   • Community support resources"
    echo ""
    
    echo -n "Press Enter to continue..."
    read -r
}

show_main_menu() {
    echo -e "${CYAN}🎯 KUBERNETES LEARNING PLATFORM - MAIN MENU${NC}"
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo ""
    
    echo -e "${GREEN}🚀 QUICK START${NC}"
    echo "   1. 🔍 Environment Validation & Setup"
    echo "   2. 🔐 Progressive Secrets Management"
    echo "   3. 📱 Application Launcher"
    echo ""
    
    echo -e "${BLUE}📊 LEARNING & TRACKING${NC}"
    echo "   4. 🎓 Learning Dashboard & Progress"
    echo "   5. ⏰ Time Investment Tracker"
    echo "   6. 📈 Application Status Overview"
    echo ""
    
    echo -e "${PURPLE}⚡ ADVANCED FEATURES${NC}"
    echo "   7. 📊 Deploy Monitoring Stack"
    echo "   8. 🛡️  Advanced Kubernetes Features"
    echo "   9. 🔧 Platform Management Tools"
    echo ""
    
    echo -e "${CYAN}📚 HELP & GUIDES${NC}"
    echo "   10. 🎯 Quick Start Guide"
    echo "   11. 📖 Learning Features Overview"
    echo "   12. 📚 Help & Documentation"
    echo ""
    
    echo "   0. 🚪 Exit Platform"
    echo ""
    echo -n "Choose an option (0-12): "
}

show_platform_stats() {
    local total_files=$(find "$WORKSPACE_ROOT" -type f | wc -l)
    local total_dirs=$(find "$WORKSPACE_ROOT" -type d | wc -l)
    local workspace_size=$(du -sh "$WORKSPACE_ROOT" 2>/dev/null | awk '{print $1}' || echo "Unknown")
    
    echo -e "${BLUE}📊 Platform Statistics:${NC}"
    echo "   📁 Total Files: $total_files"
    echo "   📂 Total Directories: $total_dirs"
    echo "   💾 Workspace Size: $workspace_size"
    echo "   🚀 Applications: 6"
    echo "   📚 Difficulty Levels: 4"
    echo "   🎯 Learning Features: 15+"
    echo ""
}

main() {
    # Handle direct commands
    case "${1:-}" in
        "validate")
            launch_validation_system
            ;;
        "secrets")
            launch_secrets_management
            ;;
        "monitoring" | "monitor")
            launch_monitoring_deployment
            ;;
        "dashboard" | "learn")
            launch_learning_dashboard
            ;;
        "time" | "timer")
            shift
            exec "$WORKSPACE_ROOT/scripts/learning/time-tracker.sh" "$@"
            ;;
        "apps" | "applications")
            show_application_launcher
            exit 0
            ;;
        "help" | "--help" | "-h")
            show_help_and_documentation
            exit 0
            ;;
        "status")
            show_platform_banner
            show_platform_stats
            show_application_status
            exit 0
            ;;
    esac
    
    # Interactive main menu
    while true; do
        show_platform_banner
        
        # Quick platform check
        if ! check_platform_readiness; then
            echo ""
            echo -e "${YELLOW}💡 Recommendation: Start with Environment Validation (option 1)${NC}"
        fi
        
        echo ""
        show_platform_stats
        show_main_menu
        read -r choice
        
        case "$choice" in
            1)
                clear
                launch_validation_system
                ;;
            2)
                clear
                launch_secrets_management
                ;;
            3)
                clear
                show_platform_banner
                show_application_launcher
                echo ""
                echo -n "Press Enter to continue..."
                read -r
                ;;
            4)
                clear
                launch_learning_dashboard
                ;;
            5)
                clear
                launch_time_tracker
                ;;
            6)
                clear
                show_platform_banner
                show_application_status
                echo ""
                echo -n "Press Enter to continue..."
                read -r
                ;;
            7)
                clear
                launch_monitoring_deployment
                ;;
            8)
                clear
                show_platform_banner
                show_advanced_features
                echo ""
                echo -n "Press Enter to continue..."
                read -r
                ;;
            9)
                clear
                show_platform_banner
                echo -e "${BLUE}🔧 Platform Management Tools${NC}"
                echo "════════════════════════════════════════════════════════════════════════════════"
                echo ""
                echo "1. 🧹 Cleanup workspace and containers"
                echo "2. 🔄 Refresh all applications"
                echo "3. 📦 Export learning progress"
                echo "4. 🔧 Update platform components"
                echo ""
                echo "For now, use individual scripts in the scripts/ directory"
                echo ""
                echo -n "Press Enter to continue..."
                read -r
                ;;
            10)
                clear
                show_platform_banner
                show_quick_start_guide
                echo ""
                echo -n "Press Enter to continue..."
                read -r
                ;;
            11)
                clear
                show_platform_banner
                show_learning_features
                echo ""
                show_monitoring_capabilities
                echo ""
                echo -n "Press Enter to continue..."
                read -r
                ;;
            12)
                clear
                show_platform_banner
                show_help_and_documentation
                ;;
            0)
                echo -e "${GREEN}🎉 Happy learning! Master Kubernetes step by step! 🚀${NC}"
                echo -e "${BLUE}💡 Remember: Consistent practice leads to mastery!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice. Please try again.${NC}"
                sleep 1
                ;;
        esac
    done
}

main "$@"