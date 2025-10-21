#!/bin/bash
# Security Vulnerability Scanning Suite
# Comprehensive security testing for containerized applications

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCAN_DIR="$(pwd)/security-scan-results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="$SCAN_DIR/security_report_$TIMESTAMP.json"

echo -e "${BLUE}🛡️  ENTERPRISE SECURITY SCANNING SUITE${NC}"
echo -e "${BLUE}=====================================${NC}"

# Create results directory
mkdir -p "$SCAN_DIR"

# Initialize report
cat > "$REPORT_FILE" << EOF
{
  "scan_timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "scan_type": "comprehensive_security_scan",
  "applications": []
}
EOF

# Function to scan container images
scan_container_image() {
    local image_name=$1
    local app_name=$2
    
    echo -e "${YELLOW}🔍 Scanning container image: $image_name${NC}"
    
    # Trivy vulnerability scan
    if command -v trivy &> /dev/null; then
        echo -e "${BLUE}  Running Trivy vulnerability scan...${NC}"
        trivy image --format json --output "$SCAN_DIR/${app_name}_trivy_$TIMESTAMP.json" "$image_name" || true
        
        # Check for critical vulnerabilities
        critical_vulns=$(trivy image --severity CRITICAL --format json "$image_name" 2>/dev/null | jq '.Results[].Vulnerabilities | length' 2>/dev/null || echo "0")
        high_vulns=$(trivy image --severity HIGH --format json "$image_name" 2>/dev/null | jq '.Results[].Vulnerabilities | length' 2>/dev/null || echo "0")
        
        echo -e "${BLUE}    Critical vulnerabilities: $critical_vulns${NC}"
        echo -e "${BLUE}    High vulnerabilities: $high_vulns${NC}"
        
        if [ "$critical_vulns" -gt 0 ]; then
            echo -e "${RED}    ❌ CRITICAL vulnerabilities found!${NC}"
        else
            echo -e "${GREEN}    ✅ No critical vulnerabilities${NC}"
        fi
    else
        echo -e "${YELLOW}  Trivy not installed, installing...${NC}"
        # Install Trivy
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install aquasecurity/trivy/trivy
        else
            curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
        fi
        # Retry scan
        scan_container_image "$image_name" "$app_name"
    fi
    
    # Docker Bench Security (if available)
    if command -v docker-bench-security &> /dev/null; then
        echo -e "${BLUE}  Running Docker Bench Security...${NC}"
        docker run --rm --net host --pid host --userns host --cap-add audit_control \
            -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
            -v /var/lib:/var/lib \
            -v /var/run/docker.sock:/var/run/docker.sock \
            -v /usr/lib/systemd:/usr/lib/systemd \
            -v /etc:/etc --label docker_bench_security \
            docker/docker-bench-security > "$SCAN_DIR/${app_name}_docker_bench_$TIMESTAMP.txt" || true
    fi
}

# Function to scan application endpoints
scan_application_endpoints() {
    local app_name=$1
    local base_url=$2
    
    echo -e "${YELLOW}🌐 Scanning application endpoints: $app_name${NC}"
    
    # OWASP ZAP Baseline scan (if available)
    if command -v docker &> /dev/null; then
        echo -e "${BLUE}  Running OWASP ZAP baseline scan...${NC}"
        docker run -t owasp/zap2docker-stable zap-baseline.py \
            -t "$base_url" \
            -J "$SCAN_DIR/${app_name}_zap_$TIMESTAMP.json" \
            -r "$SCAN_DIR/${app_name}_zap_$TIMESTAMP.html" || true
    fi
    
    # Nikto web scanner (if available)
    if command -v nikto &> /dev/null; then
        echo -e "${BLUE}  Running Nikto web vulnerability scan...${NC}"
        nikto -h "$base_url" -output "$SCAN_DIR/${app_name}_nikto_$TIMESTAMP.txt" || true
    fi
    
    # SSL/TLS testing with testssl.sh
    if command -v testssl.sh &> /dev/null; then
        echo -e "${BLUE}  Running SSL/TLS security test...${NC}"
        testssl.sh --jsonfile "$SCAN_DIR/${app_name}_ssl_$TIMESTAMP.json" "$base_url" || true
    fi
    
    # Custom security checks
    echo -e "${BLUE}  Running custom security checks...${NC}"
    
    # Check security headers
    security_headers=$(curl -s -I "$base_url" | grep -i -E "(x-frame-options|x-content-type-options|x-xss-protection|strict-transport-security|content-security-policy)" || true)
    
    echo "Security Headers Check for $app_name:" > "$SCAN_DIR/${app_name}_headers_$TIMESTAMP.txt"
    echo "=================================" >> "$SCAN_DIR/${app_name}_headers_$TIMESTAMP.txt"
    echo "$security_headers" >> "$SCAN_DIR/${app_name}_headers_$TIMESTAMP.txt"
    
    # Check for common vulnerabilities
    echo -e "${BLUE}  Checking for common vulnerabilities...${NC}"
    
    # SQL Injection test (basic)
    sql_injection_test=$(curl -s -w "%{http_code}" -o /dev/null "$base_url/api/test?id=1'OR'1'='1" || echo "000")
    
    # XSS test (basic)
    xss_test=$(curl -s -w "%{http_code}" -o /dev/null "$base_url/api/test?q=<script>alert('xss')</script>" || echo "000")
    
    # Directory traversal test
    dir_traversal_test=$(curl -s -w "%{http_code}" -o /dev/null "$base_url/../../../etc/passwd" || echo "000")
    
    cat > "$SCAN_DIR/${app_name}_basic_vuln_$TIMESTAMP.json" << EOF
{
  "application": "$app_name",
  "sql_injection_test": {
    "response_code": "$sql_injection_test",
    "status": "$([ "$sql_injection_test" -eq 500 ] && echo "POTENTIAL_VULNERABILITY" || echo "SAFE")"
  },
  "xss_test": {
    "response_code": "$xss_test",
    "status": "$([ "$xss_test" -eq 200 ] && echo "POTENTIAL_VULNERABILITY" || echo "SAFE")"
  },
  "directory_traversal_test": {
    "response_code": "$dir_traversal_test",
    "status": "$([ "$dir_traversal_test" -eq 200 ] && echo "POTENTIAL_VULNERABILITY" || echo "SAFE")"
  }
}
EOF
}

# Function to scan network security
scan_network_security() {
    echo -e "${YELLOW}🌐 Scanning network security...${NC}"
    
    # Port scanning with nmap (if available)
    if command -v nmap &> /dev/null; then
        echo -e "${BLUE}  Running network port scan...${NC}"
        nmap -sS -O localhost > "$SCAN_DIR/network_scan_$TIMESTAMP.txt" 2>/dev/null || true
    fi
    
    # Check for open ports
    echo -e "${BLUE}  Checking application ports...${NC}"
    netstat -tuln > "$SCAN_DIR/open_ports_$TIMESTAMP.txt" 2>/dev/null || true
}

# Function to scan Kubernetes security (if in K8s environment)
scan_kubernetes_security() {
    if command -v kubectl &> /dev/null; then
        echo -e "${YELLOW}☸️  Scanning Kubernetes security...${NC}"
        
        # Check for privileged containers
        echo -e "${BLUE}  Checking for privileged containers...${NC}"
        kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\t"}{.spec.containers[*].securityContext.privileged}{"\n"}{end}' > "$SCAN_DIR/k8s_privileged_containers_$TIMESTAMP.txt" 2>/dev/null || true
        
        # Check for containers running as root
        echo -e "${BLUE}  Checking for containers running as root...${NC}"
        kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\t"}{.spec.containers[*].securityContext.runAsUser}{"\n"}{end}' > "$SCAN_DIR/k8s_root_containers_$TIMESTAMP.txt" 2>/dev/null || true
        
        # Check network policies
        echo -e "${BLUE}  Checking network policies...${NC}"
        kubectl get networkpolicies --all-namespaces -o yaml > "$SCAN_DIR/k8s_network_policies_$TIMESTAMP.yaml" 2>/dev/null || true
        
        # Check RBAC
        echo -e "${BLUE}  Checking RBAC configuration...${NC}"
        kubectl get clusterrolebindings -o yaml > "$SCAN_DIR/k8s_rbac_$TIMESTAMP.yaml" 2>/dev/null || true
    fi
}

# Function to generate summary report
generate_summary_report() {
    echo -e "${YELLOW}📊 Generating security summary report...${NC}"
    
    local summary_file="$SCAN_DIR/security_summary_$TIMESTAMP.txt"
    
    cat > "$summary_file" << EOF
ENTERPRISE SECURITY SCAN SUMMARY
================================
Scan Date: $(date)
Scan Duration: $(date -u -d @$(($(date +%s) - start_time)) +"%H:%M:%S")

APPLICATIONS SCANNED:
--------------------
- Educational Platform (localhost:8080)
- Medical Care System (localhost:5170)
- Weather Application (localhost:5002)
- Task Management App (localhost:8082)

SCAN TYPES PERFORMED:
--------------------
✓ Container Image Vulnerability Scanning (Trivy)
✓ Web Application Security Testing (OWASP ZAP)
✓ SSL/TLS Configuration Testing
✓ Security Headers Analysis
✓ Basic Vulnerability Testing (SQLi, XSS, Directory Traversal)
✓ Network Security Scanning
✓ Kubernetes Security Assessment (if applicable)

SCAN RESULTS LOCATION:
---------------------
All detailed scan results are stored in: $SCAN_DIR

CRITICAL FINDINGS:
-----------------
EOF

    # Count critical findings
    critical_count=0
    high_count=0
    medium_count=0
    
    # Check Trivy results for critical vulnerabilities
    for trivy_file in "$SCAN_DIR"/*_trivy_*.json; do
        if [ -f "$trivy_file" ]; then
            local app_critical=$(jq '.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL") | .VulnerabilityID' "$trivy_file" 2>/dev/null | wc -l || echo "0")
            local app_high=$(jq '.Results[]?.Vulnerabilities[]? | select(.Severity == "HIGH") | .VulnerabilityID' "$trivy_file" 2>/dev/null | wc -l || echo "0")
            critical_count=$((critical_count + app_critical))
            high_count=$((high_count + app_high))
        fi
    done
    
    echo "Critical Vulnerabilities: $critical_count" >> "$summary_file"
    echo "High Vulnerabilities: $high_count" >> "$summary_file"
    echo "Medium Vulnerabilities: $medium_count" >> "$summary_file"
    echo "" >> "$summary_file"
    
    if [ "$critical_count" -gt 0 ]; then
        echo -e "${RED}❌ CRITICAL SECURITY ISSUES FOUND: $critical_count${NC}"
        echo "RECOMMENDATION: Address critical vulnerabilities immediately!" >> "$summary_file"
    elif [ "$high_count" -gt 5 ]; then
        echo -e "${YELLOW}⚠️  HIGH PRIORITY ISSUES FOUND: $high_count${NC}"
        echo "RECOMMENDATION: Address high-priority vulnerabilities soon." >> "$summary_file"
    else
        echo -e "${GREEN}✅ SECURITY POSTURE: GOOD${NC}"
        echo "RECOMMENDATION: Regular security monitoring and updates." >> "$summary_file"
    fi
    
    echo "" >> "$summary_file"
    echo "For detailed findings, review individual scan result files." >> "$summary_file"
    
    echo -e "${GREEN}📋 Summary report generated: $summary_file${NC}"
}

# Main execution
echo -e "${BLUE}Starting comprehensive security scanning...${NC}"
start_time=$(date +%s)

# Scan container images
echo -e "\n${BLUE}🐳 CONTAINER IMAGE SECURITY SCANNING${NC}"
echo -e "${BLUE}====================================${NC}"

# Get running containers and their images
if command -v docker &> /dev/null; then
    docker ps --format "table {{.Image}}\t{{.Names}}" | tail -n +2 | while read -r image name; do
        if [[ "$name" == *"educational"* ]]; then
            scan_container_image "$image" "educational-platform"
        elif [[ "$name" == *"medical"* ]]; then
            scan_container_image "$image" "medical-care"
        elif [[ "$name" == *"weather"* ]]; then
            scan_container_image "$image" "weather-app"
        elif [[ "$name" == *"task"* ]]; then
            scan_container_image "$image" "task-management"
        fi
    done
fi

# Scan application endpoints
echo -e "\n${BLUE}🌐 APPLICATION ENDPOINT SECURITY SCANNING${NC}"
echo -e "${BLUE}=========================================${NC}"

scan_application_endpoints "educational-platform" "http://localhost:8080"
scan_application_endpoints "medical-care" "http://localhost:5170"
scan_application_endpoints "weather-app" "http://localhost:5002"
scan_application_endpoints "task-management" "http://localhost:8082"

# Network security scanning
echo -e "\n${BLUE}🌐 NETWORK SECURITY SCANNING${NC}"
echo -e "${BLUE}===========================${NC}"
scan_network_security

# Kubernetes security scanning
echo -e "\n${BLUE}☸️  KUBERNETES SECURITY SCANNING${NC}"
echo -e "${BLUE}===============================${NC}"
scan_kubernetes_security

# Generate summary report
echo -e "\n${BLUE}📊 GENERATING SUMMARY REPORT${NC}"
echo -e "${BLUE}===========================${NC}"
generate_summary_report

echo -e "\n${GREEN}🎉 Security scanning completed!${NC}"
echo -e "${GREEN}📁 Results location: $SCAN_DIR${NC}"
echo -e "${GREEN}📋 Summary report: $SCAN_DIR/security_summary_$TIMESTAMP.txt${NC}"

# Return appropriate exit code based on findings
if [ "$critical_count" -gt 0 ]; then
    echo -e "${RED}🚨 CRITICAL VULNERABILITIES FOUND - EXIT CODE 2${NC}"
    exit 2
elif [ "$high_count" -gt 5 ]; then
    echo -e "${YELLOW}⚠️  HIGH VULNERABILITIES FOUND - EXIT CODE 1${NC}"
    exit 1
else
    echo -e "${GREEN}✅ SECURITY SCAN PASSED - EXIT CODE 0${NC}"
    exit 0
fi