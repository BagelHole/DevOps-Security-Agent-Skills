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

## When to Use This Skill

Use this skill when:
- Deploying a public-facing web application that needs attack protection
- Meeting compliance requirements (PCI-DSS, SOC2) for web application security
- Blocking OWASP Top 10 attack categories (SQLi, XSS, CSRF, etc.)
- Protecting APIs from abuse, injection, and rate-based attacks
- Adding a virtual patching layer while application code is being fixed

## Prerequisites

- Web application behind a load balancer or reverse proxy
- AWS account for AWS WAF, or Cloudflare account for Cloudflare WAF
- Nginx with ModSecurity module compiled for self-hosted WAF
- Access to application logs to tune rules and identify false positives
- Understanding of HTTP request/response structure

## AWS WAF

### Create Web ACL with Managed Rules

```bash
# Create Web ACL with AWS managed rules
aws wafv2 create-web-acl \
  --name production-waf \
  --scope REGIONAL \
  --default-action Allow={} \
  --visibility-config SampledRequestsEnabled=true,CloudWatchMetricsEnabled=true,MetricName=production-waf \
  --rules file://waf-rules.json
```

### AWS WAF Rules Configuration

```json
[
  {
    "Name": "AWSManagedRulesCommonRuleSet",
    "Priority": 1,
    "Statement": {
      "ManagedRuleGroupStatement": {
        "VendorName": "AWS",
        "Name": "AWSManagedRulesCommonRuleSet",
        "ExcludedRules": []
      }
    },
    "OverrideAction": { "None": {} },
    "VisibilityConfig": {
      "SampledRequestsEnabled": true,
      "CloudWatchMetricsEnabled": true,
      "MetricName": "AWSCommonRules"
    }
  },
  {
    "Name": "AWSManagedRulesSQLiRuleSet",
    "Priority": 2,
    "Statement": {
      "ManagedRuleGroupStatement": {
        "VendorName": "AWS",
        "Name": "AWSManagedRulesSQLiRuleSet"
      }
    },
    "OverrideAction": { "None": {} },
    "VisibilityConfig": {
      "SampledRequestsEnabled": true,
      "CloudWatchMetricsEnabled": true,
      "MetricName": "AWSSQLiRules"
    }
  },
  {
    "Name": "AWSManagedRulesKnownBadInputsRuleSet",
    "Priority": 3,
    "Statement": {
      "ManagedRuleGroupStatement": {
        "VendorName": "AWS",
        "Name": "AWSManagedRulesKnownBadInputsRuleSet"
      }
    },
    "OverrideAction": { "None": {} },
    "VisibilityConfig": {
      "SampledRequestsEnabled": true,
      "CloudWatchMetricsEnabled": true,
      "MetricName": "AWSBadInputRules"
    }
  },
  {
    "Name": "RateLimitRule",
    "Priority": 4,
    "Statement": {
      "RateBasedStatement": {
        "Limit": 2000,
        "AggregateKeyType": "IP"
      }
    },
    "Action": { "Block": {} },
    "VisibilityConfig": {
      "SampledRequestsEnabled": true,
      "CloudWatchMetricsEnabled": true,
      "MetricName": "RateLimit"
    }
  },
  {
    "Name": "GeoBlockRule",
    "Priority": 5,
    "Statement": {
      "GeoMatchStatement": {
        "CountryCodes": ["KP", "IR", "SY"]
      }
    },
    "Action": { "Block": {} },
    "VisibilityConfig": {
      "SampledRequestsEnabled": true,
      "CloudWatchMetricsEnabled": true,
      "MetricName": "GeoBlock"
    }
  },
  {
    "Name": "BlockBadUserAgents",
    "Priority": 6,
    "Statement": {
      "ByteMatchStatement": {
        "SearchString": "sqlmap",
        "FieldToMatch": { "SingleHeader": { "Name": "user-agent" } },
        "TextTransformations": [{ "Priority": 0, "Type": "LOWERCASE" }],
        "PositionalConstraint": "CONTAINS"
      }
    },
    "Action": { "Block": {} },
    "VisibilityConfig": {
      "SampledRequestsEnabled": true,
      "CloudWatchMetricsEnabled": true,
      "MetricName": "BadUserAgent"
    }
  }
]
```

### Associate WAF with ALB

```bash
# Associate with Application Load Balancer
aws wafv2 associate-web-acl \
  --web-acl-arn arn:aws:wafv2:us-east-1:123456789:regional/webacl/production-waf/abc123 \
  --resource-arn arn:aws:elasticloadbalancing:us-east-1:123456789:loadbalancer/app/my-alb/abc123

# Associate with API Gateway
aws wafv2 associate-web-acl \
  --web-acl-arn arn:aws:wafv2:us-east-1:123456789:regional/webacl/production-waf/abc123 \
  --resource-arn arn:aws:apigateway:us-east-1::/restapis/abc123/stages/prod
```

### AWS WAF Terraform

```hcl
resource "aws_wafv2_web_acl" "main" {
  name        = "production-waf"
  scope       = "REGIONAL"
  description = "Production WAF with OWASP protections"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action { none {} }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          name = "SizeRestrictions_BODY"
          action_to_use { count {} }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSCommonRules"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "RateLimit"
    priority = 10

    action { block {} }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimit"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "production-waf"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = aws_lb.main.arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}
```

## Cloudflare WAF

### API Configuration

```bash
# List available WAF rulesets
curl -s "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/rulesets" \
  -H "Authorization: Bearer ${CF_TOKEN}" | jq '.result[] | {id, name, phase}'

# Create a custom WAF rule
curl -X POST "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/rulesets" \
  -H "Authorization: Bearer ${CF_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Custom WAF Rules",
    "kind": "zone",
    "phase": "http_request_firewall_custom",
    "rules": [
      {
        "action": "block",
        "expression": "(http.request.uri.query contains \"union select\" or http.request.uri.query contains \"1=1\")",
        "description": "Block SQL injection patterns in query string"
      },
      {
        "action": "block",
        "expression": "(http.request.uri.path contains \"..%2f\" or http.request.uri.path contains \"..%5c\")",
        "description": "Block path traversal attempts"
      },
      {
        "action": "challenge",
        "expression": "(cf.threat_score gt 30)",
        "description": "Challenge high threat score visitors"
      },
      {
        "action": "block",
        "expression": "(http.request.headers[\"user-agent\"] contains \"sqlmap\" or http.request.headers[\"user-agent\"] contains \"nikto\")",
        "description": "Block known attack tools"
      }
    ]
  }'

# Configure rate limiting
curl -X POST "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/rulesets" \
  -H "Authorization: Bearer ${CF_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Rate Limiting",
    "kind": "zone",
    "phase": "http_ratelimit",
    "rules": [
      {
        "action": "block",
        "ratelimit": {
          "characteristics": ["ip.src"],
          "period": 60,
          "requests_per_period": 100,
          "mitigation_timeout": 600
        },
        "expression": "(http.request.uri.path matches \"^/api/\")",
        "description": "Rate limit API endpoints"
      }
    ]
  }'
```

### Cloudflare Terraform

```hcl
resource "cloudflare_ruleset" "waf_custom" {
  zone_id = var.zone_id
  name    = "Custom WAF Rules"
  kind    = "zone"
  phase   = "http_request_firewall_custom"

  rules {
    action      = "block"
    expression  = "(http.request.uri.query contains \"union select\")"
    description = "Block SQL injection in query string"
  }

  rules {
    action      = "managed_challenge"
    expression  = "(cf.threat_score gt 30)"
    description = "Challenge suspicious visitors"
  }
}
```

## ModSecurity with Nginx

### Installation

```bash
# Install ModSecurity for Nginx (Ubuntu)
apt install -y libmodsecurity3 libmodsecurity-dev nginx libnginx-mod-http-modsecurity

# Or compile from source
git clone https://github.com/SpiderLabs/ModSecurity /opt/modsecurity
cd /opt/modsecurity
git submodule init && git submodule update
./build.sh && ./configure && make && make install
```

### Nginx Configuration

```nginx
# /etc/nginx/nginx.conf
load_module modules/ngx_http_modsecurity_module.so;

http {
    modsecurity on;
    modsecurity_rules_file /etc/nginx/modsec/main.conf;

    server {
        listen 443 ssl http2;
        server_name example.com;

        # ModSecurity can also be enabled per-location
        location /api/ {
            modsecurity on;
            modsecurity_rules_file /etc/nginx/modsec/api-rules.conf;
            proxy_pass http://backend;
        }
    }
}
```

### ModSecurity Main Configuration

```bash
# /etc/nginx/modsec/main.conf
Include /etc/nginx/modsec/modsecurity.conf

# Set to DetectionOnly first, switch to On after tuning
SecRuleEngine On

# Request body handling
SecRequestBodyAccess On
SecRequestBodyLimit 13107200
SecRequestBodyNoFilesLimit 131072

# Response body handling
SecResponseBodyAccess On
SecResponseBodyMimeType text/plain text/html text/xml application/json

# Logging
SecAuditEngine RelevantOnly
SecAuditLogRelevantStatus "^(?:5|4(?!04))"
SecAuditLogParts ABIJDEFHZ
SecAuditLogType Serial
SecAuditLog /var/log/modsec/modsec_audit.log

# Include OWASP Core Rule Set
Include /etc/nginx/modsec/crs/crs-setup.conf
Include /etc/nginx/modsec/crs/rules/*.conf
```

### OWASP Core Rule Set Setup

```bash
# Download and install OWASP CRS
cd /etc/nginx/modsec
git clone https://github.com/coreruleset/coreruleset crs
cp crs/crs-setup.conf.example crs/crs-setup.conf

# Customize CRS settings
cat >> crs/crs-setup.conf << 'EOF'

# Set paranoia level (1-4, higher = more strict)
SecAction "id:900000, phase:1, pass, t:none, nolog, setvar:tx.paranoia_level=2"

# Set anomaly score thresholds
SecAction "id:900110, phase:1, pass, t:none, nolog, \
  setvar:tx.inbound_anomaly_score_threshold=5, \
  setvar:tx.outbound_anomaly_score_threshold=4"

# Exclude known false positives
SecRule REQUEST_URI "@beginsWith /api/upload" \
  "id:1001,phase:1,pass,nolog,ctl:ruleRemoveById=920420"
EOF

# Create rule exclusions file
cat > /etc/nginx/modsec/crs/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf << 'EOF'
# Exclude rules that cause false positives on specific paths
SecRule REQUEST_URI "@beginsWith /api/webhook" \
  "id:1000001,phase:1,pass,nolog,ctl:ruleRemoveTargetById=942100;ARGS:payload"

# Exclude rules for specific parameters
SecRule ARGS_NAMES "^content$" \
  "id:1000002,phase:1,pass,nolog,ctl:ruleRemoveTargetById=941100;ARGS:content"
EOF
```

### Custom ModSecurity Rules

```bash
# /etc/nginx/modsec/custom-rules.conf

# Block requests with known attack tool user agents
SecRule REQUEST_HEADERS:User-Agent "@pm sqlmap nikto nmap masscan dirbuster" \
  "id:10001,phase:1,deny,status:403,log,msg:'Blocked attack tool'"

# Block requests to sensitive paths
SecRule REQUEST_URI "@rx /(\.git|\.env|\.svn|wp-admin|phpmyadmin|adminer)" \
  "id:10002,phase:1,deny,status:404,log,msg:'Blocked sensitive path access'"

# Rate limit by IP (10 requests/second)
SecRule IP:REQUEST_RATE "@gt 10" \
  "id:10003,phase:1,deny,status:429,log,msg:'Rate limit exceeded',\
  setvar:IP.request_rate=+1,expirevar:IP.request_rate=1"

# Block oversized cookies (potential overflow attack)
SecRule REQUEST_HEADERS:Cookie "@gt 4096" \
  "id:10004,phase:1,deny,status:400,log,msg:'Oversized cookie header'"

# Virtual patch: block specific CVE exploit pattern
SecRule ARGS:filename "@contains ../../" \
  "id:10005,phase:2,deny,status:403,log,msg:'Path traversal blocked (virtual patch CVE-XXXX-XXXX)'"

# Require Content-Type on POST requests
SecRule REQUEST_METHOD "@streq POST" \
  "id:10006,phase:1,chain,deny,status:400,log,msg:'POST without Content-Type'"
SecRule &REQUEST_HEADERS:Content-Type "@eq 0" ""
```

## WAF Tuning Workflow

```bash
#!/bin/bash
# waf-tune.sh - Analyze WAF logs for false positives

AUDIT_LOG="/var/log/modsec/modsec_audit.log"
TIMEFRAME="24h"

echo "=== WAF Tuning Report ==="
echo "Analyzing last ${TIMEFRAME} of audit logs"
echo ""

# Top blocked rules
echo "--- Top 10 triggered rules ---"
grep -oP 'id "\K[0-9]+' "$AUDIT_LOG" | sort | uniq -c | sort -rn | head -10

echo ""
echo "--- Top blocked URIs ---"
grep -oP 'REQUEST_URI: \K[^\s]+' "$AUDIT_LOG" | sort | uniq -c | sort -rn | head -10

echo ""
echo "--- Top blocked IPs ---"
grep -oP 'client \K[0-9.]+' "$AUDIT_LOG" | sort | uniq -c | sort -rn | head -10

echo ""
echo "--- False positive candidates (high-frequency blocks on common paths) ---"
grep -oP 'id "\K[0-9]+' "$AUDIT_LOG" | sort | uniq -c | sort -rn | \
  while read count rule_id; do
    if [ "$count" -gt 100 ]; then
      echo "  Rule $rule_id triggered $count times - review for false positive"
    fi
  done
```

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| Legitimate requests blocked | False positives from CRS rules | Set `SecRuleEngine DetectionOnly` first; review audit log; add exclusions |
| WAF not blocking attacks | Rules in detection-only mode | Switch `SecRuleEngine On` after tuning period |
| High latency with WAF enabled | Response body inspection overhead | Disable `SecResponseBodyAccess` if not needed; reduce `paranoia_level` |
| AWS WAF rules not matching | Rule priority order wrong | Lower priority number = evaluated first; reorder rules |
| ModSecurity crashes nginx | Memory exhaustion on large requests | Increase `SecRequestBodyLimit`; adjust `SecPcreMatchLimit` |
| Cloudflare WAF blocks API calls | Expression too broad | Narrow expression with path or method conditions |
| CRS update breaks application | New rules trigger on existing traffic | Pin CRS version; test updates in staging first |

## Best Practices

- Start in detection/log mode, switch to blocking after tuning
- Tune rules for at least 1-2 weeks before enforcement
- Monitor blocked requests daily during tuning phase
- Update managed rule sets and CRS regularly
- Create custom rules for application-specific attack patterns
- Use virtual patching to protect against known CVEs while code is being fixed
- Set appropriate rate limits per endpoint
- Maintain exclusion rules documentation with justifications
- Test WAF rules with known attack payloads before deploying
- Keep audit logs for at least 90 days for forensic analysis

## Related Skills

- [dast-scanning](../../scanning/dast-scanning/) - Web security testing
- [ssl-tls-management](../ssl-tls-management/) - HTTPS configuration
- [firewall-config](../firewall-config/) - Network-level firewalling
