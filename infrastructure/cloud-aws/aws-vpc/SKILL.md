---
name: aws-vpc
description: Design and implement VPCs and networking. Configure subnets, route tables, and security groups. Use when setting up AWS network infrastructure.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# AWS VPC

Design and manage Virtual Private Cloud networking.

## Create VPC

```bash
# Create VPC
aws ec2 create-vpc --cidr-block 10.0.0.0/16

# Create subnets
aws ec2 create-subnet \
  --vpc-id vpc-xxx \
  --cidr-block 10.0.1.0/24 \
  --availability-zone us-east-1a

# Create internet gateway
aws ec2 create-internet-gateway
aws ec2 attach-internet-gateway --vpc-id vpc-xxx --internet-gateway-id igw-xxx
```

## Network Architecture

```
VPC (10.0.0.0/16)
├── Public Subnets
│   ├── 10.0.1.0/24 (us-east-1a)
│   └── 10.0.2.0/24 (us-east-1b)
├── Private Subnets
│   ├── 10.0.11.0/24 (us-east-1a)
│   └── 10.0.12.0/24 (us-east-1b)
├── Internet Gateway
├── NAT Gateway (in public subnet)
└── Route Tables
```

## Security Groups

```bash
aws ec2 create-security-group \
  --group-name web-sg \
  --description "Web server security group" \
  --vpc-id vpc-xxx

aws ec2 authorize-security-group-ingress \
  --group-id sg-xxx \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0
```

## NAT Gateway

```bash
# Allocate EIP
aws ec2 allocate-address --domain vpc

# Create NAT Gateway
aws ec2 create-nat-gateway \
  --subnet-id subnet-public \
  --allocation-id eipalloc-xxx
```

## Best Practices

- Use multiple AZs
- Separate public/private subnets
- Implement VPC Flow Logs
- Use security groups effectively
- Plan CIDR ranges carefully

## Related Skills

- [terraform-aws](../terraform-aws/) - IaC deployment
- [firewall-config](../../../security/network/firewall-config/) - Security
