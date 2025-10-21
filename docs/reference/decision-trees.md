# 🌳 Kubernetes Decision Trees

Quick visual guides to help you choose the right K8s resource for your use case.

---

## 1. Deployment vs. StatefulSet vs. DaemonSet

```mermaid
flowchart TD
    Start[Need to run pods?] --> Stateful{Does app need<br/>stable identity<br/>or ordered startup?}
    
    Stateful -->|Yes<br/>Database, Kafka, etc.| CheckStorage{Need persistent<br/>storage per pod?}
    CheckStorage -->|Yes| StatefulSet[✅ StatefulSet<br/>+ PVC]
    CheckStorage -->|No<br/>Just identity| StatefulSet
    
    Stateful -->|No<br/>Stateless app| EveryNode{Run on<br/>EVERY node?}
    
    EveryNode -->|Yes<br/>Logging, monitoring| DaemonSet[✅ DaemonSet]
    EveryNode -->|No<br/>Normal app| Deployment[✅ Deployment]
    
    style StatefulSet fill:#ff6b6b
    style DaemonSet fill:#4ecdc4
    style Deployment fill:#95e1d3
```

**When to Use What**:
- **Deployment**: 95% of apps (web servers, APIs, workers)
- **StatefulSet**: Databases, message queues, anything needing stable pod names (e.g., `mysql-0`, `mysql-1`)
- **DaemonSet**: Node-level agents (log collectors, monitoring, CNI plugins)

---

## 2. Service Types: ClusterIP vs. NodePort vs. LoadBalancer

```mermaid
flowchart TD
    Start[Need to expose pods?] --> Internal{Internal only<br/>or external access?}
    
    Internal -->|Internal<br/>Backend APIs| ClusterIP[✅ ClusterIP<br/>Default, internal DNS]
    
    Internal -->|External<br/>Internet-facing| Cloud{Running on<br/>cloud provider?}
    
    Cloud -->|Yes<br/>AWS, GCP, Azure| LoadBalancer[✅ LoadBalancer<br/>Auto-provisions ELB/ALB]
    
    Cloud -->|No<br/>Bare metal| UseIngress{Need HTTP<br/>routing?}
    
    UseIngress -->|Yes<br/>Multiple apps| Ingress[✅ Ingress<br/>+ ClusterIP services]
    UseIngress -->|No<br/>Single app| NodePort[✅ NodePort<br/>Opens port on all nodes]
    
    style ClusterIP fill:#a8e6cf
    style LoadBalancer fill:#ff8b94
    style Ingress fill:#ffd3b6
    style NodePort fill:#ffaaa5
```

**Quick Rules**:
- **ClusterIP**: Default. Use for backend services (not internet-facing)
- **NodePort**: Testing/dev only (exposes random port 30000-32767)
- **LoadBalancer**: Production external access (costs $$$ - one per service)
- **Ingress**: Production HTTP/HTTPS (shares one LoadBalancer across many services)

---

## 3. PVC vs. emptyDir vs. ConfigMap/Secret (Storage)

```mermaid
flowchart TD
    Start[Need storage?] --> Survive{Data must survive<br/>pod restart?}
    
    Survive -->|Yes<br/>Database, uploads| Shared{Share data<br/>between pods?}
    
    Shared -->|Yes<br/>ReadWriteMany| NFS[✅ PVC<br/>+ NFS/CephFS storage]
    Shared -->|No<br/>Single pod| RWO[✅ PVC<br/>+ Block storage<br/>ReadWriteOnce]
    
    Survive -->|No<br/>Temporary only| ScratchSpace{Scratch space<br/>or config?}
    
    ScratchSpace -->|Scratch<br/>Cache, temp files| emptyDir[✅ emptyDir<br/>Deleted on pod restart]
    
    ScratchSpace -->|Config<br/>Secrets, env vars| Sensitive{Sensitive data?}
    
    Sensitive -->|Yes<br/>Passwords, keys| Secret[✅ Secret<br/>+ volumeMount]
    Sensitive -->|No<br/>Config files| ConfigMap[✅ ConfigMap<br/>+ volumeMount]
    
    style RWO fill:#ff6b6b
    style NFS fill:#f9ca24
    style emptyDir fill:#6c5ce7
    style Secret fill:#fd79a8
    style ConfigMap fill:#fdcb6e
```

**Decision Matrix**:
| Data Type | Persists? | Resource |
|-----------|-----------|----------|
| Database | ✅ Yes | PVC (RWO) |
| Shared files | ✅ Yes | PVC (RWX) |
| Cache | ❌ No | emptyDir |
| Config files | N/A | ConfigMap |
| Passwords | N/A | Secret |

---

## 4. HPA vs. VPA vs. Manual Scaling

```mermaid
flowchart TD
    Start[Need to scale pods?] --> Auto{Automatic<br/>or manual?}
    
    Auto -->|Manual<br/>kubectl scale| Manual[✅ Manual Scaling<br/>kubectl scale deploy/app --replicas=5]
    
    Auto -->|Automatic<br/>Based on metrics| What{Scale based<br/>on what?}
    
    What -->|CPU/Memory<br/>Traffic patterns| HPA[✅ HPA<br/>Horizontal Pod Autoscaler<br/>Adds more pods]
    
    What -->|Resource requests<br/>Right-sizing| VPA[✅ VPA<br/>Vertical Pod Autoscaler<br/>Adjusts CPU/memory requests]
    
    What -->|Both| Both[✅ HPA + VPA<br/>Use together<br/>with updateMode: Auto]
    
    HPA --> Warning1[⚠️ Requires metrics-server]
    VPA --> Warning2[⚠️ Restarts pods when resizing]
    Both --> Warning3[⚠️ Complex - master HPA first]
    
    style HPA fill:#55efc4
    style VPA fill:#fdcb6e
    style Both fill:#fab1a0
    style Manual fill:#dfe6e9
```

**When to Use What**:
- **Manual**: Dev/test environments, one-time events
- **HPA**: Production apps with variable traffic (e.g., web servers, APIs)
- **VPA**: Batch jobs, ML training (right-size resource requests)
- **HPA + VPA**: Advanced (scale out when busy, scale up when over-resourced)

---

## 5. Ingress vs. LoadBalancer (External Access)

```mermaid
flowchart TD
    Start[Expose to internet?] --> How{How many<br/>services?}
    
    How -->|One service<br/>Simple| LB[✅ LoadBalancer Service<br/>One external IP]
    
    How -->|Multiple services<br/>Path-based routing| Protocol{HTTP/HTTPS<br/>only?}
    
    Protocol -->|Yes<br/>Web traffic| Ingress[✅ Ingress<br/>One IP, path-based routing<br/>/api → backend<br/>/web → frontend]
    
    Protocol -->|No<br/>TCP/UDP/gRPC| Gateway[✅ Gateway API<br/>or multiple LoadBalancers]
    
    Ingress --> Features{Need advanced<br/>features?}
    Features -->|Basic routing| NGINX[NGINX Ingress Controller<br/>Most popular]
    Features -->|TLS, WAF, auth| Traefik[Traefik or Istio Gateway<br/>More features]
    
    style LB fill:#fd79a8
    style Ingress fill:#a29bfe
    style Gateway fill:#6c5ce7
    style NGINX fill:#55efc4
    style Traefik fill:#74b9ff
```

**Cost Comparison**:
- **LoadBalancer per service**: $30/month × 5 services = **$150/month** 💸
- **Ingress (one LoadBalancer)**: $30/month for all services = **$30/month** 💰

---

## 6. ConfigMap vs. Secret (Configuration)

```mermaid
flowchart TD
    Start[Store config data?] --> Sensitive{Is data<br/>sensitive?}
    
    Sensitive -->|Yes<br/>Passwords, keys, certs| Secret[✅ Secret<br/>base64-encoded<br/>Encrypted at rest]
    
    Sensitive -->|No<br/>Public config| ConfigMap[✅ ConfigMap<br/>Plain text]
    
    Secret --> Mount1{How to use?}
    ConfigMap --> Mount2{How to use?}
    
    Mount1 -->|Environment vars| SecretEnv[❌ Avoid<br/>Shows in 'kubectl describe']
    Mount1 -->|Volume mount| SecretVol[✅ Recommended<br/>Mount to /etc/secrets]
    
    Mount2 -->|Environment vars| CMEnv[✅ OK for config]
    Mount2 -->|Volume mount| CMVol[✅ OK for files]
    
    style Secret fill:#e17055
    style ConfigMap fill:#00b894
    style SecretVol fill:#00b894
    style SecretEnv fill:#d63031
```

**Best Practices**:
- **Never commit Secrets to Git** (use External Secrets Operator or sealed-secrets)
- **Rotate secrets regularly** (use K8s 1.24+ automatic secret rotation)
- **Use RBAC to restrict Secret access** (not all pods need all secrets)

---

## 7. Namespace Strategy (Multi-Tenancy)

```mermaid
flowchart TD
    Start[Organize resources?] --> Env{Separate by<br/>what?}
    
    Env -->|Environment<br/>Dev, staging, prod| EnvNS[✅ Namespace per env<br/>dev-app, staging-app, prod-app]
    
    Env -->|Team<br/>Multiple teams| TeamNS[✅ Namespace per team<br/>team-a, team-b, team-c]
    
    Env -->|Customer<br/>Multi-tenant SaaS| TenantNS[✅ Namespace per tenant<br/>customer-acme, customer-contoso]
    
    EnvNS --> Quota1{Need resource<br/>limits?}
    TeamNS --> Quota2{Need resource<br/>limits?}
    TenantNS --> Quota3{Need resource<br/>limits?}
    
    Quota1 -->|Yes| RQ1[Add ResourceQuota<br/>Limit CPU/memory per namespace]
    Quota2 -->|Yes| RQ2[Add ResourceQuota<br/>+ NetworkPolicy for isolation]
    Quota3 -->|Yes| RQ3[Add ResourceQuota<br/>+ NetworkPolicy<br/>+ RBAC per tenant]
    
    style EnvNS fill:#74b9ff
    style TeamNS fill:#a29bfe
    style TenantNS fill:#fd79a8
```

**Namespace Patterns**:
- **Default namespace**: Never use for production (use for testing only)
- **kube-system**: Reserved for K8s components (don't deploy apps here)
- **Your apps**: Always create dedicated namespaces

---

## 🎯 How to Use These Trees

1. **Bookmark this page** for quick reference during lab work
2. **Start at the top** of each tree and follow the YES/NO arrows
3. **Check the colored boxes** for the recommended resource type
4. **Read the warnings** (⚠️) for gotchas and prerequisites

**Example Walkthrough** (Tree #1):
- Question: "Does my app need stable identity?"
- Answer: "No, it's a stateless API"
- Follow arrow: "No" → "Run on EVERY node?"
- Answer: "No, just replicas"
- **Result**: ✅ Use **Deployment**

---

## 📚 Learn More

Each decision tree maps to specific labs:
- **Tree #1 (Deployment types)**: [Lab 2](../labs/02-ecommerce-basics.md), [Lab 3](../labs/03-educational-stateful.md)
- **Tree #2 (Service types)**: [Lab 1](../labs/01-weather-basics.md), [Lab 5](../labs/05-task-ingress.md)
- **Tree #3 (Storage)**: [Lab 3](../labs/03-educational-stateful.md)
- **Tree #4 (Scaling)**: [Lab 7](../labs/07-social-scaling.md)
- **Tree #5 (External access)**: [Lab 5](../labs/05-task-ingress.md)
- **Tree #6 (Config)**: [Lab 2](../labs/02-ecommerce-basics.md), [Lab 12](../labs/12-external-secrets.md)
- **Tree #7 (Namespaces)**: [Lab 8](../labs/08-multi-app.md), [Lab 8.5](../labs/08.5-multi-tenancy.md) *(coming soon)*

---

**💡 Pro Tip**: Print this page and keep it next to your laptop during labs. These trees save 10+ minutes of googling per deployment!
