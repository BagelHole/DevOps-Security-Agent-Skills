---
name: database-backups
description: Implement database backup strategies. Configure automated backups, retention, and recovery testing. Use when designing backup and recovery procedures.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Database Backups

Implement comprehensive database backup strategies.

## Backup Types

```yaml
backup_types:
  full:
    description: Complete database copy
    frequency: Weekly
    
  incremental:
    description: Changes since last backup
    frequency: Daily
    
  transaction_log:
    description: Continuous transaction logging
    frequency: Continuous
```

## Automated Backup Script

```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups"

# PostgreSQL
pg_dump -Fc mydb > $BACKUP_DIR/pg_$DATE.dump

# MySQL
mysqldump -u root -p$MYSQL_PWD mydb | gzip > $BACKUP_DIR/mysql_$DATE.sql.gz

# Upload to S3
aws s3 cp $BACKUP_DIR/pg_$DATE.dump s3://backups/postgres/

# Cleanup old backups (keep 7 days)
find $BACKUP_DIR -name "*.dump" -mtime +7 -delete
```

## Recovery Testing

```bash
# Create test environment
docker run -d --name restore-test postgres:15

# Restore backup
pg_restore -d testdb backup.dump

# Verify data integrity
psql testdb -c "SELECT COUNT(*) FROM users;"
```

## Best Practices

- 3-2-1 Rule: 3 copies, 2 media types, 1 offsite
- Regular recovery testing
- Encrypt backups at rest
- Monitor backup success
- Document recovery procedures
