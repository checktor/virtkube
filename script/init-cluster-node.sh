#!/bin/bash

set -xe

KUBERNETES_VERSION=v1.32
NODE_IP_ADDRESS=$1

# Disable swap
sed -i 's~/swap.img~#/swap.img~g' /etc/fstab
sudo swapoff -a

# Configure network
cp /vagrant/config/sysctl.d/k8s.conf /etc/sysctl.d/k8s.conf
sudo sysctl --system

# Load kernel modules
cp /vagrant/config/modules-load.d/k8s.conf /etc/modules-load.d/k8s.conf
sudo modprobe overlay
sudo modprobe br_netfilter

# Install dependencies
sudo apt-get update -qq
sudo apt-get install -qq -y apt-transport-https ca-certificates curl gpg

# Configure apt repositories
sudo mkdir -p -m 755 /etc/apt/keyrings
## Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list
## Kubernetes
curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes.gpg
echo \
  "deb [signed-by=/etc/apt/keyrings/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" | \
   sudo tee /etc/apt/sources.list.d/kubernetes.list
## Fetch repository metadata
sudo apt-get update -qq

# Configure containerd
sudo apt-get install -qq -y containerd.io
sudo sh -c "containerd config default > /etc/containerd/config.toml"
sed -i 's~SystemdCgroup = false~SystemdCgroup = true~g' /etc/containerd/config.toml
sed -i 's~sandbox_image = "registry.k8s.io/pause:3.8"~sandbox_image = "registry.k8s.io/pause:3.10"~g' /etc/containerd/config.toml
sudo systemctl restart containerd.service

# Install kubeadm, kubelet and kubectl
sudo apt-get install -qq -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Configure crictl to use containerd socket
sudo crictl config --set runtime-endpoint=unix:///var/run/containerd/containerd.sock

# Configure kubelet to use current node's IP address
sudo sh -c "echo \"KUBELET_EXTRA_ARGS=--node-ip=$NODE_IP_ADDRESS\" > /etc/default/kubelet"

# Reload kubelet configuration
sudo systemctl restart kubelet.service
