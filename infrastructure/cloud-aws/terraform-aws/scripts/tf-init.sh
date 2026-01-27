#!/bin/bash
# Terraform AWS Project Initialization Script
# Usage: ./tf-init.sh <project-name> [region]

set -euo pipefail

PROJECT_NAME="${1:-}"
REGION="${2:-us-east-1}"

if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: $0 <project-name> [region]"
    exit 1
fi

echo "========================================="
echo "Terraform AWS Project Setup"
echo "Project: $PROJECT_NAME"
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
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # Uncomment for remote state
  # backend "s3" {
  #   bucket         = "${PROJECT_NAME}-tfstate"
  #   key            = "terraform.tfstate"
  #   region         = "${REGION}"
  #   encrypt        = true
  #   dynamodb_table = "${PROJECT_NAME}-tflock"
  # }
}

provider "aws" {
  region = var.region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
EOF

# Create variables.tf
cat > variables.tf << EOF
variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "${PROJECT_NAME}"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "${REGION}"
}
EOF

# Create outputs.tf
cat > outputs.tf << EOF
output "region" {
  description = "AWS region"
  value       = var.region
}
EOF

# Create terraform.tfvars
cat > terraform.tfvars << EOF
project_name = "${PROJECT_NAME}"
environment  = "dev"
region       = "${REGION}"
EOF

# Create .gitignore
cat > .gitignore << EOF
# Terraform
.terraform/
*.tfstate
*.tfstate.*
*.tfvars.json
crash.log
*.tfplan

# Keep tfvars template
!terraform.tfvars.example

# IDE
.idea/
*.swp
*.swo
.vscode/
EOF

# Initialize Terraform
echo ""
echo "Initializing Terraform..."
terraform init

echo ""
echo "========================================="
echo "Project created successfully!"
echo ""
echo "Files created:"
ls -la
echo ""
echo "Next steps:"
echo "  1. cd $PROJECT_NAME"
echo "  2. Edit terraform.tfvars"
echo "  3. Add resources to main.tf"
echo "  4. terraform plan"
echo "  5. terraform apply"
echo "========================================="
