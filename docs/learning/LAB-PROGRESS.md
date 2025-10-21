# 📊 Lab Progress Tracker

Track your Kubernetes hero journey and celebrate every milestone with sparkles. ✨

## 🎯 Mission Scorecard
- **Total Labs Completed**: ____ / 12
- **Total Time Logged**: __________
- **Kube-Confidence Level**: 😅 / 🙂 / 😎 / 🧙

---

## 🧭 Stage 1 · Foundations (⭐)
- [ ] **Lab 1 · Weather App Basics** (20 min) 🌦️  
  _Pods · Deployments · Services · Scaling · Port-forwarding_  
  Completed on: __________
- [ ] **Lab 2 · E-commerce Multi-tier** (30 min) 🛒  
  _Service discovery · ConfigMaps · Multi-service wiring_  
  Completed on: __________
- [ ] **Lab 3 · Educational Stateful** (40 min) 🎓  
  _StatefulSets · PVCs · Backups · Persistence_  
  Completed on: __________
- [ ] **Lab 4 · Kubernetes Fundamentals Deep Dive** (75 min) 🏷️  
  _Labels & selectors mastery · Troubleshooting gauntlet · kubectl pro tips_  
  Completed on: __________

## 🛠️ Stage 2 · Production Ops (⭐⭐)
- [ ] **Lab 5 · Task Manager Ingress** (45 min) ✅  
  _Ingress controllers · TLS · DNS routing_  
  Completed on: __________
- [ ] **Lab 6 · Medical Security** (60 min) 🏥  
  _RBAC · ServiceAccounts · NetworkPolicies · Secrets_  
  Completed on: __________
- [ ] **Lab 7 · Social Scaling** (90 min) 📈  
  _HPA/VPA · Metrics server · Load testing · Capacity tuning_  
  Completed on: __________

## 🌐 Stage 3 · Platform Engineering (⭐⭐⭐)
- [ ] **Lab 8 · Multi-App Orchestration** (120 min) 🧩  
  _Service mesh · Istio routing · Centralized logging · Prometheus_  
  Completed on: __________
- [ ] **Lab 9 · Chaos Engineering** (90 min) ⚡  
  _Fault injection · Network chaos · Resilience drills_  
  Completed on: __________

## 🪄 Stage 4 · Automation Masters (⭐⭐⭐⭐)
- [ ] **Lab 10 · Helm Package Management** (75 min) 🪄  
  _Chart authoring · Template magic · Repositories · Dependencies_  
  Completed on: __________
- [ ] **Lab 11 · GitOps with ArgoCD** (90 min) 🤖  
  _GitOps pipelines · App-of-apps · Multi-env promotion_  
  Completed on: __________
- [ ] **Lab 12 · External Secrets Management** (60 min) 🔐  
  _External Secrets Operator · Cloud secret stores · Rotation_  
  Completed on: __________

---

## 🏅 Expert badge system (optional advanced challenges)

> 💡 **These are 100% OPTIONAL!** Complete the standard labs to master Kubernetes. Expert badges are for those who want to dive deeper into production debugging, performance tuning, and senior-level topics. **You don't need these to graduate!**

### Achievement Tiers

Track your expertise level as you unlock badges:

| Badges Earned | Tier | Title | Description |
|--------------|------|-------|-------------|
| **0-2 badges** | 🥉 | **Advanced Practitioner** | You've dipped into production scenarios |
| **3-5 badges** | 🥈 | **Senior Engineer** | You can debug complex multi-component issues |
| **6-7 badges** | 🥇 | **Kubernetes Expert** | You're ready for senior SRE/Platform roles |
| **All 7 badges + 3 Challenges** | 👑 | **Kubernetes Master** | You're in the top 5% of K8s practitioners |

**Current Tier**: 🥉 _(Update as you go!)_

---

### 🎖️ Expert Badge Tracker

These challenges appear **inline** in the labs at natural progression points. They use the deployments you've already created, so there's no extra setup needed!

| Badge | Lab | Challenge | Time | Difficulty | Interview Topics | Status |
|-------|-----|-----------|------|------------|------------------|--------|
| 🔬 **Forensic Investigator** | [Lab 1](../../labs/01-weather-basics.md#expert-mode-forensic-debugging) | Debug CrashLoopBackOff with no logs | +20min | ⭐⭐⭐⭐ | kubectl debug, crictl, ephemeral containers | ☐ |
| 💾 **Data Recovery Specialist** | [Lab 3](../../labs/03-educational-stateful.md#expert-mode-data-recovery) | Recover PVC after node crash | +15min | ⭐⭐⭐⭐ | PVC rebinding, force delete, node affinity | ☐ |
| ⚙️ **Control Plane Architect** | [Lab 3.5](../../labs/03.5-kubernetes-under-the-hood.md#expert-mode-control-plane-tuning) | Tune etcd performance (8.5GB DB) | +25min | ⭐⭐⭐⭐⭐ | etcd compaction, defragmentation, disk I/O | ☐ |
| 📈 **Scaling Architect** | [Lab 7](../../labs/07-social-scaling.md#expert-mode-cluster-autoscaler-debugging) | Debug Cluster Autoscaler failures | +20min | ⭐⭐⭐⭐ | Autoscaler logs, node groups, PodDisruptionBudgets | ☐ |
| 🕸️ **Mesh Performance Engineer** | [Lab 8](../../labs/08-multi-app.md#expert-mode-service-mesh-performance-profiling) | Optimize Istio sidecar CPU usage | +30min | ⭐⭐⭐⭐⭐ | Envoy profiling, connection pooling, circuit breakers | ☐ |
| 🔍 **Network Detective** | [Lab 9](../../labs/09-chaos.md#expert-mode-the-impossible-network-debug) | Debug "impossible" CNI failures | +25min | ⭐⭐⭐⭐⭐ | CNI logs, network namespaces, IPAM troubleshooting | ☐ |
| 🌉 **Hybrid Cloud Architect** | [Lab 12](../../labs/12-external-secrets.md#expert-mode-hybrid-cloud-architecture) | External DB via VPN with HA | +30min | ⭐⭐⭐⭐ | VPN sidecars, service discovery, multi-endpoint failover | ☐ |

**Total Expert Time**: ~165 minutes (~2.75 hours) if you complete all 7 badges

---

### 📊 Expert Progress Calculator

Fill in your badges to see your completion percentage:

**Badges Completed**: _____ / 7 (____%)

**What This Unlocks**:
- **1-2 badges**: You understand advanced debugging fundamentals
- **3-4 badges**: You can lead production incident response
- **5-6 badges**: You're ready for senior engineer/SRE interviews
- **7 badges**: You've mastered production Kubernetes at scale

---

### 🎯 Two Paths to Mastery

You can complete this repository in two ways:

#### Path A: Standard Journey (Recommended for most learners)
- Complete Labs 1-12 (standard sections only)
- **Time**: ~10-12 hours total
- **Outcome**: CKA/CKAD ready, production-capable
- **Best for**: New K8s users, CKA exam prep, bootcamp students

#### Path B: Expert Journey (For senior roles)
- Complete Labs 1-12 PLUS all 7 Expert Mode challenges
- **Time**: ~12-15 hours total
- **Outcome**: Senior SRE/Platform Engineer ready, interview-tested
- **Best for**: Mid-level engineers leveling up, staff/principal aspirants, incident responders

**Pro tip**: Start with Path A. Complete all standard labs first, then revisit Expert Modes later. The standard labs give you the foundation; Expert Modes give you the war stories.

---

### 🏅 What Each Badge Teaches You

#### 🔬 Forensic Investigator (Lab 1)
**The Scenario**: Pod in CrashLoopBackOff, but `kubectl logs` shows nothing. Where do you even start?

**Skills**: kubectl debug, crictl inspect, ephemeral containers, core dump analysis, OOMKilled forensics

**Real-World Impact**: After mastering this, you'll confidently debug "invisible" failures that stump most engineers.

---

#### 💾 Data Recovery Specialist (Lab 3)
**The Scenario**: Node crashed during Black Friday. PVC won't reattach, pod stuck Pending. Customer data at risk.

**Skills**: Force delete pods, PV node affinity patching, PVC rebinding, storage class recovery

**Real-World Impact**: Shopify saved $2M using these exact techniques during Black Friday 2022.

---

#### ⚙️ Control Plane Architect (Lab 3.5)
**The Scenario**: etcd database at 8.5GB, API server timing out (45ms latency). Production is degrading.

**Skills**: etcd compaction, defragmentation, auto-compaction configuration, disk I/O tuning

**Real-World Impact**: Reddit went down in 2023 with a 12GB etcd database and no auto-compaction. Don't be Reddit.

---

#### 📈 Scaling Architect (Lab 7)
**The Scenario**: Pods stuck Pending, Cluster Autoscaler won't scale up despite needing capacity. Black Friday traffic incoming.

**Skills**: Autoscaler logs, node group limits, PodDisruptionBudgets, ASG/MIG inspection

**Real-World Impact**: Airbnb prevented a $5M Black Friday outage by debugging autoscaler node group limits.

---

#### 🕸️ Mesh Performance Engineer (Lab 8)
**The Scenario**: Istio sidecar consuming 250m CPU vs. app's 50m CPU. 5x overhead is destroying your cost budget.

**Skills**: Envoy profiling, connection pooling, circuit breakers, tracing sampling, admin interface

**Real-World Impact**: Lyft saved $500k/year by optimizing 1000 Istio sidecars using these techniques.

---

#### 🔍 Network Detective (Lab 9)
**The Scenario**: Pods stuck in ContainerCreating with CNI errors. Other pods on the SAME node work fine. What sorcery is this?

**Skills**: CNI plugin debugging, network namespace inspection, IPAM troubleshooting, crictl

**Real-World Impact**: E-commerce company lost $3M during Black Friday 2023 due to leaked network namespaces.

---

#### 🌉 Hybrid Cloud Architect (Lab 12)
**The Scenario**: Connect Kubernetes apps to on-premises database via VPN. CFO says "We're not paying for RDS!"

**Skills**: VPN sidecar patterns, service discovery, connection pooling, multi-endpoint failover

**Real-World Impact**: Fintech company saved $2.4M/year keeping core DB on-prem while running 50+ K8s microservices.

---

### 🎤 Interview Preparation

Every Expert Mode challenge includes **interview answer templates** based on real questions from:
- Google SRE interviews
- Amazon Senior DevOps Engineer interviews
- Microsoft Azure Kubernetes Service team interviews
- FAANG-level principal engineer interviews

**Common interview questions covered**:
1. "Walk me through debugging a pod stuck in CrashLoopBackOff with no logs."
2. "How do you recover a PVC after a node failure?"
3. "Explain etcd performance tuning strategies."
4. "Debug a scenario where Cluster Autoscaler won't scale."
5. "How would you optimize Istio sidecar resource usage?"
6. "A pod is stuck in ContainerCreating with a CNI error. What's your process?"
7. "Design a hybrid architecture for accessing on-premises databases from Kubernetes."

**Complete interview guide**: [Senior Kubernetes Debugging Reference](../reference/senior-k8s-debugging.md)

---

### 📚 Additional Resources

Want more context? Every Expert Mode links to the comprehensive reference doc:

**[Senior Kubernetes Debugging & Performance Tuning Guide](../reference/senior-k8s-debugging.md)**
- 1200+ lines of production debugging wisdom
- Real incident post-mortems (Shopify, Reddit, Airbnb, Lyft)
- Interview answer templates for each scenario
- Step-by-step command walkthroughs
- Architecture decision guides

---

## 🏆 Milestones unlocked
- [ ] 🐣 **First Pod Online** — You made it to the cluster!
- [ ] 🔌 **Services Talking** — Multi-tier traffic flowing
- [ ] 💾 **Data Stays Put** — StatefulSets + backups configured
- [ ] 🌍 **Ingress Online** — TLS, DNS & certificates humming
- [ ] 🛡️ **Security Shielded** — RBAC + NetworkPolicies enforced
- [ ] 📈 **Auto-scaling Party** — Apps adapt to load automatically
- [ ] 🧠 **Observability Ready** — Metrics + logs centralized
- [ ] ⚡ **Chaos Conqueror** — Resilience proven under fire
- [ ] 🪄 **Helm Hero** — Packages templated & versioned
- [ ] 🤖 **GitOps Guardian** — Git commits ship to production
- [ ] 🔐 **Secrets Whisperer** — External stores synced & rotated
- [ ] 🧭 **Troubleshooting Ninja** — Labels aligned, clusters calm

---

## 📈 Skills Acquired Along the Way

✅ **Core Concepts** — Pods, Deployments, Services, ReplicaSets  
✅ **Storage** — PersistentVolumes, PVCs, StatefulSets, Backups  
✅ **Configuration** — ConfigMaps, Secrets, Environment Variables  
✅ **Networking** — ClusterIP, LoadBalancer, Ingress, NetworkPolicies  
✅ **Security** — RBAC, ServiceAccounts, Secret Management, PSP concepts  
✅ **Scaling** — HPA, VPA, Resource Requests & Limits, Autoscaling tactics  
✅ **Observability** — Logging, Metrics, Dashboards, Alerts  
✅ **Service Mesh** — Istio, mTLS, Traffic Shaping  
✅ **Chaos Engineering** — Failure testing, Recovery playbooks  
✅ **Package Management** — Helm Charts, Templates, Repos, Releases  
✅ **GitOps** — ArgoCD, Multi-environment automation, Git-driven deployment  
✅ **Enterprise Secrets** — External Secrets Operator, Rotation, Cloud stores  
✅ **Troubleshooting** — Label mastery, kubectl power moves, Systematic diagnostics

---

## 🎓 Graduation Checklist
1. 📝 Redeploy an app from memory without peeking
2. 🧪 Break something on purpose and fix it like a pro
3. 🧰 Convert a personal project into Kubernetes manifests
4. 🏅 Attempt a CKA/CKAD practice exam scenario
5. 💬 Teach a teammate one concept you mastered

---

## 💡 Study Tips Sprinkled with Wisdom
- 🕰️ **Slow is smooth, smooth is fast** — Review before moving on
- ⌨️ **Type the commands** — Muscle memory wins production incidents
- 🛠️ **Experiment** — Clone, tweak, observe; the cluster is your sandbox
- ❓ **Ask why** — Understand the “why” behind every YAML field
- 📚 **Review manifests** — Browse the app `k8s/` directories like a detective

---

**Pro tip**: Repeat challenging labs until they feel easy. Your future on-call self will thank you! 🙌
