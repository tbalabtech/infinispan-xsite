#!/bin/bash

# Cross-site Infinispan deployment script for Kind cluster
# This script deploys Infinispan clusters in primary and secondary namespaces with cross-site replication

set -e

echo "Setting up cross-site Infinispan replication in Kind cluster..."


# Create Kind cluster if it doesn't exist
echo "Creating Kind cluster..."
if ! kind get clusters | grep -q "^primary$"; then
    kind create cluster --name primary
    echo "Kind cluster 'primary' created successfully"
else
    echo "Kind cluster 'primary' already exists"
fi

# Create namespaces
echo "Creating namespaces..."
kubectl create namespace primary --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace secondary --dry-run=client -o yaml | kubectl apply -f -


# Build Docker images for both sites (if needed)
echo "Building Infinispan Docker images..."

# Build primary image
cd infinispan-k8-primary
docker build -t infinispan-primary:latest .
kind load docker-image infinispan-primary:latest  --name primary
cd ..
# Build secondary image  
cd infinispan-k8-secondary
docker build -t infinispan-secondary:latest .
kind load docker-image infinispan-secondary:latest  --name primary
cd ../

# Deploy primary site
echo "Deploying primary Infinispan cluster..."
kubectl apply -f ./infinispan-k8-primary/helm/deployment.yaml

# Deploy secondary site  
echo "Deploying secondary Infinispan cluster..."
kubectl apply -f ./infinispan-k8-secondary/helm/deployment.yaml




