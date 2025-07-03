#!/bin/bash
set -e

# Update and install packages
apt-get update -y
apt-get install -y curl apt-transport-https docker.io conntrack

# Enable Docker
systemctl enable docker
systemctl start docker

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && mv kubectl /usr/local/bin/

# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube

# Start Minikube with none driver (use only on EC2 root)
minikube start --driver=none

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Install Istio CLI
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.22.0 sh -
mv istio-1.22.0/bin/istioctl /usr/local/bin/

# Install Istio
istioctl install --set profile=demo -y
kubectl label namespace default istio-injection=enabled
