---
name: terraform-azure
description: Provision Azure infrastructure with Terraform. Configure providers, manage state, and deploy resources. Use when implementing IaC for Azure.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Terraform Azure

Provision and manage Azure infrastructure with Terraform using the AzureRM provider. Covers provider configuration, remote state, resource groups, VNets, AKS, Key Vault, complete .tf file examples, and production workflows.

## When to Use

- You need multi-cloud or cloud-agnostic Infrastructure as Code.
- Your team standardizes on Terraform across AWS, Azure, and GCP.
- You need plan/apply workflows with change preview before deployment.
- You want modular, reusable infrastructure components.
- You need state locking and drift detection for production infrastructure.

## Prerequisites

```bash
# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Verify installation
terraform version

# Install Azure CLI and login
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az login
az account set --subscription "my-subscription-id"

# Create storage account for remote state
az group create --name tfstate-rg --location eastus
az storage account create \
  --name tfstate$(openssl rand -hex 4) \
  --resource-group tfstate-rg \
  --sku Standard_LRS \
  --encryption-services blob
az storage container create \
  --name tfstate \
  --account-name tfstateXXXXXXXX
```

## Provider Configuration

### providers.tf

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstate12345abc"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  # Optional: use a specific subscription
  # subscription_id = var.subscription_id
}

provider "azuread" {}
```

### variables.tf

```hcl
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
  default     = "myapp"
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "sql_admin_password" {
  description = "SQL Server admin password"
  type        = string
  sensitive   = true
}

variable "aks_admin_group_id" {
  description = "Azure AD group ID for AKS admin access"
  type        = string
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = merge(var.tags, {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
  })
}
```

### terraform.tfvars (per environment)

```hcl
# terraform.prod.tfvars
environment        = "prod"
location           = "eastus"
project_name       = "myapp"
aks_admin_group_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

tags = {
  cost_center = "engineering"
  owner       = "platform-team"
}
```

## Resource Group

### resource-group.tf

```hcl
resource "azurerm_resource_group" "main" {
  name     = "${local.name_prefix}-rg"
  location = var.location
  tags     = local.common_tags
}
```

## Virtual Network

### network.tf

```hcl
resource "azurerm_virtual_network" "main" {
  name                = "${local.name_prefix}-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
  tags                = local.common_tags
}

resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/22"]
}

resource "azurerm_subnet" "app" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.8.0/24"]
}

resource "azurerm_subnet" "data" {
  name                 = "data-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.9.0/24"]

  private_endpoint_network_policies_enabled = true
}

resource "azurerm_network_security_group" "app" {
  name                = "${local.name_prefix}-app-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}
```

## AKS Cluster

### aks.tf

```hcl
resource "azurerm_log_analytics_workspace" "aks" {
  name                = "${local.name_prefix}-law"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.common_tags
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "${local.name_prefix}-aks"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.project_name}-${var.environment}"
  kubernetes_version  = "1.28"

  default_node_pool {
    name                = "system"
    vm_size             = "Standard_D4s_v5"
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 5
    zones               = [1, 2, 3]
    vnet_subnet_id      = azurerm_subnet.aks.id
    os_disk_size_gb     = 128
    os_disk_type        = "Managed"
    max_pods            = 50

    node_labels = {
      role = "system"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    service_cidr      = "10.1.0.0/16"
    dns_service_ip    = "10.1.0.10"
    load_balancer_sku = "standard"
  }

  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled     = true
    admin_group_object_ids = [var.aks_admin_group_id]
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  tags = local.common_tags
}

resource "azurerm_kubernetes_cluster_node_pool" "app" {
  name                  = "app"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_D8s_v5"
  enable_auto_scaling   = true
  min_count             = 2
  max_count             = 20
  zones                 = [1, 2, 3]
  vnet_subnet_id        = azurerm_subnet.aks.id
  max_pods              = 50

  node_labels = {
    workload = "app"
  }

  node_taints = [
    "dedicated=app:NoSchedule"
  ]

  tags = local.common_tags
}
```

## Key Vault

### keyvault.tf

```hcl
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                        = "${var.project_name}-${var.environment}-kv"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 90
  purge_protection_enabled    = true
  enabled_for_disk_encryption = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = var.allowed_ip_ranges
    virtual_network_subnet_ids = [
      azurerm_subnet.app.id,
      azurerm_subnet.aks.id,
    ]
  }

  tags = local.common_tags
}

resource "azurerm_key_vault_access_policy" "terraform" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Purge", "Recover"
  ]

  key_permissions = [
    "Get", "List", "Create", "Delete", "Purge", "Recover",
    "WrapKey", "UnwrapKey"
  ]
}

resource "azurerm_key_vault_access_policy" "aks" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_kubernetes_cluster.main.key_vault_secrets_provider[0].secret_identity[0].object_id

  secret_permissions = ["Get", "List"]
}

resource "azurerm_key_vault_secret" "sql_password" {
  name         = "sql-admin-password"
  value        = var.sql_admin_password
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault_access_policy.terraform]
}
```

## SQL Database

### database.tf

```hcl
resource "azurerm_mssql_server" "main" {
  name                         = "${local.name_prefix}-sql"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = var.sql_admin_password
  minimum_tls_version          = "1.2"

  azuread_administrator {
    login_username = "SQL Admins"
    object_id      = var.aks_admin_group_id
  }

  tags = local.common_tags
}

resource "azurerm_mssql_database" "main" {
  name         = "${var.project_name}-db"
  server_id    = azurerm_mssql_server.main.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  sku_name     = var.environment == "prod" ? "BC_Gen5_4" : "GP_S_Gen5_2"
  max_size_gb  = var.environment == "prod" ? 256 : 32
  zone_redundant = var.environment == "prod"

  short_term_retention_policy {
    retention_days = var.environment == "prod" ? 14 : 7
  }

  tags = local.common_tags
}

resource "azurerm_private_endpoint" "sql" {
  name                = "${local.name_prefix}-sql-pe"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.data.id

  private_service_connection {
    name                           = "sql-connection"
    private_connection_resource_id = azurerm_mssql_server.main.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  tags = local.common_tags
}
```

## Outputs

### outputs.tf

```hcl
output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "aks_kube_config" {
  value     = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive = true
}

output "key_vault_uri" {
  value = azurerm_key_vault.main.vault_uri
}

output "sql_server_fqdn" {
  value = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "vnet_id" {
  value = azurerm_virtual_network.main.id
}
```

## Terraform Workflow Commands

```bash
# Initialize (download providers, configure backend)
terraform init

# Validate configuration syntax
terraform validate

# Format all .tf files
terraform fmt -recursive

# Plan changes for a specific environment
terraform plan \
  -var-file="terraform.prod.tfvars" \
  -var="sql_admin_password=$(az keyvault secret show --vault-name ops-vault --name sql-pass --query value -o tsv)" \
  -out=tfplan

# Apply the saved plan
terraform apply tfplan

# Apply with auto-approve (CI/CD pipelines only)
terraform apply \
  -var-file="terraform.prod.tfvars" \
  -auto-approve

# Destroy infrastructure (careful!)
terraform plan -destroy -var-file="terraform.prod.tfvars" -out=destroyplan
terraform apply destroyplan

# Import existing resources into state
terraform import azurerm_resource_group.main /subscriptions/{sub}/resourceGroups/myapp-prod-rg

# Show current state
terraform state list
terraform state show azurerm_kubernetes_cluster.main

# Move resources in state (renaming)
terraform state mv azurerm_resource_group.old azurerm_resource_group.new

# Refresh state from real infrastructure
terraform refresh -var-file="terraform.prod.tfvars"

# Unlock stuck state
terraform force-unlock LOCK_ID

# Use workspaces for environment isolation
terraform workspace new prod
terraform workspace select prod
terraform workspace list
```

## Module Structure

```
project/
  modules/
    networking/
      main.tf
      variables.tf
      outputs.tf
    aks/
      main.tf
      variables.tf
      outputs.tf
    database/
      main.tf
      variables.tf
      outputs.tf
  environments/
    dev/
      main.tf
      terraform.tfvars
      backend.tf
    prod/
      main.tf
      terraform.tfvars
      backend.tf
```

### Using Modules

```hcl
# environments/prod/main.tf
module "networking" {
  source = "../../modules/networking"

  environment   = var.environment
  location      = var.location
  project_name  = var.project_name
  address_space = ["10.0.0.0/16"]
}

module "aks" {
  source = "../../modules/aks"

  environment         = var.environment
  location            = var.location
  project_name        = var.project_name
  resource_group_name = module.networking.resource_group_name
  subnet_id           = module.networking.aks_subnet_id
  admin_group_id      = var.aks_admin_group_id
}

module "database" {
  source = "../../modules/database"

  environment         = var.environment
  location            = var.location
  project_name        = var.project_name
  resource_group_name = module.networking.resource_group_name
  subnet_id           = module.networking.data_subnet_id
  admin_password      = var.sql_admin_password
}
```

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `Error acquiring state lock` | Previous run crashed or concurrent access | Run `terraform force-unlock LOCK_ID` after confirming no other run is active |
| `Provider version constraint error` | Version conflict in required_providers | Run `terraform init -upgrade` to fetch compatible versions |
| `Resource already exists` | Resource created outside Terraform | Import with `terraform import` to bring it under management |
| `Cycle detected` in plan | Circular dependency between resources | Restructure references or use `depends_on` carefully |
| State file corruption | Concurrent writes or manual edits | Restore from state backup in the storage account versioning |
| `AuthorizationFailed` during apply | Service principal lacks RBAC permissions | Assign Contributor role on subscription or resource group |
| Plan shows unexpected changes | Drift from manual portal changes | Run `terraform refresh` then `terraform plan` to reconcile |
| Module source not found | Incorrect relative path or registry reference | Verify path in `source` attribute; run `terraform init` again |

## Related Skills

- `arm-templates` -- Azure-native IaC alternative with Bicep.
- `azure-aks` -- AKS cluster details and kubectl operations.
- `azure-networking` -- VNet and NSG design referenced in Terraform configs.
- `azure-sql` -- Database provisioning and security configurations.
- `azure-vms` -- VM sizing and scale set configurations.
