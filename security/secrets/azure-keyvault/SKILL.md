---
name: azure-keyvault
description: Manage secrets and certificates in Azure Key Vault. Configure access policies, integrate with Azure services, and implement secure secret management. Use when managing secrets in Azure environments.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Azure Key Vault

Securely store and manage secrets, keys, and certificates in Azure.

## When to Use This Skill

Use this skill when:
- Managing secrets in Azure
- Storing encryption keys
- Managing SSL certificates
- Integrating with Azure services

## Prerequisites

- Azure subscription
- Azure CLI installed
- Appropriate RBAC permissions

## Basic Operations

```bash
# Create Key Vault
az keyvault create --name mykeyvault --resource-group mygroup --location eastus

# Set secret
az keyvault secret set --vault-name mykeyvault --name db-password --value "secret123"

# Get secret
az keyvault secret show --vault-name mykeyvault --name db-password

# List secrets
az keyvault secret list --vault-name mykeyvault
```

## Application Integration

```python
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

credential = DefaultAzureCredential()
client = SecretClient(vault_url="https://mykeyvault.vault.azure.net/", credential=credential)

# Get secret
secret = client.get_secret("db-password")
print(secret.value)
```

## Kubernetes Integration

```yaml
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-keyvault
spec:
  provider: azure
  parameters:
    keyvaultName: "mykeyvault"
    objects: |
      array:
        - |
          objectName: db-password
          objectType: secret
    tenantId: "tenant-id"
```

## Best Practices

- Use managed identities
- Enable soft-delete and purge protection
- Implement access policies carefully
- Use private endpoints
- Monitor with Azure Monitor

## Related Skills

- [hashicorp-vault](../hashicorp-vault/) - Multi-cloud secrets
- [azure-networking](../../../infrastructure/cloud-azure/azure-networking/) - Network security
