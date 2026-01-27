# WAF Rules Reference

## AWS WAF

### Managed Rules
```hcl
resource "aws_wafv2_web_acl" "main" {
  name  = "myapp-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  # AWS Managed Rules - Core
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action { none {} }
    
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name               = "CommonRuleSet"
      sampled_requests_enabled  = true
    }
  }

  # SQL Injection
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 2
    override_action { none {} }
    
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesSQLiRuleSet"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name               = "SQLiRuleSet"
      sampled_requests_enabled  = true
    }
  }
}
```

### Custom Rules
```hcl
# Rate limiting
rule {
  name     = "RateLimit"
  priority = 0
  action { block {} }

  statement {
    rate_based_statement {
      limit              = 2000
      aggregate_key_type = "IP"
    }
  }
}

# Geo blocking
rule {
  name     = "GeoBlock"
  priority = 3
  action { block {} }

  statement {
    geo_match_statement {
      country_codes = ["CN", "RU"]
    }
  }
}
```

## Cloudflare WAF

```hcl
resource "cloudflare_ruleset" "waf" {
  zone_id = var.zone_id
  name    = "WAF Rules"
  kind    = "zone"
  phase   = "http_request_firewall_managed"

  rules {
    action = "execute"
    action_parameters {
      id = "efb7b8c949ac4650a09736fc376e9aee"  # OWASP Core Ruleset
    }
    expression = "true"
  }
}
```

## Common Attack Patterns

| Pattern | Description | Rule |
|---------|-------------|------|
| SQLi | SQL Injection | Block `' OR 1=1`, UNION |
| XSS | Cross-Site Scripting | Block `<script>`, event handlers |
| LFI | Local File Inclusion | Block `../`, `/etc/passwd` |
| RCE | Remote Code Execution | Block shell commands |

## Best Practices

1. Start in monitoring mode
2. Tune rules for false positives
3. Use rate limiting
4. Block known bad IPs
5. Log all blocked requests
6. Regular rule review
