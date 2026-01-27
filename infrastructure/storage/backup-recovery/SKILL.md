---
name: backup-recovery
description: Implement backup and recovery strategies. Configure rsync, Restic, and cloud backups. Use when designing data protection solutions.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Backup and Recovery

Implement comprehensive backup strategies.

## rsync Backups

```bash
# Basic sync
rsync -avz --delete /source/ /backup/

# Remote backup
rsync -avz -e ssh /data/ user@backup:/backups/

# Incremental with hard links
rsync -avz --delete --link-dest=/backup/latest /source/ /backup/$(date +%Y%m%d)/
```

## Restic Backup

```bash
# Initialize repository
restic init --repo /backups

# Backup
restic backup /data --repo /backups

# List snapshots
restic snapshots --repo /backups

# Restore
restic restore latest --target /restore --repo /backups

# Prune old backups
restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 12 --prune
```

## Cloud Backup

```bash
# AWS S3 with restic
restic init --repo s3:s3.amazonaws.com/bucket-name
restic backup /data --repo s3:s3.amazonaws.com/bucket-name

# GCS
restic init --repo gs:bucket-name:/
```

## Best Practices

- Follow 3-2-1 rule
- Test recovery regularly
- Encrypt backups
- Document procedures
- Monitor backup success
