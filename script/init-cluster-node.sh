#!/bin/bash

set -xe

KUBERNETES_VERSION=v1.29

sudo apt-get update -qq
# sudo apt-get upgrade -qq -y

# Disable swap for current session
sudo swapoff -a
# Disable swap for future sessions
sed -i 's~/swap.img~#/swap.img~g' /etc/fstab

# Load kernel modules for current session
sudo modprobe overlay
sudo modprobe br_netfilter
# Load kernel modules for future sessions
cp /vagrant/config/modules-load.d/k8s.conf /etc/modules-load.d/k8s.conf

# Configure network
cp /vagrant/config/sysctl.d/k8s.conf /etc/sysctl.d/k8s.conf
sudo sysctl --system

# Install and configure containerd
sudo apt-get install -qq -y containerd
sudo mkdir /etc/containerd
sudo sh -c "containerd config default > /etc/containerd/config.toml"
sed -i 's~SystemdCgroup = false~SystemdCgroup = true~g' /etc/containerd/config.toml
sed -i 's~sandbox_image = "registry.k8s.io/pause:3.8"~sandbox_image = "registry.k8s.io/pause:3.9"~g' /etc/containerd/config.toml
sudo systemctl restart containerd.service

# Install and configure kubeadm
sudo apt-get install -qq -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update -qq
sudo apt-get install -qq -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Configure crictl
sudo crictl config --set runtime-endpoint=unix:///var/run/containerd/containerd.sock

# Refresh kubelet configuration by restarting the service
sudo systemctl restart kubelet.service
