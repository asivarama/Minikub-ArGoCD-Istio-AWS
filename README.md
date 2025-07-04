# Minikub-ArGoCD-Istio-AWS
Documenting the setup of Minikube + ArgoCD + Istio + Sample App on an AWS EC2 Ubuntu instance using Terraform and manual provisioning:


# 🚀 Minikube + ArgoCD + Istio + Bookinfo App on AWS EC2 (Ubuntu)

This project sets up a local Kubernetes cluster using Minikube, deploys ArgoCD for GitOps, installs Istio for service mesh, and runs the Bookinfo sample app — all on an AWS EC2 Ubuntu instance.

---

## 🛠️ Prerequisites

- AWS account
- Terraform installed
- EC2 Key Pair (already created and downloaded)
- SSH access to EC2 instance
- Ubuntu 22.04 or 24.04 LTS instance
- At least 30 GB EBS volume
- Public IP or domain for accessing services

---

## 🌐 EC2 Setup Using Terraform

> Make sure your private key (e.g., `my-aws-key.pem`) is **not** committed to GitHub.

```hcl
# main.tf
provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "minikube" {
  ami                         = "ami-0f58b397bc5c1f2e8"  # Ubuntu 24.04 LTS 
  instance_type               = "t3.medium"
  key_name                    = "minikube-key"
  associate_public_ip_address = true

  root_block_device {
    volume_size = 30
  }

  tags = {
    Name = "minikube-vm"
  }
}

# variables.tf
variable "key_name" {
  default = "minikube-key"
}
hcl
Copy
Edit
# outputs.tf
output "public_ip" {
  value = aws_instance.minikube.public_ip
}
🚪 Connect to EC2 Instance

ssh -i my-aws-key.pem ubuntu@<EC2_PUBLIC_IP>
🐳 Install Docker

sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
newgrp docker
🔧 Install Minikube

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
⎈ Install kubectl

curl -LO https://dl.k8s.io/release/v1.33.1/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client
⚙️ Install cri-dockerd and CNI Plugins

# cri-dockerd
sudo apt install -y git golang-go
git clone https://github.com/Mirantis/cri-dockerd.git
cd cri-dockerd
mkdir bin
go build -o bin/cri-dockerd
sudo cp bin/cri-dockerd /usr/local/bin/
sudo systemctl daemon-reload
sudo systemctl enable cri-docker.service
sudo systemctl start cri-docker.service

# CNI Plugins
curl -LO https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz
sudo mkdir -p /opt/cni/bin
sudo tar -xzvf cni-plugins-linux-amd64-v1.1.1.tgz -C /opt/cni/bin

# socat for port-forwarding
sudo apt install -y socat
🚀 Start Minikube

minikube start --driver=none
✅ Validate Cluster

kubectl get nodes
kubectl get pods -A
🎯 Deploy ArgoCD

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
🔑 Get ArgoCD Credentials

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
🌍 Access ArgoCD UI

kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443
Visit: http://<EC2_PUBLIC_IP>:8080
Username: admin
Password: (as fetched above)

📦 Install Istio

curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.22.0 sh -
cd istio-1.22.0
sudo cp bin/istioctl /usr/local/bin/
Pre-check and install:

istioctl x precheck
istioctl install --set profile=demo -y
🧪 Deploy Bookinfo Sample App

kubectl label namespace default istio-injection=enabled
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
🌐 Access the App
Get Istio ingress port:


kubectl get svc -n istio-system istio-ingressgateway
Get EC2 public IP:

curl http://checkip.amazonaws.com
Access the app:

php-template

http://<EC2_PUBLIC_IP>:<NODEPORT>/productpage
(Example: http://3.110.183.208:30221/productpage)

📋 Useful Commands

# Check all pods and services
kubectl get pods -A
kubectl get svc -A

# View node details
kubectl get nodes -o wide

# Delete minikube cluster
minikube delete
📌 Notes
ArgoCD login port is forwarded manually to 8080.

Istio Bookinfo App is exposed via NodePort.

LoadBalancer IP will remain <pending> in Minikube.

✅ Status
 EC2 with Ubuntu 24.04 LTS

 Docker & Minikube

 ArgoCD GitOps

 Istio Service Mesh

 Bookinfo sample app
