---
name: waf-setup
description: Deploy and tune Web Application Firewalls. Configure rules for OWASP Top 10 protection. Use when protecting web applications from common attacks.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# WAF Setup

Protect web applications with Web Application Firewalls.

## AWS WAF

```bash
# Create Web ACL
aws wafv2 create-web-acl \
  --name my-waf \
  --scope REGIONAL \
  --default-action Allow={} \
  --rules file://rules.json

# Associate with ALB
aws wafv2 associate-web-acl \
  --web-acl-arn arn:aws:wafv2:... \
  --resource-arn arn:aws:elasticloadbalancing:...
```

## ModSecurity (nginx)

```nginx
# nginx.conf
load_module modules/ngx_http_modsecurity_module.so;

server {
  modsecurity on;
  modsecurity_rules_file /etc/nginx/modsec/main.conf;
}
```

```bash
# Install OWASP CRS
git clone https://github.com/coreruleset/coreruleset /etc/nginx/modsec/crs
```

## Cloudflare WAF

```bash
# Enable managed rules via API
curl -X PUT "https://api.cloudflare.com/client/v4/zones/{zone}/firewall/waf/packages/{package}/rules/{rule}" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"mode":"block"}'
```

## Common Rules

```yaml
protections:
  - SQL Injection (SQLi)
  - Cross-Site Scripting (XSS)
  - Remote File Inclusion (RFI)
  - Local File Inclusion (LFI)
  - Command Injection
  - Cross-Site Request Forgery (CSRF)
```

## Best Practices

- Start in detection mode
- Tune for false positives
- Monitor blocked requests
- Regular rule updates
- Custom rules for app-specific attacks

## Related Skills

- [dast-scanning](../../scanning/dast-scanning/) - Web security testing
- [ssl-tls-management](../ssl-tls-management/) - HTTPS configuration
