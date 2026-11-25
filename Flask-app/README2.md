# Deploying a Flask App on AWS EKS (Kubernetes)

This guide walks through creating an EKS cluster on AWS and deploying a simple Flask application to it — with both a plain `kubectl` path and a Helm chart path.

---

## Prerequisites

Install these tools locally:

```bash
# AWS CLI
brew install awscli          # or see https://aws.amazon.com/cli/

# kubectl (Kubernetes CLI)
brew install kubectl

# eksctl (EKS cluster management CLI)
brew install eksctl

# Docker (to build container images)
brew install --cask docker
```

Configure AWS credentials:

```bash
aws configure
# Enter your AWS Access Key ID, Secret Key, region (e.g. us-east-1), output format
```

---

## Step 1: Create the EKS Cluster

`eksctl` is the simplest way to stand up a cluster — it provisions the control plane, worker nodes, VPC, and networking for you.

```bash
eksctl create cluster \
  --name flask-demo-cluster \
  --region us-east-1 \
  --nodegroup-name flask-nodes \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 3 \
  --managed
```

This takes **~15-20 minutes**. It creates a CloudFormation stack with a VPC, subnets, an EKS control plane, and an autoscaling managed node group.

Once done, verify:

```bash
kubectl get nodes
```

You should see 2 nodes in `Ready` state. `eksctl` automatically updates your `~/.kube/config` so `kubectl` points at the new cluster.

---

## Step 2: Create a Simple Flask App

```
flask-app/
├── app.py
├── requirements.txt
└── Dockerfile
```

**`app.py`**
```python
from flask import Flask, jsonify
import socket

app = Flask(__name__)

@app.route("/")
def home():
    return jsonify(
        message="Hello from Flask on EKS!",
        hostname=socket.gethostname()
    )

@app.route("/health")
def health():
    return jsonify(status="ok")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

**`requirements.txt`**
```
flask==3.0.3
gunicorn==22.0.0
```

**`Dockerfile`**
```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
```

---

## Step 3: Build and Push the Image to Amazon ECR

Create a repository in ECR:

```bash
aws ecr create-repository --repository-name flask-demo --region us-east-1
```

Authenticate Docker to ECR (replace `<ACCOUNT_ID>` with your AWS account ID):

```bash
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
```

Build, tag, and push:

```bash
docker build -t flask-demo .

docker tag flask-demo:latest <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/flask-demo:latest

docker push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/flask-demo:latest
```

---

## Using Helm Instead of Raw Manifests

Helm is a package manager for Kubernetes — instead of hand-editing `deployment.yaml` and `service.yaml` and re-running `kubectl apply` every time, you define a **chart** (a templated bundle of manifests) with a `values.yaml` for the settings that change (image tag, replica count, etc). This is the standard way to do it once you have more than a toy example, and it's what most real EKS deployments use.

### Install Helm

```bash
brew install helm

# verify
helm version
```

### Scaffold a Chart

```bash
helm create flask-demo-chart
```

This generates a standard chart structure:

```
flask-demo-chart/
├── Chart.yaml
├── values.yaml
├── charts/
└── templates/
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    ├── serviceaccount.yaml
    ├── hpa.yaml
    ├── _helpers.tpl
    ├── NOTES.txt
    └── tests/
```

You could edit the generated templates, but for this simple app it's easier to replace `values.yaml` and trim `templates/` down to just `deployment.yaml` and `service.yaml`. Delete `ingress.yaml`, `hpa.yaml`, `serviceaccount.yaml`, and `tests/` for now — you can add them back later.

**`values.yaml`**
```yaml
replicaCount: 2

image:
  repository: <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/flask-demo
  tag: latest
  pullPolicy: IfNotPresent

service:
  type: LoadBalancer
  port: 80
  targetPort: 5000

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 250m
    memory: 256Mi

healthCheckPath: /health
```

**`templates/deployment.yaml`**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}
  labels:
    app: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
    spec:
      containers:
        - name: {{ .Release.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - containerPort: {{ .Values.service.targetPort }}
          readinessProbe:
            httpGet:
              path: {{ .Values.healthCheckPath }}
              port: {{ .Values.service.targetPort }}
            initialDelaySeconds: 5
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
```

**`templates/service.yaml`**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-service
spec:
  type: {{ .Values.service.type }}
  selector:
    app: {{ .Release.Name }}
  ports:
    - protocol: TCP
      port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
```

You can delete the default `Chart.yaml` boilerplate content it generated and just keep the name/version fields, or leave it as-is — it works out of the box.

### Deploy with Helm

Preview the rendered manifests first (good sanity check before anything touches the cluster):

```bash
helm template flask-demo ./flask-demo-chart
```

Install (this is the Helm equivalent of `kubectl apply` for both files at once):

```bash
helm install flask-demo ./flask-demo-chart
```

Check status:

```bash
helm list
helm status flask-demo
kubectl get pods
kubectl get svc flask-demo-service
```

### Updating

Change something in `values.yaml` (e.g. bump `replicaCount` to 4, or point `image.tag` at a new build), then:

```bash
helm upgrade flask-demo ./flask-demo-chart
```

Or override values inline without editing the file:

```bash
helm upgrade flask-demo ./flask-demo-chart --set replicaCount=4 --set image.tag=v2
```

Rollback if something breaks:

```bash
helm rollback flask-demo 1
```

View release history:

```bash
helm history flask-demo
```

### Uninstall

```bash
helm uninstall flask-demo
```

This removes everything Helm created (Deployment + Service), replacing the manual `kubectl delete -f ...` step below.

### Why bother with Helm for something this small?

For a single Flask app with one Deployment and one Service, raw `kubectl apply` is honestly fine. Helm starts paying off once you have: multiple environments (dev/staging/prod) that share the same templates but different values, a chart with many resources (Deployment + Service + Ingress + ConfigMap + Secret + HPA), or you want versioned releases with one-command rollback. It's also how you'll consume most third-party software on Kubernetes (e.g. `helm install` for the AWS Load Balancer Controller, nginx-ingress, Prometheus, etc.) — so it's worth knowing even for small projects.

---

## Step 4: Write the Kubernetes Manifests (Alternative: Plain kubectl, No Helm)

If you'd rather skip Helm and just apply manifests directly, use this instead of the Helm section above.

**`deployment.yaml`**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-demo
  labels:
    app: flask-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: flask-demo
  template:
    metadata:
      labels:
        app: flask-demo
    spec:
      containers:
        - name: flask-demo
          image: <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/flask-demo:latest
          ports:
            - containerPort: 5000
          readinessProbe:
            httpGet:
              path: /health
              port: 5000
            initialDelaySeconds: 5
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "250m"
              memory: "256Mi"
```

**`service.yaml`**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: flask-demo-service
spec:
  type: LoadBalancer
  selector:
    app: flask-demo
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5000
```

---

## Step 5: Deploy to the Cluster (Non-Helm Path)

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

Check status:

```bash
kubectl get pods
kubectl get deployment flask-demo
kubectl get svc flask-demo-service
```

The `EXTERNAL-IP` column on the service will show `<pending>` at first — AWS is provisioning a Classic/Network Load Balancer. Wait a minute or two and check again:

```bash
kubectl get svc flask-demo-service -w
```

---

## Step 6: Test It

Once `EXTERNAL-IP` is populated:

```bash
curl http://<EXTERNAL-IP>/
# {"hostname":"flask-demo-xxxxxx","message":"Hello from Flask on EKS!"}

curl http://<EXTERNAL-IP>/health
# {"status":"ok"}
```

Refresh a few times — you should see the `hostname` value change between the two pod replicas, confirming load balancing is working.

---

## Useful Commands

```bash
# View logs from a pod
kubectl logs -l app=flask-demo

# Scale replicas
kubectl scale deployment flask-demo --replicas=4

# Update the image after a new push
kubectl set image deployment/flask-demo flask-demo=<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/flask-demo:latest

# Delete everything
kubectl delete -f service.yaml -f deployment.yaml
```

---

## Cleanup (avoid ongoing AWS charges)

```bash
kubectl delete -f service.yaml -f deployment.yaml
eksctl delete cluster --name flask-demo-cluster --region us-east-1
```

This tears down the nodes, control plane, and associated VPC/networking resources. Also delete the ECR repo if you don't need the image anymore:

```bash
aws ecr delete-repository --repository-name flask-demo --region us-east-1 --force
```

---

## Notes / Gotchas

- **IAM permissions**: Your AWS user/role needs permissions for EKS, EC2, CloudFormation, IAM (to create node roles), and ECR.
- **Costs**: EKS control plane is ~$0.10/hour, plus EC2 costs for nodes and the LoadBalancer (ELB) itself. Don't forget to tear down when done testing.
- **Production considerations** this example skips: Ingress + ALB Controller (instead of a raw LoadBalancer per service), HTTPS/TLS, autoscaling (HPA), secrets management, namespaces, and CI/CD for image builds.
