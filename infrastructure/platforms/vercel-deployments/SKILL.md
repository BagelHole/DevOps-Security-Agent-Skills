---
name: vercel-deployments
description: Deploy frontend and full-stack apps on Vercel with previews, edge functions, and environment promotion.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Vercel Deployments

Ship web apps quickly with preview environments and managed edge infrastructure.

## Core Workflow

```bash
npm i -g vercel
vercel login
vercel link
vercel
vercel --prod
```

## Production Guardrails

- Require preview checks before merge.
- Separate preview and production environment variables.
- Use branch protection with required deployment status.
- Monitor function duration and cold start behavior.

## Related Skills

- [github-actions](../../../devops/ci-cd/github-actions/) - Automated deployment gates
- [cloudflare-pages](../../cloudflare/cloudflare-pages/) - Alternative edge hosting
