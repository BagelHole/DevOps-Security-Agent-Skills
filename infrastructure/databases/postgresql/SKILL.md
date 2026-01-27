---
name: postgresql
description: Administer PostgreSQL databases. Configure replication, backups, and performance tuning. Use when managing PostgreSQL deployments.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# PostgreSQL

Administer and optimize PostgreSQL databases.

## Installation & Setup

```bash
# Install
apt install postgresql postgresql-contrib

# Access
sudo -u postgres psql

# Create database and user
CREATE USER myapp WITH PASSWORD 'secret';
CREATE DATABASE mydb OWNER myapp;
GRANT ALL PRIVILEGES ON DATABASE mydb TO myapp;
```

## Configuration

```bash
# /etc/postgresql/15/main/postgresql.conf
max_connections = 200
shared_buffers = 256MB
effective_cache_size = 768MB
work_mem = 4MB
maintenance_work_mem = 64MB
```

## Backup & Restore

```bash
# Backup
pg_dump mydb > backup.sql
pg_dump -Fc mydb > backup.dump  # Custom format

# Restore
psql mydb < backup.sql
pg_restore -d mydb backup.dump
```

## Replication

```bash
# Primary
ALTER SYSTEM SET wal_level = replica;
CREATE USER replicator REPLICATION LOGIN PASSWORD 'secret';

# Replica
pg_basebackup -h primary -U replicator -D /var/lib/postgresql/15/main -P
```

## Best Practices

- Regular VACUUM and ANALYZE
- Monitor slow queries
- Implement connection pooling (PgBouncer)
- Regular backups with pg_dump or pg_basebackup
