#!/bin/bash

TEST_STATUS=0

export KUBECONFIG=sync/kubeconfig

# Create deployment with two replicas
kubectl create deployment nginx --image nginx:alpine --replicas 2 > /dev/null

sleep 20

# Check if first pod is running
FIRST_REPLICA_STATUS=$(kubectl get pods -o jsonpath='{.items[0].status.phase}')
if [ "$FIRST_REPLICA_STATUS" != 'Running' ]; then
  TEST_STATUS=1
  echo 'First pod of deployment is not running!'
fi

# Check if second pod is running
SECOND_REPLICA_STATUS=$(kubectl get pods -o jsonpath='{.items[1].status.phase}')
if [ "$SECOND_REPLICA_STATUS" != 'Running' ]; then
  TEST_STATUS=1
  echo 'Second pod of deployment is not running!'
fi

# Create service for deployment
kubectl expose deployment nginx --name nginx --port 80 > /dev/null

# Check if deployment is reachable via service
kubectl run curl --restart=Never --rm -i -t --image curlimages/curl -- -s -o /dev/null nginx > /dev/null
SERVICE_STATUS=$?
if [ $SERVICE_STATUS -ne 0 ]; then
  TEST_STATUS=1
  echo 'Deployment is not reachable!'
fi

# Remove service
kubectl delete service nginx > /dev/null

# Remove deployment
kubectl delete deployment nginx --grace-period 0 > /dev/null

if [ $TEST_STATUS -eq 0 ]; then
  echo 'Success!'
  exit 0
else
  echo 'Failure!'
  exit 1
fi
