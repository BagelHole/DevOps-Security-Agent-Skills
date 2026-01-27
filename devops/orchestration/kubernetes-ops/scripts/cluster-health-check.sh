#!/bin/bash
# Kubernetes Cluster Health Check Script
# Usage: ./cluster-health-check.sh [namespace]

set -euo pipefail

NAMESPACE="${1:-default}"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "Kubernetes Cluster Health Check"
echo "========================================="
echo ""

# Check cluster connectivity
echo -n "Checking cluster connectivity... "
if kubectl cluster-info &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    exit 1
fi

# Node status
echo ""
echo "Node Status:"
echo "------------"
kubectl get nodes -o wide

# Check for NotReady nodes
NOT_READY=$(kubectl get nodes --no-headers | grep -v " Ready" | wc -l)
if [ "$NOT_READY" -gt 0 ]; then
    echo -e "${RED}WARNING: $NOT_READY node(s) not ready${NC}"
fi

# Pod status in namespace
echo ""
echo "Pod Status in namespace '$NAMESPACE':"
echo "--------------------------------------"
kubectl get pods -n "$NAMESPACE" -o wide

# Check for failed pods
FAILED_PODS=$(kubectl get pods -n "$NAMESPACE" --no-headers | grep -E "Error|CrashLoopBackOff|ImagePullBackOff" | wc -l)
if [ "$FAILED_PODS" -gt 0 ]; then
    echo -e "${RED}WARNING: $FAILED_PODS pod(s) in error state${NC}"
fi

# Resource usage
echo ""
echo "Resource Usage:"
echo "---------------"
kubectl top nodes 2>/dev/null || echo "Metrics server not available"

# Recent events
echo ""
echo "Recent Warning Events:"
echo "----------------------"
kubectl get events -n "$NAMESPACE" --field-selector type=Warning --sort-by='.lastTimestamp' | tail -10

# PVC status
echo ""
echo "PersistentVolumeClaim Status:"
echo "-----------------------------"
kubectl get pvc -n "$NAMESPACE" 2>/dev/null || echo "No PVCs found"

# Service status
echo ""
echo "Services:"
echo "---------"
kubectl get svc -n "$NAMESPACE"

echo ""
echo "========================================="
echo "Health check complete"
echo "========================================="
