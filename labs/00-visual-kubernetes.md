# Lab 0: See Kubernetes Think
**Time**: 15 minutes  
**Difficulty**: ⭐ Beginner  
**Goal**: Install visual tools to watch Kubernetes in action

---

## 🎯 Why This Lab Exists

Kubernetes manages containers invisibly. You run `kubectl apply` and... magic? Not anymore.

**You'll install 3 tools that let you SEE what Kubernetes is doing in real-time.**

---

## 🛠️ Install Visual Tools

### 1. k9s - Kubernetes Dashboard in Terminal (5 min)

**What it does**: Live view of all Kubernetes resources. Like `kubectl get` on steroids.

```bash
# macOS
brew install derailed/k9s/k9s

# Linux
curl -sS https://webinstall.sh/k9s | bash

# Windows
scoop install k9s

# Verify
k9s version
```

### 2. stern - Multi-Pod Log Streaming (3 min)

**What it does**: Tail logs from multiple pods at once. Essential for debugging.

```bash
# macOS
brew install stern

# Linux
wget https://github.com/stern/stern/releases/download/v1.28.0/stern_1.28.0_linux_amd64.tar.gz
tar -xzf stern_1.28.0_linux_amd64.tar.gz
sudo mv stern /usr/local/bin/

# Windows
scoop install stern

# Verify
stern --version
```

### 3. kubectl tree - Visualize Object Relationships (2 min)

**What it does**: Shows how Deployments → ReplicaSets → Pods → Containers are connected.

```bash
# Install krew (kubectl plugin manager) first
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

# Add to PATH
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Install tree plugin
kubectl krew install tree

# Verify
kubectl tree --help
```

---

## 🚀 Test Drive Your New Powers

### Deploy a Test App

```bash
# Create test namespace
kubectl create namespace lab0-test

# Deploy nginx
kubectl create deployment nginx --image=nginx:latest -n lab0-test
kubectl expose deployment nginx --port=80 --target-port=80 -n lab0-test
kubectl scale deployment nginx --replicas=3 -n lab0-test
```

### 👀 Watch Mode #1: k9s

```bash
k9s -n lab0-test

# Inside k9s:
# Press '0' → View pods
# Press 'l' → View logs of selected pod
# Press 'd' → Describe selected pod
# Press 's' → Shell into pod
# Press 'ctrl-k' → Delete selected pod (watch it respawn!)
# Press ':svc' → Switch to services view
# Press ':deploy' → Switch to deployments view
# Press 'q' → Quit
```

**🎯 Challenge**: Delete a pod and watch Kubernetes recreate it in < 10 seconds.

### 🔬 Watch Mode #2: stern

```bash
# Stream logs from all nginx pods
stern nginx -n lab0-test

# In another terminal, generate logs
kubectl run -it --rm test-curl --image=curlimages/curl --restart=Never -n lab0-test -- \
  sh -c "for i in {1..20}; do curl -s nginx; sleep 1; done"

# Watch stern show logs from all 3 pods in real-time!
```

**🎯 Success**: You see logs from multiple pods color-coded in one stream.

### 🌲 Watch Mode #3: kubectl tree

```bash
# See the hierarchy
kubectl tree deployment nginx -n lab0-test

# Output shows:
# Deployment → ReplicaSet → Pods
```

**Example output**:
```
NAMESPACE   NAME                                READY  REASON  AGE
lab0-test   Deployment/nginx                    -              2m
lab0-test   └─ReplicaSet/nginx-748c667d99       -              2m
lab0-test     ├─Pod/nginx-748c667d99-7xkqm      True           2m
lab0-test     ├─Pod/nginx-748c667d99-bs4zv      True           2m
lab0-test     └─Pod/nginx-748c667d99-m8pnl      True           2m
```

---

## 🧹 Cleanup

```bash
kubectl delete namespace lab0-test
```

---

## 🎓 What You Learned

✅ **k9s**: Navigate Kubernetes visually (no more memorizing kubectl commands)  
✅ **stern**: Debug by watching all pods simultaneously  
✅ **kubectl tree**: Understand how objects relate to each other  

**From now on**: Every lab will have "👀 Watch Mode" sections using these tools.

---

## 🚀 Next Lab

**[Lab 1: Weather App Basics](01-weather-basics.md)**

Now that you can SEE Kubernetes, let's deploy your first real app!
