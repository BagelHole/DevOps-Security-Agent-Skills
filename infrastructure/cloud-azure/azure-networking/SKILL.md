---
name: azure-networking
description: Configure Azure VNets, NSGs, and Azure Firewall. Implement hub-spoke topology and private endpoints. Use when designing Azure network infrastructure.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Azure Networking

Design and implement Azure network infrastructure.

## Create VNet

```bash
az network vnet create \
  --resource-group mygroup \
  --name myvnet \
  --address-prefix 10.0.0.0/16 \
  --subnet-name default \
  --subnet-prefix 10.0.1.0/24
```

## Network Security Group

```bash
az network nsg create \
  --resource-group mygroup \
  --name mynsg

az network nsg rule create \
  --resource-group mygroup \
  --nsg-name mynsg \
  --name AllowHTTPS \
  --priority 100 \
  --destination-port-ranges 443 \
  --access Allow
```

## Private Endpoint

```bash
az network private-endpoint create \
  --resource-group mygroup \
  --name myendpoint \
  --vnet-name myvnet \
  --subnet default \
  --private-connection-resource-id /subscriptions/.../sql/... \
  --group-id sqlServer \
  --connection-name myconnection
```

## Best Practices

- Implement hub-spoke topology
- Use NSGs and Azure Firewall
- Enable DDoS protection
- Use private endpoints
- Implement VNet peering
