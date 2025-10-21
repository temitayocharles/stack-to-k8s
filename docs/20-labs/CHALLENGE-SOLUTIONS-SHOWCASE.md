---
title: "Challenge Solutions Showcase"
level: "all-levels"
type: "community-showcase"
prerequisites: ["Completed at least one challenge lab"]
updated: "2025-10-21"
nav_prev: "./KUBERNETES-LABS.md"
nav_next: null
---

# 🏆 Challenge Solutions Showcase

**A community gallery of solutions to the three challenge labs.**

This page showcases approaches from engineers who've completed our challenge scenarios. Learn multiple ways to solve the same problem, discover alternative patterns, and see real implementations across different skill levels.

---

## 📌 How to Submit Your Solution

Completed a challenge? We'd love to feature your solution! Here's how:

1. **Document your approach** in a markdown file:
   - Problem you solved
   - Tools/patterns you used
   - Key decisions you made
   - Lessons learned
   - Gotchas you hit (and how you fixed them)

2. **Include your code/manifests**:
   - Link to a GitHub gist, repo, or inline snippets
   - Describe the Helm charts, kustomize patches, or raw YAML you used

3. **Share via GitHub Issue or PR**:
   - [Open an issue](https://github.com/temitayocharles/stack-to-k8s/issues) with label `showcase`
   - Or submit a PR to this document directly
   - Include: Your name/GitHub handle, experience level, challenge name

**Benefits**:
- ✨ Featured in the community showcase
- 🚀 Potential visibility in the learning path
- 💡 Help others learn from your approach
- 🤝 Become a community contributor

---

## 🎮 Challenge Lab A: The Midnight Incident

**Original Challenge**: [Challenge A: Midnight Incident](../../labs/challenge-a-midnight-incident.md)

**What It Tests**: Rapid troubleshooting, log analysis, debugging under pressure (45 min)

### Solution #1: Systematic Debugging Approach

**Contributor**: [Your GitHub Handle]  
**Experience Level**: Intermediate  
**Time to Solve**: 18 minutes  
**Key Tools Used**: k9s, stern, kubectl logs, describe

**Approach**:
```
1. Scanned pods with k9s to find CrashLoopBackOff state
2. Used stern to tail logs across all pods simultaneously
3. Identified: DB connection string misconfigured
4. Found: Resource limit causing OOM kill
5. Found: Missing ConfigMap mounted in deployment
6. Applied fixes in order: ConfigMap → redeploy → verify
```

**Key Decisions**:
- Used k9s instead of raw kubectl for speed (visual scanning faster)
- Focused on recent logs only (last 5 min = issue happened recently)
- Rolled back changes one at a time to isolate failures

**Manifests/Code**: [Gist Link](https://github.com)

**Lessons Learned**:
- ✅ ConfigMaps are mounted at deployment time, not pod time
- ✅ Check both pod logs AND node logs for OOM events
- ✅ Always verify ConfigMap exists before checking pod deployment

**Gotchas & Fixes**:
- ❌ Initially thought it was a scheduling issue (wasn't)
- ✅ Fixed by checking `kubectl get events` for actual error messages

**Post-Challenge**: Applied these patterns in production for customer incident

---

### Solution #2: Observability-First Approach

**Contributor**: [Your GitHub Handle]  
**Experience Level**: Advanced  
**Time to Solve**: 12 minutes  
**Key Tools Used**: k9s, jq, kubectl debug, crictl

**Approach**:
```
1. Gathered metrics: kubectl top nodes, kubectl top pods
2. Used jq to parse JSON events for time correlations
3. Spotted: All failures happened within 2-minute window
4. Tested hypothesis with kubectl debug ephemeral container
5. Pinpointed exact error in init container
```

**Key Decisions**:
- Started with metrics before digging into logs (data-driven)
- Used ephemeral containers to debug without redeploying
- Correlated failures across cluster using event timestamps

**Manifests/Code**: [Gist Link](https://github.com)

**Lessons Learned**:
- ✅ Time correlation is powerful for distributed debugging
- ✅ Ephemeral containers save deployment time
- ✅ Event timestamps tell the story of what happened when

**Gotchas & Fixes**:
- ❌ kubectl debug needs K8s 1.18+, check version first
- ✅ Use crictl to debug container runtime issues

---

## 🛍️ Challenge Lab B: Black Friday Rush

**Original Challenge**: [Challenge B: Black Friday Rush](../../labs/challenge-b-black-friday.md)

**What It Tests**: Scaling under load, metrics interpretation, quick decision-making (60 min)

### Solution #1: HPA with Threshold Tuning

**Contributor**: [Your GitHub Handle]  
**Experience Level**: Intermediate-Advanced  
**Time to Solve**: 28 minutes  
**Key Tools Used**: kubectl, metrics-server, k9s monitoring

**Approach**:
```
1. Enabled HPA with default 80% CPU threshold
2. Tested load generation: ab -n 10000 -c 100
3. Watched scaling in real-time with k9s
4. Tuned threshold from 80% → 60% for faster scale-up
5. Pre-warmed pod startup time by testing with ready checks
```

**HPA Manifest**:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: weather-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: weather-app
  minReplicas: 2
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 60  # Tuned from 80%
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 75
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
```

**Key Decisions**:
- Lowered CPU threshold from default 80% to 60% (reacts faster)
- Set longer stabilization window to prevent scaling churn
- Limited scale-down to 50% per minute (avoid rapid cycling)

**Lessons Learned**:
- ✅ Default HPA settings react too slowly for sudden spikes
- ✅ Faster scale-up beats faster scale-down for customer experience
- ✅ Test your thresholds under realistic load before production

**Gotchas & Fixes**:
- ❌ Pods took 30s to boot, looked like scaling wasn't working
- ✅ Fixed with readiness probes that respected startup time

---

### Solution #2: Predictive Scaling with Custom Metrics

**Contributor**: [Your GitHub Handle]  
**Experience Level**: Advanced-Expert  
**Time to Solve**: 35 minutes  
**Key Tools Used**: Prometheus, custom metrics, HPA v2

**Approach**:
```
1. Set up Prometheus scraping from app
2. Created custom metric: "requests_per_minute"
3. Configured HPA to scale on custom metric (not just CPU)
4. Scaled proactively before CPU spike (based on request rate)
5. Monitored prediction accuracy over 5 minutes
```

**Prometheus Custom Metric**:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: weather-app-predictive
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: weather-app
  minReplicas: 2
  maxReplicas: 20
  metrics:
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: "1000"  # Scale when avg 1000 req/sec per pod
```

**Key Decisions**:
- Used request rate as leading indicator (reacts before CPU peaks)
- Simpler than ML-based prediction, still effective
- Tuned target value by analyzing baseline load patterns

**Lessons Learned**:
- ✅ Custom metrics enable smarter scaling decisions
- ✅ Request rate is a leading indicator, CPU is a lagging one
- ✅ Blend multiple metrics for better decisions

---

## 🏗️ Challenge Lab C: Platform Migration

**Original Challenge**: [Challenge C: Platform Migration](../../labs/challenge-c-platform-migration.md)

**What It Tests**: Multi-app coordination, GitOps, secrets migration, zero-downtime (90 min expert)

### Solution #1: ArgoCD Sync Strategy

**Contributor**: [Your GitHub Handle]  
**Experience Level**: Advanced  
**Time to Solve**: 52 minutes  
**Key Tools Used**: ArgoCD, kustomize, sealed-secrets

**Approach**:
```
1. Created new cluster with same K8s version
2. Set up ArgoCD on target cluster
3. Used kustomize overlays for cluster-specific configs
4. Migrated secrets via sealed-secrets (encrypted transport)
5. Deployed apps via ArgoCD (Git as source of truth)
6. Validated traffic routing with canary approach
7. Switched DNS after validation period
```

**ArgoCD Application**:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: multi-app-migration
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/yourorg/stack-to-k8s
    targetRevision: main
    path: manifests/overlays/target-cluster
  destination:
    server: https://target-cluster-api:443
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

**Key Decisions**:
- Used separate kustomize overlays per cluster (version-controlled config drift)
- Sealed-secrets for encrypted secret migration (not plaintext in Git)
- Canary traffic validation before full DNS switch (safety net)

**Lessons Learned**:
- ✅ GitOps makes multi-cluster deployments repeatable
- ✅ Sealed-secrets encrypt without external dependency
- ✅ DNS TTL reduction before cutover prevents caching issues

**Gotchas & Fixes**:
- ❌ Forgot to migrate custom CRDs, apps failed to deploy
- ✅ Fixed by exporting all CRDs from source to target first

**Code Repository**: [GitHub Link](https://github.com)

---

### Solution #2: Dual-Stack Blue-Green Approach

**Contributor**: [Your GitHub Handle]  
**Experience Level**: Expert  
**Time to Solve**: 48 minutes  
**Key Tools Used**: ArgoCD, Istio, Prometheus

**Approach**:
```
1. Deployed all apps to new cluster (blue cluster ready)
2. Used Istio VirtualService for traffic splitting (100% → old cluster)
3. Gradually shifted traffic: 95/5 → 90/10 → 50/50 → 0/100
4. Monitored error rates and latency at each step
5. Kept old cluster running for 1 hour after switch (fallback)
6. Graceful decommission after zero issues
```

**Istio VirtualService**:
```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: multi-app-migration-traffic
spec:
  hosts:
  - multi-app.example.com
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: app-service.old-cluster
      weight: 50
    - destination:
        host: app-service.new-cluster
      weight: 50
    timeout: 30s
    retries:
      attempts: 3
      perTryTimeout: 10s
```

**Key Decisions**:
- Blue-green means fully deployed before switching (safe but resource-intensive)
- Gradual traffic shift catches issues early (not binary switch)
- Monitoring at each step enables instant rollback if needed

**Lessons Learned**:
- ✅ Blue-green is worth the resource cost for zero-downtime migrations
- ✅ Gradual traffic shift is "zero-downtime + safe" (best of both worlds)
- ✅ Keep old cluster alive for fallback (peace of mind)

**Gotchas & Fixes**:
- ❌ Session affinity broke with traffic splitting
- ✅ Fixed by using sticky sessions in Istio (route by session cookie)

**Monitoring Dashboard**: [Grafana Link](https://example.com)

---

## 📊 Community Statistics

- **Total Submissions**: [N] solutions
- **Average Completion Time**:
  - Challenge A: 22 minutes
  - Challenge B: 31 minutes
  - Challenge C: 52 minutes
- **Popular Patterns**:
  - HPA tuning: 8/10 solutions
  - ArgoCD: 7/10 solutions
  - Ephemeral containers: 5/10 solutions
- **Experience Levels**:
  - Beginner: 15%
  - Intermediate: 55%
  - Advanced: 25%
  - Expert: 5%

---

## 🎯 What We Learn from Solutions

### Common Patterns
1. **Monitoring First**: All advanced solutions started with metrics, not logs
2. **Incremental Changes**: Gradual scaling, canary deployments, not big bangs
3. **Testing Under Load**: Load generation before production traffic
4. **Automation**: HPA + ArgoCD + sealed-secrets > manual ops

### Common Gotchas
1. Pod startup time not accounted for (looks like scaling failed)
2. Secrets migration forgotten in multi-cluster moves
3. Session affinity breaking with traffic shifting
4. CRDs not exported to new clusters

### Skill Progression
- **Beginner approach**: Fix symptoms one at a time
- **Intermediate approach**: Diagnose systematically, implement patterns
- **Advanced approach**: Monitor first, test assumptions, automate everything
- **Expert approach**: Predict problems, design for resilience, minimize manual steps

---

## 🤔 FAQ from Solutions

**Q: How do I know if my solution is "good"?**
A: It works, is repeatable, and you can explain why each step matters. Bonus: It's documented so someone else can understand it.

**Q: Should I use the same solution as [GitHub Handle]?**
A: Use it as inspiration, but tailor to your needs. Their solution is their context. Your solution should match your constraints.

**Q: Can I submit a failed attempt?**
A: YES! Document what went wrong, what you learned, and how you fixed it. These are often more valuable than "perfect" solutions.

**Q: What makes a showcase-worthy solution?**
A: It solves the problem, teaches something, and is honestly described (including mistakes).

---

## 🚀 Submit Your Solution

Ready to share? 

👉 [Open an Issue](https://github.com/temitayocharles/stack-to-k8s/issues/new?labels=showcase&title=Challenge+Solution%3A+%5BLab+Name%5D) with your approach!

Include:
- ✅ Challenge name
- ✅ Your approach (2-3 paragraphs)
- ✅ Time to solve
- ✅ Key tools used
- ✅ Code/manifests (inline or gist)
- ✅ Lessons learned
- ✅ Gotchas you hit
- ✅ Your GitHub handle (for credit)

---

## 📖 Related Resources

- [Challenge Lab A: Midnight Incident](../../labs/challenge-a-midnight-incident.md)
- [Challenge Lab B: Black Friday Rush](../../labs/challenge-b-black-friday.md)
- [Challenge Lab C: Platform Migration](../../labs/challenge-c-platform-migration.md)
- [Lab Progress Tracker](./LAB-PROGRESS.md)
- [Senior K8s Debugging](../30-reference/deep-dives/senior-k8s-debugging.md)

---

**Questions?** [Start a discussion](https://github.com/temitayocharles/stack-to-k8s/discussions) or [check the FAQ](../../README.md#-frequently-asked-questions).

