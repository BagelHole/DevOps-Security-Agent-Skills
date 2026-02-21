---
name: agent-observability
description: Instrument AI agents with tracing, token metrics, latency, and cost visibility. Use for reliability and debugging.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Agent Observability

Monitor AI agent behavior with logs, traces, metrics, and cost telemetry.

## Track Core Signals

- Request latency (p50/p95/p99)
- Token usage (prompt/completion/cached)
- Tool call success and failure rates
- Cost per task and per customer
- Hallucination and retry frequency

## Implementation Pattern

1. Add trace IDs to every user request.
2. Capture each LLM call and tool call as child spans.
3. Emit structured logs with model, temperature, and response status.
4. Create SLOs for success rate and median response time.

## Best Practices

- Redact PII before exporting traces.
- Keep a replayable request envelope for incident review.
- Alert on abnormal token spikes and tool error bursts.

## Related Skills

- [alerting-oncall](../../observability/alerting-oncall/) - Alert workflows
- [agent-evals](../agent-evals/) - Quality verification
