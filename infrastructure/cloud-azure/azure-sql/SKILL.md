---
name: azure-sql
description: Provision Azure SQL Database and Cosmos DB. Configure security, backups, and replication. Use when deploying managed databases on Azure.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Azure SQL

Deploy managed databases on Azure.

## Create SQL Database

```bash
# Create server
az sql server create \
  --name myserver \
  --resource-group mygroup \
  --admin-user sqladmin \
  --admin-password SecureP@ss123

# Create database
az sql db create \
  --resource-group mygroup \
  --server myserver \
  --name mydb \
  --service-objective S1
```

## Firewall Rules

```bash
az sql server firewall-rule create \
  --resource-group mygroup \
  --server myserver \
  --name AllowAzure \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

## Cosmos DB

```bash
az cosmosdb create \
  --name mycosmosdb \
  --resource-group mygroup \
  --default-consistency-level Session
```

## Best Practices

- Enable transparent data encryption
- Use Azure AD authentication
- Implement geo-replication
- Configure automated backups
- Use private endpoints
