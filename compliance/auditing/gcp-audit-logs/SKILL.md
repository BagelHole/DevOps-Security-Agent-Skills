---
name: gcp-audit-logs
description: Configure GCP Cloud Audit Logs for compliance. Set up log routing and BigQuery analysis. Use when auditing GCP activity.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# GCP Audit Logs

Audit GCP activity with Cloud Audit Logs.

## Audit Log Types

```yaml
log_types:
  admin_activity:
    - Always enabled
    - API calls that modify resources
    - No charge
    
  data_access:
    - Must be enabled
    - Read/write data operations
    - Can be high volume
    
  system_event:
    - Always enabled
    - GCP system actions
    
  policy_denied:
    - Always enabled
    - Access denials
```

## Enable Data Access Logs

```bash
# Enable for all services
gcloud logging sinks create audit-sink \
  storage.googleapis.com/audit-logs-bucket \
  --log-filter='logName:"cloudaudit.googleapis.com"'

# IAM policy for data access logs
gcloud projects get-iam-policy PROJECT_ID > policy.yaml
# Add auditConfigs section
gcloud projects set-iam-policy PROJECT_ID policy.yaml
```

## BigQuery Analysis

```sql
-- Query audit logs from BigQuery export
SELECT
  timestamp,
  protopayload_auditlog.authenticationInfo.principalEmail,
  protopayload_auditlog.methodName,
  resource.labels.project_id
FROM `project.dataset.cloudaudit_googleapis_com_activity_*`
WHERE timestamp > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
  AND protopayload_auditlog.methodName LIKE '%delete%'
ORDER BY timestamp DESC
```

## Best Practices

- Export to BigQuery for analysis
- Configure log retention
- Enable data access logs for sensitive resources
- Set up alerting policies
