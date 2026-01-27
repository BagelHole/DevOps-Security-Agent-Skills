---
name: gdpr-compliance
description: Implement GDPR data protection requirements. Configure consent management, data subject rights, and privacy by design. Use when processing EU personal data.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# GDPR Compliance

Implement GDPR requirements for EU data protection.

## Key Principles

```yaml
principles:
  lawfulness: Legal basis for processing
  purpose_limitation: Specific, explicit purposes
  data_minimization: Adequate, relevant, limited
  accuracy: Accurate and up to date
  storage_limitation: No longer than necessary
  integrity: Secure processing
  accountability: Demonstrate compliance
```

## Data Subject Rights

```yaml
rights:
  - Right to access
  - Right to rectification
  - Right to erasure
  - Right to restrict processing
  - Right to data portability
  - Right to object
  - Rights related to automated decisions
```

## Technical Implementation

```python
# Data export for portability
def export_user_data(user_id):
    return {
        "profile": get_profile(user_id),
        "activity": get_activity_log(user_id),
        "preferences": get_preferences(user_id)
    }

# Right to erasure
def delete_user_data(user_id):
    anonymize_profile(user_id)
    delete_activity_log(user_id)
    log_deletion(user_id)
```

## Best Practices

- Privacy impact assessments
- Data processing agreements
- Consent management
- Breach notification (72 hours)
- Data Protection Officer (if required)
