---
name: ai-agent-security
description: Secure AI agents against prompt injection, tool abuse, and data exfiltration with defense-in-depth controls.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# AI Agent Security

Protect agentic systems from adversarial input and unsafe tool execution.

## Threats to Model

- Prompt injection through untrusted content
- Excessive permissions on tools and APIs
- Data exfiltration via model responses
- Cross-tenant context leakage

## Security Controls

1. Isolate tool execution with strict allowlists.
2. Add policy checks before sensitive actions.
3. Limit token scope and credential lifetimes.
4. Apply output filtering for sensitive data.
5. Log every privileged tool invocation.

## Incident Readiness

- Keep immutable audit trails for prompts and tool calls.
- Build kill switches for high-risk tools.
- Run regular red-team scenarios.

## Related Skills

- [llm-app-security](../llm-app-security/) - Application-layer LLM defenses
- [threat-modeling](../operations/threat-modeling/) - Structured risk analysis
