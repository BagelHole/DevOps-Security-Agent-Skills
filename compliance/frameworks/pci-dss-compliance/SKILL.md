---
name: pci-dss-compliance
description: Implement PCI DSS requirements for payment card data. Configure cardholder data environment and security controls. Use when processing payment cards.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# PCI DSS Compliance

Implement PCI DSS requirements for payment card security.

## Requirements

```yaml
requirements:
  1_firewall:
    - Network segmentation
    - Firewall configuration
    - CDE isolation
    
  3_protect_data:
    - Mask PAN display
    - Encrypt stored data
    - Key management
    
  6_secure_systems:
    - Patch management
    - Secure development
    - Change control
    
  8_access_control:
    - Unique IDs
    - MFA for remote access
    - Password policies
    
  10_logging:
    - Audit trail
    - Time synchronization
    - Log retention (1 year)
    
  11_testing:
    - Vulnerability scans
    - Penetration testing
    - IDS/IPS monitoring
```

## Network Segmentation

```
Internet --> DMZ --> Firewall --> CDE
                                  |
            Non-CDE <-- Firewall --
```

## Data Protection

```yaml
encryption:
  at_rest: AES-256
  in_transit: TLS 1.2+
  key_storage: HSM or dedicated key vault
  
tokenization:
  - Replace PAN with token
  - Store mapping securely
  - Reduce CDE scope
```

## Best Practices

- Minimize CDE scope
- Use tokenization
- Quarterly vulnerability scans
- Annual penetration tests
- ASV scan certification
