---
name: cdn-setup
description: Configure CDNs for content delivery. Set up CloudFront, Cloudflare, and Fastly. Use when optimizing global content delivery.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# CDN Setup

Configure content delivery networks.

## AWS CloudFront

```bash
aws cloudfront create-distribution --distribution-config '{
  "CallerReference": "my-distribution",
  "Origins": {
    "Quantity": 1,
    "Items": [{
      "Id": "myS3Origin",
      "DomainName": "mybucket.s3.amazonaws.com",
      "S3OriginConfig": {"OriginAccessIdentity": ""}
    }]
  },
  "DefaultCacheBehavior": {
    "TargetOriginId": "myS3Origin",
    "ViewerProtocolPolicy": "redirect-to-https",
    "CachePolicyId": "658327ea-f89d-4fab-a63d-7e88639e58f6"
  },
  "Enabled": true
}'
```

## Cloudflare

```bash
# Via API
curl -X POST "https://api.cloudflare.com/client/v4/zones" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"example.com","jump_start":true}'
```

## Cache Headers

```nginx
location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
    expires 30d;
    add_header Cache-Control "public, immutable";
}
```

## Best Practices

- Set appropriate cache headers
- Use cache invalidation sparingly
- Implement cache warming
- Monitor cache hit ratios
