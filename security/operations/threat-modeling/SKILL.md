---
name: threat-modeling
description: Conduct threat modeling using STRIDE methodology. Identify threats, assess risks, and design security controls. Use when designing secure systems or assessing application security.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Threat Modeling

Identify and mitigate security threats during system design.

## STRIDE Methodology

| Threat | Description | Mitigation |
|--------|-------------|------------|
| **S**poofing | Pretending to be someone else | Authentication |
| **T**ampering | Modifying data | Integrity controls |
| **R**epudiation | Denying actions | Audit logging |
| **I**nformation Disclosure | Data exposure | Encryption |
| **D**enial of Service | Making service unavailable | Rate limiting |
| **E**levation of Privilege | Gaining higher access | Authorization |

## Process

```yaml
steps:
  1_scope:
    - Define system boundaries
    - Identify assets
    - Document data flows
    
  2_diagram:
    - Create data flow diagrams
    - Identify trust boundaries
    - Mark entry points
    
  3_identify:
    - Apply STRIDE to each component
    - List potential threats
    - Document attack vectors
    
  4_assess:
    - Rate likelihood and impact
    - Prioritize by risk score
    
  5_mitigate:
    - Design countermeasures
    - Accept/transfer risks
    - Document decisions
```

## Data Flow Diagram

```
[External User] --> |HTTPS| --> [Load Balancer]
                                      |
                                      v
                               [Web Server]
                                      |
                              [Trust Boundary]
                                      |
                                      v
                                [App Server] --> [Database]
```

## Threat Cards

```yaml
threat:
  id: T001
  name: SQL Injection
  category: Tampering
  component: Database queries
  likelihood: High
  impact: Critical
  mitigations:
    - Parameterized queries
    - Input validation
    - WAF rules
  status: Mitigated
```

## Best Practices

- Integrate into SDLC
- Review on architecture changes
- Include development team
- Document all decisions
- Regular reassessment

## Related Skills

- [sast-scanning](../../scanning/sast-scanning/) - Code analysis
- [penetration-testing](../penetration-testing/) - Validation
