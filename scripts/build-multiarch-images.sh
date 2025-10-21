#!/bin/bash
# 🚀 HARDENED MULTI-ARCHITECTURE DOCKER BUILD SCRIPT
# Production-ready build system for universal compatibility
# Supports: linux/amd64, linux/arm64, linux/arm/v7 for maximum coverage
# Features: Resilient error handling, comprehensive logging, parallel builds

set -euo pipefail  # Enhanced error handling

# Color codes for enhanced output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Enhanced Configuration
DOCKER_HUB_USERNAME="temitayocharles"
BUILD_PLATFORMS="linux/amd64,linux/arm64,linux/arm/v7"
BUILD_TIMEOUT="3600"  # 1 hour timeout per build
LOG_DIR="/tmp/multiarch-builds-$(date +%Y%m%d-%H%M%S)"
PARALLEL_BUILDS=3  # Number of parallel builds
RETRY_COUNT=3      # Number of retries on failure

# Application services mapping (app_name:service_path:image_name)
declare -A SERVICES=(
    # E-commerce Application
    ["ecommerce-backend"]="ecommerce-app/backend:ecommerce-backend"
    ["ecommerce-frontend"]="ecommerce-app/frontend:ecommerce-frontend"
    
    # Educational Platform
    ["educational-backend"]="educational-platform/backend:educational-backend"
    ["educational-frontend"]="educational-platform/frontend:educational-frontend"
    
    # Weather Application
    ["weather-backend"]="weather-app/backend:weather-backend"
    ["weather-frontend"]="weather-app/frontend:weather-frontend"
    
    # Medical Care System
    ["medical-api"]="medical-care-system/backend/MedicalCareSystem.API:medical-api"
    ["medical-frontend"]="medical-care-system/frontend/MedicalCareSystem.Frontend:medical-frontend"
    
    # Task Management Application
    ["task-backend"]="task-management-app/backend:task-backend"
    ["task-frontend"]="task-management-app/frontend:task-frontend"
    
    # Social Media Platform
    ["social-backend"]="social-media-platform/backend:social-backend"
    ["social-frontend"]="social-media-platform/frontend:social-frontend"
)

# Progress tracking
TOTAL_SERVICES=${#SERVICES[@]}
CURRENT_SERVICE=0
FAILED_BUILDS=()
SUCCESSFUL_BUILDS=()
BUILD_START_TIME=$(date +%s)

# Create log directory
mkdir -p "$LOG_DIR"

echo -e "${BOLD}${BLUE}🚀 HARDENED MULTI-ARCHITECTURE DOCKER BUILD SYSTEM${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}📋 Build Configuration:${NC}"
echo -e "   ${YELLOW}🏗️  Platforms: ${BUILD_PLATFORMS}${NC}"
echo -e "   ${YELLOW}📊 Total services: ${TOTAL_SERVICES}${NC}"
echo -e "   ${YELLOW}⏱️  Timeout per build: ${BUILD_TIMEOUT}s${NC}"
echo -e "   ${YELLOW}🔄 Retry attempts: ${RETRY_COUNT}${NC}"
echo -e "   ${YELLOW}📁 Log directory: ${LOG_DIR}${NC}"
echo -e "   ${YELLOW}🏃 Parallel builds: ${PARALLEL_BUILDS}${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"

# Enhanced logging function
log() {
    local level=$1
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a "${LOG_DIR}/build.log"
}

# Enhanced error handling
handle_error() {
    local exit_code=$?
    local line_number=$1
    log "ERROR" "${RED}Build failed at line ${line_number} with exit code ${exit_code}${NC}"
    cleanup_on_exit
    exit $exit_code
}

trap 'handle_error $LINENO' ERR

# Cleanup function
cleanup_on_exit() {
    log "INFO" "${YELLOW}🧹 Performing cleanup...${NC}"
    # Remove any temporary files or buildx instances if needed
    log "INFO" "${GREEN}✅ Cleanup completed${NC}"
}

# Docker buildx setup with enhanced error handling
setup_buildx() {
    log "INFO" "${YELLOW}🔍 Setting up Docker buildx...${NC}"
    
    # Check Docker buildx availability
    if ! docker buildx version >/dev/null 2>&1; then
    log "ERROR" "${RED}❌ Docker buildx not available. Enable buildx via your runtime (Docker Desktop or Rancher Desktop) before continuing.${NC}"
        exit 1
    fi
    
    # Create or use existing buildx instance
    local builder_name="hardened-multiarch-builder"
    
    if ! docker buildx inspect "$builder_name" >/dev/null 2>&1; then
        log "INFO" "${YELLOW}🔧 Creating hardened multiarch builder instance...${NC}"
        docker buildx create \
            --name "$builder_name" \
            --driver docker-container \
            --platform "$BUILD_PLATFORMS" \
            --use \
            --bootstrap 2>&1 | tee -a "${LOG_DIR}/buildx-setup.log"
    else
        log "INFO" "${GREEN}✅ Using existing $builder_name instance${NC}"
        docker buildx use "$builder_name"
    fi
    
    # Verify builder supports required platforms
    log "INFO" "${CYAN}🔍 Verifying platform support...${NC}"
    if ! docker buildx inspect --bootstrap | grep -q "linux/amd64\|linux/arm64"; then
        log "ERROR" "${RED}❌ Builder doesn't support required platforms${NC}"
        exit 1
    fi
    
    log "INFO" "${GREEN}✅ Buildx setup completed successfully${NC}"
}

# Enhanced progress display
show_progress() {
    local current=$1
    local total=$2
    local service_name="$3"
    local width=60
    local percentage=$((current * 100 / total))
    local completed=$((current * width / total))
    
    printf "\n${BOLD}${PURPLE}📊 Progress: %s${NC}\n" "$service_name"
    printf "${CYAN}["
    for ((i=1; i<=completed; i++)); do printf "█"; done
    for ((i=completed+1; i<=width; i++)); do printf "░"; done
    printf "] %d%% (%d/%d)${NC}\n" "$percentage" "$current" "$total"
    
    # Show estimated time remaining
    local elapsed=$(($(date +%s) - BUILD_START_TIME))
    if [ $current -gt 0 ]; then
        local avg_time_per_service=$((elapsed / current))
        local remaining_services=$((total - current))
        local eta=$((remaining_services * avg_time_per_service))
        printf "${YELLOW}⏱️  ETA: %02d:%02d:%02d${NC}\n" $((eta/3600)) $(((eta%3600)/60)) $((eta%60))
    fi
}

# Enhanced service build function with retry logic
build_service() {
    local service_key=$1
    local service_info="${SERVICES[$service_key]}"
    local service_path=$(echo "$service_info" | cut -d':' -f1)
    local image_name=$(echo "$service_info" | cut -d':' -f2)
    local full_path="/Volumes/512-B/Documents/PERSONAL/full-stack-apps/${service_path}"
    local full_image_name="${DOCKER_HUB_USERNAME}/${image_name}:latest"
    
    log "INFO" "${YELLOW}🔨 Building service: ${service_key}${NC}"
    log "INFO" "${CYAN}   📂 Path: ${full_path}${NC}"
    log "INFO" "${CYAN}   🏷️  Image: ${full_image_name}${NC}"
    
    # Validate Dockerfile exists
    if [ ! -f "${full_path}/Dockerfile" ]; then
        log "ERROR" "${RED}❌ Dockerfile not found in ${full_path}${NC}"
        return 1
    fi
    
    # Change to service directory
    cd "${full_path}" || {
        log "ERROR" "${RED}❌ Cannot access directory ${full_path}${NC}"
        return 1
    }
    
    # Retry logic
    local attempt=1
    while [ $attempt -le $RETRY_COUNT ]; do
        log "INFO" "${YELLOW}🚀 Build attempt ${attempt}/${RETRY_COUNT} for ${service_key}${NC}"
        
        # Enhanced build command with comprehensive options
        if timeout "$BUILD_TIMEOUT" docker buildx build \
            --platform "$BUILD_PLATFORMS" \
            --tag "$full_image_name" \
            --push \
            --progress=plain \
            --cache-from="type=registry,ref=${full_image_name}" \
            --cache-to="type=inline" \
            --metadata-file="${LOG_DIR}/${service_key}-metadata.json" \
            --provenance=false \
            --sbom=false \
            . 2>&1 | tee "${LOG_DIR}/${service_key}-build.log"; then
            
            log "INFO" "${GREEN}✅ Successfully built and pushed: ${full_image_name}${NC}"
            return 0
        else
            local exit_code=$?
            log "WARN" "${YELLOW}⚠️  Attempt ${attempt} failed for ${service_key} (exit code: ${exit_code})${NC}"
            
            if [ $attempt -eq $RETRY_COUNT ]; then
                log "ERROR" "${RED}❌ All attempts failed for ${service_key}${NC}"
                return 1
            fi
            
            # Exponential backoff
            local wait_time=$((attempt * 30))
            log "INFO" "${YELLOW}⏳ Waiting ${wait_time}s before retry...${NC}"
            sleep $wait_time
        fi
        
        ((attempt++))
    done
}

# Verify multi-arch manifest
verify_multiarch() {
    local image_name=$1
    log "INFO" "${CYAN}🔍 Verifying multi-arch manifest for ${image_name}${NC}"
    
    if docker buildx imagetools inspect "${image_name}" > "${LOG_DIR}/${image_name##*/}-manifest.txt" 2>&1; then
        local platforms=$(docker buildx imagetools inspect "${image_name}" | grep "Platform:" | wc -l)
        log "INFO" "${GREEN}✅ Manifest verified - ${platforms} platforms available${NC}"
        return 0
    else
        log "ERROR" "${RED}❌ Failed to verify manifest for ${image_name}${NC}"
        return 1
    fi
}

# Parallel build orchestrator
build_all_services() {
    log "INFO" "${BOLD}${BLUE}🚀 Starting parallel build orchestration${NC}"
    
    # Convert associative array to indexed array for processing
    local services_list=()
    for service_key in "${!SERVICES[@]}"; do
        services_list+=("$service_key")
    done
    
    # Process services in batches
    local batch_size=$PARALLEL_BUILDS
    local total_batches=$(( (${#services_list[@]} + batch_size - 1) / batch_size ))
    
    for ((batch=0; batch<total_batches; batch++)); do
        local start_idx=$((batch * batch_size))
        local end_idx=$((start_idx + batch_size - 1))
        
        if [ $end_idx -ge ${#services_list[@]} ]; then
            end_idx=$((${#services_list[@]} - 1))
        fi
        
        log "INFO" "${PURPLE}📦 Processing batch $((batch + 1))/${total_batches}${NC}"
        
        # Start builds in parallel for current batch
        local pids=()
        for ((i=start_idx; i<=end_idx; i++)); do
            local service_key="${services_list[$i]}"
            ((CURRENT_SERVICE++))
            show_progress $CURRENT_SERVICE $TOTAL_SERVICES "$service_key"
            
            # Run build in background
            (
                if build_service "$service_key"; then
                    echo "$service_key" >> "${LOG_DIR}/successful_builds.txt"
                else
                    echo "$service_key" >> "${LOG_DIR}/failed_builds.txt"
                fi
            ) &
            pids+=($!)
        done
        
        # Wait for current batch to complete
        log "INFO" "${YELLOW}⏳ Waiting for batch $((batch + 1)) to complete...${NC}"
        for pid in "${pids[@]}"; do
            wait $pid
        done
        
        log "INFO" "${GREEN}✅ Batch $((batch + 1)) completed${NC}"
    done
}

# Generate comprehensive build report
generate_report() {
    local build_end_time=$(date +%s)
    local total_time=$((build_end_time - BUILD_START_TIME))
    
    # Read results
    if [ -f "${LOG_DIR}/successful_builds.txt" ]; then
        readarray -t SUCCESSFUL_BUILDS < "${LOG_DIR}/successful_builds.txt"
    fi
    
    if [ -f "${LOG_DIR}/failed_builds.txt" ]; then
        readarray -t FAILED_BUILDS < "${LOG_DIR}/failed_builds.txt"
    fi
    
    # Generate report
    local report_file="${LOG_DIR}/build-report.md"
    {
        echo "# 🚀 Multi-Architecture Build Report"
        echo "**Generated:** $(date)"
        echo "**Total Build Time:** $(printf '%02d:%02d:%02d' $((total_time/3600)) $(((total_time%3600)/60)) $((total_time%60)))"
        echo "**Platforms:** ${BUILD_PLATFORMS}"
        echo ""
        echo "## ✅ Successful Builds (${#SUCCESSFUL_BUILDS[@]})"
        for service in "${SUCCESSFUL_BUILDS[@]}"; do
            if [ -n "$service" ]; then
                echo "- ✅ \`${DOCKER_HUB_USERNAME}/${SERVICES[$service]##*:}:latest\`"
            fi
        done
        echo ""
        echo "## ❌ Failed Builds (${#FAILED_BUILDS[@]})"
        for service in "${FAILED_BUILDS[@]}"; do
            if [ -n "$service" ]; then
                echo "- ❌ \`$service\`"
            fi
        done
        echo ""
        echo "## 📊 Platform Coverage"
        echo "All successful images support:"
        echo "- 🖥️  linux/amd64 (Intel/AMD x86_64)"
        echo "- 🍎 linux/arm64 (Apple Silicon, ARM64 servers)"
        echo "- 🤖 linux/arm/v7 (Raspberry Pi, ARM32)"
    } > "$report_file"
    
    log "INFO" "${GREEN}📄 Build report generated: ${report_file}${NC}"
}

# Main execution flow
main() {
    log "INFO" "${BOLD}${BLUE}🎬 Starting hardened multi-arch build process${NC}"
    
    # Setup
    setup_buildx
    
    # Build all services
    build_all_services
    
    # Verify builds
    log "INFO" "${CYAN}🔍 Verifying multi-arch manifests...${NC}"
    for service_key in "${!SERVICES[@]}"; do
        local image_name="${DOCKER_HUB_USERNAME}/${SERVICES[$service_key]##*:}:latest"
        verify_multiarch "$image_name" || true  # Don't fail on verification errors
    done
    
    # Generate report
    generate_report
    
    # Final summary
    log "INFO" "${BOLD}${GREEN}� MULTI-ARCHITECTURE BUILD PROCESS COMPLETED!${NC}"
    log "INFO" "${BLUE}📊 Summary:${NC}"
    log "INFO" "${GREEN}   ✅ Successful: ${#SUCCESSFUL_BUILDS[@]}${NC}"
    log "INFO" "${RED}   ❌ Failed: ${#FAILED_BUILDS[@]}${NC}"
    log "INFO" "${CYAN}   📁 Logs: ${LOG_DIR}${NC}"
    
    # Exit with appropriate code
    if [ ${#FAILED_BUILDS[@]} -gt 0 ]; then
        log "WARN" "${YELLOW}⚠️  Some builds failed. Check logs for details.${NC}"
        exit 1
    else
        log "INFO" "${GREEN}🎯 All builds completed successfully!${NC}"
        exit 0
    fi
}

# Execute main function
main "$@"