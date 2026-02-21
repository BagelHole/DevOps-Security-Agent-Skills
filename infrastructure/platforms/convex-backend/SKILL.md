---
name: convex-backend
description: Build reactive backends with Convex functions, schema validation, auth integration, and deployment workflows.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Convex Backend

Use Convex to build type-safe backend logic with realtime data sync.

## Quick Start

```bash
npm install convex
npx convex dev
npx convex deploy
```

## Implementation Tips

- Define schema and validation before writing functions.
- Keep mutations idempotent where possible.
- Use auth identity checks in every privileged query/mutation.
- Add indexing early for high-read collections.

## Related Skills

- [firebase-app-platform](../firebase-app-platform/) - Alternative managed backend
- [agent-observability](../../../devops/ai/agent-observability/) - Instrument AI-driven backend flows
