---
name: runbook-creation
description: Create operational runbooks and standard operating procedures. Document troubleshooting guides and recovery procedures. Use when documenting operational knowledge.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Runbook Creation

Create effective operational runbooks and procedures.

## Runbook Structure

```markdown
# Runbook: [Service/Process Name]

## Overview
Brief description of the service and runbook purpose.

## Prerequisites
- Required access
- Tools needed
- Knowledge required

## Procedure
Step-by-step instructions with commands.

## Verification
How to confirm success.

## Rollback
Steps to undo if needed.

## Escalation
When and how to escalate.

## Related Runbooks
Links to related procedures.
```

## Example Runbook

```markdown
# Runbook: Database Failover

## Overview
Procedure to failover PostgreSQL to replica.

## Prerequisites
- [ ] DBA access to primary and replica
- [ ] VPN connected
- [ ] Slack channel #db-ops open

## Procedure

### 1. Verify Replica Status
\`\`\`bash
psql -h replica -c "SELECT pg_is_in_recovery();"
# Should return 't'
\`\`\`

### 2. Stop Application Writes
\`\`\`bash
kubectl scale deployment app --replicas=0
\`\`\`

### 3. Promote Replica
\`\`\`bash
psql -h replica -c "SELECT pg_promote();"
\`\`\`

### 4. Update DNS
\`\`\`bash
aws route53 change-resource-record-sets ...
\`\`\`

## Verification
- [ ] Application connects to new primary
- [ ] No replication lag errors
- [ ] Transactions completing

## Escalation
If issues persist after 15 minutes, escalate to:
- Primary: @dba-lead
- Secondary: @platform-oncall
```

## Best Practices

- Keep procedures simple and clear
- Include verification steps
- Test runbooks regularly
- Version control runbooks
- Include troubleshooting tips
