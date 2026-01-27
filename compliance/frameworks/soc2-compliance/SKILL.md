---
name: soc2-compliance
description: Implement SOC 2 Trust Services Criteria. Configure security, availability, and processing integrity controls. Use when achieving SOC 2 certification.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# SOC 2 Compliance

Implement SOC 2 Trust Services Criteria for certification.

## Trust Services Criteria

```yaml
criteria:
  security:
    - Access controls
    - Change management
    - Risk assessment
    - Incident response
    
  availability:
    - System monitoring
    - Disaster recovery
    - Capacity planning
    - SLA management
    
  processing_integrity:
    - Input validation
    - Processing completeness
    - Output accuracy
    
  confidentiality:
    - Data classification
    - Encryption
    - Access restrictions
    
  privacy:
    - Data collection notice
    - Consent management
    - Data retention
```

## Key Controls

```yaml
controls:
  CC6.1_logical_access:
    - MFA enforcement
    - Role-based access
    - Access reviews
    
  CC7.2_monitoring:
    - Log aggregation
    - Alert thresholds
    - Incident tracking
    
  CC8.1_change_management:
    - Change requests
    - Approval workflows
    - Testing requirements
```

## Evidence Collection

```bash
# Access review export
aws iam generate-credential-report
aws iam get-credential-report

# Audit logs
aws cloudtrail lookup-events --start-time $(date -d '30 days ago' --iso)
```

## Best Practices

- Continuous compliance monitoring
- Annual risk assessments
- Regular control testing
- Documentation maintenance
