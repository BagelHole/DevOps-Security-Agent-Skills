---
name: llm-app-security
description: Secure LLM-powered applications with input validation, output controls, tenant isolation, and abuse prevention.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# LLM Application Security

Harden chatbots and AI features embedded in web and mobile products.

## Baseline Security Checklist

- Validate and classify all user-provided context.
- Separate system prompts from user content strictly.
- Add moderation for toxic, harmful, and policy-violating outputs.
- Enforce tenant boundaries in retrieval and memory layers.
- Rate-limit high-cost endpoints.

## Secure RAG Pattern

1. Ingest content with malware and secret scanning.
2. Tag documents by tenant and access policy.
3. Filter retrieval candidates by user authorization.
4. Add provenance metadata in final responses.

## Related Skills

- [ai-agent-security](../ai-agent-security/) - Agent-specific controls
- [sast-scanning](../scanning/sast-scanning/) - Secure coding checks
