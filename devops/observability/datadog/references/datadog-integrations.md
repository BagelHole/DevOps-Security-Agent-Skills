# Datadog Integration Reference

## Agent Configuration

```yaml
# /etc/datadog-agent/datadog.yaml
api_key: YOUR_API_KEY
site: datadoghq.com
hostname: my-host
tags:
  - env:production
  - team:platform

logs_enabled: true
apm_config:
  enabled: true
process_config:
  enabled: true
```

## Docker Integration

```yaml
# docker-compose.yml
datadog-agent:
  image: gcr.io/datadoghq/agent:latest
  environment:
    - DD_API_KEY=${DD_API_KEY}
    - DD_SITE=datadoghq.com
    - DD_LOGS_ENABLED=true
    - DD_APM_ENABLED=true
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock:ro
    - /proc/:/host/proc/:ro
    - /sys/fs/cgroup:/host/sys/fs/cgroup:ro
```

## Kubernetes Integration

```yaml
# Datadog Agent Helm values
datadog:
  apiKey: <API_KEY>
  site: datadoghq.com
  
  logs:
    enabled: true
    containerCollectAll: true
    
  apm:
    portEnabled: true
    
  processAgent:
    enabled: true
    processCollection: true

clusterAgent:
  enabled: true
  metricsProvider:
    enabled: true
```

## Custom Metrics

```python
from datadog import statsd

# Counter
statsd.increment('page.views')

# Gauge
statsd.gauge('users.online', 123)

# Histogram
statsd.histogram('request.duration', 0.5)

# Distribution
statsd.distribution('request.size', 1024)
```

## Log Integration

```python
import logging
import json_log_formatter

formatter = json_log_formatter.JSONFormatter()
handler = logging.StreamHandler()
handler.setFormatter(formatter)

logger = logging.getLogger()
logger.addHandler(handler)
logger.setLevel(logging.INFO)

logger.info('Request processed', extra={
    'dd.trace_id': trace_id,
    'dd.span_id': span_id,
    'user_id': user_id
})
```

## Monitors (Terraform)

```hcl
resource "datadog_monitor" "cpu_high" {
  name    = "High CPU Usage"
  type    = "metric alert"
  message = "CPU usage is high. @slack-alerts"
  
  query = "avg(last_5m):avg:system.cpu.user{*} by {host} > 80"
  
  monitor_thresholds {
    critical = 80
    warning  = 70
  }
  
  tags = ["env:production", "team:platform"]
}
```
