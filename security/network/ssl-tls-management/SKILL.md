---
name: ssl-tls-management
description: Manage SSL/TLS certificates with Let's Encrypt and internal PKI. Configure secure HTTPS, certificate renewal, and cipher suites. Use when implementing secure communications.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# SSL/TLS Management

Manage certificates and secure communications.

## Let's Encrypt (Certbot)

```bash
# Install
apt install certbot python3-certbot-nginx

# Get certificate
certbot --nginx -d example.com -d www.example.com

# Auto-renewal
certbot renew --dry-run
# Cron: 0 0 * * * certbot renew --quiet
```

## cert-manager (Kubernetes)

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: example-cert
spec:
  secretName: example-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
  - example.com
```

## Strong Configuration

```nginx
# nginx ssl config
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
ssl_prefer_server_ciphers off;
ssl_session_timeout 1d;
ssl_session_cache shared:SSL:10m;
ssl_stapling on;
ssl_stapling_verify on;

add_header Strict-Transport-Security "max-age=63072000" always;
```

## Certificate Monitoring

```bash
# Check expiration
openssl s_client -connect example.com:443 -servername example.com 2>/dev/null | \
  openssl x509 -noout -dates

# Check certificate chain
openssl s_client -connect example.com:443 -showcerts
```

## Best Practices

- Automate renewal
- Monitor expiration
- Use strong ciphers
- Enable HSTS
- Regular security audits

## Related Skills

- [hashicorp-vault](../../secrets/hashicorp-vault/) - PKI management
- [waf-setup](../waf-setup/) - Web protection
