---
name: sbom-supply-chain
description: Generate, sign, and verify SBOMs and provenance attestations to secure the software supply chain. Use when implementing SLSA controls, artifact trust policies, or compliance evidence for releases.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# SBOM & Supply Chain Security

Improve release trust with reproducible metadata and verification gates.

## When to Use This Skill

Use this skill when:
- Producing SBOMs for container images or application builds
- Verifying dependencies before deploy
- Enforcing signed artifact and provenance policies
- Preparing for SOC2, ISO 27001, or customer security reviews

## Recommended Tooling

- SBOM generation: Syft, CycloneDX tools
- Vulnerability matching: Grype, Trivy
- Signing and attestations: Cosign, Sigstore
- Policy enforcement: OPA, Kyverno, admission controllers

## Baseline Workflow

1. Generate SBOM in SPDX or CycloneDX format during CI builds.
2. Create provenance attestations for build steps and source commit.
3. Sign image digests and SBOM artifacts with keyless or managed keys.
4. Verify signatures and attestations before deployment.
5. Archive evidence for audits and incident response.

## Example Commands

```bash
# Generate SBOM for an image
syft registry:ghcr.io/acme/api:1.2.3 -o cyclonedx-json > sbom.json

# Sign container image digest
cosign sign ghcr.io/acme/api@sha256:abc123...

# Attach SBOM attestation
cosign attest --predicate sbom.json --type cyclonedx ghcr.io/acme/api@sha256:abc123...

# Verify signatures
cosign verify ghcr.io/acme/api@sha256:abc123...
```

## Related Skills

- [dependency-scanning](../dependency-scanning/) - Library vulnerability triage
- [container-scanning](../container-scanning/) - Container CVE scanning
- [policy-as-code](../../../compliance/governance/policy-as-code/) - Policy enforcement
