# 🔥 Chaos Engineering & Troubleshooting Lab

> **Purpose**: Learn to break things safely and fix them like a DevOps expert

## 🎯 **Learning Philosophy**

> *"The best way to learn is to break things and fix them. But break them intentionally."*

**This lab teaches you to:**
- ✅ **Think like production systems** - What can go wrong, will go wrong
- ✅ **Develop troubleshooting intuition** - Pattern recognition for failures
- ✅ **Build resilient systems** - Design for failure from the start
- ✅ **Practice incident response** - Stay calm under pressure

---

## 🧪 **Controlled Chaos Scenarios**

### 🟢 **Beginner: Container Failures**

#### Scenario 1: Out of Memory
```bash
# Application: E-commerce
cd ecommerce-app

# 1. Limit container memory severely
docker run -m 64m your-app:latest

# 💥 What breaks: OOMKilled, pod restarts
# 🔍 Debug commands:
kubectl describe pods
kubectl logs pod-name --previous
docker stats

# 🛠️ Fix approach:
# - Identify memory usage patterns
# - Optimize application memory
# - Set appropriate resource limits
```

#### Scenario 2: Wrong Environment Variables
```bash
# 2. Break database connection
export DB_HOST="wrong-host"
docker-compose up -d

# 💥 What breaks: Connection refused, app crashes
# 🔍 Debug commands:
docker-compose logs backend
netstat -an | grep 5432
nslookup wrong-host

# 🛠️ Fix approach:
# - Verify environment variable values
# - Test network connectivity
# - Check service discovery
```

#### Scenario 3: Image Pull Failures
```bash
# 3. Use non-existent image
# Edit docker-compose.yml: image: "nonexistent:latest"
docker-compose up -d

# 💥 What breaks: ImagePullBackOff, pods pending
# 🔍 Debug commands:
kubectl describe pods
docker pull nonexistent:latest
kubectl get events

# 🛠️ Fix approach:
# - Verify image names and tags
# - Check registry access
# - Validate image architecture
```

### 🟡 **Intermediate: Kubernetes Failures**

#### Scenario 4: Service Discovery Issues
```bash
# Application: Educational Platform
cd educational-platform

# 4. Break service names
# Edit k8s/service.yaml: change service name
kubectl apply -f k8s/

# 💥 What breaks: 503 Service Unavailable
# 🔍 Debug commands:
kubectl get services
kubectl describe service frontend
kubectl get endpoints
nslookup frontend-service.default.svc.cluster.local

# 🛠️ Fix approach:
# - Verify service selector labels
# - Check endpoint creation
# - Test DNS resolution
```

#### Scenario 5: Resource Quotas
```bash
# 5. Exhaust cluster resources
# Create multiple resource-heavy deployments
kubectl create deployment cpu-hog --image=progrium/stress \
  --replicas=10 -- --cpu 4

# 💥 What breaks: Pending pods, resource exhaustion
# 🔍 Debug commands:
kubectl top nodes
kubectl describe nodes
kubectl get events | grep Failed

# 🛠️ Fix approach:
# - Monitor resource usage
# - Implement resource quotas
# - Scale cluster appropriately
```

#### Scenario 6: Network Policies
```bash
# 6. Block all network traffic
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF

# 💥 What breaks: All inter-pod communication
# 🔍 Debug commands:
kubectl get networkpolicy
kubectl describe networkpolicy deny-all
kubectl exec -it pod-name -- ping other-service

# 🛠️ Fix approach:
# - Understand network policy rules
# - Design proper network segmentation
# - Test connectivity step by step
```

### 🟠 **Advanced: Production Scenarios**

#### Scenario 7: Database Failover
```bash
# Application: Medical Care System
cd medical-care-system

# 7. Simulate database primary failure
# Kill database master pod
kubectl delete pod postgres-master-0

# 💥 What breaks: Write operations fail, data inconsistency
# 🔍 Debug commands:
kubectl get pods -l app=postgres
kubectl logs postgres-replica-0
kubectl exec -it postgres-replica-0 -- psql -c "SELECT pg_is_in_recovery();"

# 🛠️ Fix approach:
# - Implement automatic failover
# - Test backup/restore procedures
# - Monitor replication lag
```

#### Scenario 8: Certificate Expiration
```bash
# 8. Simulate expired TLS certificates
# Create cert with 1-minute expiry
openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem \
  -days 0 -nodes -subj "/CN=localhost"

# Use expired cert in ingress
kubectl create secret tls expired-cert --cert=cert.pem --key=key.pem

# 💥 What breaks: HTTPS connections fail, browser warnings
# 🔍 Debug commands:
openssl x509 -in cert.pem -text -noout
kubectl describe secret expired-cert
curl -I https://your-app.com

# 🛠️ Fix approach:
# - Implement cert-manager for auto-renewal
# - Monitor certificate expiration
# - Test certificate rotation
```

#### Scenario 9: Split Brain
```bash
# 9. Create network partition
# Simulate split-brain in distributed database
# Block network between database nodes
iptables -A INPUT -s 10.0.1.0/24 -j DROP

# 💥 What breaks: Data inconsistency, multiple masters
# 🔍 Debug commands:
kubectl get pods -o wide
kubectl exec -it db-node-1 -- ping db-node-2
kubectl logs db-node-1 | grep "split"

# 🛠️ Fix approach:
# - Implement proper quorum mechanisms
# - Use anti-affinity rules
# - Monitor cluster health
```

### 🔴 **Expert: Multi-System Failures**

#### Scenario 10: Cascading Failure
```bash
# Application: Social Media Platform
cd social-media-platform

# 10. Overload system components sequentially
# Step 1: Overload database
ab -n 10000 -c 100 http://localhost:3000/api/posts

# Step 2: This overloads backend
# Step 3: Which overloads frontend
# Step 4: Load balancer starts failing

# 💥 What breaks: Entire system degrades, user experience suffers
# 🔍 Debug commands:
kubectl top pods
kubectl get hpa
kubectl describe service load-balancer
kubectl get events --sort-by='.lastTimestamp'

# 🛠️ Fix approach:
# - Implement circuit breakers
# - Add proper rate limiting
# - Design bulkhead isolation
# - Practice chaos engineering
```

---

## 🔧 **Troubleshooting Methodology**

### **The DevOps Debugging Process**

1. **🎯 Define the Problem**
   - What exactly is broken?
   - When did it start failing?
   - What changed recently?

2. **📊 Gather Information**
   ```bash
   # System overview
   kubectl get all -A
   docker ps -a
   kubectl top nodes
   
   # Resource usage
   kubectl describe nodes
   kubectl get events --sort-by='.lastTimestamp'
   
   # Logs analysis
   kubectl logs deployment/app-name
   journalctl -u docker.service
   ```

3. **🔍 Form Hypothesis**
   - Resource exhaustion?
   - Configuration error?
   - Network connectivity?
   - External dependency failure?

4. **🧪 Test Hypothesis**
   ```bash
   # Test connectivity
   kubectl exec -it pod-name -- ping external-service
   
   # Test resources
   kubectl top pods
   
   # Test configuration
   kubectl describe configmap app-config
   ```

5. **🛠️ Implement Fix**
   - Start with least disruptive changes
   - Test in isolation
   - Monitor impact

6. **✅ Verify Solution**
   - Confirm symptoms resolved
   - Monitor for regression
   - Document the fix

### **Common Failure Patterns & Solutions**

#### Pattern: "It worked yesterday"
- **Cause**: Configuration drift, env changes
- **Debug**: `git diff`, environment comparison
- **Fix**: Infrastructure as Code, immutable deployments

#### Pattern: "It works on my machine"
- **Cause**: Environment differences
- **Debug**: Container vs local differences
- **Fix**: Consistent environments, better testing

#### Pattern: "Intermittent failures"
- **Cause**: Race conditions, load-related issues
- **Debug**: Load testing, timing analysis
- **Fix**: Proper synchronization, circuit breakers

#### Pattern: "Sudden performance degradation"
- **Cause**: Resource limits, memory leaks
- **Debug**: Performance profiling, resource monitoring
- **Fix**: Resource optimization, auto-scaling

---

## 🎮 **Chaos Engineering Tools**

### **Container Level**
```bash
# Pumba: Container chaos engineering
docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock \
  gaiaadm/pumba kill --interval=10s re2:stress

# Stress testing
docker run --rm -it progrium/stress --cpu 2 --timeout 60s
```

### **Kubernetes Level**
```bash
# Chaos Mesh: Kubernetes-native chaos engineering
kubectl apply -f https://mirrors.chaos-mesh.org/v2.5.1/install.sh

# Litmus: GitOps-based chaos engineering
kubectl apply -f https://litmuschaos.github.io/litmus/litmus-operator-v3.0.0.yaml
```

### **Network Level**
```bash
# Toxiproxy: Network chaos
docker run --rm -it shopify/toxiproxy-cli:latest \
  toxic add slow_database -t latency -a latency=1000 -a jitter=100
```

---

## 📝 **Failure Journal Template**

Keep track of failures and solutions:

```markdown
## Incident: [Date] - [Brief Description]

### Symptoms
- What users experienced
- Error messages observed
- Performance degradation

### Investigation
- Commands run
- Hypothesis tested
- Dead ends explored

### Root Cause
- Technical cause
- Human factors
- Process issues

### Resolution
- Steps taken to fix
- Time to resolution
- Verification method

### Prevention
- How to prevent recurrence
- Monitoring improvements
- Process changes
```

---

## 🏆 **Troubleshooting Mastery Goals**

### **Beginner (Month 1)**
- ✅ Can debug basic container issues (OOMKilled, wrong env vars)
- ✅ Understands Docker logs and basic kubectl commands
- ✅ Can identify common configuration errors

### **Intermediate (Month 2-3)**
- ✅ Can debug Kubernetes networking issues
- ✅ Understands resource management and limits
- ✅ Can use troubleshooting tools effectively

### **Advanced (Month 4-6)**
- ✅ Can handle multi-component failures
- ✅ Designs systems with failure in mind
- ✅ Implements monitoring and alerting

### **Expert (Month 7-12)**
- ✅ Practices chaos engineering proactively
- ✅ Responds to incidents calmly and systematically
- ✅ Mentors others in troubleshooting techniques

**Remember**: The goal isn't to avoid failures—it's to fail fast, learn quickly, and build more resilient systems.