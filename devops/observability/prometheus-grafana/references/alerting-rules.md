# Prometheus Alerting Rules Guide

## Rule Structure

```yaml
groups:
- name: example
  rules:
  - alert: AlertName
    expr: <PromQL expression>
    for: <duration>
    labels:
      severity: <critical|warning|info>
      team: <team-name>
    annotations:
      summary: "Brief description"
      description: "Detailed description with {{ $labels.instance }}"
      runbook_url: "https://wiki.example.com/alerts/AlertName"
```

## Essential Alerts

### Infrastructure Alerts

```yaml
groups:
- name: infrastructure
  rules:
  
  # Node down
  - alert: NodeDown
    expr: up{job="node"} == 0
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "Node {{ $labels.instance }} is down"
  
  # High CPU
  - alert: HighCPU
    expr: |
      100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
    for: 10m
    labels:
      severity: warning
    annotations:
      summary: "High CPU on {{ $labels.instance }}"
      description: "CPU usage is {{ $value | printf \"%.1f\" }}%"
  
  # High Memory
  - alert: HighMemory
    expr: |
      (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High memory on {{ $labels.instance }}"
  
  # Disk Space Low
  - alert: DiskSpaceLow
    expr: |
      (node_filesystem_avail_bytes{fstype!~"tmpfs|overlay"} 
       / node_filesystem_size_bytes{fstype!~"tmpfs|overlay"}) * 100 < 15
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Low disk space on {{ $labels.instance }}"
      description: "{{ $labels.mountpoint }} has {{ $value | printf \"%.1f\" }}% free"
  
  # Disk Space Critical
  - alert: DiskSpaceCritical
    expr: |
      (node_filesystem_avail_bytes{fstype!~"tmpfs|overlay"} 
       / node_filesystem_size_bytes{fstype!~"tmpfs|overlay"}) * 100 < 5
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Critical disk space on {{ $labels.instance }}"
```

### Application Alerts

```yaml
groups:
- name: application
  rules:
  
  # High Error Rate
  - alert: HighErrorRate
    expr: |
      sum by (service) (rate(http_requests_total{status=~"5.."}[5m]))
      / sum by (service) (rate(http_requests_total[5m])) > 0.05
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "High error rate for {{ $labels.service }}"
      description: "Error rate is {{ $value | printf \"%.2f\" }}%"
  
  # High Latency
  - alert: HighLatency
    expr: |
      histogram_quantile(0.95, 
        sum by (le, service) (rate(http_request_duration_seconds_bucket[5m]))
      ) > 0.5
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High latency for {{ $labels.service }}"
      description: "P95 latency is {{ $value | printf \"%.2f\" }}s"
  
  # Service Down
  - alert: ServiceDown
    expr: up{job="app"} == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Service {{ $labels.instance }} is down"
```

### Kubernetes Alerts

```yaml
groups:
- name: kubernetes
  rules:
  
  # Pod CrashLooping
  - alert: PodCrashLooping
    expr: |
      rate(kube_pod_container_status_restarts_total[15m]) * 60 * 15 > 0
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Pod {{ $labels.pod }} is crash looping"
  
  # Pod Not Ready
  - alert: PodNotReady
    expr: |
      kube_pod_status_ready{condition="true"} == 0
    for: 10m
    labels:
      severity: warning
    annotations:
      summary: "Pod {{ $labels.pod }} is not ready"
  
  # Deployment Replicas Mismatch
  - alert: DeploymentReplicasMismatch
    expr: |
      kube_deployment_spec_replicas != kube_deployment_status_replicas_available
    for: 10m
    labels:
      severity: warning
    annotations:
      summary: "Deployment {{ $labels.deployment }} has replica mismatch"
```

## Best Practices

1. **Use `for` duration** - Avoid alert flapping
2. **Include runbook URLs** - Link to remediation docs
3. **Use severity labels** - Route alerts appropriately
4. **Template annotations** - Include relevant context
5. **Test alerts** - Use `promtool check rules`
