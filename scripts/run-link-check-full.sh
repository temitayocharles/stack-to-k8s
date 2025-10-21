#!/usr/bin/env bash
# Enhanced repo-wide markdown link checker with comprehensive validation
set -uo pipefail

# =============================================================================
# CONFIGURATION & GLOBALS
# =============================================================================
readonly SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly INDEX="${ROOT}/docs/00-introduction/MARKDOWN-INDEX.md"
readonly OUT="${ROOT}/scripts/validate-links.full-report.txt"

# Terminal colors
readonly GREEN="\033[0;32m"
readonly RED="\033[0;31m"
readonly YELLOW="\033[1;33m"
readonly BLUE="\033[0;34m"
readonly BOLD="\033[1m"
readonly NC="\033[0m"

# Exit codes
readonly EXIT_SUCCESS=0
readonly EXIT_INVALID_ARGS=1
readonly EXIT_MISSING_DEPS=2
readonly EXIT_MISSING_FILES=3

# =============================================================================
# CLEANUP & ERROR HANDLING
# =============================================================================
cleanup() {
    rm -f /tmp/_md_list.txt 2>/dev/null || true
}

trap cleanup EXIT INT TERM

# =============================================================================
# LOGGING FUNCTIONS
# =============================================================================
log_info() {
    echo -e "${BLUE}ℹ️  $*${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $*${NC}"
}

log_error() {
    echo -e "${RED}❌ $*${NC}" >&2
}

log_warn() {
    echo -e "${YELLOW}⚠️  $*${NC}"
}

# =============================================================================
# INPUT VALIDATION
# =============================================================================
show_usage() {
    cat <<EOF
${BOLD}Usage:${NC} ${SCRIPT_NAME} [OPTIONS]

${BOLD}DESCRIPTION:${NC}
    Comprehensive markdown link validation across the entire repository.
    Checks all markdown files listed in MARKDOWN-INDEX.md for broken links.

${BOLD}OPTIONS:${NC}
    -h, --help      Show this help message and exit
    -v, --verbose   Enable verbose output
    --dry-run       Show files to be checked without running validation

${BOLD}EXAMPLES:${NC}
    ${SCRIPT_NAME}              # Run full link validation
    ${SCRIPT_NAME} --verbose    # Run with detailed output
    ${SCRIPT_NAME} --dry-run    # Preview files to be checked

${BOLD}EXIT CODES:${NC}
    0  All links are valid
    1  Invalid arguments or usage
    2  Missing required dependencies
    3  Missing required files or validation failed

${BOLD}OUTPUT:${NC}
    Results are written to: ${OUT##*/}
EOF
}

parse_arguments() {
    local verbose=false
    local dry_run=false
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_usage
                exit ${EXIT_SUCCESS}
                ;;
            -v|--verbose)
                verbose=true
                set -x  # Enable debug mode
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            -*)
                log_error "Unknown option: $1"
                show_usage
                return ${EXIT_INVALID_ARGS}
                ;;
            *)
                log_error "Unexpected argument: $1"
                log_error "This script does not accept positional arguments"
                show_usage
                return ${EXIT_INVALID_ARGS}
                ;;
        esac
    done
    
    export VERBOSE="${verbose}"
    export DRY_RUN="${dry_run}"
    return ${EXIT_SUCCESS}
}

# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================
validate_environment() {
    log_info "Validating environment..."
    
    # Check if we're in the correct repository structure
    if [[ ! -d "${ROOT}/docs" ]] || [[ ! -d "${ROOT}/labs" ]]; then
        log_error "Invalid repository structure"
        log_error "Missing docs/ or labs/ directories in ${ROOT}"
        return ${EXIT_MISSING_FILES}
    fi
    
    # Check for markdown index file
    if [[ ! -f "${INDEX}" ]]; then
        log_error "MARKDOWN-INDEX.md not found at ${INDEX}"
        return ${EXIT_MISSING_FILES}
    fi
    
    # Check for Node.js/npx (required for markdown-link-check)
    if ! command -v npx >/dev/null 2>&1; then
        log_error "npx not found - Node.js is required"
        log_error "Please install Node.js to run markdown-link-check"
        return ${EXIT_MISSING_DEPS}
    fi
    
    log_success "Environment validation passed"
    return ${EXIT_SUCCESS}
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================
main() {
    log_info "Starting comprehensive markdown link validation"
    
    # Initialize output file
    rm -f "${OUT}"
    echo "Full link check run: $(date -u)" > "${OUT}"
    echo "Repository: ${ROOT}" >> "${OUT}"
    echo "Index source: ${INDEX}" >> "${OUT}"
    echo "" >> "${OUT}"

    # Extract markdown file paths from index
    log_info "Extracting markdown file list from ${INDEX##*/}"
    grep -E '`[^`]+\.md`' "${INDEX}" | sed -n "s/.*\`\([^\`]*\.md\)\`.*/\1/p" > /tmp/_md_list.txt
    
    local file_count
    file_count=$(wc -l < /tmp/_md_list.txt)
    
    if [[ ${file_count} -eq 0 ]]; then
        log_error "No markdown files found in ${INDEX}"
        return ${EXIT_MISSING_FILES}
    fi
    
    log_info "Found ${file_count} markdown files to validate"
    
    # Handle dry run mode
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_info "Dry run mode - showing files that would be checked:"
        while IFS= read -r path; do
            local abs="${ROOT}/${path}"
            if [[ -f "${abs}" ]]; then
                echo "  ✓ ${path}"
            else
                echo "  ✗ ${path} (MISSING)"
            fi
        done < /tmp/_md_list.txt
        return ${EXIT_SUCCESS}
    fi
    
    # Process each markdown file
    local files_processed=0
    local files_failed=0
    
    while IFS= read -r path; do
        ((files_processed++))
        log_info "Processing (${files_processed}/${file_count}): ${path}"
        
    echo "=== FILE: ${path} ===" >> "${OUT}"
        
        local abs="${ROOT}/${path}"
        if [[ ! -f "${abs}" ]]; then
            log_warn "Missing file: ${path}"
            echo "MISSING_FILE: ${path}" | tee -a "${OUT}"
            echo >> "${OUT}"
            ((files_failed++))
            continue
        fi

        # Run markdown-link-check with config if it exists
        local config_args=""
        if [[ -f "${ROOT}/.github/markdown-link-check.json" ]]; then
            config_args="-c .github/markdown-link-check.json"
        fi
        
    # Change to root directory for relative path resolution
    # Capture exit code for each file without aborting the script
    (cd "${ROOT}" && npx --yes markdown-link-check "${path}" ${config_args}) >> "${OUT}" 2>&1
    local rc=$?
        
        if [[ ${rc} -eq 0 ]]; then
            echo "RESULT: OK" >> "${OUT}"
            if [[ "${VERBOSE:-false}" == "true" ]]; then
                log_success "✓ ${path}"
            fi
        else
            echo "RESULT: FAIL (exit ${rc})" >> "${OUT}"
            log_warn "✗ ${path} - validation failed"
            ((files_failed++))
        fi
        echo >> "${OUT}"
    done < /tmp/_md_list.txt

    # Summary
    echo "" >> "${OUT}"
    echo "=== SUMMARY ===" >> "${OUT}"
    echo "Files processed: ${files_processed}" >> "${OUT}"
    echo "Files failed: ${files_failed}" >> "${OUT}"
    echo "Validation completed: $(date -u)" >> "${OUT}"
    
    log_info "Validation complete: ${files_processed} files processed, ${files_failed} failed"
    log_success "Full report written to ${OUT}"
    
    if [[ ${files_failed} -gt 0 ]]; then
        log_warn "Some files had validation errors - check ${OUT##*/} for details"
        exit ${EXIT_MISSING_FILES}
    fi

    exit ${EXIT_SUCCESS}
}

# =============================================================================
# SCRIPT EXECUTION
# =============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_arguments "$@" || exit $?
    validate_environment || exit $?
    main
    exit $?
fi
