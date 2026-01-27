#!/bin/bash
# Kubernetes Pod Debugging Script
# Usage: ./pod-debug.sh <pod-name> [namespace]

set -euo pipefail

POD_NAME="${1:-}"
NAMESPACE="${2:-default}"

if [ -z "$POD_NAME" ]; then
    echo "Usage: $0 <pod-name> [namespace]"
    echo ""
    echo "Available pods in namespace '$NAMESPACE':"
    kubectl get pods -n "$NAMESPACE" --no-headers | awk '{print "  " $1}'
    exit 1
fi

echo "========================================="
echo "Debugging Pod: $POD_NAME"
echo "Namespace: $NAMESPACE"
echo "========================================="
echo ""

# Pod details
echo "Pod Details:"
echo "------------"
kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o wide

# Pod describe
echo ""
echo "Pod Description:"
echo "----------------"
kubectl describe pod "$POD_NAME" -n "$NAMESPACE"

# Container logs
echo ""
echo "Container Logs (last 50 lines):"
echo "--------------------------------"
CONTAINERS=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.containers[*].name}')
for CONTAINER in $CONTAINERS; do
    echo ""
    echo "=== Container: $CONTAINER ==="
    kubectl logs "$POD_NAME" -n "$NAMESPACE" -c "$CONTAINER" --tail=50 2>/dev/null || echo "No logs available"
done

# Previous container logs (if crashed)
echo ""
echo "Previous Container Logs (if any):"
echo "----------------------------------"
for CONTAINER in $CONTAINERS; do
    echo ""
    echo "=== Container: $CONTAINER (previous) ==="
    kubectl logs "$POD_NAME" -n "$NAMESPACE" -c "$CONTAINER" --previous --tail=20 2>/dev/null || echo "No previous logs"
done

# Resource usage
echo ""
echo "Resource Usage:"
echo "---------------"
kubectl top pod "$POD_NAME" -n "$NAMESPACE" 2>/dev/null || echo "Metrics not available"

# Events for this pod
echo ""
echo "Related Events:"
echo "---------------"
kubectl get events -n "$NAMESPACE" --field-selector involvedObject.name="$POD_NAME" --sort-by='.lastTimestamp'

echo ""
echo "========================================="
echo "Debug information complete"
echo "========================================="
