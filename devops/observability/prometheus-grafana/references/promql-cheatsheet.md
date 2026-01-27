# PromQL Cheat Sheet

## Basic Queries

### Instant Vectors
```promql
# Simple metric
http_requests_total

# With label filter
http_requests_total{status="200"}

# Multiple labels
http_requests_total{status="200", method="GET"}

# Regex matching
http_requests_total{status=~"2.."}
http_requests_total{status!~"5.."}
```

### Range Vectors
```promql
# Last 5 minutes
http_requests_total[5m]

# Last 1 hour
http_requests_total[1h]

# Time units: s, m, h, d, w, y
```

## Functions

### Rate and Increase
```promql
# Per-second rate over 5m
rate(http_requests_total[5m])

# Total increase over 1h
increase(http_requests_total[1h])

# For gauges that can decrease
irate(http_requests_total[5m])  # instant rate
```

### Aggregations
```promql
# Sum across all instances
sum(http_requests_total)

# Sum by label
sum by (status) (http_requests_total)

# Sum excluding label
sum without (instance) (http_requests_total)

# Other aggregations
avg, min, max, count, stddev, stdvar
topk(5, http_requests_total)
bottomk(3, http_requests_total)
```

### Histogram Quantiles
```promql
# 95th percentile
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# With grouping
histogram_quantile(0.95, 
  sum by (le, endpoint) (
    rate(http_request_duration_seconds_bucket[5m])
  )
)
```

## Common Patterns

### Request Rate
```promql
# Total request rate
sum(rate(http_requests_total[5m]))

# Request rate by endpoint
sum by (endpoint) (rate(http_requests_total[5m]))
```

### Error Rate
```promql
# Error percentage
sum(rate(http_requests_total{status=~"5.."}[5m])) 
/ 
sum(rate(http_requests_total[5m])) 
* 100
```

### Latency
```promql
# Average latency
rate(http_request_duration_seconds_sum[5m])
/
rate(http_request_duration_seconds_count[5m])

# P99 latency
histogram_quantile(0.99, 
  sum by (le) (rate(http_request_duration_seconds_bucket[5m]))
)
```

### Resource Usage
```promql
# CPU usage percentage
100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage percentage
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Disk usage percentage
(1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100
```

### Kubernetes
```promql
# Pod CPU usage
sum by (pod) (rate(container_cpu_usage_seconds_total{container!=""}[5m]))

# Pod memory usage
sum by (pod) (container_memory_usage_bytes{container!=""})

# Pod restart count
sum by (pod) (kube_pod_container_status_restarts_total)
```

## Alert Examples

### High Error Rate
```yaml
- alert: HighErrorRate
  expr: |
    sum(rate(http_requests_total{status=~"5.."}[5m])) 
    / sum(rate(http_requests_total[5m])) > 0.05
  for: 5m
  labels:
    severity: critical
  annotations:
    summary: "High error rate detected"
```

### High Latency
```yaml
- alert: HighLatency
  expr: |
    histogram_quantile(0.95, 
      sum by (le) (rate(http_request_duration_seconds_bucket[5m]))
    ) > 0.5
  for: 5m
  labels:
    severity: warning
```

### Low Disk Space
```yaml
- alert: LowDiskSpace
  expr: |
    (node_filesystem_avail_bytes / node_filesystem_size_bytes) < 0.1
  for: 5m
  labels:
    severity: warning
```
