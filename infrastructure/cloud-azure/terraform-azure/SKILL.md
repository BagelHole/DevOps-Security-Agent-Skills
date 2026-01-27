---
name: terraform-azure
description: Provision Azure infrastructure with Terraform. Configure providers, manage state, and deploy resources. Use when implementing IaC for Azure.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Terraform Azure

Provision Azure infrastructure with Terraform.

## Provider Configuration

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate12345"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
```

## Example Resources

```hcl
resource "azurerm_resource_group" "main" {
  name     = "myapp-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "main" {
  name                = "myapp-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}
```

## Best Practices

- Use remote state in Azure Storage
- Implement resource naming conventions
- Use data sources for existing resources
- Tag all resources
- Use modules for reusability
