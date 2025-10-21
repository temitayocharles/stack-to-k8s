# 📜 Certification Alignment: CKA & CKAD Exam Prep

Map our labs to CNCF Kubernetes certifications (CKA, CKAD) to accelerate your exam prep.

---

## 🎯 Which Certification Should I Take?

| Certification | Focus | Audience | Exam Format |
|---------------|-------|----------|-------------|
| **CKAD** (Certified Kubernetes Application Developer) | **Deploying apps** | Developers, DevOps engineers | 2 hours, 15-20 tasks |
| **CKA** (Certified Kubernetes Administrator) | **Managing clusters** | SREs, Platform engineers | 2 hours, 15-20 tasks |
| **CKS** (Certified Kubernetes Security Specialist) | **Securing clusters** | Security engineers | 2 hours, 15-20 tasks (requires CKA first) |

**Recommendation**: Start with **CKAD** if you're focused on application deployment (matches these labs). Move to **CKA** if you need cluster administration skills.

---

## 📋 CKAD Exam Objectives → Lab Mapping

### Domain 1: Application Design and Build (20%)

| Objective | Lab(s) | Key Skills |
|-----------|--------|-----------|
| Define, build, modify container images | [Lab 2](../../20-labs/02-ecommerce-basics.md) | Dockerfile, multi-stage builds |
| Choose and use the right workload resource | [Lab 1-3](../../20-labs/01-weather-basics.md) + [Decision Trees](../cheatsheets/decision-trees.md) | Deployment vs. StatefulSet vs. DaemonSet |
| Understand multi-container pod patterns | [Lab 4](../../20-labs/04-kubernetes-fundamentals.md) | Sidecar, init containers |
| Utilize persistent and ephemeral volumes | [Lab 3](../../20-labs/03-educational-stateful.md) | PVC, emptyDir, ConfigMap mounts |

**Exam Tips**:
- ⚡ **Speed**: Know `kubectl run` shortcuts (e.g., `kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml`)
- 🔍 **Docs**: Bookmark https://kubernetes.io/docs/ (allowed during exam)
- 🧪 **Practice**: Complete Labs 1-4 under 2-hour time limit

---

### Domain 2: Application Deployment (20%)

| Objective | Lab(s) | Key Skills |
|-----------|--------|-----------|
| Use Kubernetes primitives to implement deployment strategies | [Lab 7](../../20-labs/07-social-scaling.md), [Lab 11](../../20-labs/11-gitops-argocd.md) | Rolling updates, blue/green, canary |
| Understand Deployments and rolling updates | [Lab 1](../../20-labs/01-weather-basics.md), [Lab 7](../../20-labs/07-social-scaling.md) | `kubectl rollout`, `maxSurge`, `maxUnavailable` |
| Use Helm package manager | [Lab 10](../../20-labs/10-helm-package-management.md) | `helm install`, `helm upgrade`, templating |

**Exam Tips**:
- ⚡ **Rollout commands**: `kubectl rollout status`, `kubectl rollout undo`
- 📝 **Helm shortcuts**: `helm create`, `helm template` (validate before install)
- 🧪 **Practice**: Deploy app, break it, rollback in < 5 minutes

---

### Domain 3: Application Observability and Maintenance (15%)

| Objective | Lab(s) | Key Skills |
|-----------|--------|-----------|
| Understand API deprecations | [Lab 4](../../20-labs/04-kubernetes-fundamentals.md) | `kubectl api-resources`, version migrations |
| Implement probes and health checks | [Lab 1-6](../../20-labs/01-weather-basics.md) + [Observability sections](../../20-labs/01-weather-basics.md#observability-check) | livenessProbe, readinessProbe, startupProbe |
| Monitor applications | [Lab 8](../../20-labs/08-multi-app.md), [Observability sections](../../20-labs/01-weather-basics.md#observability-check) | `kubectl top`, `kubectl logs`, metrics-server |
| Utilize container logs | All labs | `kubectl logs -f`, `stern`, `--previous` |
| Debugging | [Lab 4](../../20-labs/04-kubernetes-fundamentals.md), [Challenge Labs](../../20-labs/challenge-a-midnight-incident.md) | `kubectl describe`, `kubectl exec`, events |

**Exam Tips**:
- ⚡ **Log shortcuts**: `kubectl logs <pod> -c <container>` (multi-container pods)
- 🔍 **Debug workflow**: `kubectl get events` → `kubectl describe pod` → `kubectl logs`
- 🧪 **Practice**: Complete [Challenge A](../../20-labs/challenge-a-midnight-incident.md) in < 30 minutes

---

### Domain 4: Application Environment, Configuration, and Security (25%)

| Objective | Lab(s) | Key Skills |
|-----------|--------|-----------|
| Discover and use resources that extend Kubernetes (CRDs) | [Lab 11](../../20-labs/11-gitops-argocd.md), [Lab 12](../../20-labs/12-external-secrets.md) | ArgoCD Application, ExternalSecret CRDs |
| Understand authentication, authorization, admission control | [Lab 6](../../20-labs/06-medical-security.md) | RBAC, ServiceAccounts, admission webhooks |
| Understand Secrets and ConfigMaps | [Lab 2](../../20-labs/02-ecommerce-basics.md), [Lab 12](../../20-labs/12-external-secrets.md) | Secret types, immutable ConfigMaps |
| Understand SecurityContexts | [Lab 6](../../20-labs/06-medical-security.md) | `runAsNonRoot`, `readOnlyRootFilesystem`, capabilities |
| Define resource requirements | [Lab 7](../../20-labs/07-social-scaling.md) | `requests`, `limits`, LimitRanges |

**Exam Tips**:
- ⚡ **Secret creation**: `kubectl create secret generic <name> --from-literal=key=value`
- 📝 **RBAC shortcuts**: `kubectl create role`, `kubectl create rolebinding`
- 🧪 **Practice**: Create ServiceAccount, Role, RoleBinding in < 3 minutes

---

### Domain 5: Services and Networking (20%)

| Objective | Lab(s) | Key Skills |
|-----------|--------|-----------|
| Demonstrate basic understanding of NetworkPolicies | [Lab 6](../../20-labs/06-medical-security.md) | Ingress/egress rules, pod/namespace selectors |
| Provide and troubleshoot access to applications | [Lab 5](../../20-labs/05-task-ingress.md) | ClusterIP, NodePort, LoadBalancer, Ingress |
| Use Ingress rules to expose applications | [Lab 5](../../20-labs/05-task-ingress.md) | Path-based routing, TLS, NGINX ingress |

**Exam Tips**:
- ⚡ **Service shortcuts**: `kubectl expose deployment <name> --port=80 --target-port=8080`
- 🔍 **Network debugging**: `kubectl run curl --image=curlimages/curl -i --rm --restart=Never -- curl <service>`
- 🧪 **Practice**: Create Ingress with TLS in < 5 minutes

---

## 📋 CKA Exam Objectives → Lab Mapping

### Domain 1: Cluster Architecture, Installation & Configuration (25%)

| Objective | Lab(s) | Additional Resources |
|-----------|--------|---------------------|
| Manage RBAC | [Lab 6](../../20-labs/06-medical-security.md) | `kubectl auth can-i` |
| Use Kubeadm to install a cluster | ❌ Not covered | [Kubeadm docs](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/) |
| Manage cluster upgrades | ❌ Not covered | Practice on [Killercoda](https://killercoda.com/cka) |
| Implement etcd backup and restore | [Lab 11.5](../../20-labs/11.5-disaster-recovery.md) *(coming soon)* | Critical for CKA |
| Understand namespaces and resource quotas | [Lab 8](../../20-labs/08-multi-app.md), [Lab 8.5](../../20-labs/08.5-multi-tenancy.md) *(coming soon)* | ResourceQuota, LimitRanges |

**CKA-Specific Skills**:
- 🛠️ **etcd backup**: `etcdctl snapshot save /backup/etcd.db`
- 🛠️ **etcd restore**: `etcdctl snapshot restore /backup/etcd.db`
- 🧪 **Practice**: Use [Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way)

---

### Domain 2: Workloads & Scheduling (15%)

| Objective | Lab(s) | Key Skills |
|-----------|--------|-----------|
| Understand deployments and rolling updates | [Lab 1](../../20-labs/01-weather-basics.md), [Lab 7](../../20-labs/07-social-scaling.md) | `maxSurge`, `maxUnavailable` |
| Use ConfigMaps and Secrets | [Lab 2](../../20-labs/02-ecommerce-basics.md), [Lab 12](../../20-labs/12-external-secrets.md) | Environment vs. volume mounts |
| Scale applications | [Lab 7](../../20-labs/07-social-scaling.md) | HPA, manual scaling |
| Understand pod scheduling | [Lab 3.5](../../20-labs/03.5-kubernetes-under-the-hood.md) | Scheduler algorithm, taints/tolerations |

---

### Domain 3: Services & Networking (20%)

| Objective | Lab(s) | Key Skills |
|-----------|--------|-----------|
| Understand ClusterIP, NodePort, LoadBalancer | [Lab 1](../../20-labs/01-weather-basics.md), [Lab 5](../../20-labs/05-task-ingress.md) | Service types |
| Use Ingress controllers | [Lab 5](../../20-labs/05-task-ingress.md) | NGINX ingress |
| Know how to use CoreDNS | [Lab 3](../../20-labs/03-educational-stateful.md) | Headless services, DNS debugging |
| Understand NetworkPolicies | [Lab 6](../../20-labs/06-medical-security.md) | Ingress/egress rules |

---

### Domain 4: Storage (10%)

| Objective | Lab(s) | Key Skills |
|-----------|--------|-----------|
| Understand PersistentVolumes | [Lab 3](../../20-labs/03-educational-stateful.md) | PV, PVC, StorageClass |
| Configure applications with persistent storage | [Lab 3](../../20-labs/03-educational-stateful.md) | volumeMounts, StatefulSet volumeClaimTemplates |

---

### Domain 5: Troubleshooting (30%)

| Objective | Lab(s) | Key Skills |
|-----------|--------|-----------|
| Evaluate cluster and node logging | [Observability sections](../../20-labs/01-weather-basics.md#observability-check) | `kubectl logs`, `journalctl -u kubelet` |
| Monitor applications | [Lab 8](../../20-labs/08-multi-app.md) | Prometheus, Grafana |
| Troubleshoot application failures | [Challenge Labs](../../20-labs/challenge-a-midnight-incident.md) | Debug workflow |
| Troubleshoot cluster component failures | [Lab 3.5](../../20-labs/03.5-kubernetes-under-the-hood.md) | etcd, kube-apiserver, scheduler, controller-manager |
| Troubleshoot networking | [Lab 5](../../20-labs/05-task-ingress.md), [Lab 6](../../20-labs/06-medical-security.md) | DNS, NetworkPolicy, service endpoints |

**CKA Troubleshooting Workflow**:
```bash
# 1. Check cluster health
kubectl get nodes
kubectl get pods -A

# 2. Check logs (control plane)
kubectl logs -n kube-system <pod>

# 3. Check node logs (SSH to node)
journalctl -u kubelet
journalctl -u containerd

# 4. Check events
kubectl get events -A --sort-by='.lastTimestamp'
```

---

## ⚡ Exam Speedrun Cheatsheet

### CKAD Fast Commands

```bash
# Create pod YAML without applying
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml

# Create deployment YAML
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > deploy.yaml

# Expose deployment
kubectl expose deployment nginx --port=80 --target-port=8080 --dry-run=client -o yaml > svc.yaml

# Create ConfigMap from literal
kubectl create configmap app-config --from-literal=key=value

# Create Secret from file
kubectl create secret generic app-secret --from-file=password.txt

# Port-forward for testing
kubectl port-forward svc/nginx 8080:80

# Quick debug pod
kubectl run curl --image=curlimages/curl -i --rm --restart=Never -- curl http://service:80
```

### CKA Fast Commands

```bash
# Check RBAC permissions
kubectl auth can-i get pods --as=system:serviceaccount:default:mysa

# Drain node (maintenance)
kubectl drain <node> --ignore-daemonsets --delete-emptydir-data

# Uncordon node
kubectl uncordon <node>

# etcd backup
ETCDCTL_API=3 etcdctl snapshot save /backup/etcd.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# etcd restore
ETCDCTL_API=3 etcdctl snapshot restore /backup/etcd.db --data-dir=/var/lib/etcd-backup

# View kubelet logs
journalctl -u kubelet --no-pager | tail -50
```

---

## 🎯 Exam Prep Study Plan

### Week 1-2: Core Labs (CKAD focus)
- [ ] Complete Labs 1-4 (foundations)
- [ ] Master `kubectl` shortcuts (see above)
- [ ] Practice [Challenge A](../../20-labs/challenge-a-midnight-incident.md) 3 times

### Week 3-4: Advanced Labs (CKAD focus)
- [ ] Complete Labs 5-7 (ingress, security, scaling)
- [ ] Complete Labs 10-12 (Helm, GitOps, secrets)
- [ ] Practice [Challenge B](../../20-labs/challenge-b-black-friday.md) 3 times

### Week 5-6: Troubleshooting (CKA focus)
- [ ] Complete [Lab 3.5](../../20-labs/03.5-kubernetes-under-the-hood.md) (K8s internals)
- [ ] Complete [Challenge C](../../20-labs/challenge-c-platform-migration.md)
- [ ] Practice Killercoda CKA scenarios

### Week 7-8: Mock Exams
- [ ] Take [killer.sh](https://killer.sh/) mock exam (2 free with certification purchase)
- [ ] Review weak areas (check exam scorecard)
- [ ] Redo challenge labs under time pressure

**Total Prep Time**: 40-60 hours (10-15 hours/week for 6-8 weeks)

---

## 📚 Additional Resources

### Official Documentation
- 📖 [Kubernetes Docs](https://kubernetes.io/docs/) - Allowed during exam!
- 📖 [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- 📖 [CKAD Curriculum](https://github.com/cncf/curriculum/blob/master/CKAD_Curriculum_v1.28.pdf)
- 📖 [CKA Curriculum](https://github.com/cncf/curriculum/blob/master/CKA_Curriculum_v1.28.pdf)

### Practice Platforms
- 🧪 [Killercoda](https://killercoda.com/kubernetes) - Free K8s playground
- 🧪 [Killer.sh](https://killer.sh/) - Realistic mock exams (2 free with cert purchase)
- 🧪 [Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) - CKA cluster setup practice

### Community Resources
- 💬 [CNCF Slack #certifications](https://cloud-native.slack.com/)
- 📹 [KodeKloud CKAD/CKA Courses](https://kodekloud.com/)
- 📝 [CKAD Exercises](https://github.com/dgkanatsios/CKAD-exercises)

---

## 💡 Exam Day Tips

### Before the Exam
- ✅ Test your setup 24 hours before (webcam, mic, internet speed)
- ✅ Clear your desk (only water, one monitor, keyboard, mouse allowed)
- ✅ Have government-issued ID ready
- ✅ Practice `kubectl` autocomplete: `source <(kubectl completion bash)`

### During the Exam
- ⏱️ **Time management**: 2 hours = 6-8 minutes per question (flag hard ones, come back later)
- 📋 **Use the docs**: Bookmark https://kubernetes.io/docs/ search (CMD+F is your friend)
- 🧪 **Test everything**: Run `kubectl get pods` after each task to verify
- 🗑️ **Clean up**: Delete test resources to avoid confusion (e.g., `kubectl delete pod test-pod`)

### After Failed Tasks
- ❌ **Don't panic**: 66% passing score means you can miss 5-6 questions
- ⏭️ **Skip and return**: Flag hard questions, finish easy ones first
- 🔍 **Read carefully**: Question says "namespace: production"? Don't forget `-n production`!

---

## 🎓 Certification Progression Path

```
CKAD (App Developer)
  ↓ (if you like it)
CKA (Cluster Admin)
  ↓ (if security interests you)
CKS (Security Specialist)
```

**Most Common Path**: CKAD → Production K8s experience → CKA (after 6-12 months)

---

## 📊 Lab Coverage vs. Exam Objectives

| Exam Domain | Lab Coverage | Gap | Fill Gap With |
|-------------|--------------|-----|---------------|
| CKAD: Application Deployment | ✅ 90% | Helm advanced features | [Lab 10](../../20-labs/10-helm-package-management.md) |
| CKAD: Observability | ✅ 100% | None | [Observability sections](../../20-labs/01-weather-basics.md#observability-check) |
| CKAD: Security | ✅ 85% | Pod Security Standards | [Lab 6](../../20-labs/06-medical-security.md) + docs |
| CKA: Cluster Setup | ❌ 20% | Kubeadm, etcd | [Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) |
| CKA: Troubleshooting | ✅ 95% | Node troubleshooting | [Lab 3.5](../../20-labs/03.5-kubernetes-under-the-hood.md) |

**Recommendation**: Complete all labs → Practice Killercoda → Take killer.sh mock → Schedule exam

---

**🎯 Goal**: After completing these labs, you should be 70-80% ready for CKAD, 50-60% ready for CKA. The remaining prep focuses on speed (kubectl shortcuts) and exam-specific scenarios (kubeadm, cluster upgrades).

**Good luck!** 🚀
