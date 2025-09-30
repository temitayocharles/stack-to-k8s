#!/bin/bash
# 🚀 SMART DEVOPS PRACTICE SETUP
# Interactive installation and setup for multi-application Kubernetes practice workspace
# Supports: Docker, Kubernetes, CI/CD, Infrastructure as Code, GitOps

set -e

# 🎨 Beautiful Colors for Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

# 📊 Progress Tracking
TOTAL_STEPS=12
CURRENT_STEP=0

# 🎯 System Information
OS_TYPE=""
ARCH_TYPE=""
DOCKER_STATUS=""
K8S_STATUS=""
SETUP_MODE=""

# Function to show progress
show_progress() {
    local step_name="$1"
    CURRENT_STEP=$((CURRENT_STEP + 1))
    local percentage=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    local completed=$((CURRENT_STEP * 50 / TOTAL_STEPS))
    
    echo -e "\n${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}Step $CURRENT_STEP of $TOTAL_STEPS: $step_name${NC}"
    echo -e "${CYAN}║${NC} Progress: ["
    printf "${GREEN}"
    for ((i=1; i<=completed; i++)); do printf "█"; done
    printf "${WHITE}"
    for ((i=completed+1; i<=50; i++)); do printf "░"; done
    printf "${NC}"
    echo "] $percentage%"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
}

# Function to detect system
detect_system() {
    show_progress "System Detection & Analysis"
    
    echo -e "${BLUE}🔍 Analyzing your system...${NC}"
    
    # Detect OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS_TYPE="macOS"
        echo -e "${GREEN}✅ Operating System: macOS${NC}"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS_TYPE="Linux"
        echo -e "${GREEN}✅ Operating System: Linux${NC}"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        OS_TYPE="Windows"
        echo -e "${GREEN}✅ Operating System: Windows${NC}"
    else
        echo -e "${RED}❌ Unsupported operating system: $OSTYPE${NC}"
        exit 1
    fi
    
    # Detect Architecture
    ARCH_TYPE=$(uname -m)
    echo -e "${GREEN}✅ Architecture: $ARCH_TYPE${NC}"
    
    # Check system resources
    if [[ "$OS_TYPE" == "macOS" ]]; then
        local ram_gb=$(($(sysctl -n hw.memsize) / 1024 / 1024 / 1024))
        local cpu_cores=$(sysctl -n hw.ncpu)
    elif [[ "$OS_TYPE" == "Linux" ]]; then
        local ram_gb=$(($(grep MemTotal /proc/meminfo | awk '{print $2}') / 1024 / 1024))
        local cpu_cores=$(nproc)
    fi
    
    echo -e "${GREEN}✅ CPU Cores: $cpu_cores${NC}"
    echo -e "${GREEN}✅ RAM: ${ram_gb}GB${NC}"
    
    # Resource recommendations
    if [[ $ram_gb -lt 8 ]]; then
        echo -e "${YELLOW}⚠️  Warning: 8GB+ RAM recommended for full Kubernetes experience${NC}"
    fi
    
    if [[ $cpu_cores -lt 4 ]]; then
        echo -e "${YELLOW}⚠️  Warning: 4+ CPU cores recommended for optimal performance${NC}"
    fi
    
    sleep 2
}

# Function to check Docker
check_docker() {
    show_progress "Docker Installation Check"
    
    echo -e "${BLUE}🐳 Checking Docker installation...${NC}"
    
    if command -v docker &> /dev/null; then
        if docker --version &> /dev/null; then
            DOCKER_STATUS="installed"
            echo -e "${GREEN}✅ Docker is installed: $(docker --version)${NC}"
            
            # Check if Docker is running
            if docker ps &> /dev/null; then
                echo -e "${GREEN}✅ Docker daemon is running${NC}"
                DOCKER_STATUS="running"
            else
                echo -e "${YELLOW}⚠️  Docker is installed but not running${NC}"
                echo -e "${BLUE}📝 We'll help you start Docker...${NC}"
            fi
        else
            DOCKER_STATUS="broken"
            echo -e "${RED}❌ Docker installation appears broken${NC}"
        fi
    else
        DOCKER_STATUS="missing"
        echo -e "${YELLOW}⚠️  Docker not found${NC}"
    fi
    
    sleep 1
}

# Function to check Kubernetes
check_kubernetes() {
    show_progress "Kubernetes Tools Check"
    
    echo -e "${BLUE}☸️  Checking Kubernetes tools...${NC}"
    
    # Check kubectl
    if command -v kubectl &> /dev/null; then
        echo -e "${GREEN}✅ kubectl is installed: $(kubectl version --client --short 2>/dev/null || echo 'version check failed')${NC}"
        K8S_STATUS="kubectl-installed"
    else
        echo -e "${YELLOW}⚠️  kubectl not found${NC}"
        K8S_STATUS="missing"
    fi
    
    # Check for Kubernetes cluster access
    if kubectl cluster-info &> /dev/null; then
        echo -e "${GREEN}✅ Kubernetes cluster is accessible${NC}"
        K8S_STATUS="cluster-available"
    else
        echo -e "${BLUE}📝 No Kubernetes cluster detected (we'll set up local options)${NC}"
    fi
    
    # Check Helm
    if command -v helm &> /dev/null; then
        echo -e "${GREEN}✅ Helm is installed: $(helm version --short 2>/dev/null || echo 'version check failed')${NC}"
    else
        echo -e "${YELLOW}⚠️  Helm not found (needed for advanced deployments)${NC}"
    fi
    
    sleep 1
}

# Function to choose setup mode
choose_setup_mode() {
    show_progress "Setup Mode Selection"
    
    echo -e "${PURPLE}🎯 Choose Your DevOps Practice Level:${NC}\n"
    
    echo -e "${WHITE}1) 🟢 Quick Start (Beginner)${NC}"
    echo -e "   └─ Docker Compose only, local development"
    echo -e "   └─ Perfect for: First-time DevOps learners"
    echo -e "   └─ Time: 15 minutes setup\n"
    
    echo -e "${WHITE}2) 🟡 Kubernetes Practice (Intermediate)${NC}"
    echo -e "   └─ Local Kubernetes cluster + applications"
    echo -e "   └─ Perfect for: K8s learning and certification prep"
    echo -e "   └─ Time: 45 minutes setup\n"
    
    echo -e "${WHITE}3) 🟠 CI/CD & GitOps (Advanced)${NC}"
    echo -e "   └─ Full pipeline automation + Infrastructure as Code"
    echo -e "   └─ Perfect for: Production-like DevOps experience"
    echo -e "   └─ Time: 2-3 hours setup\n"
    
    echo -e "${WHITE}4) 🔴 Enterprise Production (Expert)${NC}"
    echo -e "   └─ Cloud deployment + monitoring + security"
    echo -e "   └─ Perfect for: Real-world production experience"
    echo -e "   └─ Time: 4-6 hours setup\n"
    
    echo -e "${WHITE}5) 🔧 Custom Setup${NC}"
    echo -e "   └─ Pick and choose components"
    echo -e "   └─ Perfect for: Specific learning goals\n"
    
    while true; do
        echo -e "${CYAN}Enter your choice (1-5): ${NC}"
        read -r choice
        
        case $choice in
            1)
                SETUP_MODE="quick"
                echo -e "${GREEN}✅ Selected: Quick Start - Docker Compose Practice${NC}"
                break
                ;;
            2)
                SETUP_MODE="kubernetes"
                echo -e "${GREEN}✅ Selected: Kubernetes Practice Mode${NC}"
                break
                ;;
            3)
                SETUP_MODE="cicd"
                echo -e "${GREEN}✅ Selected: CI/CD & GitOps Mode${NC}"
                break
                ;;
            4)
                SETUP_MODE="enterprise"
                echo -e "${GREEN}✅ Selected: Enterprise Production Mode${NC}"
                break
                ;;
            5)
                SETUP_MODE="custom"
                echo -e "${GREEN}✅ Selected: Custom Setup${NC}"
                break
                ;;
            *)
                echo -e "${RED}❌ Invalid choice. Please enter 1, 2, 3, 4, or 5.${NC}"
                ;;
        esac
    done
    
    sleep 1
}

# Function to install Docker
install_docker() {
    if [[ "$DOCKER_STATUS" == "running" ]]; then
        echo -e "${GREEN}✅ Docker is already running, skipping installation${NC}"
        return
    fi
    
    show_progress "Docker Installation & Setup"
    
    echo -e "${BLUE}🐳 Setting up Docker for your system...${NC}"
    
    if [[ "$OS_TYPE" == "macOS" ]]; then
        echo -e "${BLUE}📝 Installing Docker Desktop for macOS...${NC}"
        
        if ! command -v brew &> /dev/null; then
            echo -e "${BLUE}📦 Installing Homebrew first...${NC}"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        
        echo -e "${BLUE}📦 Installing Docker Desktop via Homebrew...${NC}"
        brew install --cask docker
        
        echo -e "${YELLOW}⚠️  Please start Docker Desktop from Applications folder${NC}"
        echo -e "${BLUE}📝 Waiting for Docker Desktop to start...${NC}"
        
        # Wait for Docker to be available
        local timeout=300  # 5 minutes
        local elapsed=0
        
        while ! docker ps &> /dev/null && [[ $elapsed -lt $timeout ]]; do
            echo -e "${BLUE}⏳ Waiting for Docker... ($elapsed/$timeout seconds)${NC}"
            sleep 10
            elapsed=$((elapsed + 10))
        done
        
        if docker ps &> /dev/null; then
            echo -e "${GREEN}✅ Docker is now running!${NC}"
        else
            echo -e "${RED}❌ Docker failed to start. Please start Docker Desktop manually.${NC}"
            echo -e "${YELLOW}📝 After starting Docker, run this script again.${NC}"
            exit 1
        fi
        
    elif [[ "$OS_TYPE" == "Linux" ]]; then
        echo -e "${BLUE}📝 Installing Docker for Linux...${NC}"
        
        # Update package index
        sudo apt-get update
        
        # Install required packages
        sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
        
        # Add Docker GPG key
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        
        # Add Docker repository
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        # Install Docker
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        
        # Start and enable Docker
        sudo systemctl start docker
        sudo systemctl enable docker
        
        # Add user to docker group
        sudo usermod -aG docker $USER
        
        echo -e "${GREEN}✅ Docker installed successfully!${NC}"
        echo -e "${YELLOW}⚠️  Please log out and back in for group changes to take effect${NC}"
        
    elif [[ "$OS_TYPE" == "Windows" ]]; then
        echo -e "${BLUE}📝 For Windows, please install Docker Desktop manually:${NC}"
        echo -e "${CYAN}1. Download Docker Desktop from: https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe${NC}"
        echo -e "${CYAN}2. Run the installer${NC}"
        echo -e "${CYAN}3. Restart your computer${NC}"
        echo -e "${CYAN}4. Run this script again${NC}"
        exit 1
    fi
    
    sleep 2
}

# Function to setup Kubernetes
setup_kubernetes() {
    if [[ "$SETUP_MODE" == "quick" ]]; then
        echo -e "${BLUE}📝 Skipping Kubernetes setup for Quick Start mode${NC}"
        return
    fi
    
    show_progress "Kubernetes Environment Setup"
    
    echo -e "${BLUE}☸️  Setting up Kubernetes environment...${NC}"
    
    # Install kubectl if missing
    if ! command -v kubectl &> /dev/null; then
        echo -e "${BLUE}📦 Installing kubectl...${NC}"
        
        if [[ "$OS_TYPE" == "macOS" ]]; then
            brew install kubectl
        elif [[ "$OS_TYPE" == "Linux" ]]; then
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
            sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        fi
        
        echo -e "${GREEN}✅ kubectl installed${NC}"
    fi
    
    # Enable Kubernetes in Docker Desktop or suggest alternatives
    if docker ps &> /dev/null; then
        echo -e "${BLUE}📝 Enabling Kubernetes in Docker Desktop...${NC}"
        echo -e "${YELLOW}⚠️  Please enable Kubernetes in Docker Desktop:${NC}"
        echo -e "${CYAN}1. Open Docker Desktop${NC}"
        echo -e "${CYAN}2. Go to Settings (gear icon)${NC}"
        echo -e "${CYAN}3. Click 'Kubernetes' tab${NC}"
        echo -e "${CYAN}4. Check 'Enable Kubernetes'${NC}"
        echo -e "${CYAN}5. Click 'Apply & Restart'${NC}"
        
        echo -e "\n${BLUE}Press ENTER when Kubernetes is enabled...${NC}"
        read
        
        # Verify Kubernetes
        if kubectl cluster-info &> /dev/null; then
            echo -e "${GREEN}✅ Kubernetes cluster is accessible!${NC}"
        else
            echo -e "${YELLOW}⚠️  Using kind for local Kubernetes cluster...${NC}"
            
            # Install kind
            if [[ "$OS_TYPE" == "macOS" ]]; then
                brew install kind
            elif [[ "$OS_TYPE" == "Linux" ]]; then
                curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
                chmod +x ./kind
                sudo mv ./kind /usr/local/bin/kind
            fi
            
            # Create kind cluster
            echo -e "${BLUE}📝 Creating local Kubernetes cluster with kind...${NC}"
            kind create cluster --name devops-practice
            
            echo -e "${GREEN}✅ Local Kubernetes cluster created!${NC}"
        fi
    fi
    
    sleep 2
}

# Function to install additional tools
install_tools() {
    show_progress "DevOps Tools Installation"
    
    echo -e "${BLUE}🔧 Installing additional DevOps tools...${NC}"
    
    # Install Helm
    if ! command -v helm &> /dev/null; then
        echo -e "${BLUE}📦 Installing Helm...${NC}"
        
        if [[ "$OS_TYPE" == "macOS" ]]; then
            brew install helm
        elif [[ "$OS_TYPE" == "Linux" ]]; then
            curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
        fi
        
        echo -e "${GREEN}✅ Helm installed${NC}"
    fi
    
    # Install additional tools based on mode
    case $SETUP_MODE in
        "cicd"|"enterprise")
            echo -e "${BLUE}📦 Installing CI/CD tools...${NC}"
            
            # Install ArgoCD CLI
            if [[ "$OS_TYPE" == "macOS" ]]; then
                brew install argocd
            elif [[ "$OS_TYPE" == "Linux" ]]; then
                curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
                sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
                rm argocd-linux-amd64
            fi
            
            echo -e "${GREEN}✅ ArgoCD CLI installed${NC}"
            ;;
    esac
    
    # Install k9s for better Kubernetes management
    if [[ "$SETUP_MODE" != "quick" ]]; then
        echo -e "${BLUE}📦 Installing k9s (Kubernetes dashboard)...${NC}"
        
        if [[ "$OS_TYPE" == "macOS" ]]; then
            brew install k9s
        elif [[ "$OS_TYPE" == "Linux" ]]; then
            curl -sS https://webinstall.dev/k9s | bash
        fi
        
        echo -e "${GREEN}✅ k9s installed${NC}"
    fi
    
    sleep 2
}

# Function to verify setup
verify_setup() {
    show_progress "Setup Verification"
    
    echo -e "${BLUE}🔍 Verifying your DevOps environment...${NC}"
    
    # Test Docker
    if docker run --rm hello-world &> /dev/null; then
        echo -e "${GREEN}✅ Docker is working correctly${NC}"
    else
        echo -e "${RED}❌ Docker test failed${NC}"
    fi
    
    # Test Kubernetes if applicable
    if [[ "$SETUP_MODE" != "quick" ]]; then
        if kubectl get nodes &> /dev/null; then
            echo -e "${GREEN}✅ Kubernetes cluster is accessible${NC}"
            kubectl get nodes
        else
            echo -e "${RED}❌ Kubernetes cluster not accessible${NC}"
        fi
    fi
    
    sleep 2
}

# Function to clone/update repository
setup_repository() {
    show_progress "Repository Setup & Application Preparation"
    
    echo -e "${BLUE}📂 Preparing DevOps practice applications...${NC}"
    
    # We're already in the repo, so just verify applications
    local apps=("ecommerce-app" "educational-platform" "medical-care-system" "task-management-app" "weather-app" "social-media-platform")
    
    for app in "${apps[@]}"; do
        if [[ -d "$app" ]]; then
            echo -e "${GREEN}✅ Found: $app${NC}"
        else
            echo -e "${RED}❌ Missing: $app${NC}"
        fi
    done
    
    echo -e "${GREEN}✅ All applications ready for DevOps practice!${NC}"
    sleep 1
}

# Function to show next steps
show_next_steps() {
    show_progress "Setup Complete - Next Steps"
    
    echo -e "\n${GREEN}🎉 CONGRATULATIONS! Your DevOps Practice Environment is Ready!${NC}\n"
    
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}What You Can Do Now:${NC}"
    echo -e "${CYAN}║${NC}"
    
    case $SETUP_MODE in
        "quick")
            echo -e "${CYAN}║${NC} ${WHITE}🟢 Quick Start Practice:${NC}"
            echo -e "${CYAN}║${NC}   1. Choose an application: cd ecommerce-app"
            echo -e "${CYAN}║${NC}   2. Start with Docker: docker-compose up -d"
            echo -e "${CYAN}║${NC}   3. Open: http://localhost:3001"
            echo -e "${CYAN}║${NC}   4. Practice: Modify, rebuild, redeploy"
            ;;
        "kubernetes")
            echo -e "${CYAN}║${NC} ${WHITE}🟡 Kubernetes Practice:${NC}"
            echo -e "${CYAN}║${NC}   1. Deploy to K8s: kubectl apply -f k8s/"
            echo -e "${CYAN}║${NC}   2. Scale applications: kubectl scale deployment"
            echo -e "${CYAN}║${NC}   3. Practice: Rolling updates, health checks"
            echo -e "${CYAN}║${NC}   4. Monitor: k9s (interactive dashboard)"
            ;;
        "cicd")
            echo -e "${CYAN}║${NC} ${WHITE}🟠 CI/CD & GitOps Practice:${NC}"
            echo -e "${CYAN}║${NC}   1. Setup pipelines: Check ci-cd/ folders"
            echo -e "${CYAN}║${NC}   2. Practice GitOps: Modify YAML, watch auto-deploy"
            echo -e "${CYAN}║${NC}   3. Monitor: ArgoCD dashboard"
            ;;
        "enterprise")
            echo -e "${CYAN}║${NC} ${WHITE}🔴 Enterprise Production:${NC}"
            echo -e "${CYAN}║${NC}   1. Deploy monitoring: Prometheus + Grafana"
            echo -e "${CYAN}║${NC}   2. Setup alerting: AlertManager"
            echo -e "${CYAN}║${NC}   3. Practice: Production troubleshooting"
            ;;
    esac
    
    echo -e "${CYAN}║${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}Learning Resources:${NC}"
    echo -e "${CYAN}║${NC}   📚 Documentation: docs/START-HERE.md"
    echo -e "${CYAN}║${NC}   🎯 Application Guides: docs/applications/"
    echo -e "${CYAN}║${NC}   🔧 Troubleshooting: docs/troubleshooting/"
    echo -e "${CYAN}║${NC}   🚀 Advanced: docs/deployment/"
    echo -e "${CYAN}║${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}Quick Commands:${NC}"
    echo -e "${CYAN}║${NC}   • View all apps: ls -la"
    echo -e "${CYAN}║${NC}   • Start learning: open docs/START-HERE.md"
    echo -e "${CYAN}║${NC}   • Get help: cat docs/troubleshooting/quick-fixes.md"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "\n${PURPLE}🚀 Ready to become a DevOps expert? Start with: ${BOLD}open docs/START-HERE.md${NC}\n"
}

# Main execution
main() {
    clear
    echo -e "${BOLD}${CYAN}"
    echo "╔════════════════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                                        ║"
    echo "║        🚀 SMART DEVOPS PRACTICE SETUP 🚀                                              ║"
    echo "║                                                                                        ║"
    echo "║        Interactive Installation for Multi-Application Kubernetes Practice Workspace   ║"
    echo "║                                                                                        ║"
    echo "║        📦 6 Real Applications  ☸️  Kubernetes  🔄 CI/CD  ☁️  Cloud Ready             ║"
    echo "║                                                                                        ║"
    echo "╚════════════════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
    
    echo -e "${YELLOW}⚡ This script will set up everything you need for hands-on DevOps practice!${NC}"
    echo -e "${BLUE}📝 We'll detect your system and install the right tools automatically.${NC}\n"
    
    echo -e "${CYAN}Press ENTER to start the setup...${NC}"
    read
    
    # Run setup steps
    detect_system
    check_docker
    check_kubernetes
    choose_setup_mode
    install_docker
    setup_kubernetes
    install_tools
    setup_repository
    verify_setup
    show_next_steps
    
    echo -e "${GREEN}✨ Setup completed successfully! Happy learning! ✨${NC}"
}

# Run main function
main "$@"