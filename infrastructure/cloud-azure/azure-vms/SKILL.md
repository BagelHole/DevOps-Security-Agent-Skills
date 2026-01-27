---
name: azure-vms
description: Manage Azure Virtual Machines and scale sets. Configure availability sets and managed disks. Use when deploying compute resources on Azure.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Azure Virtual Machines

Deploy and manage Azure VMs and scale sets.

## Create VM

```bash
az vm create \
  --resource-group mygroup \
  --name myvm \
  --image Ubuntu2204 \
  --size Standard_B2s \
  --admin-username azureuser \
  --generate-ssh-keys \
  --nsg-rule SSH
```

## Scale Sets

```bash
az vmss create \
  --resource-group mygroup \
  --name myvmss \
  --image Ubuntu2204 \
  --instance-count 2 \
  --vm-sku Standard_B2s \
  --upgrade-policy-mode automatic
```

## Best Practices

- Use managed disks
- Implement availability zones
- Use scale sets for auto-scaling
- Enable Azure Backup
- Use spot instances for cost savings
