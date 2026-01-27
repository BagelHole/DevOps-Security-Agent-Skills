---
name: audit-logging
description: Implement centralized audit logging and SIEM integration. Configure log retention and security monitoring. Use when implementing audit trail requirements.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Audit Logging

Implement comprehensive audit logging for compliance.

## Log Categories

```yaml
audit_events:
  authentication:
    - Login attempts
    - MFA events
    - Session management
    
  authorization:
    - Access grants
    - Permission changes
    - Role assignments
    
  data_access:
    - Read operations
    - Write operations
    - Delete operations
    
  administrative:
    - Configuration changes
    - User management
    - System changes
```

## Application Logging

```python
import logging
import json

class AuditLogger:
    def log_event(self, event_type, user, resource, action, result):
        log_entry = {
            'timestamp': datetime.utcnow().isoformat(),
            'event_type': event_type,
            'user': user,
            'resource': resource,
            'action': action,
            'result': result,
            'source_ip': request.remote_addr
        }
        logger.info(json.dumps(log_entry))
```

## Centralized Logging

```yaml
# Fluentd configuration
<source>
  @type tail
  path /var/log/audit/*.log
  tag audit.*
</source>

<match audit.**>
  @type elasticsearch
  host elasticsearch.example.com
  index_name audit-logs
</match>
```

## Best Practices

- Structured logging (JSON)
- Centralized collection
- Tamper-proof storage
- Retention policies
- Alerting on anomalies
