---
name: penetration-testing
description: Perform basic penetration testing and security assessments. Use reconnaissance, vulnerability discovery, and exploitation techniques. Use when validating security controls or assessing system security.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Penetration Testing

Validate security controls through authorized testing.

## Phases

```yaml
pentest_phases:
  1_reconnaissance:
    - Passive information gathering
    - DNS enumeration
    - Network mapping
    
  2_scanning:
    - Port scanning
    - Service identification
    - Vulnerability scanning
    
  3_exploitation:
    - Attempt exploitation
    - Verify vulnerabilities
    - Document findings
    
  4_post_exploitation:
    - Privilege escalation
    - Lateral movement
    - Data access
    
  5_reporting:
    - Document findings
    - Risk assessment
    - Remediation recommendations
```

## Reconnaissance

```bash
# DNS enumeration
dig example.com ANY
host -l example.com

# Subdomain discovery
subfinder -d example.com

# WHOIS
whois example.com
```

## Scanning

```bash
# Port scan
nmap -sV -sC -p- target.com

# Web scanning
nikto -h https://target.com
dirb https://target.com

# Vulnerability scan
nmap --script vuln target.com
```

## Web Testing

```bash
# SQL injection test
sqlmap -u "http://target.com/page?id=1"

# XSS testing
# Use Burp Suite or manual testing

# Directory traversal
curl "http://target.com/file?path=../../../etc/passwd"
```

## Rules of Engagement

```yaml
scope:
  in_scope:
    - target.com
    - api.target.com
  out_of_scope:
    - production-db.target.com
    - third-party services
  
  testing_window: "Weekdays 2-6 AM UTC"
  emergency_contact: "security@target.com"
```

## Best Practices

- Always get written authorization
- Define clear scope
- Document everything
- Report critical findings immediately
- Safe exploitation techniques only

## Related Skills

- [dast-scanning](../../scanning/dast-scanning/) - Automated testing
- [vulnerability-scanning](../../scanning/vulnerability-scanning/) - Vulnerability discovery
