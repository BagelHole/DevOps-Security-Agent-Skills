---
name: ollama-stack
description: Run local LLM workloads with Ollama, Open WebUI, and GPU-aware tuning for private development environments.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Ollama Stack

Deploy a local LLM stack for offline and privacy-first workflows.

## Minimal Setup

```bash
curl -fsSL https://ollama.com/install.sh | sh
ollama serve
ollama pull llama3.1:8b
ollama run llama3.1:8b
```

## Docker Compose Pattern

- Ollama container with persistent model volume
- Open WebUI for chat interface
- Optional LiteLLM proxy for unified API routing

## Best Practices

- Pin model versions for reproducibility.
- Monitor VRAM, RAM, and swap utilization.
- Restrict network exposure to trusted subnets.

## Related Skills

- [mac-mini-llm-lab](../mac-mini-llm-lab/) - Apple Silicon optimization
- [docker-compose](../../../devops/containers/docker-compose/) - Service orchestration
