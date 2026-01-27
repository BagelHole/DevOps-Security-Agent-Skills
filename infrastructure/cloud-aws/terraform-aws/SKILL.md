---
name: terraform-aws
description: Provision AWS infrastructure with Terraform. Create modules, manage state, and implement IaC best practices. Use when deploying AWS resources declaratively.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Terraform AWS

Provision and manage AWS infrastructure with Terraform.

## Provider Configuration

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket = "terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
  
  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
```

## Example Resources

```hcl
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  
  tags = { Name = "main-vpc" }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public.id
  
  tags = { Name = "web-server" }
}
```

## Modules

```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  
  name = "my-vpc"
  cidr = "10.0.0.0/16"
  
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  
  enable_nat_gateway = true
}
```

## Commands

```bash
terraform init
terraform plan -out=plan.tfplan
terraform apply plan.tfplan
terraform destroy
```

## Best Practices

- Use remote state with locking
- Implement module structure
- Use workspaces or separate states per environment
- Pin provider versions
- Use data sources for AMIs

## Related Skills

- [aws-vpc](../aws-vpc/) - VPC networking
- [aws-iam](../aws-iam/) - IAM policies
