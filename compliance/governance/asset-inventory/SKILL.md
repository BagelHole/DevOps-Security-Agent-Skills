---
name: asset-inventory
description: Maintain IT asset inventory and configuration management database. Track hardware, software, and cloud resources. Use when managing IT assets.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Asset Inventory

Maintain comprehensive IT asset tracking.

## Asset Categories

```yaml
asset_types:
  hardware:
    - Servers
    - Network devices
    - Endpoints
    
  software:
    - Applications
    - Operating systems
    - Licenses
    
  cloud:
    - Compute instances
    - Storage
    - Databases
    
  data:
    - Databases
    - File shares
    - Backups
```

## AWS Inventory

```bash
# List all resources
aws resourcegroupstaggingapi get-resources

# EC2 instances
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name]'

# AWS Config
aws configservice describe-configuration-recorders
```

## Asset Database Schema

```yaml
asset:
  id: unique identifier
  name: display name
  type: hardware/software/cloud
  owner: responsible team
  classification: public/internal/confidential
  location: physical/cloud location
  status: active/retired/decommissioned
  created: timestamp
  updated: timestamp
  tags: []
```

## Best Practices

- Automated discovery
- Regular reconciliation
- Owner assignment
- Classification tagging
- Lifecycle tracking
