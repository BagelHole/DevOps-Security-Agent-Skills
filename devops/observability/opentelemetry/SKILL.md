---
name: opentelemetry
description: Instrument applications and infrastructure with OpenTelemetry for unified traces, metrics, and logs. Use when implementing distributed tracing, service-level troubleshooting, or vendor-neutral observability.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# OpenTelemetry

Adopt vendor-neutral telemetry with consistent instrumentation across services.

## When to Use This Skill

Use this skill when:
- Debugging latency across microservices
- Standardizing observability data model and naming
- Sending telemetry to Prometheus, Grafana, Datadog, or OTLP backends
- Building SLO dashboards with trace-to-log correlation

## Core Workflow

1. Define semantic conventions for services, environments, and versions.
2. Add SDK or auto-instrumentation in each service.
3. Run an OpenTelemetry Collector to receive, transform, and export telemetry.
4. Validate cardinality and sampling to control cost.
5. Create golden signals dashboards and alerting from collected data.

## Collector Starter Config

```yaml
# otel-collector.yaml
receivers:
  otlp:
    protocols:
      grpc:
      http:

processors:
  batch:
  memory_limiter:
    check_interval: 1s
    limit_mib: 512
  attributes:
    actions:
      - key: deployment.environment
        value: production
        action: upsert

exporters:
  debug: {}
  otlp:
    endpoint: observability-backend:4317
    tls:
      insecure: true

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [memory_limiter, batch, attributes]
      exporters: [otlp, debug]
    metrics:
      receivers: [otlp]
      processors: [memory_limiter, batch, attributes]
      exporters: [otlp]
```

## Best Practices

- Use tail-based sampling for high-volume production traces.
- Tag telemetry with `service.name`, `service.version`, and `deployment.environment`.
- Drop noisy attributes early in the collector.
- Keep metric label cardinality low for stable query performance.

## Related Skills

- [prometheus-grafana](../prometheus-grafana/) - Dashboarding and alerting
- [datadog](../datadog/) - Managed observability backend
- [alerting-oncall](../alerting-oncall/) - On-call routing and escalation
