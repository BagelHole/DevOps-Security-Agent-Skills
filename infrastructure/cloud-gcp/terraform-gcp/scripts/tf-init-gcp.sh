#!/bin/bash
# Terraform GCP Project Initialization Script
# Usage: ./tf-init-gcp.sh <project-name> <gcp-project-id> [region]

set -euo pipefail

PROJECT_NAME="${1:-}"
GCP_PROJECT="${2:-}"
REGION="${3:-us-central1}"

if [ -z "$PROJECT_NAME" ] || [ -z "$GCP_PROJECT" ]; then
    echo "Usage: $0 <project-name> <gcp-project-id> [region]"
    exit 1
fi

echo "========================================="
echo "Terraform GCP Project Setup"
echo "Project: $PROJECT_NAME"
echo "GCP Project: $GCP_PROJECT"
echo "Region: $REGION"
echo "========================================="
echo ""

mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Create main.tf
cat > main.tf << EOF
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  
  # Uncomment for remote state
  # backend "gcs" {
  #   bucket = "${PROJECT_NAME}-tfstate"
  #   prefix = "terraform/state"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  common_labels = {
    project     = var.project_name
    environment = var.environment
    managed-by  = "terraform"
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

variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "${GCP_PROJECT}"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "${REGION}"
}
EOF

# Create outputs.tf
cat > outputs.tf << EOF
output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "region" {
  description = "GCP region"
  value       = var.region
}
EOF

# Create terraform.tfvars
cat > terraform.tfvars << EOF
project_name = "${PROJECT_NAME}"
project_id   = "${GCP_PROJECT}"
environment  = "dev"
region       = "${REGION}"
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
