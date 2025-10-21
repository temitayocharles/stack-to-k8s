#!/usr/bin/env bash
# Enhanced lab prerequisites checker with comprehensive validation and interactive remediation
# Supports Windows (Git Bash, WSL, PowerShell), macOS, and Linux environments
set -euo pipefail

# Ensure we have a compatible bash version (4.0+)
if [[ "${BASH_VERSINFO[0]:-0}" -lt 4 ]]; then
    echo "Error: This script requires Bash 4.0 or later. Current version: ${BASH_VERSION:-unknown}" >&2
    echo "On macOS, consider installing via: brew install bash" >&2
    exit 1
fi

# =============================================================================
# CONFIGURATION & GLOBALS
# =============================================================================
readonly SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Terminal colors (with Windows compatibility)
if [[ "${TERM:-}" != "dumb" ]] && [[ -t 1 ]]; then
    readonly GREEN="\033[0;32m"
    readonly RED="\033[0;31m"
    readonly YELLOW="\033[1;33m"
    readonly BLUE="\033[0;34m"
    readonly CYAN="\033[0;36m"
    readonly BOLD="\033[1m"
    readonly NC="\033[0m"
else
    # Disable colors for non-interactive terminals or Windows CMD
    readonly GREEN=""
    readonly RED=""
    readonly YELLOW=""
    readonly BLUE=""
    readonly CYAN=""
    readonly BOLD=""
    readonly NC=""
fi

# Exit codes
readonly EXIT_SUCCESS=0
readonly EXIT_INVALID_ARGS=1
readonly EXIT_MISSING_DEPS=2
readonly EXIT_MISSING_FILES=3

# Interactivity (default true). Use --non-interactive to disable prompts.
INTERACTIVE=true

# Lab configuration (supports up to Lab 13 + decimal labs)
declare -A LAB_TITLES=(
    ["0"]="Lab 0 · Visual Kubernetes Setup"
    ["0.5"]="Lab 0.5 · Docker Compose to Kubernetes"
    ["1"]="Lab 1 · Weather App Basics"
    ["2"]="Lab 2 · E-commerce Multi-Service"
    ["3"]="Lab 3 · Educational Stateful"
    ["3.5"]="Lab 3.5 · Kubernetes Under the Hood"
    ["4"]="Lab 4 · Kubernetes Fundamentals Deep Dive"
    ["5"]="Lab 5 · Task Manager Ingress"
    ["6"]="Lab 6 · Medical System Security"
    ["7"]="Lab 7 · Social Media Autoscaling"
    ["8"]="Lab 8 · Multi-App Orchestration"
    ["8.5"]="Lab 8.5 · Multi-Tenancy"
    ["9"]="Lab 9 · Chaos Engineering"
    ["9.5"]="Lab 9.5 · Complex Microservices"
    ["10"]="Lab 10 · Helm Package Management"
    ["11"]="Lab 11 · GitOps with ArgoCD"
    ["11.5"]="Lab 11.5 · Disaster Recovery"
    ["12"]="Lab 12 · External Secrets Management"
    ["13"]="Lab 13 · AI/ML GPU Workloads"
)

# Counters
declare -i CHECKS_PASSED=0
declare -i CHECKS_FAILED=0
declare -i CHECKS_WARNED=0

# =============================================================================
# CLEANUP & ERROR HANDLING
# =============================================================================
cleanup() {
    local exit_code=$?
    if [[ ${exit_code} -ne 0 ]]; then
        echo -e "\n${RED}❌ Prerequisites check interrupted with exit code ${exit_code}${NC}" >&2
    fi
}

trap cleanup EXIT

# =============================================================================
# LOGGING FUNCTIONS
# =============================================================================
log_header() {
    echo -e "\n${BLUE}${BOLD}═══════════════════════════════════════════════${NC}"
    echo -e "${BLUE}${BOLD}  $*${NC}"
    echo -e "${BLUE}${BOLD}═══════════════════════════════════════════════${NC}\n"
}

log_subheader() {
    echo -e "\n${CYAN}${BOLD}▶ $*${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $*${NC}"
    ((CHECKS_PASSED++))
}

log_error() {
    echo -e "${RED}❌ $*${NC}"
    ((CHECKS_FAILED++))
}

log_warn() {
    echo -e "${YELLOW}⚠️  $*${NC}"
    ((CHECKS_WARNED++))
}

log_info() {
    echo -e "${BLUE}ℹ️  $*${NC}"
}

# =============================================================================
# INPUT VALIDATION
# =============================================================================
show_usage() {
    cat <<USAGE
${BOLD}Usage:${NC} ${SCRIPT_NAME} [OPTIONS] <lab-number>

${BOLD}DESCRIPTION:${NC}
    Verify that your local environment has the tools, manifests, and configuration
    needed before you begin a lab. Supports decimal lab numbers (e.g., 3.5, 8.5).

${BOLD}OPTIONS:${NC}
    -h, --help           Show this help message and exit
    -l, --list           List all available labs
    -v, --verbose        Enable verbose output
    --all               Check prerequisites for all labs
    --non-interactive   Disable interactive prompts (fail fast)

${BOLD}ARGUMENTS:${NC}
    lab-number      Lab number to check (e.g., 1, 3.5, 8, 11.5, 13)

${BOLD}EXAMPLES:${NC}
    ${SCRIPT_NAME} 1              # Check Lab 1 prerequisites
    ${SCRIPT_NAME} 3.5            # Check Lab 3.5 prerequisites  
    ${SCRIPT_NAME} 8              # Check Lab 8 prerequisites
    ${SCRIPT_NAME} --list         # Show all available labs
    ${SCRIPT_NAME} --all          # Check all labs

${BOLD}EXIT CODES:${NC}
    0  All prerequisites satisfied
    1  Invalid arguments or usage
    2  Missing required dependencies
    3  Missing required files or paths

${BOLD}SUPPORTED LABS:${NC}
USAGE
    
    # Show available labs in sorted order
    for lab_num in $(printf '%s\n' "${!LAB_TITLES[@]}" | sort -V); do
        printf "    %-6s %s\n" "${lab_num}" "${LAB_TITLES[$lab_num]}"
    done
}

show_lab_list() {
    echo -e "${BOLD}Available Labs:${NC}\n"
    
    for lab_num in $(printf '%s\n' "${!LAB_TITLES[@]}" | sort -V); do
        printf "${CYAN}%-8s${NC} %s\n" "Lab ${lab_num}" "${LAB_TITLES[$lab_num]}"
    done
    
    echo -e "\n${BOLD}Usage:${NC} ${SCRIPT_NAME} <lab-number>"
}

validate_lab_number() {
    local lab="$1"
    
    # Check if lab number is empty
    if [[ -z "${lab}" ]]; then
        log_error "No lab number provided"
        show_usage
        return ${EXIT_INVALID_ARGS}
    fi
    
    # Validate format (numbers and optional single decimal point)
    if [[ ! "${lab}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        log_error "Invalid lab number format: '${lab}'"
        log_error "Expected format: integer or decimal (e.g., 1, 3.5, 8.5)"
        return ${EXIT_INVALID_ARGS}
    fi
    
    # Check if lab exists in our configuration
    if [[ ! -v LAB_TITLES["${lab}"] ]]; then
        log_error "Lab ${lab} is not available"
        log_info "Use '${SCRIPT_NAME} --list' to see available labs"
        return ${EXIT_INVALID_ARGS}
    fi
    
    return ${EXIT_SUCCESS}
}

parse_arguments() {
    # Handle no arguments
    if [[ $# -eq 0 ]]; then
        log_error "No arguments provided"
        show_usage
        return ${EXIT_INVALID_ARGS}
    fi
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_usage
                exit ${EXIT_SUCCESS}
                ;;
            -l|--list)
                show_lab_list
                exit ${EXIT_SUCCESS}
                ;;
            -v|--verbose)
                set -x  # Enable debug mode
                shift
                ;;
            --non-interactive)
                INTERACTIVE=false
                shift
                ;;
            --all)
                log_info "Checking all available labs..."
                for lab_num in $(printf '%s\n' "${!LAB_TITLES[@]}" | sort -V); do
                    echo -e "\n${BOLD}Checking Lab ${lab_num}...${NC}"
                    run_checks_for_lab "${lab_num}" || true
                done
                exit ${EXIT_SUCCESS}
                ;;
            -*)
                log_error "Unknown option: $1"
                show_usage
                return ${EXIT_INVALID_ARGS}
                ;;
            *)
                # This should be the lab number
                validate_lab_number "$1" || return $?
                export LAB_NUMBER="$1"
                return ${EXIT_SUCCESS}
                ;;
        esac
    done
    
    log_error "No lab number provided after parsing options"
    show_usage
    return ${EXIT_INVALID_ARGS}
}
detect_os() {
    local os="$(uname -s | tr '[:upper:]' '[:lower:]')"
    
    # Check for Windows environments
    if [[ -n "${WINDIR:-}" ]] || [[ "${os}" =~ mingw|msys|cygwin ]]; then
        echo "windows"
        return
    fi
    
    # Check for WSL (Windows Subsystem for Linux)
    if [[ -n "${WSL_DISTRO_NAME:-}" ]] || [[ "$(uname -r)" =~ microsoft ]]; then
        echo "wsl"
        return
    fi
    
    case "$os" in
        darwin) echo "macos" ;;
        linux) echo "linux" ;;
        *) echo "unknown" ;;
    esac
}

# Windows package manager detection
choco_available() { command -v choco >/dev/null 2>&1; }
scoop_available() { command -v scoop >/dev/null 2>&1; }
winget_available() { command -v winget >/dev/null 2>&1; }

# Cross-platform timeout function
run_with_timeout() {
    local timeout_duration="$1"
    shift
    local cmd=("$@")
    
    if command -v timeout >/dev/null 2>&1; then
        # Linux/WSL timeout command
        timeout "${timeout_duration}s" "${cmd[@]}"
    elif command -v gtimeout >/dev/null 2>&1; then
        # macOS with coreutils
        gtimeout "${timeout_duration}s" "${cmd[@]}"
    else
        # Fallback: just run the command without timeout
        log_warn "timeout command not available, running without timeout limit"
        "${cmd[@]}"
    fi
}

brew_available() { command -v brew >/dev/null 2>&1; }

apt_available() { command -v apt-get >/dev/null 2>&1; }

dnf_available() { command -v dnf >/dev/null 2>&1; }

prompt_yes_no() {
    local prompt="$1"; local default="${2:-y}"; local ans
    if [[ "$INTERACTIVE" != true ]]; then return 1; fi
    while true; do
        read -r -p "${prompt} [y/n] (default ${default}): " ans || return 1
        ans=${ans:-$default}
        case "$ans" in
            y|Y|yes|YES) return 0 ;;
            n|N|no|NO) return 1 ;;
            *) echo "Please answer y or n." ;;
        esac
    done
}

prompt_with_options() {
    local prompt="$1"
    shift
    local options=("$@")
    local default=1
    
    if [[ "$INTERACTIVE" != true ]]; then return 1; fi
    
    echo -e "${CYAN}${prompt}${NC}"
    for i in "${!options[@]}"; do
        echo "  $((i+1)). ${options[$i]}"
    done
    
    while true; do
        read -r -p "Select option [1-${#options[@]}] (default ${default}): " choice || return 1
        choice=${choice:-$default}
        
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le ${#options[@]} ]]; then
            return $((choice-1))
        else
            echo "Please enter a number between 1 and ${#options[@]}."
        fi
    done
}

attempt_install() {
    local cmd="$1"
    local os; os=$(detect_os)
    
    if [[ "$os" == "macos" ]] && brew_available; then
        case "$cmd" in
            kubectl) echo "brew install kubernetes-cli" ;;
            helm) echo "brew install helm" ;;
            docker) echo "brew install --cask docker" ;;
            stern) echo "brew install stern" ;;
            k9s) echo "brew install k9s" ;;
            jq) echo "brew install jq" ;;
            git) echo "brew install git" ;;
            curl) echo "brew install curl" ;;
            *) return 1 ;;
        esac
        return 0
    elif [[ "$os" == "windows" ]] || [[ "$os" == "wsl" ]]; then
        # Try Windows package managers in order of preference
        if winget_available; then
            case "$cmd" in
                kubectl) echo "winget install -e --id Kubernetes.kubectl" ;;
                helm) echo "winget install -e --id Helm.Helm" ;;
                docker) echo "winget install -e --id Docker.DockerDesktop" ;;
                git) echo "winget install -e --id Git.Git" ;;
                jq) echo "winget install -e --id stedolan.jq" ;;
                curl) echo "winget install -e --id cURL.cURL" ;;
                rancher-desktop) echo "winget install -e --id suse.RancherDesktop" ;;
                *) return 1 ;;
            esac
            return 0
        elif choco_available; then
            case "$cmd" in
                kubectl) echo "choco install kubernetes-cli -y" ;;
                helm) echo "choco install kubernetes-helm -y" ;;
                docker) echo "choco install docker-desktop -y" ;;
                git) echo "choco install git -y" ;;
                jq) echo "choco install jq -y" ;;
                curl) echo "choco install curl -y" ;;
                rancher-desktop) echo "choco install rancher-desktop -y" ;;
                *) return 1 ;;
            esac
            return 0
        elif scoop_available; then
            case "$cmd" in
                kubectl) echo "scoop install kubectl" ;;
                helm) echo "scoop install helm" ;;
                git) echo "scoop install git" ;;
                jq) echo "scoop install jq" ;;
                curl) echo "scoop install curl" ;;
                *) return 1 ;;
            esac
            return 0
        fi
    elif [[ "$os" == "linux" ]]; then
        if apt_available; then
            case "$cmd" in
                kubectl) echo "sudo apt-get update && sudo apt-get install -y kubectl" ;;
                helm) echo "curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash" ;;
                docker) echo "curl -fsSL https://get.docker.com | sh" ;;
                jq) echo "sudo apt-get update && sudo apt-get install -y jq" ;;
                git) echo "sudo apt-get update && sudo apt-get install -y git" ;;
                curl) echo "sudo apt-get update && sudo apt-get install -y curl" ;;
                *) return 1 ;;
            esac
            return 0
        elif dnf_available; then
            case "$cmd" in
                kubectl) echo "sudo dnf install -y kubernetes-client" ;;
                helm) echo "curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash" ;;
                docker) echo "sudo dnf -y install docker && sudo systemctl enable --now docker" ;;
                jq) echo "sudo dnf -y install jq" ;;
                git) echo "sudo dnf -y install git" ;;
                curl) echo "sudo dnf -y install curl" ;;
                *) return 1 ;;
            esac
            return 0
        fi
    fi
    return 1
}

remediate_command_missing() {
    local cmd="$1"; local desc="$2"
    if [[ "$INTERACTIVE" != true ]]; then return ${EXIT_MISSING_DEPS}; fi
    
    local os; os=$(detect_os)
    log_warn "${desc} not found (${cmd})."
    
    # Provide OS-specific guidance
    if [[ "$os" == "windows" ]] || [[ "$os" == "wsl" ]]; then
        log_info "Windows detected. Checking for package managers..."
        if ! winget_available && ! choco_available && ! scoop_available; then
            log_warn "No Windows package manager found. Consider installing:"
            log_info "• winget (recommended): https://aka.ms/getwinget"
            log_info "• chocolatey: https://chocolatey.org/install"
            log_info "• scoop: https://scoop.sh/"
        fi
    fi
    
    if prompt_yes_no "Attempt to install ${desc} now?" y; then
        local install_cmd
        if install_cmd=$(attempt_install "$cmd"); then
            log_info "Running: ${install_cmd}"
            set +e
            
            # Handle Windows-specific execution
            if [[ "$os" == "windows" ]] || [[ "$os" == "wsl" ]]; then
                if [[ "$install_cmd" =~ winget ]] && command -v powershell.exe >/dev/null 2>&1; then
                    powershell.exe -Command "${install_cmd}"
                    local rc=$?
                elif [[ "$install_cmd" =~ choco ]] && command -v cmd.exe >/dev/null 2>&1; then
                    cmd.exe /c "${install_cmd}"
                    local rc=$?
                else
                    bash -lc "${install_cmd}"
                    local rc=$?
                fi
            else
                bash -lc "${install_cmd}"
                local rc=$?
            fi
            
            set -e
            if [[ $rc -eq 0 ]]; then
                log_success "Installed ${desc}"
                # Refresh PATH for Windows
                if [[ "$os" == "windows" ]] || [[ "$os" == "wsl" ]]; then
                    log_info "You may need to restart your terminal or source your profile for PATH changes to take effect."
                fi
                return ${EXIT_SUCCESS}
            else
                log_error "Failed to install ${desc} (exit code: ${rc})"
                if [[ "$os" == "windows" ]] || [[ "$os" == "wsl" ]]; then
                    log_info "Try running your terminal as Administrator or check Windows permissions."
                fi
            fi
        else
            log_warn "No automated installer available for ${desc} on this OS."
            if [[ "$os" == "windows" ]] || [[ "$os" == "wsl" ]]; then
                log_info "Manual installation options for Windows:"
                case "$cmd" in
                    kubectl)
                        log_info "• Download from: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/"
                        ;;
                    helm)
                        log_info "• Download from: https://helm.sh/docs/intro/install/"
                        ;;
                    docker)
                        log_info "• Rancher Desktop: https://rancherdesktop.io/ (recommended)"
                        log_info "• Docker Desktop: https://www.docker.com/products/docker-desktop/"
                        ;;
                    git)
                        log_info "• Download from: https://git-scm.com/download/win"
                        ;;
                esac
            fi
        fi
    fi
    
    # OS-specific setup guide references
    case "$os" in
        windows|wsl)
            log_info "See setup guides: docs/setup/windows-setup.md · docs/setup/rancher-desktop.md"
            ;;
        macos)
            log_info "See setup guides: docs/setup/rancher-desktop.md · docs/setup/macos-setup.md"
            ;;
        *)
            log_info "See setup guides: docs/setup/rancher-desktop.md · docs/setup/linux-kind-k3d.md"
            ;;
    esac
    
    return ${EXIT_MISSING_DEPS}
}

run_cleanup_menu() {
    [[ "$INTERACTIVE" == true ]] || return 0
    if prompt_yes_no "Run workspace cleanup to free resources?" n; then
        if [[ -x "${ROOT_DIR}/scripts/cleanup-workspace.sh" ]]; then
            bash "${ROOT_DIR}/scripts/cleanup-workspace.sh" || true
        else
            log_warn "cleanup-workspace.sh not found"
        fi
    fi
}

# =============================================================================
# WINDOWS-SPECIFIC FUNCTIONS
# =============================================================================
check_docker_desktop_running() {
    local os; os=$(detect_os)
    if [[ "$os" == "windows" ]] || [[ "$os" == "wsl" ]]; then
        # Check if Docker Desktop is running on Windows
        if command -v powershell.exe >/dev/null 2>&1; then
            powershell.exe -Command "Get-Process 'Docker Desktop' -ErrorAction SilentlyContinue" >/dev/null 2>&1
        elif command -v cmd.exe >/dev/null 2>&1; then
            cmd.exe /c "tasklist /FI \"IMAGENAME eq Docker Desktop.exe\" 2>nul | find /I \"Docker Desktop.exe\" >nul"
        else
            return 1
        fi
    else
        return 1
    fi
}

uninstall_docker_desktop_windows() {
    local os; os=$(detect_os)
    [[ "$os" == "windows" ]] || [[ "$os" == "wsl" ]] || return 1
    [[ "$INTERACTIVE" == true ]] || return 1
    
    log_warn "Docker Desktop detected. For optimal Kubernetes experience, Rancher Desktop is recommended."
    log_info "Rancher Desktop provides better resource management and k8s integration."
    
    if ! prompt_yes_no "Would you like to replace Docker Desktop with Rancher Desktop?" y; then
        log_info "Keeping Docker Desktop. Ensure it has Kubernetes enabled."
        return 0
    fi
    
    log_info "Starting Docker Desktop to Rancher Desktop migration..."
    
    # Stop Docker Desktop gracefully first
    log_info "Stopping Docker Desktop..."
    set +e
    if command -v powershell.exe >/dev/null 2>&1; then
        powershell.exe -Command "Stop-Process -Name 'Docker Desktop' -Force -ErrorAction SilentlyContinue" 2>/dev/null
        sleep 5
    fi
    set -e
    
    # Attempt uninstallation
    local uninstall_success=false
    
    # Try winget first (most reliable)
    if winget_available; then
        log_info "Attempting to uninstall Docker Desktop using winget..."
        set +e
        if winget uninstall "Docker Desktop" --silent 2>/dev/null; then
            uninstall_success=true
            log_success "Docker Desktop uninstalled successfully via winget"
        fi
        set -e
    fi
    
    # Try chocolatey if winget failed
    if [[ "$uninstall_success" == false ]] && choco_available; then
        log_info "Attempting to uninstall Docker Desktop using chocolatey..."
        set +e
        if choco uninstall docker-desktop -y 2>/dev/null; then
            uninstall_success=true
            log_success "Docker Desktop uninstalled successfully via chocolatey"
        fi
        set -e
    fi
    
    # Manual uninstall instructions if automated methods failed
    if [[ "$uninstall_success" == false ]]; then
        log_warn "Automated uninstall failed. Please manually uninstall Docker Desktop:"
        log_info "1. Go to Settings > Apps > Docker Desktop"
        log_info "2. Click 'Uninstall' and follow the prompts"
        log_info "3. Restart your computer when prompted"
        
        if prompt_yes_no "Have you manually uninstalled Docker Desktop?" n; then
            uninstall_success=true
        fi
    fi
    
    return $([[ "$uninstall_success" == true ]] && echo 0 || echo 1)
}

install_rancher_desktop_windows() {
    local os; os=$(detect_os)
    [[ "$os" == "windows" ]] || [[ "$os" == "wsl" ]] || return 1
    
    log_info "Installing Rancher Desktop..."
    
    local install_cmd
    if install_cmd=$(attempt_install "rancher-desktop"); then
        log_info "Running: ${install_cmd}"
        set +e
        if [[ "$install_cmd" =~ winget ]]; then
            # Use PowerShell for winget to handle Windows paths properly
            powershell.exe -Command "${install_cmd}"
        else
            bash -lc "${install_cmd}"
        fi
        local rc=$?
        set -e
        
        if [[ $rc -eq 0 ]]; then
            log_success "Rancher Desktop installed successfully"
            log_info "Starting Rancher Desktop (this may take a few minutes)..."
            
            # Try to start Rancher Desktop
            set +e
            if command -v powershell.exe >/dev/null 2>&1; then
                powershell.exe -Command "Start-Process 'Rancher Desktop'" 2>/dev/null
            fi
            set -e
            
            log_info "Waiting for Rancher Desktop to initialize..."
            log_info "Please configure Rancher Desktop:"
            log_info "1. Enable Kubernetes in Rancher Desktop settings"
            log_info "2. Wait for the cluster to start (green indicator)"
            log_info "3. Verify with: kubectl cluster-info"
            
            # Wait for user confirmation
            if [[ "$INTERACTIVE" == true ]]; then
                read -r -p "Press Enter when Rancher Desktop is ready..." || true
            else
                sleep 30
            fi
            
            return ${EXIT_SUCCESS}
        else
            log_error "Failed to install Rancher Desktop (exit code: ${rc})"
            return ${EXIT_MISSING_DEPS}
        fi
    else
        log_error "No installation method available for Rancher Desktop"
        log_info "Please download and install manually from: https://rancherdesktop.io/"
        return ${EXIT_MISSING_DEPS}
    fi
}

migrate_docker_to_rancher_windows() {
    local os; os=$(detect_os)
    [[ "$os" == "windows" ]] || [[ "$os" == "wsl" ]] || return 0
    [[ "$INTERACTIVE" == true ]] || return 0
    
    # Check if Docker Desktop is installed and running
    if check_docker_desktop_running || command -v docker >/dev/null 2>&1; then
        log_info "Docker Desktop detected on Windows system"
        
        if prompt_yes_no "Would you like to migrate from Docker Desktop to Rancher Desktop for better Kubernetes support?" y; then
            if uninstall_docker_desktop_windows; then
                install_rancher_desktop_windows || {
                    log_error "Failed to install Rancher Desktop"
                    log_info "You can install it manually from https://rancherdesktop.io/"
                    return ${EXIT_MISSING_DEPS}
                }
            else
                log_warn "Docker Desktop uninstallation failed. Continuing with existing setup."
            fi
        fi
    fi
    
    return ${EXIT_SUCCESS}
}

# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================
check_environment() {
    log_subheader "Environment Validation"
    
    # Check if we're in the correct repository structure
    if [[ ! -d "${ROOT_DIR}/docs" ]] || [[ ! -d "${ROOT_DIR}/labs" ]]; then
        log_error "Invalid repository structure. Missing docs/ or labs/ directories"
        log_error "Please run from the repository root or scripts/ directory"
        return ${EXIT_MISSING_FILES}
    fi
    
    # Check if git is available and we're in a git repo
    if command -v git >/dev/null 2>&1; then
        if git rev-parse --git-dir >/dev/null 2>&1; then
            log_success "Git repository detected"
        else
            log_warn "Not in a git repository (this may be intentional)"
        fi
    else
        log_warn "Git command not available"
    fi
    
    log_success "Environment validation passed"
    return ${EXIT_SUCCESS}
}

check_command() {
    local cmd="$1"
    local description="${2:-${cmd}}"
    local required="${3:-true}"
    
    if command -v "${cmd}" >/dev/null 2>&1; then
        local version=""
        case "${cmd}" in
            kubectl)
                version="$(kubectl version --client --short 2>/dev/null | grep -o 'v[0-9.]*' || echo '')"
                ;;
            helm)
                version="$(helm version --short 2>/dev/null | grep -o 'v[0-9.]*' || echo '')"
                ;;
            docker)
                version="$(docker --version 2>/dev/null | grep -o '[0-9.]*' | head -1 || echo '')"
                ;;
            *)
                version="$(${cmd} --version 2>/dev/null | head -1 | grep -o '[0-9.]*' | head -1 || echo '')"
                ;;
        esac
        
        if [[ -n "${version}" ]]; then
            log_success "Found ${description}: ${cmd} ${version}"
        else
            log_success "Found ${description}: ${cmd}"
        fi
        return ${EXIT_SUCCESS}
    else
        if [[ "${required}" == "true" ]]; then
            # Interactive remediation
            remediate_command_missing "${cmd}" "${description}" || true
            if command -v "${cmd}" >/dev/null 2>&1; then
                log_success "Found ${description} after remediation: ${cmd}"
                return ${EXIT_SUCCESS}
            fi
            log_error "Missing required command: ${cmd} (${description})"
            return ${EXIT_MISSING_DEPS}
        else
            log_warn "Optional command missing: ${cmd} (${description})"
            return ${EXIT_SUCCESS}
        fi
    fi
}

check_path() {
    local path="$1"
    local description="${2:-${path}}"
    local required="${3:-true}"
    local full_path="${ROOT_DIR}/${path}"
    
    if [[ -e "${full_path}" ]]; then
        if [[ -d "${full_path}" ]]; then
            local item_count
            item_count=$(find "${full_path}" -maxdepth 1 -type f | wc -l)
            log_success "Found ${description} (${item_count} files)"
        elif [[ -f "${full_path}" ]]; then
            local file_size
            file_size=$(du -h "${full_path}" 2>/dev/null | cut -f1)
            log_success "Found ${description} (${file_size:-'unknown size'})"
        else
            log_success "Found ${description}"
        fi
        return ${EXIT_SUCCESS}
    else
        if [[ "${required}" == "true" ]]; then
            log_error "Missing required path: ${description}"
            log_error "Expected location: ${full_path}"
            return ${EXIT_MISSING_FILES}
        else
            log_warn "Optional path missing: ${description}"
            log_info "Expected location: ${full_path}"
            return ${EXIT_SUCCESS}
        fi
    fi
}

check_kubernetes_cluster() {
    log_subheader "Kubernetes Cluster Connectivity"
    
    if ! command -v kubectl >/dev/null 2>&1; then
        log_error "kubectl not found - cannot check cluster connectivity"
        return ${EXIT_MISSING_DEPS}
    fi
    
    # Check cluster connectivity with timeout
    if run_with_timeout 10 kubectl cluster-info >/dev/null 2>&1; then
        local context
        context="$(kubectl config current-context 2>/dev/null || echo 'unknown')"
        log_success "Kubernetes cluster accessible (context: ${context})"
        
        # Check node status
        local node_count
        node_count="$(kubectl get nodes --no-headers 2>/dev/null | wc -l)"
        if [[ ${node_count} -gt 0 ]]; then
            log_success "Found ${node_count} cluster node(s)"
        else
            log_warn "No nodes found in cluster"
        fi
    else
        log_error "Cannot connect to Kubernetes cluster"
        log_error "Ensure your cluster is running and kubectl is configured correctly"
        if [[ "$INTERACTIVE" == true ]]; then
            local os; os=$(detect_os)
            
            if [[ "$os" == "windows" ]] || [[ "$os" == "wsl" ]]; then
                # Windows-specific cluster startup handling
                if prompt_yes_no "Would you like to set up Kubernetes on Windows now?" y; then
                    migrate_docker_to_rancher_windows || true
                    
                    log_info "Waiting 30s for Kubernetes cluster to initialize..."
                    sleep 30
                    if run_with_timeout 30 kubectl cluster-info >/dev/null 2>&1; then
                        log_success "Cluster is now accessible"
                        return ${EXIT_SUCCESS}
                    else
                        log_warn "Cluster not ready yet. You may need to:"
                        log_info "1. Open Rancher Desktop and enable Kubernetes"
                        log_info "2. Wait for the cluster status to show 'Running' (green)"
                        log_info "3. Run this script again"
                    fi
                fi
            elif [[ "$os" == "macos" ]] && prompt_yes_no "Open Rancher Desktop to start Kubernetes now?" y; then
                set +e; open -a "Rancher Desktop" 2>/dev/null || open -a Docker 2>/dev/null || true; set -e
                log_info "Waiting 15s for cluster to initialize..."
                sleep 15
                if run_with_timeout 20 kubectl cluster-info >/dev/null 2>&1; then
                    log_success "Cluster is now accessible"
                    return ${EXIT_SUCCESS}
                fi
            fi
            log_info "You can also run: kubectl config get-contexts && kubectl config use-context <name>"
        fi
        return ${EXIT_MISSING_DEPS}
    fi
    
    return ${EXIT_SUCCESS}
}

check_manifest_bundle() {
    local lab="$1"
    local lab_padded
    lab_padded="$(printf "%02g" "${lab}" 2>/dev/null || echo "${lab}")"
    local dir="labs/manifests/lab-${lab_padded}"
    
    check_path "${dir}" "Lab ${lab} manifest overlay" "false"
}

# =============================================================================
# LAB-SPECIFIC CHECKS
# =============================================================================
check_lab() {
    local lab="$1"
    local exit_code=0

    log_info "Checking prerequisites for ${LAB_TITLES[${lab}]}"

    case "$lab" in
        0|"0")
            check_command "kubectl" "Kubernetes CLI"
            ;;
        0.5|"0.5")
            check_command "docker" "Docker Engine"
            check_command "docker-compose" "Docker Compose" "false"
            ;;
        1|"1")
            check_path "weather-app" "Weather app source code"
            check_path "weather-app/k8s" "Weather app Kubernetes manifests"
            check_manifest_bundle "$lab"
            ;;
        2|"2") 
            check_path "ecommerce-app" "E-commerce app source"
            check_path "ecommerce-app/k8s" "E-commerce Kubernetes manifests"
            check_manifest_bundle "$lab"
            ;;
        3|"3")
            check_path "educational-platform" "Educational platform source"
            check_path "educational-platform/k8s" "Educational platform manifests"
            check_manifest_bundle "$lab"
            ;;
        3.5|"3.5")
            check_command "kubectl" "Kubernetes CLI"
            ;;
        4|"4")
            check_command "kubectl" "Kubernetes CLI"
            check_manifest_bundle "$lab"
            ;;
        5|"5")
            check_path "task-management-app" "Task management source"
            check_path "task-management-app/k8s" "Task management manifests" 
            check_command "curl" "HTTP client for testing" "false"
            check_manifest_bundle "$lab"
            ;;
        6|"6")
            check_path "medical-care-system" "Medical system source"
            check_path "medical-care-system/k8s" "Medical system manifests"
            check_manifest_bundle "$lab"
            ;;
        7|"7")
            check_path "social-media-platform" "Social media platform source"
            check_path "social-media-platform/k8s" "Social media manifests"
            check_manifest_bundle "$lab"
            ;;
        8|"8")
            check_path "weather-app" "Weather app"
            check_path "ecommerce-app" "E-commerce app" 
            check_path "educational-platform" "Educational platform"
            check_manifest_bundle "$lab"
            
            # Resource warning for Lab 8
            log_warn "Lab 8 (Multi-App) requires significant resources (3 CPU / 4GB+ RAM minimum)"
            log_info "For machines with 8-12 CPU / 8-16GB RAM: Consider Lab 8 Lite instead"
            log_info "📖 Lab 8 Lite Guide: docs/10-setup/LAB-8-LITE.md (82% resource reduction)"
            ;;
        8.5|"8.5")
            check_command "kubectl" "Kubernetes CLI"
            ;;
        9|"9")
            check_command "kubectl" "Kubernetes CLI"
            check_path "social-media-platform" "Social media platform"
            check_manifest_bundle "$lab"
            ;;
        9.5|"9.5")
            check_command "kubectl" "Kubernetes CLI"
            ;;
        10|"10")
            check_command "helm" "Helm package manager"
            check_path "weather-app" "Weather app source"
            check_manifest_bundle "$lab"
            ;;
        11|"11")
            check_command "kubectl" "Kubernetes CLI"
            check_command "git" "Git version control"
            check_manifest_bundle "$lab"
            ;;
        11.5|"11.5")
            check_command "kubectl" "Kubernetes CLI"
            ;;
        12|"12")
            check_command "kubectl" "Kubernetes CLI"
            check_manifest_bundle "$lab"
            ;;
        13|"13")
            check_command "kubectl" "Kubernetes CLI"
            check_manifest_bundle "$lab"
            ;;
        *)
            log_error "Unknown lab number: $lab"
            show_usage
            return ${EXIT_INVALID_ARGS}
            ;;
    esac

    return ${exit_code}
}

check_docker_compose() {
    log_subheader "Docker Environment"
    
    local os; os=$(detect_os)
    
    check_command "docker" "Docker Engine" || {
        if [[ "$INTERACTIVE" == true ]] && prompt_yes_no "Attempt to install/start container runtime?" y; then
            if [[ "$os" == "windows" ]] || [[ "$os" == "wsl" ]]; then
                # On Windows, prefer Rancher Desktop for better k8s integration
                log_info "For Windows, installing Rancher Desktop (includes Docker + Kubernetes)..."
                if install_rancher_desktop_windows; then
                    log_info "Rancher Desktop installed. Waiting for services to start..."
                    sleep 15
                else
                    log_warn "Rancher Desktop installation failed, falling back to Docker Desktop"
                    local install_cmd
                    if install_cmd=$(attempt_install "docker"); then
                        log_info "Running: ${install_cmd}"
                        set +e
                        if [[ "$install_cmd" =~ winget ]]; then
                            powershell.exe -Command "${install_cmd}"
                        else
                            bash -lc "${install_cmd}"
                        fi
                        set -e
                    fi
                fi
            elif [[ "$os" == "macos" ]]; then
                if brew_available; then
                    set +e; bash -lc "brew install --cask docker"; set -e
                fi
                set +e; open -a Docker 2>/dev/null || true; set -e
                log_info "Waiting 10s for Docker to start..."; sleep 10
            fi
        fi
        # Re-check docker availability
        command -v docker >/dev/null 2>&1 || return ${EXIT_MISSING_DEPS}
    }
    check_command "docker-compose" "Docker Compose" "false"
    
    # Check if Docker daemon is running
    if docker info >/dev/null 2>&1; then
        log_success "Docker daemon is running"
    else
        log_error "Docker daemon is not running or not accessible"
        if [[ "$INTERACTIVE" == true ]]; then
            if [[ "$os" == "windows" ]] || [[ "$os" == "wsl" ]]; then
                if prompt_yes_no "Start container runtime now?" y; then
                    # Try to start Rancher Desktop first, then Docker Desktop
                    set +e
                    if command -v powershell.exe >/dev/null 2>&1; then
                        powershell.exe -Command "Start-Process 'Rancher Desktop'" 2>/dev/null || \
                        powershell.exe -Command "Start-Process 'Docker Desktop'" 2>/dev/null || true
                    fi
                    set -e
                    log_info "Waiting 20s for container runtime to start..."
                    sleep 20
                    if docker info >/dev/null 2>&1; then
                        log_success "Docker daemon is running"
                        return ${EXIT_SUCCESS}
                    else
                        log_warn "Container runtime may still be starting. Please wait and try again."
                    fi
                fi
            elif [[ "$os" == "macos" ]] && prompt_yes_no "Start Docker Desktop now?" y; then
                set +e; open -a Docker 2>/dev/null || true; set -e
                log_info "Waiting 10s for Docker to start..."; sleep 10
                if docker info >/dev/null 2>&1; then
                    log_success "Docker daemon is running"
                    return ${EXIT_SUCCESS}
                fi
            fi
        fi
        log_error "Please start your container runtime and ensure proper permissions"
        log_info "For Windows: Start Rancher Desktop or Docker Desktop"
        log_info "For macOS: Start Docker Desktop"
        log_info "For Linux: Ensure Docker service is running"
        run_cleanup_menu
        return ${EXIT_MISSING_DEPS}
    fi
}

check_common_prereqs() {
    log_subheader "Common Prerequisites"
    
    check_command "kubectl" "Kubernetes CLI" || return $?
    check_command "git" "Git version control" "false"
    check_command "curl" "HTTP client" "false"
    check_command "jq" "JSON processor" "false"
    
    return ${EXIT_SUCCESS}
}

# =============================================================================
# MAIN EXECUTION FUNCTIONS
# =============================================================================
main() {
    local exit_code=${EXIT_SUCCESS}
    
    log_header "Kubernetes Lab Prerequisites Checker"
    log_info "Validating environment for ${LAB_TITLES[${LAB_NUMBER}]}"
    
    # Run comprehensive checks
    check_environment || exit_code=${EXIT_MISSING_FILES}
    check_common_prereqs || exit_code=${EXIT_MISSING_DEPS}
    check_kubernetes_cluster || exit_code=${EXIT_MISSING_DEPS}
    check_docker_compose || exit_code=${EXIT_MISSING_DEPS}
    check_lab "${LAB_NUMBER}" || exit_code=${EXIT_MISSING_FILES}
    
    # Summary
    log_header "Prerequisites Check Summary"
    
    local total_checks=$((CHECKS_PASSED + CHECKS_FAILED + CHECKS_WARNED))
    echo -e "${GREEN}✅ Passed:  ${CHECKS_PASSED}${NC}"
    echo -e "${RED}❌ Failed:  ${CHECKS_FAILED}${NC}"
    echo -e "${YELLOW}⚠️  Warned:  ${CHECKS_WARNED}${NC}"
    echo -e "${BLUE}📊 Total:   ${total_checks}${NC}"
    
    if [[ ${CHECKS_FAILED} -eq 0 ]]; then
        echo -e "\n${GREEN}${BOLD}🎉 All critical prerequisites satisfied!${NC}"
        echo -e "${GREEN}You are ready to begin ${LAB_TITLES[${LAB_NUMBER}]}${NC}"
        
        if [[ ${CHECKS_WARNED} -gt 0 ]]; then
            echo -e "\n${YELLOW}Note: Some optional tools are missing but won't prevent lab completion${NC}"
        fi
    else
        echo -e "\n${RED}${BOLD}❌ Prerequisites check failed${NC}"
        if [[ "$INTERACTIVE" == true ]]; then
            echo -e "${YELLOW}You can rerun this checker after remediation, or continue at your own risk.${NC}"
            
            local os; os=$(detect_os)
            if [[ "$os" == "windows" ]] || [[ "$os" == "wsl" ]]; then
                echo -e "\n${CYAN}${BOLD}Windows-specific remediation options:${NC}"
                if prompt_with_options "Choose how to proceed:" \
                    "Install missing tools automatically (recommended)" \
                    "Get manual installation instructions" \
                    "Continue with current setup" \
                    "Open troubleshooting guide"; then
                    
                    case $? in
                        0) # Auto-install
                            log_info "Attempting to install missing prerequisites automatically..."
                            # Re-run checks with installation attempts
                            ;;
                        1) # Manual instructions
                            echo -e "\n${YELLOW}Manual Installation Instructions for Windows:${NC}"
                            echo -e "1. Install winget: ${BOLD}https://aka.ms/getwinget${NC}"
                            echo -e "2. Install tools: ${BOLD}winget install kubectl helm git${NC}"
                            echo -e "3. Install Rancher Desktop: ${BOLD}https://rancherdesktop.io/${NC}"
                            echo -e "4. Enable Kubernetes in Rancher Desktop settings"
                            ;;
                        2) # Continue
                            log_warn "Continuing with incomplete setup..."
                            ;;
                        3) # Troubleshooting
                            echo -e "See: ${BOLD}docs/troubleshooting/troubleshooting.md${NC}"
                            echo -e "Windows guide: ${BOLD}docs/setup/windows-setup.md${NC}"
                            ;;
                    esac
                fi
            else
                if prompt_yes_no "Open troubleshooting guide now?" y; then
                    echo -e "See: ${BOLD}docs/troubleshooting/troubleshooting.md${NC}"
                fi
            fi
            run_cleanup_menu
        else
            echo -e "${RED}Please install missing dependencies before starting the lab, or run without --non-interactive for guided remediation.${NC}"
            local os; os=$(detect_os)
            if [[ "$os" == "windows" ]] || [[ "$os" == "wsl" ]]; then
                echo -e "${YELLOW}For Windows users: Consider using winget, chocolatey, or scoop for package management.${NC}"
                echo -e "${YELLOW}Recommended: Install Rancher Desktop for integrated Kubernetes support.${NC}"
            fi
        fi
    fi
    
    return ${exit_code}
}

# Run lab-specific check function
run_checks_for_lab() {
    local lab="$1"
    local saved_lab_number="${LAB_NUMBER:-}"
    
    LAB_NUMBER="${lab}"
    CHECKS_PASSED=0
    CHECKS_FAILED=0  
    CHECKS_WARNED=0
    
    main
    local result=$?
    
    LAB_NUMBER="${saved_lab_number}"
    return ${result}
}

# =============================================================================
# SCRIPT EXECUTION
# =============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_arguments "$@" || exit $?
    main
    exit $?
fi
