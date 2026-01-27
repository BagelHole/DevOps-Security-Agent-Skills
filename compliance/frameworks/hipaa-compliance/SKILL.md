---
name: hipaa-compliance
description: Implement HIPAA security and privacy rules. Configure PHI protections and BAA requirements. Use when handling healthcare data.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# HIPAA Compliance

Implement HIPAA requirements for healthcare data protection.

## HIPAA Rules

```yaml
security_rule:
  administrative:
    - Risk analysis
    - Security management
    - Workforce training
    - Contingency planning
    
  physical:
    - Facility access
    - Workstation security
    - Device controls
    
  technical:
    - Access control
    - Audit controls
    - Integrity controls
    - Transmission security
```

## Technical Safeguards

```yaml
requirements:
  encryption:
    at_rest: AES-256
    in_transit: TLS 1.2+
    
  access_control:
    - Unique user IDs
    - Emergency access procedure
    - Automatic logoff
    - Encryption/decryption
    
  audit:
    - Access logging
    - Activity monitoring
    - Log retention (6 years)
```

## AWS HIPAA Setup

```bash
# Enable CloudTrail for HIPAA auditing
aws cloudtrail create-trail \
  --name hipaa-audit-trail \
  --s3-bucket-name hipaa-logs \
  --is-multi-region-trail \
  --enable-log-file-validation

# Use HIPAA-eligible services only
```

## Best Practices

- Business Associate Agreements (BAAs)
- Minimum necessary access
- Breach notification procedures
- Regular risk assessments
