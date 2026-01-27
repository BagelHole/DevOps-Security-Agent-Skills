# Terraform AWS Best Practices

## Project Structure

```
project/
├── main.tf           # Main configuration
├── variables.tf      # Input variables
├── outputs.tf        # Output values
├── locals.tf         # Local values
├── data.tf           # Data sources
├── versions.tf       # Provider versions
├── terraform.tfvars  # Variable values (git-ignored)
├── modules/          # Local modules
│   └── vpc/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── environments/     # Environment configs
    ├── dev/
    ├── staging/
    └── prod/
```

## State Management

### Remote State with S3
```hcl
terraform {
  backend "s3" {
    bucket         = "company-terraform-state"
    key            = "project/env/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### State Locking
```hcl
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
```

## Security Best Practices

### Use IAM Roles, Not Credentials
```hcl
provider "aws" {
  region = "us-east-1"
  # No access_key or secret_key - use IAM role or env vars
}
```

### Enable Encryption Everywhere
```hcl
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.example.arn
    }
  }
}
```

### Use Sensitive Variables
```hcl
variable "database_password" {
  type      = string
  sensitive = true
}
```

## Tagging Strategy

```hcl
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = var.team
    CostCenter  = var.cost_center
  }
}

resource "aws_instance" "example" {
  # ... configuration ...
  
  tags = merge(local.common_tags, {
    Name = "example-instance"
    Role = "web"
  })
}
```

## Module Best Practices

### Version Pinning
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"  # Pin specific version
  
  # ... configuration ...
}
```

### Variable Validation
```hcl
variable "environment" {
  type        = string
  description = "Environment name"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

## Workflow

### Plan Before Apply
```bash
terraform plan -out=tfplan
terraform apply tfplan
```

### Use Workspaces or Directories for Environments
```bash
# Workspaces
terraform workspace new prod
terraform workspace select prod

# Or separate directories (recommended)
cd environments/prod
terraform apply
```

## Common Patterns

### Data Sources for Existing Resources
```hcl
data "aws_vpc" "existing" {
  filter {
    name   = "tag:Name"
    values = ["main-vpc"]
  }
}

resource "aws_subnet" "new" {
  vpc_id = data.aws_vpc.existing.id
  # ...
}
```

### Dynamic Blocks
```hcl
resource "aws_security_group" "example" {
  # ...
  
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}
```
