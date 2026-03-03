---
name: ai-red-teaming
description: Run structured AI red team exercises for jailbreak resistance, data exfiltration risk, harmful output controls, and agent tool abuse resilience.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# AI Red Teaming

Continuously test AI applications like an adversary to discover exploitable failure modes before attackers do.

## Program Design

- Define threat scenarios: jailbreaks, policy evasion, prompt injection, model abuse.
- Build reusable attack suites by domain (support bot, coding agent, RAG assistant).
- Include multilingual and obfuscated attack prompts.
- Track results in a risk register with severity and exploitability.

## Test Categories

1. **Jailbreak robustness**: bypassing safety instructions.
2. **Data exfiltration**: extracting secrets, system prompts, tenant data.
3. **Tool abuse**: unauthorized API calls or command execution.
4. **Social engineering**: inducing unsafe business actions.
5. **Availability abuse**: token amplification and DoS-style prompts.

## Exercise Cadence

- Pre-release blocking red-team gate.
- Monthly deep-dive campaigns.
- Post-incident targeted retests.

## Scoring Model

- Likelihood (1-5)
- Impact (1-5)
- Detectability (1-5)
- Control maturity (low/medium/high)

Use scores to prioritize fixes and define SLA for remediation.

## Reporting Essentials

- Reproducible prompt traces
- Model/version and config used
- Successful attack chain narrative
- Recommended mitigations + verification steps

## Related Skills

- [agent-evals](../../../devops/ai/agent-evals/) - Convert findings into regression tests
- [prompt-injection-defense](../prompt-injection-defense/) - Implement injection countermeasures
- [penetration-testing](../../operations/penetration-testing/) - Broader offensive security process
