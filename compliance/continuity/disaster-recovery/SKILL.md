---
name: disaster-recovery
description: Implement disaster recovery strategies and runbooks. Configure RPO/RTO targets and failover procedures. Use when planning for business continuity.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Disaster Recovery

Implement disaster recovery strategies and procedures.

## DR Metrics

```yaml
recovery_metrics:
  RTO: Recovery Time Objective
    - Maximum acceptable downtime
    - How long to restore service
    
  RPO: Recovery Point Objective
    - Maximum acceptable data loss
    - How much data can be lost
```

## DR Strategies

| Strategy | RTO | RPO | Cost |
|----------|-----|-----|------|
| Backup & Restore | Hours | Hours | $ |
| Pilot Light | Minutes-Hours | Minutes | $$ |
| Warm Standby | Minutes | Seconds | $$$ |
| Multi-Site Active | Near-zero | Near-zero | $$$$ |

## AWS Multi-Region

```bash
# Cross-region RDS replica
aws rds create-db-instance-read-replica \
  --db-instance-identifier dr-replica \
  --source-db-instance-identifier prod-db \
  --source-region us-east-1 \
  --region us-west-2

# S3 cross-region replication
aws s3api put-bucket-replication \
  --bucket source-bucket \
  --replication-configuration file://replication.json
```

## DR Testing

```yaml
dr_test_schedule:
  tabletop: Quarterly
  component_failover: Monthly
  full_failover: Annually
  
test_checklist:
  - [ ] Verify backup integrity
  - [ ] Test failover procedures
  - [ ] Validate data consistency
  - [ ] Measure actual RTO/RPO
  - [ ] Document lessons learned
```

## Best Practices

- Regular DR testing
- Automate failover where possible
- Document all procedures
- Update runbooks after tests
