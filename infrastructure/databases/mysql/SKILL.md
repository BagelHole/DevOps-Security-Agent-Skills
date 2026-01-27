---
name: mysql
description: Administer MySQL/MariaDB databases. Configure replication and optimize performance. Use when managing MySQL deployments.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# MySQL / MariaDB

Administer MySQL and MariaDB databases.

## Installation & Setup

```bash
# Install
apt install mysql-server

# Secure installation
mysql_secure_installation

# Access
mysql -u root -p

# Create database and user
CREATE DATABASE mydb;
CREATE USER 'myapp'@'%' IDENTIFIED BY 'secret';
GRANT ALL PRIVILEGES ON mydb.* TO 'myapp'@'%';
FLUSH PRIVILEGES;
```

## Configuration

```bash
# /etc/mysql/mysql.conf.d/mysqld.cnf
[mysqld]
innodb_buffer_pool_size = 1G
max_connections = 200
slow_query_log = 1
long_query_time = 2
```

## Backup & Restore

```bash
# Backup
mysqldump -u root -p mydb > backup.sql
mysqldump -u root -p --all-databases > full_backup.sql

# Restore
mysql -u root -p mydb < backup.sql
```

## Replication

```bash
# Primary
[mysqld]
server-id = 1
log_bin = mysql-bin

# Replica
CHANGE MASTER TO
  MASTER_HOST='primary',
  MASTER_USER='replicator',
  MASTER_PASSWORD='secret',
  MASTER_LOG_FILE='mysql-bin.000001',
  MASTER_LOG_POS=0;
START SLAVE;
```

## Best Practices

- Enable slow query logging
- Use InnoDB storage engine
- Regular backups with mysqldump
- Monitor with SHOW PROCESSLIST
