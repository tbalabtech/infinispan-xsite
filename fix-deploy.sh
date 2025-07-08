#!/bin/bash

echo "=== Infinispan Cross-Site Replication Fix Deployment ==="
echo "This script will redeploy Infinispan with the cross-site configuration fixes"
echo ""

# Apply the fixed configurations
echo "1. Deploying Primary Site..."
kubectl apply -f infinispan-k8-primary/helm/deployment.yaml
kubectl apply -f infinispan-k8-primary/helm/service.yaml
kubectl apply -f infinispan-k8-primary/helm/headless-service.yaml

echo ""
echo "2. Deploying Secondary Site..."
kubectl apply -f infinispan-k8-secondary/helm/deployment.yaml
kubectl apply -f infinispan-k8-secondary/helm/service.yaml
kubectl apply -f infinispan-k8-secondary/helm/headless-service.yaml

echo ""
echo "3. Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=infinispan -n primary --timeout=300s
kubectl wait --for=condition=ready pod -l app=infinispan -n secondary --timeout=300s

echo ""
echo "4. Checking cross-site connectivity..."
echo "Primary site pods:"
kubectl get pods -n primary -l app=infinispan
echo ""
echo "Secondary site pods:"
kubectl get pods -n secondary -l app=infinispan

echo ""
echo "5. Checking services..."
echo "Primary services:"
kubectl get svc -n primary
echo ""
echo "Secondary services:"
kubectl get svc -n secondary

echo ""
echo "=== Deployment Complete ==="
echo "Check the pod logs for any remaining cross-site replication errors:"
echo "kubectl logs -n primary <pod-name>"
echo "kubectl logs -n secondary <pod-name>"
