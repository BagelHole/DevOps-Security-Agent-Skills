#!/bin/bash
# Kubernetes Namespace Cleanup Script
# Removes completed jobs, failed pods, and unused resources
# Usage: ./namespace-cleanup.sh <namespace> [--dry-run]

set -euo pipefail

NAMESPACE="${1:-}"
DRY_RUN="${2:-}"

if [ -z "$NAMESPACE" ]; then
    echo "Usage: $0 <namespace> [--dry-run]"
    exit 1
fi

if [ "$DRY_RUN" == "--dry-run" ]; then
    echo "DRY RUN MODE - No changes will be made"
    DELETE_CMD="echo [DRY RUN] Would delete:"
else
    DELETE_CMD="kubectl delete"
fi

echo "========================================="
echo "Namespace Cleanup: $NAMESPACE"
echo "========================================="
echo ""

# Delete completed jobs
echo "Cleaning up completed Jobs..."
COMPLETED_JOBS=$(kubectl get jobs -n "$NAMESPACE" -o jsonpath='{.items[?(@.status.succeeded==1)].metadata.name}' 2>/dev/null)
if [ -n "$COMPLETED_JOBS" ]; then
    for job in $COMPLETED_JOBS; do
        $DELETE_CMD job "$job" -n "$NAMESPACE" 2>/dev/null || true
    done
else
    echo "No completed jobs found"
fi

# Delete failed pods
echo ""
echo "Cleaning up failed Pods..."
FAILED_PODS=$(kubectl get pods -n "$NAMESPACE" --field-selector status.phase=Failed -o name 2>/dev/null)
if [ -n "$FAILED_PODS" ]; then
    for pod in $FAILED_PODS; do
        $DELETE_CMD "$pod" -n "$NAMESPACE" 2>/dev/null || true
    done
else
    echo "No failed pods found"
fi

# Delete evicted pods
echo ""
echo "Cleaning up evicted Pods..."
EVICTED_PODS=$(kubectl get pods -n "$NAMESPACE" -o json | jq -r '.items[] | select(.status.reason=="Evicted") | .metadata.name' 2>/dev/null)
if [ -n "$EVICTED_PODS" ]; then
    for pod in $EVICTED_PODS; do
        $DELETE_CMD pod "$pod" -n "$NAMESPACE" 2>/dev/null || true
    done
else
    echo "No evicted pods found"
fi

# Delete orphaned ReplicaSets (0 replicas, no owner)
echo ""
echo "Cleaning up orphaned ReplicaSets..."
kubectl get rs -n "$NAMESPACE" -o json | jq -r '.items[] | select(.spec.replicas==0) | .metadata.name' 2>/dev/null | while read rs; do
    if [ -n "$rs" ]; then
        $DELETE_CMD rs "$rs" -n "$NAMESPACE" 2>/dev/null || true
    fi
done

echo ""
echo "========================================="
echo "Cleanup complete"
echo "========================================="
