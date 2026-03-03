---
name: llmops-platform-engineering
description: Build production LLMOps platforms with CI/CD, model promotion workflows, evaluation gates, rollback, and governance across cloud and self-hosted inference.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# LLMOps Platform Engineering

Design and operate an internal LLM platform that supports rapid experimentation without compromising reliability, cost, or compliance.

## Outcomes

- Standardized path from experiment to production
- Safe model rollout with quality and safety gates
- Repeatable infra modules for inference, vector DB, and observability
- Clear ownership model across platform, app, and security teams

## Reference Architecture

1. **Control Plane**: model registry, prompt/version catalog, policy checks, eval pipeline.
2. **Data Plane**: inference gateway, vector database, cache, feature store.
3. **Ops Plane**: telemetry, alerting, SLO dashboards, cost analytics.
4. **Security Plane**: IAM boundaries, secret rotation, content filters, audit logs.

## Golden Delivery Workflow

1. Train/fine-tune or onboard provider model.
2. Register artifact and metadata (license, intended use, constraints).
3. Run automated eval suite (quality + safety + latency + cost).
4. Deploy canary behind gateway with strict traffic policy.
5. Promote after SLO and business KPI thresholds pass.
6. Keep rollback target hot for fast reversion.

## CI/CD Design for AI Services

- Build immutable containers with pinned dependencies and model hashes.
- Use environment promotion: `dev -> stage -> prod`.
- Fail deployment if:
  - regression evals drop below baseline,
  - safety tests exceed risk threshold,
  - p95 latency exceeds SLO budget.
- Store deployment evidence for audits (commit SHA, eval report, approver).

## Operational SLOs

- Availability: `99.9%` for synchronous inference endpoints.
- Latency: p95 under product-specific target (for example, `<1200ms`).
- Cost: per-request and per-tenant budget ceilings.
- Quality: task success rate and groundedness thresholds.

## Platform Guardrails

- Enforce tenant quotas and model allow-lists.
- Require structured output contracts for automation paths.
- Default to low-risk model settings for critical workflows.
- Disable unconstrained tool execution in production.

## Tooling Stack (Example)

- **Orchestration**: Argo Workflows / GitHub Actions / Airflow.
- **Model Registry**: MLflow / custom metadata DB.
- **Gateway**: LiteLLM / Envoy-based API gateway.
- **Observability**: OpenTelemetry + Prometheus + Grafana + Langfuse.
- **Policy**: OPA/Rego for deployment and runtime checks.

## Incident Readiness

- Runbooks for model outage, provider timeout spikes, and cost surges.
- Chaos drills for provider failover and vector DB degradation.
- Pre-approved rollback path with one-command execution.

## Related Skills

- [ai-pipeline-orchestration](../ai-pipeline-orchestration/) - Orchestrate ingestion and inference workflows
- [agent-evals](../agent-evals/) - Build evaluation gates for releases
- [llm-gateway](../../../infrastructure/networking/llm-gateway/) - Route and control LLM traffic
