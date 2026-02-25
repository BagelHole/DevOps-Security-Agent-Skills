---
name: aws-cost-optimization
description: Reduce AWS spend with rightsizing, autoscaling, commitment planning, and storage lifecycle policies. Use when running FinOps reviews, lowering cloud bills, or improving cost-per-request metrics.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# AWS Cost Optimization

Apply practical FinOps controls without sacrificing reliability.

## When to Use This Skill

Use this skill when:
- Monthly AWS cost spikes unexpectedly
- Preparing cost reviews with engineering and finance
- Rightsizing EC2, RDS, and EKS workloads
- Choosing Savings Plans or Reserved Instances

## Cost Review Workflow

1. Tag resources by team, service, and environment.
2. Use Cost Explorer and CUR to identify top spend drivers.
3. Rightsize underutilized compute and storage.
4. Apply commitment discounts for stable baseline usage.
5. Set budgets, anomaly alerts, and KPI reporting.

## High-Impact Actions

- Move bursty non-prod compute to Spot where safe.
- Configure S3 lifecycle rules for infrequent access and archive tiers.
- Reduce NAT Gateway and inter-AZ data transfer surprises.
- Schedule dev/test shutdown windows outside business hours.
- Tune log retention (CloudWatch, OpenSearch) to policy requirements.

## Useful Commands

```bash
# Cost Explorer rightsizing recommendations (example)
aws ce get-rightsizing-recommendation \
  --service "AmazonEC2" \
  --configuration file://rightsizing-config.json

# List unattached EBS volumes
aws ec2 describe-volumes --filters Name=status,Values=available

# Retrieve budget alerts
aws budgets describe-budgets --account-id 123456789012
```

## Related Skills

- [aws-ec2](../aws-ec2/) - EC2 operations and sizing
- [aws-s3](../aws-s3/) - S3 storage and lifecycle controls
- [terraform-aws](../terraform-aws/) - Codifying cost guardrails
