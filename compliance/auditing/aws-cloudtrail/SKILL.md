---
name: aws-cloudtrail
description: Configure AWS CloudTrail for audit logging. Set up organization trails and event analysis. Use when auditing AWS activity.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# AWS CloudTrail

Audit AWS account activity with CloudTrail.

## Create Trail

```bash
# Create organization trail
aws cloudtrail create-trail \
  --name org-audit-trail \
  --s3-bucket-name audit-logs-bucket \
  --is-organization-trail \
  --is-multi-region-trail \
  --enable-log-file-validation \
  --kms-key-id arn:aws:kms:...

# Start logging
aws cloudtrail start-logging --name org-audit-trail
```

## Event Selectors

```bash
# Log all management and data events
aws cloudtrail put-event-selectors \
  --trail-name org-audit-trail \
  --event-selectors '[{
    "ReadWriteType": "All",
    "IncludeManagementEvents": true,
    "DataResources": [{
      "Type": "AWS::S3::Object",
      "Values": ["arn:aws:s3:::sensitive-bucket/"]
    }]
  }]'
```

## CloudTrail Lake

```sql
-- Query events
SELECT eventTime, userIdentity.userName, eventName, sourceIPAddress
FROM cloudtrail_logs
WHERE eventTime > '2024-01-01'
  AND eventName LIKE '%Delete%'
ORDER BY eventTime DESC
LIMIT 100
```

## Best Practices

- Organization-wide trails
- Enable log file validation
- Encrypt with KMS
- CloudWatch Logs integration
- Event alerting
