---
name: access-review
description: Conduct periodic access reviews and certifications. Implement access governance and recertification workflows. Use when managing access compliance.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Access Review

Implement periodic access review processes.

## Review Process

```yaml
access_review_workflow:
  1_extract:
    - Pull access data from systems
    - Generate access report
    
  2_review:
    - Manager certification
    - Risk-based prioritization
    - Decision documentation
    
  3_action:
    - Revoke unnecessary access
    - Update exceptions
    - Document decisions
    
  4_report:
    - Compliance metrics
    - Remediation tracking
```

## AWS IAM Review

```bash
# Generate credential report
aws iam generate-credential-report
aws iam get-credential-report --output text --query Content | base64 -d

# Find inactive users
aws iam list-users | jq -r '.Users[] | select(.PasswordLastUsed < "2024-01-01") | .UserName'

# List unused access keys
aws iam get-access-key-last-used --access-key-id AKIAXXXXXXXX
```

## Automation

```python
def generate_access_report():
    users = get_all_users()
    report = []
    
    for user in users:
        report.append({
            'user': user.email,
            'roles': user.roles,
            'last_login': user.last_login,
            'manager': user.manager,
            'review_status': 'pending'
        })
    
    return report
```

## Best Practices

- Quarterly reviews minimum
- Risk-based frequency
- Manager attestation
- Automated revocation
- Audit trail maintenance
