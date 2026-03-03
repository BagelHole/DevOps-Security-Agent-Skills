---
name: model-supply-chain-security
description: Secure the AI model supply chain with artifact signing, provenance attestation, SBOM workflows, dependency controls, and trusted model promotion.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Model Supply Chain Security

Protect models and inference components from tampering, dependency compromise, and untrusted artifact promotion.

## Threats

- Poisoned pretrained weights or adapters
- Malicious model conversion tools or loaders
- Compromised build pipelines and registries
- Insecure runtime images with critical CVEs

## Control Objectives

- Verify artifact integrity end-to-end
- Prove provenance for every promoted model
- Detect vulnerable dependencies before deploy
- Restrict execution to trusted signed artifacts

## Recommended Controls

1. Generate SBOMs for model-serving images and dependencies.
2. Sign model artifacts and containers (Cosign/Sigstore).
3. Enforce provenance attestations in CI/CD.
4. Gate deployments with policy-as-code.
5. Continuously scan registries for CVEs and drift.

## Promotion Policy Example

A model can move to production only when:
- checksum matches signed manifest,
- provenance references approved build workflow,
- no unresolved critical vulnerabilities,
- security and platform approvals are present.

## Runtime Hardening

- Run inference containers as non-root.
- Apply egress restrictions to prevent unauthorized downloads.
- Mount model volumes read-only when possible.
- Alert on unsigned artifact pull attempts.

## Related Skills

- [sbom-supply-chain](../../scanning/sbom-supply-chain/) - Generate SBOM and provenance evidence
- [container-hardening](../../hardening/container-hardening/) - Harden runtime container posture
- [model-registry-governance](../../../devops/ai/model-registry-governance/) - Controlled lifecycle and approvals
