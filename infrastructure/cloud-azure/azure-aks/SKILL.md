---
name: azure-aks
description: Deploy and manage Azure Kubernetes Service clusters. Configure node pools, networking, and integrations. Use when running Kubernetes workloads on Azure.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Azure Kubernetes Service

Deploy managed Kubernetes clusters on Azure.

## Create Cluster

```bash
az aks create \
  --resource-group mygroup \
  --name myakscluster \
  --node-count 3 \
  --node-vm-size Standard_B2s \
  --enable-managed-identity \
  --generate-ssh-keys

# Get credentials
az aks get-credentials --resource-group mygroup --name myakscluster
```

## Node Pools

```bash
az aks nodepool add \
  --resource-group mygroup \
  --cluster-name myakscluster \
  --name gpupool \
  --node-count 1 \
  --node-vm-size Standard_NC6
```

## Enable Add-ons

```bash
# Enable monitoring
az aks enable-addons \
  --resource-group mygroup \
  --name myakscluster \
  --addons monitoring

# Enable Azure Policy
az aks enable-addons \
  --resource-group mygroup \
  --name myakscluster \
  --addons azure-policy
```

## Best Practices

- Use managed identity
- Enable Azure CNI for networking
- Implement pod identity
- Use node pools for workload isolation
- Enable cluster autoscaler
