---
name: multi-tenant-llm-hosting
description: Design secure, multi-tenant LLM hosting platforms with tenant isolation, quotas, billing attribution, noisy-neighbor protection, and per-tenant policy controls.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Multi-Tenant LLM Hosting

Host many teams/customers on shared inference infrastructure without sacrificing security, performance, or cost governance.

## Isolation Model

- Strong tenant identity on every request
- Per-tenant API keys and scoped model access
- Namespace or workload isolation for high-risk tenants
- Strict data retention and log partitioning controls

## Noisy-Neighbor Controls

- Per-tenant RPM/TPM limits
- Concurrency caps and queue isolation
- Fair scheduling with weighted priority classes
- Backpressure and graceful degradation policies

## Billing and Chargeback

Track per-tenant:
- prompt/completion/cached tokens,
- model type and route,
- latency and success rate,
- cost with markup or internal transfer pricing.

## Security Baseline

- Encrypt data in transit and at rest.
- Disallow cross-tenant cache leakage.
- Restrict debug data access by role.
- Audit all privileged administrative actions.

## Operational Runbook

1. Onboard tenant with policy template.
2. Issue virtual key and quota profile.
3. Validate observability and billing tags.
4. Run tenant-specific load/safety tests.
5. Enable production traffic with canary limits.

## Related Skills

- [llm-gateway](../../networking/llm-gateway/) - Key management and traffic routing
- [llm-cost-optimization](../../../devops/ai/llm-cost-optimization/) - Cost controls and optimization tactics
- [zero-trust](../../../security/network/zero-trust/) - Identity-centric network and access patterns
