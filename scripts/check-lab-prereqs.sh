#!/usr/bin/env bash

set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

LAB_TITLES=(
    ""  # index 0 placeholder
    "Lab 1 · Weather App Basics"
    "Lab 2 · E-commerce Multi-Service"
    "Lab 3 · Educational Stateful"
    "Lab 4 · Kubernetes Fundamentals Deep Dive"
    "Lab 5 · Task Manager Ingress"
    "Lab 6 · Medical System Security"
    "Lab 7 · Social Media Autoscaling"
    "Lab 8 · Multi-App Orchestration"
    "Lab 9 · Chaos Engineering"
    "Lab 10 · Helm Package Management"
    "Lab 11 · GitOps with ArgoCD"
    "Lab 12 · External Secrets Management"
)

log_header() {
    echo -e "${BLUE}\n═══════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $*${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}\n"
}

log_success() {
    echo -e "${GREEN}✅ $*${NC}"
}

log_error() {
    echo -e "${RED}❌ $*${NC}"
}

log_warn() {
    echo -e "${YELLOW}⚠️  $*${NC}"
}

usage() {
    cat <<'EOF'
Usage: ./scripts/check-lab-prereqs.sh <lab-number>

Verify that your local environment has the tools, manifests, and configuration
needed before you begin a lab. The script checks for required CLI tools,
Kubernetes manifests, and optional dependencies like Helm or AWS CLI.

Examples:
  ./scripts/check-lab-prereqs.sh 1
  ./scripts/check-lab-prereqs.sh 8
EOF
}

require_lab_number() {
    local lab="$1"
    if [[ -z "$lab" ]]; then
        log_error "No lab number supplied."
        usage
        exit 1
    fi
    if ! [[ "$lab" =~ ^[0-9]+$ ]] || (( lab < 1 || lab > 12 )); then
        log_error "Lab number must be between 1 and 12."
        exit 1
    fi
}

check_command() {
    local cmd="$1"
    if command -v "$cmd" >/dev/null 2>&1; then
        log_success "Found command: $cmd"
        return 0
    fi
    log_error "Missing command: $cmd"
    return 1
}

check_path() {
    local path="$1"
    local friendly="$2"
    if [[ -e "$ROOT_DIR/$path" ]]; then
        log_success "Found ${friendly:-$path}"
        return 0
    fi
    log_error "Missing ${friendly:-$path}"
    return 1
}

check_optional_path() {
    local path="$1"
    local friendly="$2"
    if [[ -e "$ROOT_DIR/$path" ]]; then
        log_success "Found ${friendly:-$path}"
    else
        log_warn "Optional path missing: ${friendly:-$path}"
    fi
}

check_manifest_bundle() {
    local lab="$1"
    local dir="labs/manifests/lab-$(printf "%02d" "$lab")"
    if [[ -d "$ROOT_DIR/$dir" ]]; then
        log_success "Lab manifest overlay available at $dir"
    else
        log_warn "Manifest overlay $dir not found."
    fi
}

run_checks_for_lab() {
    local lab="$1"
    log_header "${LAB_TITLES[$lab]}"

    local missing=0

    # Base requirement
    check_command kubectl || missing=1

    case "$lab" in
        1)
            check_path "weather-app/k8s" "Weather app manifests" || missing=1
            ;;
        2)
            check_path "ecommerce-app/k8s" "E-commerce manifests" || missing=1
            ;;
        3)
            check_path "educational-platform/k8s" "Educational platform manifests" || missing=1
            ;;
        4)
            check_path "labs/04-kubernetes-fundamentals.md" "Lab 4 instructions" || missing=1
            ;;
        5)
            check_path "task-management-app/k8s" "Task manager manifests" || missing=1
            ;;
        6)
            check_path "medical-care-system/k8s" "Medical system manifests" || missing=1
            ;;
        7)
            check_command helm || missing=1
            check_path "social-media-platform/k8s" "Social media manifests" || missing=1
            ;;
        8)
            check_command helm || missing=1
            check_path "weather-app/k8s" "Weather app manifests" || missing=1
            check_path "ecommerce-app/k8s" "E-commerce manifests" || missing=1
            check_path "educational-platform/k8s" "Educational manifests" || missing=1
            check_path "task-management-app/k8s" "Task manager manifests" || missing=1
            check_path "medical-care-system/k8s" "Medical manifests" || missing=1
            check_path "social-media-platform/k8s" "Social manifests" || missing=1
            check_optional_path "shared-k8s" "Shared Kubernetes add-ons" 
            ;;
        9)
            check_command helm || missing=1
            check_path "social-media-platform/k8s" "Social media manifests" || missing=1
            ;;
        10)
            check_command helm || missing=1
            check_optional_path "gitops-configs" "GitOps configuration workspace"
            check_optional_path "labs/manifests/lab-10" "Lab 10 manifest overlay"
            ;;
        11)
            check_command helm || log_warn "Helm is optional but recommended for ArgoCD install"
            check_command git || missing=1
            check_optional_path "gitops-configs" "GitOps configuration workspace"
            ;;
        12)
            check_command helm || missing=1
            check_command aws || log_warn "AWS CLI is optional (only for AWS provider)"
            check_optional_path "labs/manifests/lab-12" "Lab 12 manifest overlay"
            ;;
    esac

    check_manifest_bundle "$lab"

    if [[ "$missing" -eq 0 ]]; then
        log_header "✅ All prerequisites satisfied — you're ready to start!"
        exit 0
    else
        log_header "❌ Missing prerequisites detected"
        exit 1
    fi
}

main() {
    if [[ $# -lt 1 ]]; then
        usage
        exit 1
    fi
    require_lab_number "$1"
    run_checks_for_lab "$1"
}

main "$@"
