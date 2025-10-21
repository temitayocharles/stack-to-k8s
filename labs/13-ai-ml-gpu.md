# Lab 13: AI/ML GPU Workloads 🤖🚀

**⏱ Time**: 90 minutes  
**🎯 Difficulty**: ⭐⭐⭐⭐ Expert  
**📋 Prerequisites**: Labs 3 (StatefulSets), 7 (Monitoring), 9 (Helm)

> **Note for Windows Users**: This lab involves Linux-based GPU drivers and kernel modules. Windows users should use **WSL2 with GPU support** (Windows 11 with NVIDIA drivers) or connect to a cloud-based Kubernetes cluster (EKS, GKE, AKS) where GPU setup is managed by the cloud provider.

---

## 🎯 Objective

**The Problem**: Training ML models on your laptop takes **24 hours**. Production ML requires:
- 🔥 **GPU acceleration** (train in 2 hours, not 24)
- 🔥 **Distributed training** (use 8 GPUs simultaneously)
- 🔥 **Model serving** (deploy trained models as APIs)
- 🔥 **Cost optimization** ($2/hour GPUs sitting idle = $1,440/month waste)

**This Lab**: Deploy AI/ML workloads on Kubernetes with:
1. **GPU scheduling** (nvidia.com/gpu resource allocation)
2. **Jupyter notebooks** (interactive data science)
3. **TensorFlow training jobs** (distributed training)
4. **Model serving** (deploy models with KServe)
5. **GPU monitoring** (track utilization, cost per job)

**Why This Matters**: OpenAI runs **25,000+ GPUs** on Kubernetes. This lab teaches the fundamentals.

---

## 📚 Key Concepts

### GPU in Kubernetes

**Traditional (No K8s)**:
```
Data Scientist → SSH to GPU server → Train model
Problems:
- Only 1 person can use GPU at a time
- No isolation (user A crashes user B's job)
- No resource limits (one job consumes all GPU memory)
```

**With Kubernetes**:
```
Data Scientist → Submit K8s Job → Schedule on available GPU → Auto-scale
Benefits:
- Multiple users share GPU cluster (fair scheduling)
- Resource quotas (max 2 GPUs per user)
- Auto-scale GPU nodes (save money when idle)
```

### GPU Resource Types

| Resource | Description | Example |
|----------|-------------|---------|
| **nvidia.com/gpu** | Whole GPU (full 24GB) | Training large models |
| **nvidia.com/gpu-memory** | GPU memory slices (6GB) | Multiple small jobs |
| **nvidia.com/mig-1g.5gb** | Multi-Instance GPU (MIG) | Cost-effective shared GPUs |

**This Lab**: Uses whole GPUs (simplest, most common).

---

## 🔧 Setup: Install NVIDIA Device Plugin

### Prerequisites

**You need**:
- Kubernetes cluster with GPU nodes (AWS p3.2xlarge, GCP n1-standard-4 + Tesla T4, Azure NC6)
- OR: Minikube with GPU passthrough (advanced)

**For this lab**:
- If you have GPU nodes: Follow all steps
- If you don't have GPUs: Skip to **Part 6: CPU-Only Alternatives**

### Step 1: Verify GPU Nodes

```bash
# Check if nodes have GPUs
kubectl get nodes -o json | jq '.items[].status.capacity | select(."nvidia.com/gpu" != null)'

# Expected (if you have GPU nodes):
# {
#   "nvidia.com/gpu": "1",
#   "cpu": "4",
#   "memory": "16Gi"
# }

# If empty: Your cluster has no GPU nodes (see cloud provider setup below)
```

### Step 2: Cloud Provider GPU Node Setup

**AWS EKS**:
```bash
# Create GPU node group (p3.2xlarge = 1x V100)
eksctl create nodegroup \
  --cluster=my-cluster \
  --name=gpu-nodes \
  --node-type=p3.2xlarge \
  --nodes=1 \
  --nodes-min=0 \
  --nodes-max=3 \
  --node-labels="workload=gpu"
```

**GCP GKE**:
```bash
# Create GPU node pool (n1-standard-4 + T4)
gcloud container node-pools create gpu-pool \
  --cluster=my-cluster \
  --accelerator=type=nvidia-tesla-t4,count=1 \
  --machine-type=n1-standard-4 \
  --num-nodes=1 \
  --min-nodes=0 \
  --max-nodes=3 \
  --enable-autoscaling \
  --node-labels=workload=gpu
```

**Azure AKS**:
```bash
# Create GPU node pool (Standard_NC6 = 1x K80)
az aks nodepool add \
  --resource-group=my-rg \
  --cluster-name=my-cluster \
  --name=gpupool \
  --node-count=1 \
  --node-vm-size=Standard_NC6 \
  --node-taints=sku=gpu:NoSchedule \
  --labels=workload=gpu
```

### Step 3: Install NVIDIA Device Plugin

```bash
# Install NVIDIA device plugin (DaemonSet)
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.0/nvidia-device-plugin.yml

# Verify plugin is running
kubectl get pods -n kube-system | grep nvidia
# Expected: nvidia-device-plugin-daemonset-* (Running on each GPU node)

# Check GPU resources are available
kubectl get nodes -o custom-columns=NAME:.metadata.name,GPUs:.status.capacity.'nvidia\.com/gpu'
# Expected: 
# NAME           GPUs
# gpu-node-1     1
```

**✅ GPU scheduling enabled!** Pods can now request `nvidia.com/gpu`.

---

## 🪐 Part 1: Simple GPU Test (Verify Setup)

### Step 1: Run GPU-Accelerated Pod

```yaml
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: gpu-test
spec:
  restartPolicy: OnFailure
  containers:
  - name: cuda-test
    image: nvidia/cuda:12.0.0-base-ubuntu22.04
    command: ["nvidia-smi"]
    resources:
      limits:
        nvidia.com/gpu: 1  # Request 1 GPU
EOF

# Wait for completion
kubectl wait --for=condition=Ready pod/gpu-test --timeout=300s

# Check output
kubectl logs gpu-test
# Expected:
# +-----------------------------------------------------------------------------+
# | NVIDIA-SMI 525.60.13    Driver Version: 525.60.13    CUDA Version: 12.0   |
# |-------------------------------+----------------------+----------------------+
# | GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
# |   0  Tesla V100-SXM2...  Off  | 00000000:00:1E.0 Off |                    0 |
# +-----------------------------------------------------------------------------+

# Cleanup
kubectl delete pod gpu-test
```

**✅ Success!** Pod can access GPU.

---

## 📓 Part 2: JupyterHub (Interactive Data Science)

### Step 1: Install JupyterHub

```bash
# Add Helm repo
helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
helm repo update

# Create namespace
kubectl create namespace jupyterhub

# Install JupyterHub
helm install jupyterhub jupyterhub/jupyterhub \
  --namespace jupyterhub \
  --version 3.0.3 \
  --values - <<EOF
proxy:
  service:
    type: LoadBalancer
singleuser:
  image:
    name: jupyter/tensorflow-notebook
    tag: "2023-11-19"
  profileList:
  - display_name: "CPU Only (2 cores, 4GB)"
    description: "For data exploration"
    kubespawner_override:
      cpu_limit: 2
      cpu_guarantee: 1
      mem_limit: "4G"
      mem_guarantee: "2G"
  - display_name: "GPU (1x Tesla T4, 8GB)"
    description: "For model training"
    kubespawner_override:
      cpu_limit: 4
      cpu_guarantee: 2
      mem_limit: "16G"
      mem_guarantee: "8G"
      extra_resource_limits:
        nvidia.com/gpu: "1"
hub:
  config:
    Authenticator:
      admin_users:
        - admin
    DummyAuthenticator:
      password: jupyter123  # Change in production!
    JupyterHub:
      authenticator_class: dummy
EOF

# Wait for deployment (2-3 minutes)
kubectl rollout status -n jupyterhub deploy/hub

# Get LoadBalancer IP
kubectl get svc -n jupyterhub proxy-public
# Note the EXTERNAL-IP
```

### Step 2: Access JupyterHub

```bash
# Get JupyterHub URL
JUPYTER_URL=$(kubectl get svc -n jupyterhub proxy-public -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "JupyterHub: http://$JUPYTER_URL"

# Login:
# - Username: admin
# - Password: jupyter123

# Select profile: "GPU (1x Tesla T4, 8GB)"
# Wait for pod to start (30-60s)
```

### Step 3: Test GPU in Jupyter Notebook

**In Jupyter Notebook**, create new notebook and run:

```python
# Cell 1: Verify GPU is available
import tensorflow as tf

print("TensorFlow version:", tf.__version__)
print("GPUs available:", tf.config.list_physical_devices('GPU'))
# Expected: [PhysicalDevice(name='/physical_device:GPU:0', device_type='GPU')]

# Cell 2: Simple GPU computation
import numpy as np

# Create random data
X = np.random.rand(10000, 100).astype('float32')
y = np.random.rand(10000, 1).astype('float32')

# Build model (runs on GPU automatically)
model = tf.keras.Sequential([
    tf.keras.layers.Dense(64, activation='relu', input_shape=(100,)),
    tf.keras.layers.Dense(32, activation='relu'),
    tf.keras.layers.Dense(1)
])

model.compile(optimizer='adam', loss='mse')

# Train (watch GPU utilization spike!)
model.fit(X, y, epochs=10, batch_size=32)

# Cell 3: Monitor GPU usage
!nvidia-smi
# Shows GPU memory usage (should be ~2-4GB during training)
```

**✅ Success!** Jupyter notebooks can access GPU for interactive ML.

---

## 🏋️ Part 3: Distributed Training (TensorFlow)

### Step 1: Create Training Dataset (ConfigMap)

```yaml
kubectl create namespace ml-training

kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: training-script
  namespace: ml-training
data:
  train.py: |
    import tensorflow as tf
    import os
    
    # Multi-GPU strategy
    strategy = tf.distribute.MirroredStrategy()
    print(f'Number of devices: {strategy.num_replicas_in_sync}')
    
    # Load MNIST dataset
    (x_train, y_train), (x_test, y_test) = tf.keras.datasets.mnist.load_data()
    x_train = x_train / 255.0
    x_test = x_test / 255.0
    
    # Build model inside strategy scope
    with strategy.scope():
        model = tf.keras.Sequential([
            tf.keras.layers.Flatten(input_shape=(28, 28)),
            tf.keras.layers.Dense(128, activation='relu'),
            tf.keras.layers.Dropout(0.2),
            tf.keras.layers.Dense(10, activation='softmax')
        ])
        model.compile(optimizer='adam',
                      loss='sparse_categorical_crossentropy',
                      metrics=['accuracy'])
    
    # Train
    model.fit(x_train, y_train, epochs=5, batch_size=64)
    
    # Evaluate
    test_loss, test_acc = model.evaluate(x_test, y_test)
    print(f'Test accuracy: {test_acc:.4f}')
    
    # Save model
    model.save('/output/mnist_model.h5')
    print('Model saved to /output/mnist_model.h5')
EOF
```

### Step 2: Create Persistent Volume (for model storage)

```yaml
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: model-storage
  namespace: ml-training
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
EOF
```

### Step 3: Create Training Job (1 GPU)

```yaml
kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: mnist-training
  namespace: ml-training
spec:
  template:
    spec:
      restartPolicy: OnFailure
      containers:
      - name: trainer
        image: tensorflow/tensorflow:2.14.0-gpu
        command: ["python", "/scripts/train.py"]
        resources:
          limits:
            nvidia.com/gpu: 1  # Request 1 GPU
            memory: "8Gi"
            cpu: "4"
          requests:
            memory: "4Gi"
            cpu: "2"
        volumeMounts:
        - name: training-script
          mountPath: /scripts
        - name: model-storage
          mountPath: /output
      volumes:
      - name: training-script
        configMap:
          name: training-script
      - name: model-storage
        persistentVolumeClaim:
          claimName: model-storage
EOF

# Monitor training
kubectl logs -n ml-training -f job/mnist-training
# Expected:
# Number of devices: 1
# Epoch 1/5 ... loss: 0.2956 - accuracy: 0.9145
# ...
# Test accuracy: 0.9782
# Model saved to /output/mnist_model.h5
```

### Step 4: Distributed Training (Multi-GPU)

For **multi-GPU** training (e.g., 4 GPUs), use **TensorFlow Distributed Training**:

```yaml
kubectl apply -f - <<EOF
apiVersion: kubeflow.org/v1
kind: TFJob
metadata:
  name: mnist-dist-training
  namespace: ml-training
spec:
  tfReplicaSpecs:
    # Chief worker (orchestrates training)
    Chief:
      replicas: 1
      template:
        spec:
          containers:
          - name: tensorflow
            image: tensorflow/tensorflow:2.14.0-gpu
            command: ["python", "/scripts/train.py"]
            resources:
              limits:
                nvidia.com/gpu: 1
            volumeMounts:
            - name: training-script
              mountPath: /scripts
          volumes:
          - name: training-script
            configMap:
              name: training-script
    # Worker replicas (parallel training)
    Worker:
      replicas: 3  # 3 additional workers = 4 GPUs total
      template:
        spec:
          containers:
          - name: tensorflow
            image: tensorflow/tensorflow:2.14.0-gpu
            command: ["python", "/scripts/train.py"]
            resources:
              limits:
                nvidia.com/gpu: 1
            volumeMounts:
            - name: training-script
              mountPath: /scripts
          volumes:
          - name: training-script
            configMap:
              name: training-script
EOF
```

**Note**: TFJob requires **Kubeflow Training Operator** (install: `kubectl apply -k "github.com/kubeflow/training-operator/manifests/overlays/standalone?ref=v1.7.0"`).

**✅ Success!** Training jobs use GPUs efficiently (auto-terminate when done).

---

## 🚀 Part 4: Model Serving (KServe)

### Step 1: Install KServe

```bash
# Install cert-manager (prerequisite)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Wait for cert-manager
kubectl rollout status -n cert-manager deploy

# Install KServe
kubectl apply -f https://github.com/kserve/kserve/releases/download/v0.11.0/kserve.yaml

# Verify
kubectl get pods -n kserve
# Expected: kserve-controller-manager (Running)
```

### Step 2: Deploy Trained Model

```yaml
kubectl apply -f - <<EOF
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: mnist-model
  namespace: ml-training
spec:
  predictor:
    tensorflow:
      storageUri: "pvc://model-storage/"  # Load from PVC
      resources:
        limits:
          nvidia.com/gpu: 1  # GPU for inference
          memory: "4Gi"
          cpu: "2"
        requests:
          memory: "2Gi"
          cpu: "1"
EOF

# Wait for deployment
kubectl wait --for=condition=Ready inferenceservice/mnist-model -n ml-training --timeout=300s

# Get model URL
kubectl get inferenceservice mnist-model -n ml-training
# Expected: URL = http://mnist-model.ml-training.svc.cluster.local/v1/models/mnist-model:predict
```

### Step 3: Test Model Inference

```bash
# Create test image (digit "7")
kubectl run curl-test --image=curlimages/curl -n ml-training --rm -it -- sh

# Inside pod:
cat > payload.json <<EOF
{
  "instances": [
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.5,0.9,
     1,1,1,1,0.8,0.4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0.1,0.9,1,1,1,1,1,1,0.2,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0.1,0.9,1,1,1,1,0.8,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.7,1,1,0.9,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.7,1,0.9,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.7,1,0.8,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.6,1,0.8,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.5,1,0.8,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.5,1,0.8,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.4,1,0.8,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.3,1,0.8,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
  ]
}
EOF

curl -X POST http://mnist-model.ml-training.svc.cluster.local/v1/models/mnist-model:predict \
  -H "Content-Type: application/json" \
  -d @payload.json

# Expected:
# {
#   "predictions": [[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.99, 0.0, 0.01]]
# }
# Index 7 has highest probability (predicted: "7")
```

**✅ Success!** Model serves predictions on GPU (low latency inference).

---

## 💰 Part 5: GPU Cost Optimization

### Problem: Idle GPU Costs

```
GPU node: $2/hour (AWS p3.2xlarge)
Idle 50% of time = $720/month wasted
```

### Solution 1: Cluster Autoscaler (Scale to Zero)

```yaml
kubectl apply -f - <<EOF
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: mnist-model-hpa
  namespace: ml-training
spec:
  scaleTargetRef:
    apiVersion: serving.kserve.io/v1beta1
    kind: InferenceService
    name: mnist-model
  minReplicas: 0  # Scale to zero when no traffic
  maxReplicas: 5
  targetCPUUtilizationPercentage: 70
EOF
```

**With Cluster Autoscaler**:
- No traffic → 0 replicas → Node scales down → $0/hour
- Traffic arrives → Pods scale up → Node scales up → $2/hour

### Solution 2: Spot Instances (70% Cheaper)

```bash
# AWS EKS: Use spot instances for GPU nodes
eksctl create nodegroup \
  --cluster=my-cluster \
  --name=gpu-spot-nodes \
  --node-type=p3.2xlarge \
  --nodes=0 \
  --nodes-min=0 \
  --nodes-max=3 \
  --spot  # ← 70% cheaper than on-demand

# Add toleration to training jobs
kubectl patch job mnist-training -n ml-training --type json -p='[
  {"op": "add", "path": "/spec/template/spec/tolerations", "value": [
    {"key": "nvidia.com/gpu", "operator": "Exists", "effect": "NoSchedule"}
  ]}
]'
```

### Solution 3: GPU Sharing (Time-Slicing)

**Install NVIDIA GPU Time-Slicing**:
```bash
# Configure 4 slices per GPU (4 jobs share 1 GPU)
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: time-slicing-config
  namespace: kube-system
data:
  any: |-
    version: v1
    sharing:
      timeSlicing:
        replicas: 4
EOF

# Restart device plugin
kubectl delete pod -n kube-system -l name=nvidia-device-plugin-ds
```

**Result**: 1 GPU serves 4 small jobs (4x utilization, 75% cost savings).

---

## 📊 Part 6: GPU Monitoring (Prometheus + Grafana)

### Step 1: Install DCGM Exporter (GPU Metrics)

```bash
helm repo add gpu-helm-charts https://nvidia.github.io/dcgm-exporter/helm-charts
helm repo update

helm install dcgm-exporter gpu-helm-charts/dcgm-exporter \
  --namespace kube-system \
  --set serviceMonitor.enabled=true
```

### Step 2: Prometheus Queries

```promql
# GPU utilization (%)
DCGM_FI_DEV_GPU_UTIL

# GPU memory usage (MB)
DCGM_FI_DEV_FB_USED

# GPU temperature (Celsius)
DCGM_FI_DEV_GPU_TEMP

# GPU power usage (Watts)
DCGM_FI_DEV_POWER_USAGE

# Cost per job (assumes $2/hour)
sum(DCGM_FI_DEV_GPU_UTIL) * (2/3600) * on(pod) group_left(job_name) kube_pod_labels{label_job_name!=""}
```

### Step 3: Grafana Dashboard

```bash
# Import NVIDIA GPU dashboard (ID 12239)
# https://grafana.com/grafana/dashboards/12239-nvidia-dcgm-exporter-dashboard/

# Metrics to track:
# - GPU utilization (should be >70% to justify cost)
# - GPU memory usage (detect memory leaks)
# - Pod GPU allocation (which pods use GPUs)
# - Cost per namespace (label-based billing)
```

**✅ Success!** You can now track GPU utilization and optimize costs.

---

## 🖥️ Part 7: CPU-Only Alternatives (No GPU)

If you don't have GPU nodes, you can still practice ML on Kubernetes:

### Option 1: Use CPU-Only Images

```yaml
# Replace GPU image
image: tensorflow/tensorflow:2.14.0-gpu
# With CPU image
image: tensorflow/tensorflow:2.14.0

# Remove GPU resource requests
resources:
  limits:
    nvidia.com/gpu: 1  # ← Remove this
```

### Option 2: Simulate GPU with Resource Quotas

```yaml
# Treat CPU as "fake GPU" for learning
resources:
  limits:
    cpu: "4"  # Simulate 1 GPU = 4 CPUs
    memory: "16Gi"
```

### Option 3: Cloud ML Services

| Provider | Service | Description |
|----------|---------|-------------|
| **AWS** | SageMaker | Managed ML training (Jupyter + GPU) |
| **GCP** | Vertex AI | AutoML + custom training |
| **Azure** | Machine Learning | Full ML lifecycle |

**Cost**: ~$1-5/hour (cheaper than managing GPU cluster).

---

## 🎓 Key Takeaways

### What You Learned
1. **GPU Scheduling**: Pods request `nvidia.com/gpu` resource
2. **JupyterHub**: Interactive notebooks with GPU access
3. **Training Jobs**: Batch training with auto-termination
4. **Model Serving**: Deploy models with KServe (GPU inference)
5. **Cost Optimization**: Autoscaling, spot instances, GPU sharing
6. **GPU Monitoring**: Track utilization, cost per job

### GPU Workflow Summary

```
1. Data Scientist → Submit Jupyter pod (GPU profile)
2. Train model interactively → Save to PVC
3. Convert to Training Job (batch) → Train on multiple GPUs
4. Deploy with KServe → Serve predictions (GPU inference)
5. Monitor GPU utilization → Scale down when idle
```

### Production Checklist
- [ ] Install NVIDIA device plugin on GPU nodes
- [ ] Configure cluster autoscaler (scale GPU nodes to zero)
- [ ] Use spot instances for training (70% cost savings)
- [ ] Set resource quotas (max GPUs per namespace)
- [ ] Monitor GPU utilization (>70% target)
- [ ] Enable GPU sharing for small jobs (time-slicing)
- [ ] Automate model versioning (MLflow, Kubeflow)
- [ ] Set up alerts for idle GPUs (>1 hour unused)

---

## 🔄 What's Next?

- **[Lab 7: Monitoring with Prometheus](07-monitoring.md)** → Add GPU metrics to dashboards
- **[Lab 9.5: Complex Microservices](09.5-complex-microservices.md)** → Deploy ML models with service mesh
- **[Lab 11: GitOps with ArgoCD](11-gitops-argocd.md)** → Automate ML pipeline deployments

---

## 🤔 Common Questions

**Q: Do I need GPUs for ML?**  
A: **Small models** (MNIST, tabular data): CPU is fine. **Large models** (LLMs, image generation): GPU required (100x faster).

**Q: Which GPU should I use?**  
A: **Training**: V100, A100 (high memory). **Inference**: T4 (cheap, efficient). **Prototyping**: K80 (old, but cheapest).

**Q: GPU vs. TPU?**  
A: **GPU** (NVIDIA): Universal (TensorFlow, PyTorch, ONNX). **TPU** (Google): TensorFlow only, faster for large-scale training. Start with GPU.

**Q: How to share GPUs between teams?**  
A: Use **ResourceQuotas** per namespace (e.g., team-a: max 2 GPUs, team-b: max 4 GPUs). Or use **GPU time-slicing** (4 jobs share 1 GPU).

**Q: What about multi-node training (8+ GPUs)?**  
A: Use **Kubeflow** or **Ray** (distributed training frameworks). This lab covers single-node (1-4 GPUs).

**Q: Can I use GPUs for non-ML workloads?**  
A: Yes! GPUs accelerate: video encoding (FFmpeg), 3D rendering (Blender), crypto mining (don't do this 😅), scientific computing (CUDA).

---

## 🧹 Cleanup

```bash
# Delete training jobs
kubectl delete namespace ml-training

# Delete JupyterHub
helm uninstall jupyterhub -n jupyterhub
kubectl delete namespace jupyterhub

# Delete KServe
kubectl delete -f https://github.com/kserve/kserve/releases/download/v0.11.0/kserve.yaml

# Delete NVIDIA device plugin
kubectl delete -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.0/nvidia-device-plugin.yml

# Delete GPU node pool (to stop GPU costs)
# AWS: eksctl delete nodegroup --cluster=my-cluster --name=gpu-nodes
# GCP: gcloud container node-pools delete gpu-pool --cluster=my-cluster
# Azure: az aks nodepool delete --resource-group=my-rg --cluster-name=my-cluster --name=gpupool
```

---

**🎉 Congrats!** You can now run AI/ML workloads at scale like OpenAI. Time to train some LLMs! 🤖🚀
