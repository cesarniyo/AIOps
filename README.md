# AIOps




# Interacting with the deployed cluster
1. Install Required CLI Tools (If Not Already Installed)
• AWS CLI v2
• kubectl: Used to inspect nodes, deploy containers, and check logs inside Kubernetes.
           (sudo snap install kubectl --classic)
2. Configure Your test-user Credentials Locally
aws configure
	• AWS Access Key ID: <your-test-user-access-key>
	• AWS Secret Access Key: <your-test-user-secret-key>
	• Default region name: us-east-2
	• Default output format: json
3. Verify your terminal is authenticated as test-user:bash


3. Connect kubectl to Your EKS Cluster
aws eks update-kubeconfig --region us-east-2 --name test-aiops-use2-eks


4. Run Your First kubectl Commands
kubectl cluster-info
kubectl get namespaces
kubectl get nodes
kubectl get pods -A

5. Deploy and Manage Applications
Once kubectl get nodes shows your EC2 nodes as Ready, you interact with the cluster by applying declarative YAML files:
bash
# Deploy an application (Deployment, Service, Secrets, etc.)
kubectl apply -f deployment.yaml

# Check running pods and public LoadBalancer URLs
kubectl get pods
kubectl get services

# View live container logs or open a shell inside a pod
kubectl logs <pod-name>
kubectl exec -it <pod-name> -- /bin/sh

# View you application
kubectl get svc flask-app-service (glab the <EXTERNAL-IP> )
Open http://<EXTERNAL-IP> in your browser.