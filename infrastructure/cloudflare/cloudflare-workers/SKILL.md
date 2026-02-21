---
name: cloudflare-workers
description: Build and deploy edge functions with Cloudflare Workers and Wrangler. Use for APIs, cron jobs, and edge middleware.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Cloudflare Workers

Deploy JavaScript/TypeScript functions globally at the edge.

## Quick Start

```bash
npm create cloudflare@latest my-worker
cd my-worker
npx wrangler login
npx wrangler deploy
```

## Common Commands

```bash
# Local dev
npx wrangler dev

# Set secret
npx wrangler secret put API_TOKEN

# Tail logs
npx wrangler tail
```

## Best Practices

- Keep workers stateless and fast.
- Use KV, D1, or R2 for persistence.
- Add rate limits for public APIs.
- Version Wrangler config in git.

## Related Skills

- [cloudflare-pages](../cloudflare-pages/) - Frontend deployments
- [cloudflare-r2](../cloudflare-r2/) - Object storage at the edge
