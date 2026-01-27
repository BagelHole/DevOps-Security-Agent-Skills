---
name: vendor-management
description: Implement vendor risk management programs. Assess third-party security and maintain vendor inventory. Use when managing supplier security.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Vendor Management

Manage third-party vendor security risks.

## Vendor Assessment

```yaml
assessment_process:
  1_identify:
    - Catalog all vendors
    - Classify by risk tier
    
  2_assess:
    - Security questionnaire
    - SOC 2 review
    - Penetration test results
    
  3_contract:
    - Security requirements
    - Data processing agreement
    - SLAs
    
  4_monitor:
    - Continuous monitoring
    - Annual reassessment
    - Incident notification
```

## Risk Tiers

| Tier | Criteria | Assessment |
|------|----------|------------|
| Critical | Access to sensitive data | Full assessment, annual |
| High | Significant data access | Questionnaire + SOC 2 |
| Medium | Limited data access | Security questionnaire |
| Low | No data access | Basic due diligence |

## Security Questionnaire

```yaml
categories:
  governance:
    - Security policies
    - Risk management
    - Compliance certifications
    
  technical:
    - Access controls
    - Encryption
    - Vulnerability management
    
  operational:
    - Incident response
    - Business continuity
    - Change management
```

## Best Practices

- Tier-based assessments
- Regular reassessment
- Contract security terms
- Incident notification requirements
- Exit strategy planning
