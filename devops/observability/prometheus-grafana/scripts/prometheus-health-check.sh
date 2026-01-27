#!/bin/bash
# Prometheus Health Check Script
# Usage: ./prometheus-health-check.sh [prometheus-url]

set -euo pipefail

PROMETHEUS_URL="${1:-http://localhost:9090}"

echo "========================================="
echo "Prometheus Health Check"
echo "URL: $PROMETHEUS_URL"
echo "========================================="
echo ""

# Check Prometheus health
echo -n "Prometheus Health: "
HEALTH=$(curl -s "$PROMETHEUS_URL/-/healthy" 2>/dev/null)
if [ "$HEALTH" == "Prometheus Server is Healthy." ]; then
    echo "✓ Healthy"
else
    echo "✗ Unhealthy"
fi

# Check readiness
echo -n "Prometheus Ready: "
READY=$(curl -s "$PROMETHEUS_URL/-/ready" 2>/dev/null)
if [ "$READY" == "Prometheus Server is Ready." ]; then
    echo "✓ Ready"
else
    echo "✗ Not Ready"
fi

# Get runtime info
echo ""
echo "Runtime Information:"
echo "--------------------"
curl -s "$PROMETHEUS_URL/api/v1/status/runtimeinfo" 2>/dev/null | jq -r '
  .data | 
  "Start Time: \(.startTime)",
  "Uptime: \(.CWD // "N/A")",
  "Storage Retention: \(.storageRetention)",
  "TSDB Info:",
  "  - Head Chunks: \(.TSDB.headChunks // "N/A")",
  "  - Head Series: \(.TSDB.headSeries // "N/A")"
' 2>/dev/null || echo "Could not retrieve runtime info"

# Get active targets summary
echo ""
echo "Target Status:"
echo "--------------"
curl -s "$PROMETHEUS_URL/api/v1/targets" 2>/dev/null | jq -r '
  .data.activeTargets | 
  group_by(.health) | 
  map({health: .[0].health, count: length}) | 
  .[] | 
  "\(.health): \(.count) targets"
' 2>/dev/null || echo "Could not retrieve targets"

# List unhealthy targets
echo ""
echo "Unhealthy Targets:"
echo "------------------"
curl -s "$PROMETHEUS_URL/api/v1/targets" 2>/dev/null | jq -r '
  .data.activeTargets[] | 
  select(.health != "up") | 
  "- \(.labels.job)/\(.labels.instance): \(.lastError)"
' 2>/dev/null || echo "Could not check unhealthy targets"

# Check for firing alerts
echo ""
echo "Firing Alerts:"
echo "--------------"
curl -s "$PROMETHEUS_URL/api/v1/alerts" 2>/dev/null | jq -r '
  .data.alerts[] | 
  select(.state == "firing") | 
  "- [\(.labels.severity // "unknown")] \(.labels.alertname): \(.annotations.summary // .annotations.description // "No description")"
' 2>/dev/null || echo "Could not retrieve alerts"

echo ""
echo "========================================="
echo "Health check complete"
echo "========================================="
