---
name: dns-management
description: Configure DNS zones and records. Manage Route53, Cloud DNS, and self-hosted DNS. Use when setting up DNS infrastructure.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# DNS Management

Configure and manage DNS infrastructure.

## AWS Route 53

```bash
# Create hosted zone
aws route53 create-hosted-zone --name example.com --caller-reference $(date +%s)

# Create record
aws route53 change-resource-record-sets --hosted-zone-id ZXXXXX --change-batch '{
  "Changes": [{
    "Action": "CREATE",
    "ResourceRecordSet": {
      "Name": "www.example.com",
      "Type": "A",
      "TTL": 300,
      "ResourceRecords": [{"Value": "1.2.3.4"}]
    }
  }]
}'
```

## BIND Configuration

```bash
# /etc/bind/zones/example.com.db
$TTL 86400
@   IN  SOA ns1.example.com. admin.example.com. (
        2024010101 ; Serial
        3600       ; Refresh
        1800       ; Retry
        604800     ; Expire
        86400 )    ; Minimum TTL

    IN  NS      ns1.example.com.
    IN  A       1.2.3.4
www IN  A       1.2.3.4
```

## Common Records

```
A     - IPv4 address
AAAA  - IPv6 address
CNAME - Alias to another domain
MX    - Mail server
TXT   - Text record (SPF, DKIM)
NS    - Name server
```

## Best Practices

- Low TTL during migrations
- Implement DNSSEC
- Use multiple name servers
- Monitor DNS resolution
