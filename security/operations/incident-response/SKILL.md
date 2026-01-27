---
name: incident-response
description: Handle security incidents with IR playbooks and procedures. Implement detection, containment, eradication, and recovery processes. Use when responding to security events or building incident response capabilities.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Incident Response

Handle security incidents effectively with structured response procedures.

## Incident Response Phases

```yaml
phases:
  1_preparation:
    - IR team and contacts
    - Tools and access ready
    - Playbooks documented
    
  2_detection:
    - Alert triage
    - Initial assessment
    - Severity classification
    
  3_containment:
    - Short-term containment
    - Evidence preservation
    - System isolation
    
  4_eradication:
    - Root cause analysis
    - Remove threat
    - Patch vulnerabilities
    
  5_recovery:
    - System restoration
    - Monitoring enhanced
    - Business continuity
    
  6_lessons_learned:
    - Post-incident review
    - Documentation update
    - Process improvement
```

## Severity Classification

| Level | Impact | Response Time |
|-------|--------|---------------|
| Critical | Data breach, full outage | Immediate |
| High | Service degraded, potential breach | < 1 hour |
| Medium | Limited impact, contained | < 4 hours |
| Low | Minimal impact | Next business day |

## Initial Response Checklist

```markdown
- [ ] Confirm incident is real (not false positive)
- [ ] Classify severity level
- [ ] Notify IR team
- [ ] Begin documentation
- [ ] Preserve evidence
- [ ] Implement containment
- [ ] Communicate to stakeholders
```

## Evidence Collection

```bash
# System state
ps aux > /evidence/processes.txt
netstat -tuln > /evidence/connections.txt
last -a > /evidence/logins.txt

# Memory dump
dd if=/dev/mem of=/evidence/memory.dump

# Log preservation
tar czf /evidence/logs.tar.gz /var/log/
```

## Best Practices

- Pre-defined playbooks
- Regular IR drills
- Clear communication channels
- Legal team involvement
- Post-incident reviews

## Related Skills

- [audit-logging](../../../compliance/auditing/audit-logging/) - Log analysis
- [alerting-oncall](../../../devops/observability/alerting-oncall/) - Alert management
