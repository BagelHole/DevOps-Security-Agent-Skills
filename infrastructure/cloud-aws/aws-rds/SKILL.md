---
name: aws-rds
description: Provision and manage RDS databases. Configure backups, replication, and security. Use when deploying managed relational databases on AWS.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# AWS RDS

Deploy managed relational databases with Amazon RDS.

## Create Database

```bash
aws rds create-db-instance \
  --db-instance-identifier mydb \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version 15 \
  --master-username admin \
  --master-user-password secretpassword \
  --allocated-storage 20 \
  --storage-encrypted \
  --vpc-security-group-ids sg-xxx \
  --db-subnet-group-name my-subnet-group \
  --backup-retention-period 7 \
  --multi-az
```

## Parameter Groups

```bash
aws rds create-db-parameter-group \
  --db-parameter-group-name custom-pg \
  --db-parameter-group-family postgres15 \
  --description "Custom PostgreSQL parameters"

aws rds modify-db-parameter-group \
  --db-parameter-group-name custom-pg \
  --parameters "ParameterName=max_connections,ParameterValue=200,ApplyMethod=pending-reboot"
```

## Snapshots & Recovery

```bash
# Create snapshot
aws rds create-db-snapshot \
  --db-instance-identifier mydb \
  --db-snapshot-identifier mydb-snapshot

# Restore from snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier mydb-restored \
  --db-snapshot-identifier mydb-snapshot
```

## Read Replicas

```bash
aws rds create-db-instance-read-replica \
  --db-instance-identifier mydb-replica \
  --source-db-instance-identifier mydb
```

## Best Practices

- Enable Multi-AZ for production
- Use encryption at rest
- Implement automated backups
- Use read replicas for read scaling
- Store credentials in Secrets Manager

## Related Skills

- [terraform-aws](../terraform-aws/) - IaC deployment
- [aws-secrets-manager](../../../security/secrets/aws-secrets-manager/) - Credentials
