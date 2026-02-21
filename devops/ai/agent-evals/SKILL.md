---
name: agent-evals
description: Build automated evaluation suites for AI agents using golden datasets, rubrics, and regression gates.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Agent Evals

Create repeatable checks so agent behavior improves safely over time.

## Evaluation Layers

- Unit evals: prompt-level correctness
- Tool evals: API/tool call decision quality
- End-to-end evals: realistic multi-step tasks
- Safety evals: prompt injection and data leak resistance

## CI/CD Integration

```bash
# Example eval pipeline steps
make evals-smoke
make evals-regression
make evals-safety
```

## Best Practices

- Version datasets with expected outputs.
- Track pass rates and score drift over time.
- Block deploys on critical safety regressions.

## Related Skills

- [github-actions](../../ci-cd/github-actions/) - Eval automation in CI
- [ai-agent-security](../../../security/ai/ai-agent-security/) - Security-focused eval cases
