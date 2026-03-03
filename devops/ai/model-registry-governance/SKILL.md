---
name: model-registry-governance
description: Establish model registry standards, governance controls, metadata schemas, approvals, and lifecycle policies for enterprise AI deployments.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Model Registry Governance

Create a trustworthy system of record for model artifacts, prompts, adapters, and evaluation evidence.

## Core Principles

- **Traceability**: every production model maps to source code, data snapshot, and evaluation results.
- **Reproducibility**: builds are deterministic with pinned dependencies.
- **Policy-driven promotion**: no manual bypass for critical safety checks.
- **Lifecycle hygiene**: stale, vulnerable, or unowned models are retired automatically.

## Required Metadata Schema

Track at minimum:

- Model name, semantic version, checksum, and storage URI
- Base model lineage and fine-tune method
- Training/eval datasets and time windows
- License, allowed use cases, prohibited use cases
- Security risk rating and mitigation controls
- Owner, backup owner, and escalation contact

## Approval Workflow

1. Registration request created from CI.
2. Security checks (artifact scan, dependency scan, provenance).
3. Evaluation package uploaded (quality, toxicity, jailbreak, bias, latency, cost).
4. Required approvals: platform + product + security (as policy dictates).
5. Promotion to stage/prod based on signed decision record.

## Lifecycle States

- `draft`: internal experimentation.
- `candidate`: passed baseline tests.
- `approved`: authorized for production rollout.
- `deprecated`: replacement announced, new usage blocked.
- `retired`: no serving allowed, archived for audit.

## Governance Policies

- Reject artifacts without SBOM/provenance.
- Block promotion if known critical CVEs remain unresolved.
- Require refreshed evals after prompt/template changes.
- Expire approvals after a configurable period (for example 90 days).

## Audit Readiness

Maintain immutable records of:

- Who approved and when
- Which policy checks executed
- Which exceptions were granted
- What model/version served each customer request window

## Related Skills

- [sbom-supply-chain](../../../security/scanning/sbom-supply-chain/) - Provenance and signing
- [policy-as-code](../../../compliance/governance/policy-as-code/) - Enforce governance with policy engines
- [llm-fine-tuning](../../../infrastructure/local-ai/llm-fine-tuning/) - Version adapters and training outputs
