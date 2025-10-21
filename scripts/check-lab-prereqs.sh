#!/usr/bin/env bash
# Enhanced lab prerequisites checker with comprehensive validation
set -euo pipefail

# =============================================================================
# CONFIGURATION & GLOBALS
# =============================================================================
readonly SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Terminal colors
readonly GREEN="\033[0;32m"
readonly RED="\033[0;31m"
readonly YELLOW="\033[1;33m"
readonly BLUE="\033[0;34m"
readonly CYAN="\033[0;36m"
readonly BOLD="\033[1m"
readonly NC="\033[0m"

# Exit codes
readonly EXIT_SUCCESS=0
readonly EXIT_INVALID_ARGS=1
readonly EXIT_MISSING_DEPS=2
readonly EXIT_MISSING_FILES=3

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
    -h, --help      Show this help message and exit
    -l, --list      List all available labs
    -v, --verbose   Enable verbose output
    --all          Check prerequisites for all labs

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
    if timeout 10s kubectl cluster-info >/dev/null 2>&1; then
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
    
    check_command "docker" "Docker Engine" || return $?
    check_command "docker-compose" "Docker Compose" "false"
    
    # Check if Docker daemon is running
    if docker info >/dev/null 2>&1; then
        log_success "Docker daemon is running"
    else
        log_error "Docker daemon is not running or not accessible"
        log_error "Please start Docker and ensure your user has proper permissions"
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
        echo -e "${RED}Please install missing dependencies before starting the lab${NC}"
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
