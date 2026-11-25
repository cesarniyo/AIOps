

# ========================================================================================================================KUBANETIS THEORY 
# *K8s Definition:
 open source container orchestration tool
 helps you manage containerized application in different environments
 
 A CONTAINER: is nothing but a application with its dependences packages (wrapped) together
 
 
# What problem K8S came to solve : 
 Trend from Monolith to Microservices (small independent applications that work together) increased the usage of containers
 With the demand for a proper way of managing those hundreds of containers ==> K8s came as a solution to that problem
 
 
# k8s features:
   HIGH AVAILABILITY ===========> No downtime
   HIGH SCALABILITY  ===========> High perfomance (depending on load size)
   DISASTER RECOVERY ===========> Backup and restore
 

# *k8s Basic architecture and  processes
 Master Node- contains following components
        - API server container(cluster entrypoint) providing:  ui => we use browser to get dashboard 
                                                               api=> using curl
                                                               cli=> using kubectl
        - controller manager container: keeps track of what happening in the cluster       
        - scheduler          container: ensures Pods placement
        - etcd               container: hold the current state of the cluster (...whole cluster snapshot backups)
        - virtual network
        
 Worker Nodes - contains following components
        - kubelet        
        - kube proxy 
        - pods : inside of which apps container lives
        - docker engine            

Virtual Network: which turns the whole cluster into one powerfull machine


 
# *Kubernetes Objects (cluster-> nodes-> namespaces-> service-> deployment-> pod-> container )
 - container : application & dependences wrapped together
 - pod :a pod is the smallest deployable unit in K8s that wraps one or more containers to share resources like networking and storage
 - deployment : used to build and replicate pods (used for stateLESS application)
 - service : used as pod address instead of pod ip (it is both permenent ip and load balancer)
             pod ip will be replaced once the pod die but service stay the same for that application
 - configmap : hold things like db URL : indicating where the db is hosted...
 - secret : where thing like db password are stored for pod to access and use
 - volume : data storage 
 - statefulset: used to build and replicate a db  (used for stateFULL application or DB)
 - ingress : define allowed incoming traffic into the cluster (route traffics)
 - DaemonSet: type of workload resource that ensures a copy of a Pod runs on all (or some) Nodes in your cluster
 
# *k8s configuration (all configs go through Master Node/api server using ui, api or kubectl)
 - config file format can be : yaml or json (with Metadata - Spec - Status)
 - types of yaml to expect:
 
# Core Kubernetes Resources & YAML Manifests

## 1. Compute & Workloads (Running Applications)
* **Container:** Application code and its dependencies packaged together (runs inside a Pod).
* **Pod:** The smallest deployable unit in K8s; wraps one or more containers to share networking and storage.
* **Deployment (`deployment.yaml`):** Builds, updates, and replicates Pods for **stateless** applications.
* **StatefulSet (`statefulset.yaml`):** Builds and replicates Pods with sticky identities and persistent storage for **stateful** applications (e.g., databases).
* **DaemonSet (`daemonset.yaml`):** Ensures a copy of a Pod runs on all (or specific) Nodes in the cluster (e.g., log collectors, monitoring).
* **Job / CronJob (`job.yaml`, `cronjob.yaml`):** Runs Pods for one-off tasks to completion (e.g., DB migrations) or on a recurring schedule (e.g., backups).

## 2. Networking & Traffic (Exposing & Routing)
* **Service (`service.yaml`):** Provides a permanent IP address, DNS name, and load balancer in front of Pods (survives Pod restarts/IP changes).
* **Ingress (`ingress.yaml`):** Defines rules to route external HTTP/HTTPS traffic from outside the cluster into internal Services.
* **NetworkPolicy (`networkpolicy.yaml`):** Acts as an internal firewall controlling which Pods are allowed to communicate with each other.

## 3. Configuration & Storage (Data & Settings)
* **ConfigMap (`configmap.yaml`):** Stores non-sensitive configuration data as key-value pairs (e.g., database URLs, environment variables).
* **Secret (`secret.yaml`):** Stores sensitive data securely for Pods to access (e.g., database passwords, API keys, TLS certificates).
* **PersistentVolume (`volume.yaml` / `pv.yaml`):** Provisioned physical or cloud storage resource available in the cluster.
* **PersistentVolumeClaim (`pvc.yaml`):** A Pod's request to claim a specific size and access mode from a PersistentVolume.

## 4. Cluster Organization, Security & Scaling
* **Namespace (`namespace.yaml`):** Creates isolated virtual clusters within a physical cluster to separate environments or teams (e.g., `dev`, `prod`).
* **ServiceAccount / Role / RoleBinding (`rbac.yaml`):** Manages permissions (RBAC), defining who or what can access specific cluster resources.
* **HorizontalPodAutoscaler (`hpa.yaml`):** Automatically scales the number of Pods up or down based on CPU, memory, or custom metrics.

## 5. Packaging & Templating (Common Repo Files)
* **Kustomize (`kustomization.yaml`):** Customizes and overlays base YAML manifests for different environments without templates.
* **Helm (`Chart.yaml`, `values.yaml`):** Packages, templates, and versions a collection of Kubernetes YAML files as a single deployable app.

 
# k8s installation tool : 
- Kubectl : tool used to create stuff on the cluster : this is the k8s client
 
 



# ========================================================================================================================CLUSTER CREATION: USING MINICUBE
# New version with NANA
Youtube : https://www.youtube.com/watch?v=s_o8dwzRlu4&t=2765s
Gitlab  : https://gitlab.com/nanuchi/k8s-in-1-hour
Minicube: 

 
 

# ========================================================================================================================CLUSTER CREATION: VIRTUAL BOX & VAGRANT    
# INSTALL VIRTUAL BOX (USED TO CREATE VIRTUAL MACHINE)
sudo apt-get update && sudo apt-get upgrade && add-apt-repository multiverse 
sudo apt install virtualbox
sudo apt install virtualbox-ext-pack
sudo apt-get install virtualbox-guest-addition-iso

# UNINSTALL VIRTUAL BOX (stop the running virtual machine first):
sudo apt-get remove --purge virtualbox (tab to auto-complete)
sudo apt-get remove --purge virtualbox-6.1 / virtualbox-dkms / virtualbox-ext-pack
sudo apt autoremove

=========
on local machine:
create or edit "/etc/vbox/networks.conf"  file
Just edit or create the file /etc/vbox/networks.conf and change to:
* 0.0.0.0/0 ::/0
Do not forget the * at the beginning.
This will allow all addresses as host addresses like in old VirtualBox versions.

=========
clik RIGHT CTRL for the mouse exit off the virtual box





# INSTALL VAGRANT (USED TO CREATE K8S CLUSTER)
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install vagrant
vagrant -v
vagrant --help


# UNINSTALL VAGRANT:
rm -rf /opt/vagrant
rm -f /usr/bin/vagrant


==================================

# step 1 -create a cluster using Vagrant 
#         create a file "Vagrantfile" in a specific location and then add following machines specifications:

Vagrant.configure("2") do |config|
  config.vm.define "master" do |master|
    master.vm.box_download_insecure = true
    master.vm.box = "bento/ubuntu-20.04"        ## For ubuntu 18.04 use - hashicorp/bionic64
    master.vm.network "private_network", ip: "100.0.0.5"
    master.vm.hostname = "master"
    master.vm.provider "virtualbox" do |v|
      v.name = "master"
      v.memory = 2048
      v.cpus = 2
      # Display the VirtualBox GUI when booting the machine
      v.gui = true
    end
  end

  config.vm.define "worker" do |worker|
    worker.vm.box_download_insecure = true 
    worker.vm.box = "bento/ubuntu-20.04"        ## For ubuntu 18.04 use - hashicorp/bionic64
    worker.vm.network "private_network", ip: "100.0.0.6"
    worker.vm.hostname = "worker"
    worker.vm.provider "virtualbox" do |v|
      v.name = "worker"
      v.memory = 1024
      v.cpus = 1
    end
  end

end

# FROM LOCAL where Vagrantfile is located (ON HOST MACHINE)
vagrant init (this is another option to generate the Vagrantfile file template:___ we already have one manually create in step1)

vagrant up   (eg: (base) cesar@cesar-GS66-Stealth-10SE:~/Desktop/Tools-updated/other/Vbox-Vagrant-Kubernetes$ vagrant up)
vagrant halt
vagrant provision
vagrant destroy

# default:
username :vagrant
password :vagrant


=================

# Step 2 - Update host files on both master and worker node

master node - SSH into the master node (..............................................From local)
vagrant ssh master
sudo nano /etc/hosts
100.0.0.5 master.cesar.com master
100.0.0.6 worker.cesar.com worker

worker node - SSH into the worker node
vagrant ssh worker
sudo nano /etc/hosts
100.0.0.5 master.cesar.com master
100.0.0.6 worker.cesar.com worker

ping worker from master
ping master from worker

# Step 3 - Install Docker on both master and worker node
sudo apt-get update && \
sudo apt install docker.io && \
sudo systemctl enable docker && \
sudo systemctl start  docker && \
sudo systemctl status docker 

Create this file "daemon.json" in the directory "/etc/docker" and add the following
sudo nano /etc/docker/daemon.json
{
"exec-opts": ["native.cgroupdriver=systemd"]
}

# Restart your docker service: 
systemctl restart docker


# Step 4 - Disable the firewall and turnoff the “swapping” on both master and worker node
sudo ufw disable && \
sudo swapoff -a;

sudo nano /etc/fstab  # comment the line with "sw"

# Step 5 - Install “apt-transport-https” package on both master and worker node
sudo apt-get update && sudo apt-get install -y apt-transport-https

# Step 6 - Download the public keys on both master and worker
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# Step 7 - Add kubernetes repo on both master and worker node
sudo bash -c 'echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list'

# Step 8 - Install kubernetes on both master and worker node
sudo apt-get update && sudo apt-get install -y kubelet kubeadm kubectl

# Step 9 - Enable and Start kubelet on both master and worker node
sudo systemctl enable kubelet && systemctl start kubelet

# Step 10 - Initialize the kubernetes cluster                               (**********only run on master)
Initialize your network: 
sudo kubeadm init --apiserver-advertise-address=100.0.0.5 --pod-network-cidr=100.0.0.0/16 --ignore-preflight-errors=all

A new token will be generated like this:
kubeadm join 100.0.0.5:6443 --token 7k6mgz.z1nrdgpks2ei6bvq --discovery-token-ca-cert-hash sha256:a0a5fb817baa5740c722ca5dd27bcde5297ed03943570256ebbafc9a49a50edc

#Step 11 - Move kube config file to current user                            (**********only run on master)
mkdir -p $HOME/.kube;
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config;
sudo chown $(id -u):$(id -g) $HOME/.kube/config;



# Step 12 - Apply CNI(container network interface) from CALICO OR FLANNEL    (**********only run on master)

# CALICO (Best option there is more options):
wget https://projectcalico.docs.tigera.io/manifests/calico.yaml
sudo nano calico.yaml
kubectl apply -f calico.yaml


# Step 13 - Join worker nodes to master                                     (**********only run on worker)
sudo \
kubeadm join 100.0.0.5:6443 --token 7k6mgz.z1nrdgpks2ei6bvq --discovery-token-ca-cert-hash sha256:a0a5fb817baa5740c722ca5dd27bcde5297ed03943570256ebbafc9a49a50edc --ignore-preflight-errors=all


#  ================================================================================================================================================= INSTALL DASHBOARD

# step 14 spinning up the dashboard

# INSTALL/UNINSTAL A DASHBOARD (on master)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/recommended.yaml

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.4.0/aio/deploy/recommended.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.4.0/aio/deploy/recommended.yaml


# Check the dashboard installed correctly
kubectl get pods -o wide --all-namespaces
kubectl -n kubernetes-dashboard get all  (show everything in this namespace) #************************************************
kubectl -n kubernetes-dashboard describe service kubernetes-dashboard


# Edit the service to "NodePort"  instead of "ClustIP" (from master)
kubectl  edit service kubernetes-dashboard -n kubernetes-dashboard  (use vi command ;  i, esc+:,:wq, :!q)
Then do:
kubectl get services -n kubernetes-dashboard(GET THE PORT FROM HERE)
kubectl get nodes -o wide                   (GET BOTH masterIP*****AND******workerIP)
https://workerIP:port                       eg: https://100.0.0.6:30915.....................(USE FIREFOX)


OR

kubectl proxy
To view the dashboard in the browser, navigate to the following address in the browser of your Master VM: 
http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/



# GENERATE TOKEN (for dashboard login)
# 1. This command will create a service account for dashboard in the default namespace
kubectl create serviceaccount dashboard -n default

# 2. This command will add the cluster binding rules to your dashboard account
kubectl create clusterrolebinding dashboard-admin -n default --clusterrole=cluster-admin --serviceaccount=default:dashboard

# 3. NO LONGER WORKING:  This command will give you the token required for your dashboard login
kubectl get secret -n default $(kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode


# 4. If #3 above not working : here dashboard = "serviceaccount" name
kubectl create token dashboard --duration=999999h




# ================================================================================================================================================K8S MORE COMMANDS

#Step 15 - Check the nodes status and MORE (only run on master) 

# CLUSTER INFO
kubectl cluster-info
kubectl get ep 

# NODES INFO
kubectl get nodes -o wide
kubectl describe node worker
kubectl delete node worker


# NAMESPACE INFO                             **************************************************************** make sure to be in right namespace
kubectl get namespaces
kubectl get all -n <given-namespace>         **************************************************************** all in the namespace
kubectl create namespace cesar
kubectl delete namespace cesar
kubectl config get-contexts                                           # display current namespaces
kubectl config set-context --current --namespace=kubernetes-dashboard # switch to "kubernetes-dashboard" namespace

# SERVICEACCOUNT
    # 1. This command will create a service account for dashboard in the default namespace
    kubectl create serviceaccount dashboard -n default

    # 2. This command will add the cluster binding rules to your dashboard account
    kubectl create clusterrolebinding dashboard-admin -n default --clusterrole=cluster-admin --serviceaccount=default:dashboard

    # 3. Here dashboard = "serviceaccount" name
    kubectl create token dashboard --duration=999999h

# SERVICE INFO
kubectl get service --all-namespaces
kubectl get service --all-namespaces | grep kubernetes-dashboard 
kubectl delete serviceaccount dashboard -n default
kubectl get service flask-test-service

# DEPLOYMENT INFO
kubectl get deployments                                                         #in default namespace
kubectl get deployment -o wide --all-namespaces                                 #in all namespaces
kubectl get deployments -n kubernetes-dashboard                                 #deployment from kubernetes-dashboard namespace
kubectl describe deployments --all-namespaces                                   #deployment from all namespaces
kubectl set image deployment.v1.apps/nginx-deployment nginx=nginx:1.16.1        #update a deployment
kubectl edit deployment/nginx-deployment                                        #edit a deployment
kubectl rollout status deployment/nginx-deployment                              #to see the rollout status
kubectl rollout restart deployment <deployment_name>

kubectl delete deployment flask-test-app                                        #delete deployment
kubectl -n kubernetes-dashboard rollout restart deployment kubernetes-dashboard # restarting "kubernetes-dashboard" pod from "kubernetes-dashboard" namespace

-> DEPLOY "nginx" IN A PARTICULAR NAMESPACE
kubectl apply -f https://k8s.io/examples/controllers/nginx-deployment.yaml -n namespacename
kubectl scale deployment nginx-deployment --replicas=9

# PODS INFO
kubectl get pods -o wide --all-namespaces
kubectl get pods -o=name --all-namespaces | grep kubernetes-dashboard
kubectl describe pod
kubectl get pods -o json
kubectl get pods -o yaml
kubectl logs <pod-name> -n <namespace>

# CONTAINERS / IMAGES INFO (usually one container per pod)
containers:
kubectl config set-context --current --namespace=default # switch between namespaces
kubectl get pods                                         # get pod/container in given namespace
kubectl exec --stdin --tty <POD NAME> -- /bin/bash       # interact with container

container images:
kubectl get pods --all-namespaces -o jsonpath="{.items[*].spec.containers[*].image}" -l app=nginx    # by Pod label
kubectl get pods --namespace kubernetes-dashboard -o jsonpath="{.items[*].spec.containers[*].image}" # by Pod namespace


# SECRETS INFOBasic k8s concept
kubectl -n kube-system get secret
kubectl -n kube-system describe secret deployment-controller-token-7nxzc


# TOKEN INFO
sudo kubeadm token list
sudo kubeadm token create
kubectl -n kube-system get cm kubeadm-config -o yaml


# REPLICASET
kubectl get rs                                       # List all ReplicaSets in default namespace
kubectl get rs -A                                    # List ReplicaSets across all namespaces
kubectl describe rs <replicaset-name>                # Show details, events, and pod status
kubectl scale rs <replicaset-name> --replicas=3      # Manually scale pod replicas
kubectl delete rs <replicaset-name>                  # Delete a ReplicaSet (and its pods)


# STATEFULSET
kubectl get sts                                      # List all StatefulSets
kubectl describe sts <statefulset-name>              # View ordered pod creation, storage, and events
kubectl scale sts <statefulset-name> --replicas=3    # Scale StatefulSet up or down sequentially
kubectl rollout status sts/<statefulset-name>        # Watch live rolling update progress
kubectl delete sts <statefulset-name> --cascade=orphan # Delete StatefulSet while keeping its Pods alive


# DAEMONSET
kubectl get ds                                       # List all DaemonSets
kubectl get ds -n kube-system                        # List system DaemonSets (e.g., kube-proxy, CNI)
kubectl describe ds <daemonset-name>                 # Check node selector rules and desired vs. ready pods
kubectl rollout restart ds/<daemonset-name>          # Restart all DaemonSet pods across every node


# JOB
kubectl get jobs                                     # List all Jobs and their completion status (e.g., 1/1)
kubectl create job my-job --image=busybox -- echo "Hello K8s" # Create a quick one-off Job imperatively
kubectl describe job <job-name>                      # Inspect job duration, parallelism, and pod events
kubectl logs job/<job-name>                          # View output logs from the Job's pod
kubectl delete job <job-name>                        # Clean up completed Job and its pods


# CRONJOBS
kubectl get cj                                       # List all CronJobs, schedules, and last run times
kubectl create cronjob my-cj --image=busybox --schedule="*/5 * * * *" -- date # Create a CronJob running every 5 mins
kubectl create job --from=cronjob/<cronjob-name> manual-run # Trigger a CronJob immediately as a manual Job
kubectl patch cj <cronjob-name> -p '{"spec":{"suspend":true}}' # Pause future scheduled runs
kubectl delete cj <cronjob-name>                     # Delete a CronJob



# COMMAND CHAIN
#kubectl get service, pod, deployment -n studytonight



# =============================================================================================================================== DEPLOYING ON KUBERNETES (COPY PAST)
# CREATE THE APP
create an app (poetry based)
dockerize the app (create both Dockerfile and kubernetes deployment.yaml)


# COPY files/folders FROM LOCAL (HOST) TO VIRTUAL MACHINE (GUEST)
vagrant plugin install vagrant-scp
vagrant scp ~/Desktop/app  master:~/
vagrant scp ~/Desktop/app  worker:~/

# GENERATE THE APP IMAGE (on both master and worker)******************************** Images on both
cd app  (where we have the Dockerfile)
sudo docker build -t flask-kubernetes .
or:
docker save -o <path for generated tar file> <image name>
docker load -i <path to image tar file>


# DEPLOY THE APP USING yaml file
cd app
create deployment.yaml file
kubectl apply -f deployment.yaml (or -f foldername: applying multiple yaml at same time)  #*************************************************Applying multiple yaml file similtanously
kubectl get deployments
kubectl expose deployment flask-test-app --type=NodePort --name=flask-service
kubectl describe services flask-service (GET PORT FROM HERE)

Accessing the service:
UI : http://100.0.0.6:30427
API: curl http://<public-node-ip>:<node-port> 

kubectl delete deployment flask-test-app
kubectl edit service flask-service -n default
kubectl delete flask-service

# Accessing POSTGRES POD
kubectl exec -it postgres-deployment-6b69cc6bd9-45gsz -- psql -U postgres
CREATE DATABASE flask_db;


# ======================================================================================================================================= DEPLOYING ON KUBERNETES(HELM)
# HELM Definition
Packages manager for kubernetes (like apt on lunix)
Helm packages kubernetes yaml files and distribute them to the private or public registry (canbe used for push and pull)

# Release management
version2 : comes into 2 parts
- CLIENT (helm cli)
- SERVER (Tiller)

version3 : comes into 1 part
- CLIENT (helm cli)
- loose versioning 


# Kubectl installation on our local (needed for interaction with our cluster from our local)
sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo bash -c 'echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list'
sudo apt-get update && sudo apt-get install -y kubectl
kubectl version

# From your cluster master move the .kube folder ( including cert and key) to your local machine
vagrant scp master:/home/vagrant/.kube /home/cesar


# helm installation on our local:
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
$ chmod 700 get_helm.sh
$ ./get_helm.sh
$ helm version

# helm uninstall
https://helm.sh/docs/faq/uninstalling/

# helm hub    :
helm search repo <something>  :  available on our local
helm search hub  <something>  :  available on helm hub (artifacthub.io)
    $ helm repo add bitnami https://charts.bitnami.com/bitnami : add to the repo
    $ helm install my-release bitnami/wordpress                : install from repo

# helm charts : bandle of yaml files
              You can create chart for your application and use it for deployment on dev, staging and prod clusters
              You can also do push and pull : eg: Database app, monitoring app they all have helm charts available
helm create example-app


Helm chart Directory structure:
chartname/
 chart.yaml   : meta info about the chart
 value.yaml   : values for the template files
 charts/      : folder with chart dependencies
  templates/  : folder with actual template files (Deployment.yaml,service.yaml...)
  ...
         
 
# values
Template files will be filled with the values from values.yaml
Values defined either via yaml file or with --set flag (the values will be injected into Deployment.yaml,service.yaml...within tamplate create inside shart folder)
helm install --set param=value
helm install --values app-1.yaml
helm install --values app-2.yaml

app-1.yaml
==========
deployment:
  image: "xxxxxxxxx"
  tag: "xxxxxxx"

deployment.yaml
==========
image:{{.Values.deployment.image}}:{{.Values.deployement.tag}}

# helm work as a templating engine (create templetes for you)
In case you have multiple multi-services that will need pod,deployment,service,secret yaml file...
instead of creating one for each you can make a tamplete(with placeholder) insted and reuse the template with value.yaml

apiVersion:v1
kind: Pod
metadata:
  name :{{.Values.name}}
spec:
  containers:
  - name: {{.Values.container.name}}
    name: {{.Values.container.image}}
    name: {{.Values.container.port}}
              
Deployment.yaml
Service.yaml
Secret.yaml
PersistentVolume.yaml
PersistentVolumeclaim.yaml
helm template <chartname> <chart_directory>: used to desplay all of the yaml files created and ready for deploment
helm upgrade  <chartname> <chart_directory> <path-to-values.yaml>: used to upgrade the values under our yaml files

# command
helm install <chartname> <chart_directory>: used to deploy those yaml files
helm install --values=my_values.yaml <chartname>
helm install --set version=2.0.0
helm upgrade   <chartname> <chart_directory> <path-to-values.yaml>
helm rollback  <chartname>
helm uninstall <chartname>
helm list

helm --help (will provide you the most used commands):
helm search
helm pull
helm install
helm list

helm repo
helm repo --help
helm repo update --help

# eg: gitlab-runner
helm repo add gitlab https://charts.gitlab.io
helm list
configure values within values.yaml

kubeclt create namespace git-runner
kubectl create serviceaccount git-runner-sa --namespace git-runner
kubectl create clusterrolebinding git-runner-sa-admin -n default --clusterrole=cluster-admin --serviceaccount=default:git-runner-sa

helm install --generate-name -f kube-chart-values.yaml gitlab/gitlab-runner
helm install --namespace git-runner git-runner -f kube-chart-values.yaml gitlab/gitlab-runner



# ==================================================================================================================================================TROUBLE SHOOT
systemctl enable kubectl
systemctl restart kubectl
sudo docker restart $(sudo docker ps -a -q)
https://www.tutorialworks.com/kubernetes-imagepullbackoff/


kubectl delete deployments flask-test-app;
kubectl delete service flask-service;
kubectl delete service flask-app-service;
sudo docker rmi flask-kubernetes;

sudo docker build -t flask-kubernetes .
kubectl apply -f app-deploy-service.yaml
kubectl get services 
kubectl delete services flask-app-service
kubectl expose deployment flask-test-app --type=NodePort --name=flask-service
kubectl exec --stdin --tty <POD NAME> -- /bin/bash
su - postgres

# On worker node
sudo iptables -P INPUT ACCEPT;
sudo iptables -P FORWARD ACCEPT;
sudo iptables -P OUTPUT ACCEPT;
sudo iptables -F;

# Restart a pod from master node
kubectl scale deployment coredns --replicas=0 -n kube-system
kubectl scale deployment coredns --replicas=2 -n kube-system


kubectl scale deployment flask-test-app --replicas=0 -n kubernetes-dashboard
kubectl scale deployment flask-test-app --replicas=1 -n kubernetes-dashboard





# ==========================================================================================================================================================REFERENCE
THEORY  : https://www.youtube.com/watch?v=VnvRFRk_51k
KUBE    : https://www.youtube.com/watch?v=s_o8dwzRlu4&t=2216s
RUNCH   : https://www.youtube.com/watch?v=1j5lhDzlFUM
FLUX    : https://www.youtube.com/watch?v=OFgziggbCOg
HELM    : https://helm.sh/docs/intro/install/
POSTGR  : https://www.sumologic.com/blog/kubernetes-deploy-postgres/
FLASK   : https://www.digitalocean.com/community/tutorials/how-to-use-a-postgresql-database-in-a-flask-application
CNI     : https://platform9.com/blog/the-ultimate-guide-to-using-calico-flannel-weave-and-cilium/
AWS EKS : https://learnk8s.io/terraform-eks

AUTOMATED CLUSTER BUILDING: https://mohewedy.medium.com/install-kubernetes-cluster-in-virtual-machines-the-easy-way-337ef0c4e37f

DEPLOYING ON KUBERNETES
https://www.youtube.com/watch?v=0jUGdSI92KM
https://testdriven.io/blog/deploying-spark-on-kubernetes/

GITLAB INTEGRATION WITH KUBERNETES
https://www.youtube.com/watch?v=FkS_Cn4AH7o
https://gitlab.com/anishnath/runner-example
https://docs.gitlab.com/runner/install/
https://docs.gitlab.com/runner/install/kubernetes.html

VAULT ON KUBERNETES
https://www.youtube.com/watch?v=0dSv3DFWNY0

# MORE
 https://jhooq.com/kubernetes-index/

https://kubernetes.io/docs/reference/kubectl/cheatsheet/
https://kubernetes.io/docs/concepts/services-networking/ingress/
https://kubernetes.io/docs/tasks/debug-application-cluster/get-shell-running-container/
https://jhooq.com/14-steps-to-install-kubernetes-on-ubuntu-18-04-and-16-04/
https://www.edureka.co/blog/install-kubernetes-on-ubuntu
https://stackoverflow.com/questions/46664104/how-to-sign-in-kubernetes-dashboard
https://kubernetes.io/docs/tasks/access-application-cluster/service-access-application-cluster/


===============================================================================================================================================================




