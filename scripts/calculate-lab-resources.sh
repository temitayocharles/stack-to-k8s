#!/usr/bin/env bash

# Resource Calculator for Kubernetes Labs
# Calculates total CPU, memory, disk, and pod requirements for custom lab combinations
# Usage: ./scripts/calculate-lab-resources.sh [lab numbers...]
# Example: ./scripts/calculate-lab-resources.sh 1 2 3

set -euo pipefail

# Colors for output
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# Lab resource definitions (in millicores for CPU, Mi for memory)
declare -A LAB_CPU_REQUEST LAB_CPU_LIMIT LAB_MEMORY_REQUEST LAB_MEMORY_LIMIT LAB_PODS LAB_DISK LAB_NAME

# Lab 1: Weather App
LAB_NAME[1]="Weather App (Basics)"
LAB_CPU_REQUEST[1]=300
LAB_CPU_LIMIT[1]=1450
LAB_MEMORY_REQUEST[1]=384
LAB_MEMORY_LIMIT[1]=1536
LAB_PODS[1]=4
LAB_DISK[1]=200

# Lab 2: E-commerce
LAB_NAME[2]="E-commerce (Multi-Service)"
LAB_CPU_REQUEST[2]=650
LAB_CPU_LIMIT[2]=3200
LAB_MEMORY_REQUEST[2]=832
LAB_MEMORY_LIMIT[2]=3328
LAB_PODS[2]=7
LAB_DISK[2]=500

# Lab 3: Educational Platform
LAB_NAME[3]="Educational Platform (Stateful)"
LAB_CPU_REQUEST[3]=1400
LAB_CPU_LIMIT[3]=5500
LAB_MEMORY_REQUEST[3]=1433
LAB_MEMORY_LIMIT[3]=5632
LAB_PODS[3]=5
LAB_DISK[3]=800

# Lab 4: Task Manager
LAB_NAME[4]="Task Manager (Ingress)"
LAB_CPU_REQUEST[4]=650
LAB_CPU_LIMIT[4]=2750
LAB_MEMORY_REQUEST[4]=730
LAB_MEMORY_LIMIT[4]=2662
LAB_PODS[4]=5
LAB_DISK[4]=600

# Lab 5: Medical System
LAB_NAME[5]="Medical System (Security)"
LAB_CPU_REQUEST[5]=1000
LAB_CPU_LIMIT[5]=5000
LAB_MEMORY_REQUEST[5]=1310
LAB_MEMORY_LIMIT[5]=5120
LAB_PODS[5]=5
LAB_DISK[5]=1000

# Lab 6: Social Media (min config)
LAB_NAME[6]="Social Media (Autoscaling Min)"
LAB_CPU_REQUEST[6]=900
LAB_CPU_LIMIT[6]=3400
LAB_MEMORY_REQUEST[6]=1187
LAB_MEMORY_LIMIT[6]=4505
LAB_PODS[6]=8
LAB_DISK[6]=1200

# Lab 7: Multi-App (aggregate)
LAB_NAME[7]="Multi-App Orchestration"
LAB_CPU_REQUEST[7]=4750
LAB_CPU_LIMIT[7]=20800
LAB_MEMORY_REQUEST[7]=5795
LAB_MEMORY_LIMIT[7]=22528
LAB_PODS[7]=33
LAB_DISK[7]=5000

# Lab 8: Chaos Engineering
LAB_NAME[8]="Chaos Engineering"
LAB_CPU_REQUEST[8]=1800
LAB_CPU_LIMIT[8]=6400
LAB_MEMORY_REQUEST[8]=2089
LAB_MEMORY_LIMIT[8]=7577
LAB_PODS[8]=12
LAB_DISK[8]=1500

# Lab 9: Helm
LAB_NAME[9]="Helm Package Management"
LAB_CPU_REQUEST[9]=300
LAB_CPU_LIMIT[9]=1450
LAB_MEMORY_REQUEST[9]=384
LAB_MEMORY_LIMIT[9]=1536
LAB_PODS[9]=4
LAB_DISK[9]=200

# Lab 10: GitOps
LAB_NAME[10]="GitOps with ArgoCD"
LAB_CPU_REQUEST[10]=1050
LAB_CPU_LIMIT[10]=3450
LAB_MEMORY_REQUEST[10]=1177
LAB_MEMORY_LIMIT[10]=3584
LAB_PODS[10]=7
LAB_DISK[10]=800

# Lab 11: External Secrets
LAB_NAME[11]="External Secrets Operator"
LAB_CPU_REQUEST[11]=1000
LAB_CPU_LIMIT[11]=3900
LAB_MEMORY_REQUEST[11]=1248
LAB_MEMORY_LIMIT[11]=4096
LAB_PODS[11]=8
LAB_DISK[11]=700

# Lab 12: Fundamentals
LAB_NAME[12]="Kubernetes Fundamentals"
LAB_CPU_REQUEST[12]=500
LAB_CPU_LIMIT[12]=2000
LAB_MEMORY_REQUEST[12]=512
LAB_MEMORY_LIMIT[12]=2048
LAB_PODS[12]=10
LAB_DISK[12]=300

# Helper functions
print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

format_cpu() {
    local millicores=$1
    if [ "$millicores" -ge 1000 ]; then
        echo "$(awk "BEGIN {printf \"%.2f\", $millicores/1000}") CPU"
    else
        echo "${millicores}m CPU"
    fi
}

format_memory() {
    local megabytes=$1
    if [ "$megabytes" -ge 1024 ]; then
        echo "$(awk "BEGIN {printf \"%.2f\", $megabytes/1024}") Gi"
    else
        echo "${megabytes} Mi"
    fi
}

format_disk() {
    local megabytes=$1
    if [ "$megabytes" -ge 1024 ]; then
        echo "$(awk "BEGIN {printf \"%.2f\", $megabytes/1024}") GB"
    else
        echo "${megabytes} MB"
    fi
}

# Usage information
show_usage() {
    cat << EOF
${GREEN}Kubernetes Labs Resource Calculator${NC}

${YELLOW}Usage:${NC}
  ./scripts/calculate-lab-resources.sh [OPTIONS] [LAB_NUMBERS...]

${YELLOW}Options:${NC}
  -h, --help          Show this help message
  -a, --all           Calculate resources for all labs (1-12)
  -l, --list          List available labs with their names
  -v, --verbose       Show detailed per-lab breakdown

${YELLOW}Examples:${NC}
  # Calculate resources for Labs 1, 2, and 3
  ./scripts/calculate-lab-resources.sh 1 2 3

  # Calculate resources for all labs
  ./scripts/calculate-lab-resources.sh --all

  # Show detailed breakdown
  ./scripts/calculate-lab-resources.sh -v 1 2 3

  # List available labs
  ./scripts/calculate-lab-resources.sh --list

${YELLOW}Lab Numbers:${NC}
  1  - Weather App (Basics)
  2  - E-commerce (Multi-Service)
  3  - Educational Platform (Stateful)
  4  - Task Manager (Ingress)
  5  - Medical System (Security)
  6  - Social Media (Autoscaling)
  7  - Multi-App Orchestration
  8  - Chaos Engineering
  9  - Helm Package Management
  10 - GitOps with ArgoCD
  11 - External Secrets Operator
  12 - Kubernetes Fundamentals

${YELLOW}Note:${NC}
  - Lab 7 (Multi-App) includes resources from Labs 1-6 combined
  - Lab 6 (Social Media) shows minimum autoscaling configuration
  - Resources are calculated for default configurations

EOF
}

# List available labs
list_labs() {
    print_header "Available Labs"
    for i in {1..12}; do
        printf "  ${GREEN}%2d${NC} - %s\n" "$i" "${LAB_NAME[$i]}"
    done
    echo ""
}

# Calculate total resources
calculate_resources() {
    local labs=("$@")
    local total_cpu_request=0
    local total_cpu_limit=0
    local total_memory_request=0
    local total_memory_limit=0
    local total_pods=0
    local total_disk=0
    local verbose=false

    # Check for verbose flag
    if [[ " ${labs[@]} " =~ " -v " ]] || [[ " ${labs[@]} " =~ " --verbose " ]]; then
        verbose=true
        # Remove verbose flag from labs array
        labs=("${labs[@]/-v/}")
        labs=("${labs[@]/--verbose/}")
    fi

    # Validate lab numbers
    local valid_labs=()
    for lab in "${labs[@]}"; do
        if [[ ! "$lab" =~ ^[0-9]+$ ]]; then
            continue
        fi
        if [ "$lab" -lt 1 ] || [ "$lab" -gt 12 ]; then
            echo -e "${RED}Error: Lab $lab is invalid. Labs must be between 1 and 12.${NC}" >&2
            exit 1
        fi
        valid_labs+=("$lab")
    done

    if [ "${#valid_labs[@]}" -eq 0 ]; then
        echo -e "${RED}Error: No valid lab numbers provided.${NC}" >&2
        show_usage
        exit 1
    fi

    print_header "Resource Calculation for Labs: ${valid_labs[*]}"

    # Calculate totals
    for lab in "${valid_labs[@]}"; do
        if [ "$verbose" = true ]; then
            echo -e "${YELLOW}Lab $lab: ${LAB_NAME[$lab]}${NC}"
            echo "  CPU Request:    $(format_cpu ${LAB_CPU_REQUEST[$lab]})"
            echo "  CPU Limit:      $(format_cpu ${LAB_CPU_LIMIT[$lab]})"
            echo "  Memory Request: $(format_memory ${LAB_MEMORY_REQUEST[$lab]})"
            echo "  Memory Limit:   $(format_memory ${LAB_MEMORY_LIMIT[$lab]})"
            echo "  Pods:           ${LAB_PODS[$lab]}"
            echo "  Disk:           $(format_disk ${LAB_DISK[$lab]})"
            echo ""
        fi

        total_cpu_request=$((total_cpu_request + LAB_CPU_REQUEST[$lab]))
        total_cpu_limit=$((total_cpu_limit + LAB_CPU_LIMIT[$lab]))
        total_memory_request=$((total_memory_request + LAB_MEMORY_REQUEST[$lab]))
        total_memory_limit=$((total_memory_limit + LAB_MEMORY_LIMIT[$lab]))
        total_pods=$((total_pods + LAB_PODS[$lab]))
        total_disk=$((total_disk + LAB_DISK[$lab]))
    done

    # Display totals
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    TOTAL RESOURCES                         ║${NC}"
    echo -e "${GREEN}╠════════════════════════════════════════════════════════════╣${NC}"
    printf "${GREEN}║${NC} CPU Request:    %-42s ${GREEN}║${NC}\n" "$(format_cpu $total_cpu_request)"
    printf "${GREEN}║${NC} CPU Limit:      %-42s ${GREEN}║${NC}\n" "$(format_cpu $total_cpu_limit)"
    printf "${GREEN}║${NC} Memory Request: %-42s ${GREEN}║${NC}\n" "$(format_memory $total_memory_request)"
    printf "${GREEN}║${NC} Memory Limit:   %-42s ${GREEN}║${NC}\n" "$(format_memory $total_memory_limit)"
    printf "${GREEN}║${NC} Total Pods:     %-42s ${GREEN}║${NC}\n" "$total_pods"
    printf "${GREEN}║${NC} Disk Space:     %-42s ${GREEN}║${NC}\n" "$(format_disk $total_disk)"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"

    # Recommendations
    echo ""
    print_header "Cluster Recommendations"

    local min_cpu=$((total_cpu_limit / 1000 + 1))
    local min_memory=$((total_memory_limit / 1024 + 1))
    local min_disk=$((total_disk / 1024 + 1))

    echo -e "${YELLOW}Minimum Cluster Requirements:${NC}"
    echo "  • CPU:    ${min_cpu} cores (${total_cpu_limit}m limits)"
    echo "  • Memory: ${min_memory} GB ($(format_memory $total_memory_limit) limits)"
    echo "  • Disk:   ${min_disk} GB (for container images)"
    echo "  • Pods:   ${total_pods} (check node pod limit)"
    echo ""

    local rec_cpu=$((min_cpu * 2))
    local rec_memory=$((min_memory * 2))
    local rec_disk=$((min_disk * 3))

    echo -e "${GREEN}Recommended Cluster (with headroom):${NC}"
    echo "  • CPU:    ${rec_cpu} cores"
    echo "  • Memory: ${rec_memory} GB"
    echo "  • Disk:   ${rec_disk} GB"
    echo ""

    # Check if this fits on common machines
    echo -e "${BLUE}Will this fit on my machine?${NC}"
    if [ "$min_cpu" -le 4 ] && [ "$min_memory" -le 8 ]; then
        echo -e "  ${GREEN}✅ YES${NC} - Can run on MacBook Pro M1/M2 (8GB RAM)"
        echo -e "  ${GREEN}✅ YES${NC} - Can run on standard dev laptop (4 cores, 8GB RAM)"
    elif [ "$min_cpu" -le 8 ] && [ "$min_memory" -le 16 ]; then
        echo -e "  ${YELLOW}⚠️  MAYBE${NC} - Needs MacBook Pro M1/M2 (16GB RAM)"
        echo -e "  ${YELLOW}⚠️  MAYBE${NC} - Needs desktop/laptop with 8 cores, 16GB RAM"
    else
        echo -e "  ${RED}❌ NO${NC} - Requires high-end workstation or cloud cluster"
        echo -e "  ${YELLOW}💡 TIP${NC} - Run labs sequentially instead of concurrently"
    fi
    echo ""

    # Cloud comparison (optional)
    if [ "$min_cpu" -ge 8 ] || [ "$min_memory" -ge 16 ]; then
        echo -e "${BLUE}Cloud Instance Recommendations:${NC}"
        local nodes=$(( (min_cpu + 3) / 4 ))  # Round up to nearest 4-core node
        echo "  • AWS EKS:   ${nodes}x t3.xlarge (4 vCPU, 16GB) ≈ \$$(awk "BEGIN {printf \"%.0f\", $nodes * 0.67 * 730}")/month"
        echo "  • GCP GKE:   ${nodes}x n1-standard-4 (4 vCPU, 15GB) ≈ \$$(awk "BEGIN {printf \"%.0f\", $nodes * 0.62 * 730}")/month"
        echo "  • Azure AKS: ${nodes}x Standard_D4s_v3 (4 vCPU, 16GB) ≈ \$$(awk "BEGIN {printf \"%.0f\", $nodes * 0.68 * 730}")/month"
        echo ""
        echo -e "  ${GREEN}💰 Local Cluster: FREE!${NC} (Rancher Desktop, kind, k3d)"
        echo ""
    fi

    # Port conflict warnings
    if [[ " ${valid_labs[@]} " =~ " 7 " ]] || [ "${#valid_labs[@]}" -ge 4 ]; then
        echo -e "${YELLOW}⚠️  PORT CONFLICT WARNING:${NC}"
        echo "  Running multiple labs simultaneously may cause port conflicts."
        echo "  Solutions:"
        echo "    1. Use different local ports: kubectl port-forward ... 8081:80"
        echo "    2. Use Ingress instead of port-forward (Lab 4)"
        echo "    3. Run labs sequentially, cleaning up between labs"
        echo ""
        echo "  See docs/reference/resource-requirements.md for port allocation matrix"
        echo ""
    fi

    # Link to detailed guide
    echo -e "${BLUE}📚 For detailed breakdown and optimization tips:${NC}"
    echo "   docs/reference/resource-requirements.md"
    echo ""
}

# Main script logic
main() {
    if [ $# -eq 0 ]; then
        show_usage
        exit 1
    fi

    case "$1" in
        -h|--help)
            show_usage
            exit 0
            ;;
        -l|--list)
            list_labs
            exit 0
            ;;
        -a|--all)
            shift
            calculate_resources "$@" {1..12}
            ;;
        *)
            calculate_resources "$@"
            ;;
    esac
}

main "$@"
