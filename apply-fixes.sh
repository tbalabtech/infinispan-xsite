#!/bin/bash

echo "=== Redeploying Infinispan with Cross-Site Fixes ==="
echo ""

# Rebuild and load Docker images
echo "1. Rebuilding Docker images with updated configurations..."
cd infinispan-k8-primary
docker build -t infinispan-primary:latest .
kind load docker-image infinispan-primary:latest --name primary
cd ../infinispan-k8-secondary
docker build -t infinispan-secondary:latest .
kind load docker-image infinispan-secondary:latest --name primary
cd ../

# Restart the StatefulSets to pick up new images and configurations
echo ""
echo "2. Restarting StatefulSets..."
kubectl rollout restart statefulset infinispan -n primary
kubectl rollout restart statefulset infinispan -n secondary

# Wait for rollout to complete
echo ""
echo "3. Waiting for rollout to complete..."
kubectl rollout status statefulset infinispan -n primary --timeout=300s
kubectl rollout status statefulset infinispan -n secondary --timeout=300s

# Check pod status
echo ""
echo "4. Checking pod status..."
echo "Primary pods:"
kubectl get pods -n primary -l app=infinispan
echo ""
echo "Secondary pods:"
kubectl get pods -n secondary -l app=infinispan

# Wait a bit for startup
echo ""
echo "5. Waiting 30 seconds for services to stabilize..."
sleep 30

# Check logs for cross-site status
echo ""
echo "6. Checking recent logs for cross-site status..."
PRIMARY_POD=$(kubectl get pods -n primary -l app=infinispan -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
SECONDARY_POD=$(kubectl get pods -n secondary -l app=infinispan -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ ! -z "$PRIMARY_POD" ]; then
    echo "Primary pod ($PRIMARY_POD) RELAY2 logs:"
    kubectl logs -n primary $PRIMARY_POD --tail=50 | grep -i "relay\|site\|bridge" | tail -10
fi

if [ ! -z "$SECONDARY_POD" ]; then
    echo ""
    echo "Secondary pod ($SECONDARY_POD) RELAY2 logs:"
    kubectl logs -n secondary $SECONDARY_POD --tail=50 | grep -i "relay\|site\|bridge" | tail -10
fi

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "To monitor cross-site replication status:"
echo "kubectl logs -n primary $PRIMARY_POD -f | grep -i relay"
echo "kubectl logs -n secondary $SECONDARY_POD -f | grep -i relay"
echo ""
echo "To test connectivity:"
echo "kubectl exec -n primary $PRIMARY_POD -- telnet infinispan-xsite.secondary.svc.cluster.local 7800"
