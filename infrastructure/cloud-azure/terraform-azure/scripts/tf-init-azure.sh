#!/bin/bash
# Terraform Azure Project Initialization Script
# Usage: ./tf-init-azure.sh <project-name> [location]

set -euo pipefail

PROJECT_NAME="${1:-}"
LOCATION="${2:-eastus}"

if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: $0 <project-name> [location]"
    exit 1
fi

echo "========================================="
echo "Terraform Azure Project Setup"
echo "Project: $PROJECT_NAME"
echo "Location: $LOCATION"
echo "========================================="
echo ""

mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Create main.tf
cat > main.tf << EOF
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  
  # Uncomment for remote state
  # backend "azurerm" {
  #   resource_group_name  = "${PROJECT_NAME}-tfstate-rg"
  #   storage_account_name = "${PROJECT_NAME}tfstate"
  #   container_name       = "tfstate"
  #   key                  = "terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "\${var.project_name}-\${var.environment}-rg"
  location = var.location

  tags = local.common_tags
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
EOF

# Create variables.tf
cat > variables.tf << EOF
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "${PROJECT_NAME}"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "${LOCATION}"
}
EOF

# Create outputs.tf
cat > outputs.tf << EOF
output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.main.name
}

output "location" {
  description = "Azure region"
  value       = azurerm_resource_group.main.location
}
EOF

# Create terraform.tfvars
cat > terraform.tfvars << EOF
project_name = "${PROJECT_NAME}"
environment  = "dev"
location     = "${LOCATION}"
EOF

# Create .gitignore
cat > .gitignore << EOF
.terraform/
*.tfstate
*.tfstate.*
*.tfvars.json
crash.log
*.tfplan
!terraform.tfvars.example
.idea/
*.swp
.vscode/
EOF

# Initialize Terraform
echo ""
echo "Initializing Terraform..."
terraform init

echo ""
echo "========================================="
echo "Project created successfully!"
echo "========================================="
