#!/bin/bash

set -xe

CONTROLPLANE_IP_ADDRESS=$1

# Install Kubernetes controlplane
sudo kubeadm init --apiserver-advertise-address=$CONTROLPLANE_IP_ADDRESS --pod-network-cidr=10.244.0.0/16

# Configure kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
cp -f $HOME/.kube/config /vagrant/sync/kubeconfig

# Install Flannel CNI plugin
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Generate kubeadm join command for worker nodes and store it in /vagrant/sync folder
sudo sh -c "kubeadm token create --print-join-command > /vagrant/sync/kubeadm-join.sh"
