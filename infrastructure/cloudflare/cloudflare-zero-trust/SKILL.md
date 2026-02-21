---
name: cloudflare-zero-trust
description: Protect internal apps with Cloudflare Access, device posture, and Zero Trust policies.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Cloudflare Zero Trust

Secure access to internal services without exposing public VPN endpoints.

## Core Workflow

1. Register application in Cloudflare Access.
2. Integrate identity provider (Google Workspace, Okta, Entra ID).
3. Define access policies by group, email domain, and device posture.
4. Add logging and alerts for blocked requests.

## Tunnel Setup

```bash
cloudflared tunnel login
cloudflared tunnel create internal-app
cloudflared tunnel route dns internal-app app.example.com
cloudflared tunnel run internal-app
```

## Best Practices

- Enforce MFA and managed-device posture checks.
- Use service tokens for CI/CD automation.
- Review app policies quarterly.

## Related Skills

- [zero-trust](../../../security/network/zero-trust/) - Zero trust architecture fundamentals
- [dns-management](../../networking/dns-management/) - DNS routing concepts
