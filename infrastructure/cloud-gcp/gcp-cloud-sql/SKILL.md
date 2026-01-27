---
name: gcp-cloud-sql
description: Provision Cloud SQL and Spanner databases. Configure high availability, backups, and security. Use when deploying managed databases on GCP.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# GCP Cloud SQL

Deploy managed databases on Google Cloud.

## Create Instance

```bash
gcloud sql instances create mydb \
  --database-version=POSTGRES_15 \
  --tier=db-f1-micro \
  --region=us-central1 \
  --root-password=secretpassword \
  --storage-auto-increase \
  --backup-start-time=02:00

# Create database
gcloud sql databases create myapp --instance=mydb

# Create user
gcloud sql users create appuser \
  --instance=mydb \
  --password=userpassword
```

## High Availability

```bash
gcloud sql instances create mydb \
  --database-version=POSTGRES_15 \
  --tier=db-custom-2-8192 \
  --region=us-central1 \
  --availability-type=REGIONAL
```

## Best Practices

- Enable automated backups
- Use Cloud SQL Proxy for connections
- Implement private IP
- Use read replicas for scaling
