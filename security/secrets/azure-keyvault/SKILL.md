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
- Managing secrets, encryption keys, or certificates in Azure
- Implementing centralized secret management for Azure services
- Integrating secrets into AKS, App Service, or Azure Functions
- Encrypting data with customer-managed keys (CMK)
- Meeting compliance requirements for key management (FIPS 140-2)

## Prerequisites

- Azure subscription with appropriate permissions
- Azure CLI installed (`az` command)
- Contributor or Key Vault Administrator role for vault management
- Managed identity configured for application access
- Understanding of Azure RBAC vs. Key Vault access policies

## Vault Creation and Configuration

```bash
# Create a resource group
az group create --name rg-secrets --location eastus

# Create Key Vault with RBAC authorization (recommended)
az keyvault create \
  --name myapp-vault-prod \
  --resource-group rg-secrets \
  --location eastus \
  --enable-rbac-authorization true \
  --enable-soft-delete true \
  --retention-days 90 \
  --enable-purge-protection true \
  --sku premium  # Use premium for HSM-backed keys

# Create Key Vault with access policies (legacy)
az keyvault create \
  --name myapp-vault-dev \
  --resource-group rg-secrets \
  --location eastus \
  --enable-soft-delete true \
  --retention-days 30

# Enable private endpoint (no public access)
az keyvault update \
  --name myapp-vault-prod \
  --resource-group rg-secrets \
  --public-network-access Disabled

# Enable diagnostics logging
az monitor diagnostic-settings create \
  --name kv-diagnostics \
  --resource "/subscriptions/{sub}/resourceGroups/rg-secrets/providers/Microsoft.KeyVault/vaults/myapp-vault-prod" \
  --workspace "/subscriptions/{sub}/resourceGroups/rg-monitor/providers/Microsoft.OperationalInsights/workspaces/security-logs" \
  --logs '[{"category":"AuditEvent","enabled":true,"retentionPolicy":{"enabled":true,"days":365}}]'
```

## Secret Management

```bash
# Set a secret
az keyvault secret set \
  --vault-name myapp-vault-prod \
  --name db-password \
  --value "S3cur3P@ssw0rd!" \
  --content-type "text/plain" \
  --tags Environment=production Team=platform

# Set a multi-line secret (JSON credentials)
az keyvault secret set \
  --vault-name myapp-vault-prod \
  --name db-credentials \
  --value '{"username":"dbadmin","password":"S3cur3P@ss!","host":"db.postgres.database.azure.com","port":5432}'

# Get secret value
az keyvault secret show \
  --vault-name myapp-vault-prod \
  --name db-password \
  --query value -o tsv

# Get specific version
az keyvault secret show \
  --vault-name myapp-vault-prod \
  --name db-password \
  --version abc123def456

# List all secrets
az keyvault secret list --vault-name myapp-vault-prod -o table

# List secret versions
az keyvault secret list-versions \
  --vault-name myapp-vault-prod \
  --name db-password -o table

# Set expiration date
az keyvault secret set-attributes \
  --vault-name myapp-vault-prod \
  --name api-key \
  --expires "2026-01-01T00:00:00Z"

# Disable a secret (without deleting)
az keyvault secret set-attributes \
  --vault-name myapp-vault-prod \
  --name old-api-key \
  --enabled false

# Delete a secret (soft-delete)
az keyvault secret delete \
  --vault-name myapp-vault-prod \
  --name old-api-key

# Recover a deleted secret
az keyvault secret recover \
  --vault-name myapp-vault-prod \
  --name old-api-key

# Purge a deleted secret (permanent, requires purge protection to be off)
az keyvault secret purge \
  --vault-name myapp-vault-prod \
  --name old-api-key

# Backup and restore
az keyvault secret backup \
  --vault-name myapp-vault-prod \
  --name db-password \
  --file db-password.backup

az keyvault secret restore \
  --vault-name myapp-vault-prod \
  --file db-password.backup
```

## Key Management

```bash
# Create an RSA key for encryption
az keyvault key create \
  --vault-name myapp-vault-prod \
  --name data-encryption-key \
  --kty RSA \
  --size 4096 \
  --ops encrypt decrypt wrapKey unwrapKey

# Create an EC key for signing
az keyvault key create \
  --vault-name myapp-vault-prod \
  --name signing-key \
  --kty EC \
  --curve P-256 \
  --ops sign verify

# Import an existing key
az keyvault key import \
  --vault-name myapp-vault-prod \
  --name imported-key \
  --pem-file key.pem

# Encrypt data
az keyvault key encrypt \
  --vault-name myapp-vault-prod \
  --name data-encryption-key \
  --algorithm RSA-OAEP-256 \
  --value "base64-encoded-plaintext"

# Rotate a key
az keyvault key rotate \
  --vault-name myapp-vault-prod \
  --name data-encryption-key

# Set key rotation policy
az keyvault key rotation-policy update \
  --vault-name myapp-vault-prod \
  --name data-encryption-key \
  --value '{
    "lifetimeActions": [
      {
        "trigger": {"timeBeforeExpiry": "P30D"},
        "action": {"type": "Notify"}
      },
      {
        "trigger": {"timeAfterCreate": "P90D"},
        "action": {"type": "Rotate"}
      }
    ],
    "attributes": {"expiryTime": "P180D"}
  }'
```

## Certificate Management

```bash
# Create a self-signed certificate
az keyvault certificate create \
  --vault-name myapp-vault-prod \
  --name app-tls-cert \
  --policy '{
    "issuerParameters": {"name": "Self"},
    "keyProperties": {"exportable": true, "keySize": 4096, "keyType": "RSA"},
    "secretProperties": {"contentType": "application/x-pkcs12"},
    "x509CertificateProperties": {
      "subject": "CN=app.example.com",
      "subjectAlternativeNames": {"dnsNames": ["app.example.com", "*.app.example.com"]},
      "validityInMonths": 12,
      "keyUsage": ["digitalSignature", "keyEncipherment"],
      "ekus": ["1.3.6.1.5.5.7.3.1"]
    },
    "lifetimeActions": [
      {"trigger": {"daysBeforeExpiry": 30}, "action": {"actionType": "AutoRenew"}}
    ]
  }'

# Import a certificate
az keyvault certificate import \
  --vault-name myapp-vault-prod \
  --name imported-cert \
  --file certificate.pfx \
  --password "pfx-password"

# Download certificate
az keyvault certificate download \
  --vault-name myapp-vault-prod \
  --name app-tls-cert \
  --file cert.pem \
  --encoding PEM

# List certificates
az keyvault certificate list --vault-name myapp-vault-prod -o table
```

## Access Policies and RBAC

### RBAC (Recommended)

```bash
# Grant secret reader access to a managed identity
az role assignment create \
  --role "Key Vault Secrets User" \
  --assignee-object-id "$(az identity show -g rg-app -n myapp-identity --query principalId -o tsv)" \
  --scope "/subscriptions/{sub}/resourceGroups/rg-secrets/providers/Microsoft.KeyVault/vaults/myapp-vault-prod"

# Grant admin access to security team
az role assignment create \
  --role "Key Vault Administrator" \
  --assignee "security-team@example.com" \
  --scope "/subscriptions/{sub}/resourceGroups/rg-secrets/providers/Microsoft.KeyVault/vaults/myapp-vault-prod"

# Available Key Vault RBAC roles:
# - Key Vault Administrator (full management)
# - Key Vault Secrets Officer (manage secrets)
# - Key Vault Secrets User (read secrets)
# - Key Vault Certificates Officer (manage certs)
# - Key Vault Crypto Officer (manage keys)
# - Key Vault Crypto User (use keys for encrypt/decrypt)
# - Key Vault Reader (read metadata only)
```

### Access Policies (Legacy)

```bash
# Grant secret access via access policy
az keyvault set-policy \
  --name myapp-vault-prod \
  --object-id "$(az identity show -g rg-app -n myapp-identity --query principalId -o tsv)" \
  --secret-permissions get list

# Grant key access
az keyvault set-policy \
  --name myapp-vault-prod \
  --object-id "$OBJECT_ID" \
  --key-permissions get unwrapKey wrapKey

# Grant certificate access
az keyvault set-policy \
  --name myapp-vault-prod \
  --object-id "$OBJECT_ID" \
  --certificate-permissions get list
```

## Application Integration

### Python SDK

```python
from azure.identity import DefaultAzureCredential, ManagedIdentityCredential
from azure.keyvault.secrets import SecretClient
from azure.keyvault.keys import KeyClient
from azure.keyvault.certificates import CertificateClient

# Use DefaultAzureCredential (works locally and in Azure)
credential = DefaultAzureCredential()

vault_url = "https://myapp-vault-prod.vault.azure.net/"

# Secrets
secret_client = SecretClient(vault_url=vault_url, credential=credential)
db_password = secret_client.get_secret("db-password")
print(f"Secret value: {db_password.value}")

# Get specific version
specific = secret_client.get_secret("db-password", version="abc123")

# List secrets
for secret_properties in secret_client.list_properties_of_secrets():
    print(f"Secret: {secret_properties.name}, Enabled: {secret_properties.enabled}")

# Keys
key_client = KeyClient(vault_url=vault_url, credential=credential)
from azure.keyvault.keys.crypto import CryptographyClient, EncryptionAlgorithm

key = key_client.get_key("data-encryption-key")
crypto_client = CryptographyClient(key, credential=credential)

# Encrypt data
plaintext = b"sensitive data"
result = crypto_client.encrypt(EncryptionAlgorithm.rsa_oaep_256, plaintext)
ciphertext = result.ciphertext

# Decrypt data
decrypted = crypto_client.decrypt(EncryptionAlgorithm.rsa_oaep_256, ciphertext)
```

### .NET SDK

```csharp
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;

var credential = new DefaultAzureCredential();
var client = new SecretClient(new Uri("https://myapp-vault-prod.vault.azure.net/"), credential);

KeyVaultSecret secret = await client.GetSecretAsync("db-password");
string password = secret.Value;
```

## Kubernetes Integration (AKS)

### Secrets Store CSI Driver

```yaml
# SecretProviderClass for AKS with managed identity
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-keyvault-secrets
  namespace: production
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    useVMManagedIdentity: "true"
    userAssignedIdentityID: "<managed-identity-client-id>"
    keyvaultName: "myapp-vault-prod"
    cloudName: ""
    objects: |
      array:
        - |
          objectName: db-password
          objectType: secret
          objectVersion: ""
        - |
          objectName: api-key
          objectType: secret
        - |
          objectName: app-tls-cert
          objectType: secret
    tenantId: "<azure-tenant-id>"
  secretObjects:
    - secretName: db-secrets
      type: Opaque
      data:
        - objectName: db-password
          key: password
        - objectName: api-key
          key: api-key
    - secretName: tls-secret
      type: kubernetes.io/tls
      data:
        - objectName: app-tls-cert
          key: tls.crt
---
# Pod using the secrets
apiVersion: v1
kind: Pod
metadata:
  name: myapp
  namespace: production
spec:
  serviceAccountName: myapp-sa
  containers:
    - name: myapp
      image: ghcr.io/acme/myapp:v1.0.0
      env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secrets
              key: password
      volumeMounts:
        - name: secrets-store
          mountPath: "/mnt/secrets-store"
          readOnly: true
  volumes:
    - name: secrets-store
      csi:
        driver: secrets-store.csi.k8s.io
        readOnly: true
        volumeAttributes:
          secretProviderClass: "azure-keyvault-secrets"
```

## Terraform Configuration

```hcl
resource "azurerm_key_vault" "main" {
  name                        = "myapp-vault-prod"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "premium"

  enable_rbac_authorization   = true
  purge_protection_enabled    = true
  soft_delete_retention_days  = 90
  public_network_access_enabled = false

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = ["203.0.113.0/24"]
    virtual_network_subnet_ids = [azurerm_subnet.app.id]
  }
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.main.id
  content_type = "text/plain"

  expiration_date = "2026-01-01T00:00:00Z"

  tags = {
    environment = "production"
    rotation    = "enabled"
  }
}

resource "azurerm_role_assignment" "app_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}
```

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| "Access denied" when reading secrets | Missing RBAC role or access policy | Assign `Key Vault Secrets User` role; or add access policy with `get` permission |
| "Vault not found" | Network access restricted | Check firewall rules; enable private endpoint; add IP to allow list |
| Soft-deleted secret blocks creation | Name collision with deleted secret | Recover and update, or purge the deleted secret first |
| Managed identity cannot access vault | Identity not in correct scope | Verify identity principal ID; check role assignment scope matches vault |
| Certificate renewal fails | Auto-renew policy not configured | Set `lifetimeActions` with `AutoRenew` action in certificate policy |
| CSI driver fails to mount secrets | Wrong provider configuration | Verify `tenantId`, `userAssignedIdentityID`, and object names match exactly |
| High latency on secret retrieval | No client-side caching | Implement caching in application; use CSI driver for K8s (syncs on interval) |

## Best Practices

- Use RBAC authorization over access policies for granular control
- Enable soft-delete and purge protection (required for compliance)
- Use managed identities for all service access (no credentials to manage)
- Enable private endpoints to eliminate public network exposure
- Set expiration dates on all secrets and certificates
- Enable diagnostic logging and forward to SIEM
- Use premium SKU for HSM-backed key operations
- Implement key rotation policies for all encryption keys
- Regularly audit access with Azure Activity logs
- Tag all vault resources for cost and ownership tracking

## Related Skills

- [hashicorp-vault](../hashicorp-vault/) - Multi-cloud secrets
- [azure-networking](../../../infrastructure/cloud-azure/azure-networking/) - Network security
- [aws-secrets-manager](../aws-secrets-manager/) - AWS secret management
- [gcp-secret-manager](../gcp-secret-manager/) - GCP secret management
