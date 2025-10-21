---
title: "Production Network Operations Guide"
level: "intermediate-to-advanced"
type: "deep-dive"
prerequisites: ["Lab 5: Ingress", "Lab 6: Security", "Basic networking knowledge"]
topics: ["DNS Debugging", "Service Discovery", "Network Policies", "Ingress Troubleshooting", "Latency Analysis"]
estimated_time: "45-60 minutes"
updated: "2025-10-21"
nav_prev: "./storage-operations.md"
nav_next: null
---

# 🌐 Production Network Operations: DNS, Discovery & Troubleshooting

Network issues in Kubernetes can be mystifying. This guide demystifies service discovery, DNS resolution, and network debugging to get your apps talking to each other.

---

## 📋 Quick Navigation

- [Service Discovery Fundamentals](#service-discovery-fundamentals)
- [DNS Resolution Debugging](#dns-resolution-debugging)
- [Service Endpoints Troubleshooting](#service-endpoints-troubleshooting)
- [Network Policies & Connectivity](#network-policies--connectivity)
- [Ingress Debugging](#ingress-debugging-external-access)
- [Latency Analysis](#latency-analysis-diagnosing-slowness)
- [Common Network Failures](#common-network-failures--solutions)

---

## 🔍 Service Discovery Fundamentals

### How Service Discovery Works

```
┌─────────────────────────────────────────┐
│ Your Pod (e.g., webapp)                 │
│ Tries: curl http://api-service:8080     │
└──────────────┬──────────────────────────┘
               │
               ├─→ DNS Query: "api-service.production.svc.cluster.local?"
               │
               ├─→ CoreDNS Pod (listening on 10.96.0.10:53)
               │   Resolves to Service IP: 10.102.45.67
               │
               ├─→ kube-proxy (on node) 
               │   Routes Service IP → Pod IPs
               │
               └─→ Traffic hits api-service pod on 192.168.1.15:8080
```

### Service DNS Names

```
Service:           my-api
Namespace:         production
Full DNS name:     my-api.production.svc.cluster.local
```

**FQDN Format**:
- `<service>.<namespace>.svc.cluster.local` — Full name (always works)
- `<service>.<namespace>` — Works within same cluster
- `<service>` — Works only within same namespace

---

## 🐛 DNS Resolution Debugging

### Quick DNS Test

```bash
# From inside a pod, test DNS
kubectl exec -it <pod-name> -n <namespace> -- nslookup api-service

# Expected output:
# Server: 10.96.0.10
# Address: 10.96.0.10#53
# 
# Name: api-service.production.svc.cluster.local
# Address: 10.102.45.67
```

### Common DNS Issues

**Issue 1: DNS Timeout**

```bash
# Test DNS resolution
kubectl exec <pod> -- nslookup api-service
# Error: dial tcp 10.96.0.10:53: i/o timeout

# Diagnosis steps:
# 1. Check if CoreDNS is running
kubectl get pods -n kube-system | grep coredns

# 2. Check CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns -f

# 3. Verify DNS service exists
kubectl get svc -n kube-system -l k8s-app=kube-dns

# Solution: Restart CoreDNS
kubectl rollout restart deployment/coredns -n kube-system
```

**Issue 2: Service Not Resolving**

```bash
# Problem: nslookup returns NXDOMAIN (not found)
kubectl exec <pod> -- nslookup nonexistent-service
# Error: NXDOMAIN

# Check the service actually exists
kubectl get svc nonexistent-service

# Correct the name and try with full FQDN
kubectl exec <pod> -- nslookup existing-service.production.svc.cluster.local

# If full FQDN works but short name doesn't:
# Check namespace; must be same namespace to use short name
```

**Issue 3: Slow DNS Resolution**

```bash
# Time DNS query
kubectl exec <pod> -- time nslookup api-service

# If slow (>100ms), investigate CoreDNS:
# 1. Check CoreDNS CPU/memory
kubectl top pod -n kube-system -l k8s-app=kube-dns

# 2. Check CoreDNS logs for errors
kubectl logs -n kube-system -l k8s-app=kube-dns | grep -i error

# 3. Scale up CoreDNS if needed
kubectl scale deployment coredns -n kube-system --replicas=3
```

### Debugging DNS Cache Issues

```bash
# Clear DNS cache (if app pod caches DNS)
kubectl exec <pod> -- rm /etc/resolv.conf  # Only if your app caches

# Check resolv.conf
kubectl exec <pod> -- cat /etc/resolv.conf
# Should show:
# search production.svc.cluster.local svc.cluster.local cluster.local
# nameserver 10.96.0.10

# Test with explicit nameserver
kubectl exec <pod> -- nslookup -server=10.96.0.10 api-service
```

---

## 📍 Service Endpoints Troubleshooting

### Understanding Endpoints

```bash
# Service routes traffic to its endpoints (pod IPs)
kubectl get endpoints api-service -n production

# Expected output:
# NAME            ENDPOINTS                  AGE
# api-service     192.168.1.15:8080,...     5d
```

### Common Endpoints Issues

**Issue: Service Has No Endpoints**

```bash
# Service exists but shows empty endpoints
kubectl get endpoints api-service
# NAME            ENDPOINTS   AGE
# api-service     <none>      5m

# Troubleshoot:
# 1. Check if selector matches any pods
kubectl get pods --selector=app=api-service

# 2. If no pods, deployment may have 0 replicas
kubectl describe deployment api-service
# Look for "Replicas: 0 desired, 0 updated"

# 3. If pods exist, check they're running and ready
kubectl get pods -l app=api-service -o wide
# STATUS should be "Running", READY should be "1/1"

# 4. If pods aren't ready, check pod logs
kubectl logs <pod-name> --previous  # If restarting
kubectl logs <pod-name>              # Current logs
```

**Issue: Pods in Endpoints but Not Receiving Traffic**

```bash
# Endpoints show pods, but traffic isn't reaching them
# Check if pod has the right label
kubectl get pods <pod-name> --show-labels

# Must have label matching service selector:
# kubectl get svc api-service -o yaml | grep selector

# If pod label is wrong, fix it:
kubectl label pods <pod-name> app=api-service --overwrite

# Verify endpoint updated
kubectl get endpoints api-service
```

### Testing Service Connectivity

```bash
# From one pod, test connection to service
kubectl exec -it <source-pod> -- /bin/sh

# Inside the pod:
# 1. Test DNS resolves
nslookup api-service

# 2. Test TCP connection
nc -zv api-service 8080
# or
curl -v http://api-service:8080/health

# 3. If connection refused, service might not be listening
# Check target pod logs:
kubectl logs <target-pod>
```

---

## 🛡️ Network Policies & Connectivity

### Default Network Policy (No Restrictions)

```yaml
# By default, all pods can talk to all pods
# No network policy = open network
```

### Restricting Traffic (Deny All First)

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: production
spec:
  podSelector: {}  # Applies to all pods
  policyTypes:
  - Ingress
# No ingress rules = all ingress traffic denied
```

### Allowing Specific Traffic

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-api-from-web
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: api-service
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: web-frontend
    ports:
    - protocol: TCP
      port: 8080
```

### Debugging Network Policy Blocks

```bash
# If traffic is blocked by network policy, you'll see:
# - Connection timeout or refused
# - Curl: "Connection refused" or hangs

# Check what policies apply to a pod
kubectl describe pod <pod-name> -n <namespace>
# (Shows pod labels that policies match against)

# List all network policies in namespace
kubectl get networkpolicy -n production

# Describe specific policy to see rules
kubectl describe networkpolicy allow-api-from-web -n production

# Test connectivity through a pod:
# From web pod, try to reach api
kubectl exec <web-pod> -- curl -v http://api-service:8080

# If blocked:
# 1. Verify pods have correct labels
kubectl get pods --show-labels
#   web pod should have: app=web-frontend
#   api pod should have: app=api-service

# 2. Verify network policy allows the traffic
kubectl get networkpolicy allow-api-from-web -o yaml

# 3. Test with explicit allow-all policy (temporary):
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-all-ingress-test
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - {}  # Allow all
EOF

# If traffic works with allow-all, network policy was the issue
```

### Cross-Namespace Traffic

```yaml
# Allow traffic from different namespace
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-other-ns
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: api-service
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: monitoring  # From monitoring namespace
    ports:
    - protocol: TCP
      port: 8080
```

---

## 🌐 Ingress Debugging: External Access

### Quick Ingress Test

```bash
# 1. Check if ingress is deployed
kubectl get ingress -n production

# 2. Get ingress details
kubectl describe ingress app-ingress -n production

# 3. Get ingress IP/hostname
kubectl get ingress app-ingress -n production -o wide
# HOSTS                  ADDRESS          PORTS
# app.example.com        192.168.1.100    80, 443

# 4. Test external access
curl -H "Host: app.example.com" http://192.168.1.100
```

### Common Ingress Issues

**Issue: Ingress Pending (No IP)**

```bash
# Ingress shows <pending> address
kubectl get ingress
# NAME           HOSTS             ADDRESS        PORTS
# app-ingress    app.example.com   <pending>      80

# Cause: No Ingress Controller running
# Solution: Install NGINX Ingress Controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace

# Verify:
kubectl get pods -n ingress-nginx  # Should see ingress-nginx-controller pod
kubectl get ingress  # ADDRESS should now be populated
```

**Issue: 502 Bad Gateway**

```bash
# Browser shows: "502 Bad Gateway"
# Ingress is running but can't reach backend

# Debug steps:
# 1. Check ingress backend is correct
kubectl get ingress app-ingress -o yaml | grep backend

# 2. Verify service exists
kubectl get svc <service-name>

# 3. Verify service has endpoints
kubectl get endpoints <service-name>

# 4. Verify pods are ready
kubectl get pods -l app=<app-name>
# STATUS should be Running, READY should be 1/1

# 5. Check pod logs for errors
kubectl logs <pod-name>

# 6. Test from ingress controller pod directly:
kubectl exec -it -n ingress-nginx <ingress-pod> -- \
  curl http://<service-name>.<namespace>:8080
```

**Issue: Hostname Not Resolving**

```bash
# Browser says "Cannot resolve app.example.com"

# Check:
# 1. DNS is actually pointing to ingress IP
nslookup app.example.com
# Should return: 192.168.1.100 (ingress IP)

# 2. If not, update DNS:
# AWS Route53, GCP Cloud DNS, etc.
# Point A record to ingress IP

# 3. Test with IP directly:
curl -H "Host: app.example.com" http://192.168.1.100
# If this works, DNS was the issue

# 4. Wait for DNS cache to clear (TTL usually 5 min)
```

---

## ⚡ Latency Analysis: Diagnosing Slowness

### Measuring Network Latency

```bash
# From one pod to another, measure latency:
kubectl exec <source-pod> -- ping -c 4 <target-service>

# Measure HTTP request time:
kubectl exec <source-pod> -- time curl http://api-service:8080/api/users

# Measure with curl timing:
kubectl exec <source-pod> -- curl -w "
  Total: %{time_total}s
  Connect: %{time_connect}s
  Lookup: %{time_namelookup}s
  TTFB: %{time_starttransfer}s
\n" http://api-service:8080
```

### Finding Latency Bottlenecks

```bash
# 1. Is it DNS?
time nslookup api-service
# If > 100ms, CoreDNS might be slow

# 2. Is it network layer?
ping -c 10 <target-ip>
# If > 10ms, network might be congested

# 3. Is it the application?
curl http://api-service:8080/health
# Check if health endpoint is fast

# 4. Check network policies
# Too many policies = slower evaluation
kubectl get networkpolicy --all-namespaces | wc -l

# 5. Check CNI performance
# Check pod-to-pod latency directly:
kubectl exec <pod1> -- ping -c 10 <pod2-ip>
# Should be < 5ms in same node, < 20ms cross-node
```

### Monitoring Network Performance

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: network-latency-alerts
spec:
  groups:
  - name: network.rules
    interval: 30s
    rules:
    - alert: HighNetworkLatency
      expr: rate(container_network_transmit_errors_total[5m]) > 0.01
      for: 5m
      annotations:
        summary: "High network errors detected"

    - alert: HighDNSLatency
      expr: histogram_quantile(0.95, rate(coredns_dns_request_duration_seconds_bucket[5m])) > 0.1
      for: 5m
      annotations:
        summary: "DNS resolution is slow (>100ms)"
```

---

## ❌ Common Network Failures & Solutions

| Symptom | Cause | Solution |
|---------|-------|----------|
| `Connection refused` | Service not listening | Check pod logs, verify port matches |
| `Connection timeout` | Service unreachable | Check network policy, verify service exists |
| `DNS not resolving` | CoreDNS down | Restart coredns, check kube-system namespace |
| `502 Bad Gateway` | Ingress can't reach backend | Verify service/pods/endpoints |
| `High latency` | Network congestion or DNS slow | Check CoreDNS, measure pod-to-pod latency |
| `Intermittent failures` | Load balancing across pod replicas | Check all pod replicas are healthy |

### Emergency Network Debugging Script

```bash
#!/bin/bash
# debug-network.sh - Quick network troubleshooting

POD=$1
NAMESPACE=${2:-default}

echo "🔍 Checking network for $POD in $NAMESPACE"

# 1. Pod status
echo "
=== POD STATUS ==="
kubectl get pod $POD -n $NAMESPACE -o wide

# 2. Pod network
echo "
=== POD NETWORK CONFIG ==="
kubectl exec $POD -n $NAMESPACE -- ifconfig

# 3. DNS
echo "
=== DNS RESOLUTION ==="
kubectl exec $POD -n $NAMESPACE -- nslookup kubernetes.default

# 4. CoreDNS status
echo "
=== COREDNS STATUS ==="
kubectl get pods -n kube-system | grep coredns

# 5. Network policies
echo "
=== NETWORK POLICIES ==="
kubectl get networkpolicy -n $NAMESPACE

# 6. Service connectivity test
echo "
=== SERVICE CONNECTIVITY ==="
kubectl exec $POD -n $NAMESPACE -- \
  curl -I http://kubernetes.default.svc.cluster.local:443 2>&1 | head -10

echo "
=== DIAGNOSTICS COMPLETE ==="
```

---

## 📚 Related Resources

- [Lab 5: Ingress Routing](../../labs/05-task-ingress.md) — Ingress fundamentals
- [Lab 6: Security](../../labs/06-medical-security.md) — Network policies
- [Lab 9.5: Microservices](../../labs/09.5-complex-microservices.md) — Advanced networking
- [Troubleshooting Hub](../40-troubleshooting/troubleshooting-index.md) — Network issue solutions

---

**Questions?** [Open an issue](https://github.com/temitayocharles/stack-to-k8s/issues) or check the [Troubleshooting Hub](../40-troubleshooting/troubleshooting-index.md).

