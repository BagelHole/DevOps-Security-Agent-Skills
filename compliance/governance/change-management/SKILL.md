---
name: change-management
description: Implement change management processes. Configure CAB reviews, change windows, and rollback procedures. Use when managing production changes.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Change Management

Implement structured change management processes.

## Change Process

```yaml
change_workflow:
  1_request:
    - Change description
    - Risk assessment
    - Rollback plan
    - Testing evidence
    
  2_review:
    - Technical review
    - Security review
    - CAB approval (if high risk)
    
  3_schedule:
    - Change window
    - Communication
    - Resource allocation
    
  4_implement:
    - Execute change
    - Verify success
    - Update documentation
    
  5_review:
    - Post-implementation review
    - Lessons learned
```

## Change Classification

| Type | Risk | Approval | Example |
|------|------|----------|---------|
| Standard | Low | Pre-approved | Patching |
| Normal | Medium | Manager | Config change |
| Emergency | Variable | Expedited | Security fix |

## Pull Request Template

```markdown
## Change Description

## Risk Level
- [ ] Low - Standard change
- [ ] Medium - Normal change
- [ ] High - CAB required

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Staging deployment verified

## Rollback Plan

## Stakeholders Notified
- [ ] Operations
- [ ] Security
- [ ] Business owners
```

## Best Practices

- Clear change categories
- Required approvals by risk
- Rollback procedures documented
- Post-change verification
- Change freeze windows
