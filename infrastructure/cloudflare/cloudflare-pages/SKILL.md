---
name: cloudflare-pages
description: Deploy static sites and full-stack apps on Cloudflare Pages with previews, functions, and custom domains.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Cloudflare Pages

Deploy frontend projects with preview builds and edge functions.

## Connect Project

1. Create a Pages project in Cloudflare dashboard.
2. Link your GitHub repository.
3. Set build command and output directory.
4. Configure environment variables per environment.

## Wrangler-Based Deploy

```bash
npm install -D wrangler
npx wrangler pages project create my-site
npx wrangler pages deploy dist --project-name=my-site
```

## Best Practices

- Require previews for pull requests.
- Separate production and preview secrets.
- Enable Web Analytics for performance visibility.
- Add Cloudflare WAF rules for abuse protection.

## Related Skills

- [cloudflare-workers](../cloudflare-workers/) - Edge backend logic
- [vercel-deployments](../../platforms/vercel-deployments/) - Alternative frontend hosting
