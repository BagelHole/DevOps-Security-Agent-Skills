---
name: ai-sre-incident-response
description: Build AI-focused SRE incident response practices for LLM outages, degraded quality, runaway cost events, and safety regressions.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# AI SRE Incident Response

Apply SRE rigor to AI systems where incidents include quality regressions, unsafe outputs, and budget explosions.

## AI Incident Classes

- **Availability incident**: model/provider unavailable, timeout storm.
- **Quality incident**: answer accuracy or tool success drops below SLO.
- **Safety incident**: harmful or policy-violating outputs increase.
- **Cost incident**: unexpected token or provider spend spike.

## Severity Framework (Example)

- **SEV1**: user-facing outage, critical compliance risk, or active data leak.
- **SEV2**: major degradation affecting key flows.
- **SEV3**: limited impact or internal-only issue.

## Golden Signals for AI Services

- Request success rate
- Latency (queue + generation + tool execution)
- Hallucination/groundedness proxy metrics
- Cost per minute and per tenant
- Guardrail violation rate

## Response Playbooks

### Model Outage
1. Freeze deployments.
2. Shift traffic to fallback model/provider.
3. Enforce stricter rate limits.
4. Communicate ETA and mitigation.

### Quality Regression
1. Roll back prompt/model version.
2. Disable risky optimization flags.
3. Increase sampling for trace review.
4. Re-run latest eval baseline.

### Cost Spike
1. Identify top tenants/routes/models.
2. Enable cache + cheaper fallback path.
3. Apply temporary token caps.
4. Open postmortem with prevention actions.

## Postmortem Requirements

- Timeline with detector and responder timestamps
- Blast radius by tenant and feature
- Missed signals and alert tuning actions
- Concrete hardening tasks with owners and due dates

## Related Skills

- [incident-response](../../../security/operations/incident-response/) - Standard incident process and evidence
- [alerting-oncall](../../observability/alerting-oncall/) - Paging and escalation policy
- [llm-cost-optimization](../llm-cost-optimization/) - Spend controls and efficiency patterns
