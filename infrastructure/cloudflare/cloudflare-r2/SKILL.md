---
name: cloudflare-r2
description: Manage Cloudflare R2 buckets, lifecycle, and signed URLs. Use for low-egress object storage and media delivery.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Cloudflare R2

Use S3-compatible object storage without egress fees.

## Setup

```bash
# Create bucket
npx wrangler r2 bucket create app-assets

# List buckets
npx wrangler r2 bucket list

# Upload object
npx wrangler r2 object put app-assets/logo.png --file ./logo.png
```

## S3-Compatible Access

- Generate R2 API tokens with least privilege.
- Use endpoint format: `https://<accountid>.r2.cloudflarestorage.com`.
- Configure lifecycle rules for archive/delete.

## Best Practices

- Use short-lived signed URLs for private content.
- Store user uploads in tenant-specific prefixes.
- Enable object versioning for recovery-critical buckets.

## Related Skills

- [cloudflare-workers](../cloudflare-workers/) - Signed URL generation
- [object-storage](../../storage/object-storage/) - Storage patterns
