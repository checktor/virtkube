#!/bin/bash

set -xe

NODE_IP_ADDRESS=$1

# Configure kubelet to use current node's IP address
sudo sh -c "echo \"KUBELET_EXTRA_ARGS=--node-ip=$NODE_IP_ADDRESS\" > /etc/default/kubelet"

# Reload kubelet configuration
sudo systemctl restart kubelet.service
