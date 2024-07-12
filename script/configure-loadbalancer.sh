#!/bin/bash

set -xe

TMP_PROXY_CONF_FILE='/vagrant/sync/haproxy.cfg'

# Proxy configuration without backend server IP addresses
cat > $TMP_PROXY_CONF_FILE <<EOF
frontend loadbalancer_node
  mode tcp
  option tcplog
  bind :6443
  default_backend controlplane_nodes

backend controlplane_nodes
  mode tcp
EOF

# Add backend server IP addresses
INDEX=0
for ARG in "$@"
do
  echo "  server controlplane_$INDEX $ARG:6443 check" >> $TMP_PROXY_CONF_FILE
  INDEX=$((INDEX + 1))
done

cat $TMP_PROXY_CONF_FILE >> /etc/haproxy/haproxy.cfg

rm $TMP_PROXY_CONF_FILE

# Refresh HAProxy configuration
sudo systemctl restart haproxy.service