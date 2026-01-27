---
name: azure-monitor-audit
description: Configure Azure Monitor and Activity Log for auditing. Set up diagnostic settings and log analytics. Use when auditing Azure activity.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Azure Monitor Audit

Audit Azure activity with Monitor and Activity Logs.

## Diagnostic Settings

```bash
# Enable diagnostic settings
az monitor diagnostic-settings create \
  --name audit-logs \
  --resource /subscriptions/{sub}/resourceGroups/{rg}/providers/... \
  --logs '[{"category":"AuditEvent","enabled":true}]' \
  --workspace /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace}
```

## Activity Log Export

```bash
# Export activity log to Log Analytics
az monitor diagnostic-settings subscription create \
  --name activity-log-export \
  --location global \
  --logs '[{"category":"Administrative","enabled":true},{"category":"Security","enabled":true}]' \
  --workspace /subscriptions/.../workspaces/audit-workspace
```

## Log Analytics Queries

```kusto
// Failed login attempts
AuditLogs
| where TimeGenerated > ago(24h)
| where ResultType != "0"
| project TimeGenerated, Identity, ResultDescription, IPAddress

// Administrative changes
AzureActivity
| where CategoryValue == "Administrative"
| where OperationNameValue contains "write" or OperationNameValue contains "delete"
| project TimeGenerated, Caller, OperationNameValue, ResourceGroup
```

## Best Practices

- Centralize to Log Analytics
- Long-term archive to Storage
- Configure alerts
- Regular query reviews
