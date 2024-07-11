#!/bin/bash

set -xe

CONTROLPLANE_IP_ADDRESS=$1

# Install Kubernetes controlplane
sudo kubeadm init \
--apiserver-advertise-address=$CONTROLPLANE_IP_ADDRESS \
--pod-network-cidr=10.244.0.0/16

# Generate kubeadm join command for worker node and store it in /vagrant/sync folder
TOKEN=$(sudo kubeadm token list -o jsonpath='{.token}')
CA_CERT_HASH=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2> /dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')
KUBEADM_JOIN_COMMAND="kubeadm join $CONTROLPLANE_IP_ADDRESS:6443 --token $TOKEN --discovery-token-ca-cert-hash sha256:$CA_CERT_HASH"
echo "sudo $KUBEADM_JOIN_COMMAND" > /vagrant/sync/kubeadm-join-worker.sh

# Configure kubectl to use admin user
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
cp $HOME/.kube/config /vagrant/sync/kubeconfig

# Install and configure Flannel CNI plugin
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
kubectl patch ds kube-flannel-ds --patch-file /vagrant/manifest/patch-kube-flannel.yml -n kube-flannel
