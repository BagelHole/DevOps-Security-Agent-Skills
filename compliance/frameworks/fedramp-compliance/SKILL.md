---
name: fedramp-compliance
description: Implement FedRAMP requirements for federal cloud services. Configure NIST 800-53 controls and continuous monitoring. Use when providing cloud services to US federal agencies.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# FedRAMP Compliance

Implement FedRAMP requirements for federal cloud services.

## Impact Levels

```yaml
levels:
  low:
    controls: ~125
    use_case: Public data
    
  moderate:
    controls: ~325
    use_case: CUI, most federal systems
    
  high:
    controls: ~425
    use_case: Law enforcement, emergency services
```

## NIST 800-53 Families

```yaml
control_families:
  AC: Access Control
  AU: Audit and Accountability
  AT: Awareness and Training
  CM: Configuration Management
  CP: Contingency Planning
  IA: Identification and Authentication
  IR: Incident Response
  MA: Maintenance
  MP: Media Protection
  PE: Physical Protection
  PL: Planning
  PS: Personnel Security
  RA: Risk Assessment
  CA: Assessment and Authorization
  SC: System and Communications Protection
  SI: System and Information Integrity
  SA: System and Services Acquisition
  PM: Program Management
```

## Continuous Monitoring

```yaml
conmon:
  vulnerability_scans: Monthly
  penetration_tests: Annual
  poa_m_updates: Monthly
  security_assessment: Annual
```

## Best Practices

- 3PAO assessment
- SSP documentation
- POA&M tracking
- Continuous monitoring
- Annual authorization
