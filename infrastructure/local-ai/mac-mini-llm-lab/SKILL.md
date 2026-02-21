---
name: mac-mini-llm-lab
description: Configure a Mac mini as a reliable local LLM server with remote access, observability, and power-safe operation.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Mac mini LLM Lab

Turn a Mac mini into a low-noise, always-on local AI appliance.

## System Setup

1. Update macOS and Xcode command line tools.
2. Install Homebrew and core packages (`tmux`, `htop`, `ollama`).
3. Enable automatic login and restart-after-power-failure.
4. Configure Tailscale or WireGuard for remote access.

## Reliability Checklist

- Keep device on wired Ethernet.
- Use UPS for power protection.
- Schedule weekly reboot window.
- Add launchd service for Ollama auto-start.

## Security Checklist

- Disable unnecessary sharing services.
- Enforce FileVault and strong local admin password.
- Restrict SSH to key-based auth only.

## Related Skills

- [ollama-stack](../ollama-stack/) - Local inference software stack
- [ssh-configuration](../../servers/ssh-configuration/) - Secure remote shell access
