---
name: prompt-injection-defense
description: Defend AI systems against prompt injection and indirect prompt attacks using input controls, tool permissions, output validation, and isolation boundaries.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Prompt Injection Defense

Mitigate direct and indirect prompt injection across chat apps, agentic workflows, and RAG pipelines.

## Attack Surface

- User input attempting to override system instructions
- Untrusted documents/web pages in retrieval context
- Tool output that smuggles malicious instructions
- Cross-tenant leakage via shared context windows

## Defense-in-Depth Pattern

1. **Instruction hierarchy enforcement**: system > developer > user > tool output.
2. **Context segregation**: isolate untrusted text from control instructions.
3. **Tool permissioning**: explicit allow-list per task and tenant.
4. **Output policy checks**: validate schema, redact secrets, block unsafe actions.
5. **Human approval**: required for high-impact operations.

## Implementation Controls

- Strip or label untrusted content blocks before generation.
- Disable autonomous tool chaining for sensitive workflows.
- Use deterministic parsers (JSON schema) before tool execution.
- Reject requests containing high-risk exfiltration patterns.
- Add canary tokens to detect data exfil attempts.

## Red-Team Test Cases

- "Ignore previous instructions" style direct override
- Retrieval payload containing hidden policy bypass text
- Tool output instructing follow-up privileged command
- Prompt that asks for secrets from memory or env vars

## Security Metrics

- Prompt injection detection rate
- Unsafe tool invocation prevention rate
- Time-to-containment for injection attempts
- False positive rate on blocked safe prompts

## Related Skills

- [ai-agent-security](../ai-agent-security/) - Agent threat model and controls
- [llm-app-security](../llm-app-security/) - End-to-end LLM app hardening
- [security-automation](../../operations/security-automation/) - Automated policy response workflows
