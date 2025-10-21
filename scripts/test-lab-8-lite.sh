#!/usr/bin/env bash

# Lab 8 Lite Automated Validation Test
# For CI/CD pipelines to validate Lab 8 Lite deployments on constrained environments
# Usage: ./scripts/test-lab-8-lite.sh [namespace]
# Exit codes: 0=success, 1=failure, 2=warnings

set -euo pipefail

# Configuration
readonly SCRIPT_NAME="$(basename "${0}")"
readonly NAMESPACE="${1:-lab-8-lite-test}"
readonly TIMEOUT_SECONDS=300
readonly MAX_CPU="1000"    # millicores (1 CPU = 1000m)
readonly MAX_MEMORY="2000" # MiB

# Colors
readonly GREEN="\033[0;32m"
readonly RED="\033[0;31m"
readonly YELLOW="\033[1;33m"
readonly BLUE="\033[0;34m"
readonly NC="\033[0m"

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_WARNED=0

# =============================================================================
# LOGGING FUNCTIONS
# =============================================================================
log_header() {
    echo -e "\n${BLUE}${BOLD}═══════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $*${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}\n"
}

log_test() {
    echo -e "${BLUE}▶ TEST: $*${NC}"
}

log_pass() {
    echo -e "${GREEN}✅ PASS: $*${NC}"
    ((TESTS_PASSED++))
}

log_fail() {
    echo -e "${RED}❌ FAIL: $*${NC}"
    ((TESTS_FAILED++))
}

log_warn() {
    echo -e "${YELLOW}⚠️  WARN: $*${NC}"
    ((TESTS_WARNED++))
}

log_info() {
    echo -e "${BLUE}ℹ️  $*${NC}"
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================
cleanup() {
    echo ""
    log_header "Cleanup"
    
    if kubectl get namespace "${NAMESPACE}" >/dev/null 2>&1; then
        log_info "Deleting test namespace: ${NAMESPACE}"
        kubectl delete namespace "${NAMESPACE}" --wait=true >/dev/null 2>&1 || true
    fi
}

trap cleanup EXIT

wait_for_pods() {
    local namespace="$1"
    local expected_running="$2"
    local wait_time=0
    
    while [ $wait_time -lt $TIMEOUT_SECONDS ]; do
        local running
        running=$(kubectl get pods -n "${namespace}" --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
        
        if [ "$running" -ge "$expected_running" ]; then
            return 0
        fi
        
        sleep 5
        ((wait_time += 5))
        echo -n "."
    done
    
    return 1
}

# =============================================================================
# TEST FUNCTIONS
# =============================================================================

test_cluster_ready() {
    log_test "Cluster is accessible and ready"
    
    if ! kubectl cluster-info >/dev/null 2>&1; then
        log_fail "Cluster not accessible"
        return 1
    fi
    
    if ! kubectl get nodes | grep -q "Ready"; then
        log_fail "No ready nodes found"
        return 1
    fi
    
    log_pass "Cluster accessible with ready nodes"
    return 0
}

test_namespace_creation() {
    log_test "Create test namespace"
    
    if kubectl create namespace "${NAMESPACE}" 2>/dev/null; then
        log_pass "Namespace created: ${NAMESPACE}"
        return 0
    else
        log_fail "Failed to create namespace"
        return 1
    fi
}

test_app_deployment() {
    log_test "Deploy Lab 8 Lite apps (Weather, E-commerce, Task Manager)"
    
    local failed=0
    
    # Weather App
    if kubectl apply -f weather-app/k8s/ -n "${NAMESPACE}" >/dev/null 2>&1; then
        log_pass "Weather app deployed"
    else
        log_fail "Weather app deployment failed"
        ((failed++))
    fi
    
    # E-commerce App
    if kubectl apply -f ecommerce-app/k8s/ -n "${NAMESPACE}" >/dev/null 2>&1; then
        log_pass "E-commerce app deployed"
    else
        log_fail "E-commerce app deployment failed"
        ((failed++))
    fi
    
    # Task Manager App
    if kubectl apply -f task-management-app/k8s/ -n "${NAMESPACE}" >/dev/null 2>&1; then
        log_pass "Task Manager app deployed"
    else
        log_fail "Task Manager app deployment failed"
        ((failed++))
    fi
    
    return $failed
}

test_pods_running() {
    log_test "Wait for all pods to reach Running state"
    
    log_info "Waiting for pods to initialize (max ${TIMEOUT_SECONDS}s)..."
    
    if wait_for_pods "${NAMESPACE}" 6; then
        local running
        running=$(kubectl get pods -n "${NAMESPACE}" --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
        log_pass "All pods running (${running} pods)"
        return 0
    else
        local running
        running=$(kubectl get pods -n "${NAMESPACE}" --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
        log_fail "Not all pods reached Running state (${running} running)"
        
        # Show pod status
        echo ""
        log_info "Pod status:"
        kubectl get pods -n "${NAMESPACE}" | sed 's/^/  /'
        
        return 1
    fi
}

test_services_exist() {
    log_test "Verify services are created"
    
    local services
    services=$(kubectl get svc -n "${NAMESPACE}" --no-headers 2>/dev/null | wc -l)
    
    if [ "$services" -gt 0 ]; then
        log_pass "Services created (${services} services found)"
        return 0
    else
        log_fail "No services found"
        return 1
    fi
}

test_pod_health() {
    log_test "Check pod health (no restarts, no errors)"
    
    local unhealthy
    unhealthy=$(kubectl get pods -n "${NAMESPACE}" \
        -o jsonpath='{.items[?(@.status.containerStatuses[0].restartCount>0)].metadata.name}' 2>/dev/null | wc -w)
    
    if [ "$unhealthy" -eq 0 ]; then
        log_pass "All pods healthy (no restarts)"
        return 0
    else
        log_warn "Some pods have restarts (${unhealthy} pods)"
        kubectl get pods -n "${NAMESPACE}" | grep -E "NAME|Restart" | sed 's/^/  /'
        return 1
    fi
}

test_resource_usage() {
    log_test "Verify resource usage is within limits"
    
    # Check if metrics are available
    if ! kubectl top pods -n "${NAMESPACE}" >/dev/null 2>&1; then
        log_warn "Metrics server not available, skipping resource check"
        return 0
    fi
    
    local total_cpu=0
    local total_memory=0
    
    # Sum up CPU usage
    total_cpu=$(kubectl top pods -n "${NAMESPACE}" --no-headers 2>/dev/null | \
        awk '{gsub(/m$/, "", $2); sum += $2} END {print sum}' || echo "0")
    
    # Sum up memory usage
    total_memory=$(kubectl top pods -n "${NAMESPACE}" --no-headers 2>/dev/null | \
        awk '{gsub(/Mi$/, "", $3); sum += $3} END {print sum}' || echo "0")
    
    if [ "$total_cpu" -le "$MAX_CPU" ] && [ "$total_memory" -le "$MAX_MEMORY" ]; then
        log_pass "Resource usage acceptable (CPU: ${total_cpu}m, Memory: ${total_memory}Mi)"
        return 0
    else
        log_warn "Resource usage higher than expected (CPU: ${total_cpu}m/${MAX_CPU}m, Memory: ${total_memory}Mi/${MAX_MEMORY}Mi)"
        return 1
    fi
}

test_network_connectivity() {
    log_test "Test inter-pod communication"
    
    # Get a pod name
    local test_pod
    test_pod=$(kubectl get pods -n "${NAMESPACE}" -o name | head -1 | cut -d'/' -f2)
    
    if [ -z "$test_pod" ]; then
        log_fail "No pods found for connectivity test"
        return 1
    fi
    
    # Try to resolve a service
    if kubectl exec -it -n "${NAMESPACE}" "pod/${test_pod}" -- \
        sh -c "nslookup kubernetes.default.svc.cluster.local >/dev/null 2>&1"; then
        log_pass "DNS resolution working (pod can reach cluster DNS)"
        return 0
    else
        log_fail "DNS resolution failed"
        return 1
    fi
}

test_scaling() {
    log_test "Test horizontal scaling (scale to 2 replicas)"
    
    # Scale a deployment
    if kubectl scale deployment --all -n "${NAMESPACE}" --replicas=2 >/dev/null 2>&1; then
        log_pass "Scaling command successful"
        
        # Wait for new pods
        if wait_for_pods "${NAMESPACE}" 12; then
            log_pass "New pods started successfully after scaling"
            return 0
        else
            log_warn "Scaling didn't create expected number of pods"
            return 1
        fi
    else
        log_fail "Failed to scale deployments"
        return 1
    fi
}

test_pod_recovery() {
    log_test "Test self-healing (delete pod and verify recreation)"
    
    # Find and delete a pod
    local pod_to_delete
    pod_to_delete=$(kubectl get pods -n "${NAMESPACE}" -o name | head -1 | cut -d'/' -f2)
    
    if [ -z "$pod_to_delete" ]; then
        log_fail "No pods found to test recovery"
        return 1
    fi
    
    local initial_creation_time
    initial_creation_time=$(kubectl get pod "${pod_to_delete}" -n "${NAMESPACE}" \
        -o jsonpath='{.metadata.creationTimestamp}')
    
    # Delete the pod
    kubectl delete pod "${pod_to_delete}" -n "${NAMESPACE}" >/dev/null 2>&1
    
    # Wait for replacement
    sleep 2
    
    local new_pod_created=0
    for i in {1..30}; do
        local new_creation_time
        new_creation_time=$(kubectl get pods -n "${NAMESPACE}" -o jsonpath=\
            "{.items[?(@.status.phase=='Running')].metadata.creationTimestamp}" | head -1)
        
        if [ "$new_creation_time" != "$initial_creation_time" ]; then
            new_pod_created=1
            break
        fi
        
        sleep 1
    done
    
    if [ $new_pod_created -eq 1 ]; then
        log_pass "Pod self-healing verified (new pod created)"
        return 0
    else
        log_fail "Pod was not recreated after deletion"
        return 1
    fi
}

test_no_evictions() {
    log_test "Check for pod evictions or resource issues"
    
    local events
    events=$(kubectl get events -n "${NAMESPACE}" 2>/dev/null | grep -E "Evicted|OOMKilled" | wc -l)
    
    if [ "$events" -eq 0 ]; then
        log_pass "No evictions or OOM kills detected"
        return 0
    else
        log_fail "Found ${events} eviction/OOM events"
        kubectl get events -n "${NAMESPACE}" | grep -E "Evicted|OOMKilled" | sed 's/^/  /'
        return 1
    fi
}

# =============================================================================
# MAIN TEST EXECUTION
# =============================================================================
main() {
    log_header "Lab 8 Lite Automated Validation Test"
    
    log_info "Testing namespace: ${NAMESPACE}"
    log_info "Timeout: ${TIMEOUT_SECONDS}s"
    log_info "Max CPU: ${MAX_CPU}m"
    log_info "Max Memory: ${MAX_MEMORY}Mi"
    
    echo ""
    
    # Run all tests
    local test_failed=0
    
    test_cluster_ready || ((test_failed++))
    test_namespace_creation || ((test_failed++))
    test_app_deployment || ((test_failed++))
    test_pods_running || ((test_failed++))
    test_services_exist || ((test_failed++))
    test_pod_health || ((test_failed++))
    test_resource_usage || ((test_failed++))
    test_network_connectivity || ((test_failed++))
    test_scaling || ((test_failed++))
    test_pod_recovery || ((test_failed++))
    test_no_evictions || ((test_failed++))
    
    # Summary
    log_header "Test Summary"
    
    echo -e "${GREEN}✅ Passed:  ${TESTS_PASSED}${NC}"
    echo -e "${RED}❌ Failed:  ${TESTS_FAILED}${NC}"
    echo -e "${YELLOW}⚠️  Warned:  ${TESTS_WARNED}${NC}"
    echo ""
    
    local total=$((TESTS_PASSED + TESTS_FAILED + TESTS_WARNED))
    echo -e "${BLUE}📊 Total:   ${total}${NC}"
    
    if [ ${TESTS_FAILED} -eq 0 ]; then
        echo ""
        echo -e "${GREEN}${BOLD}✅ All tests passed!${NC}"
        echo -e "${GREEN}Lab 8 Lite is ready for use on this system${NC}"
        return 0
    else
        echo ""
        echo -e "${RED}${BOLD}❌ Some tests failed${NC}"
        echo -e "${RED}Review output above for details${NC}"
        return 1
    fi
}

main "$@"
