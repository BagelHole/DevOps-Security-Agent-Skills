---
name: incident-management
description: Implement incident management processes and escalation procedures. Configure on-call schedules and post-incident reviews. Use when managing production incidents.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Incident Management

Implement effective incident management processes.

## Incident Severity

| Severity | Impact | Response | Example |
|----------|--------|----------|---------|
| SEV1 | Total outage | Immediate, all-hands | Site down |
| SEV2 | Major degradation | Urgent, on-call | Feature broken |
| SEV3 | Minor impact | Standard | Slow performance |
| SEV4 | Minimal | Next business day | Cosmetic issue |

## Incident Process

```yaml
incident_workflow:
  1_detect:
    - Alerting triggers
    - Customer reports
    - Monitoring anomalies
    
  2_triage:
    - Severity assessment
    - Impact determination
    - Team notification
    
  3_respond:
    - Incident commander assigned
    - Communication established
    - Mitigation started
    
  4_resolve:
    - Root cause addressed
    - Service restored
    - Customer notified
    
  5_review:
    - Timeline documented
    - Root cause analysis
    - Action items created
```

## Incident Commander

```yaml
ic_responsibilities:
  - Own incident resolution
  - Coordinate response teams
  - Manage communication
  - Make escalation decisions
  - Schedule post-mortem
```

## Post-Incident Review

```markdown
## Incident Summary
- Duration:
- Impact:
- Severity:

## Timeline

## Root Cause

## What Went Well

## What Could Be Improved

## Action Items
| Item | Owner | Due Date |
```

## Best Practices

- Clear severity definitions
- Defined escalation paths
- Blameless post-mortems
- Action item tracking
- Regular training
