#!/bin/bash

TEST_STATUS=0

export KUBECONFIG=sync/kubeconfig

# Create deployment with two replicas
kubectl create deployment nginx --image nginx --replicas 2 > /dev/null

sleep 5

# Cheek if first pod is running
FIRST_REPLICA_STATUS=$(kubectl get pods -o jsonpath='{.items[0].status.phase}')
if [ "$FIRST_REPLICA_STATUS" != 'Running' ]; then
  TEST_STATUS=1
  echo 'First pod of deployment is not running!'
fi

# Cheek if second pod is running
SECOND_REPLICA_STATUS=$(kubectl get pods -o jsonpath='{.items[1].status.phase}')
if [ "$SECOND_REPLICA_STATUS" != 'Running' ]; then
  TEST_STATUS=1
  echo 'Second pod of deployment is not running!'
fi

# Remove deployment
kubectl delete deployment nginx --grace-period 0 > /dev/null

if [ $TEST_STATUS -eq 0 ]; then
  echo 'Success!'
  exit 0
else
  echo 'Failure!'
  exit 1
fi
