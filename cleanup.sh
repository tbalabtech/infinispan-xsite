#!/bin/bash

# Cleanup script for cross-site Infinispan deployment

set -e

echo "Cleaning up cross-site Infinispan deployment..."

# Delete resources from primary namespace
echo "Deleting Infinispan primary resources..."
kubectl delete -f ./infinispan-k8-primary/helm/deployment.yaml --ignore-not-found=true

# Delete resources from secondary namespace
echo "Deleting Infinispan secondary resources..."
kubectl delete -f ./infinispan-k8-secondary/helm/deployment.yaml --ignore-not-found=true