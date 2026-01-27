---
name: aws-iam
description: Manage IAM users, roles, and policies. Implement least-privilege access and security best practices. Use when configuring AWS identity and access management.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# AWS IAM

Manage identity and access in AWS.

## IAM Policies

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "s3:GetObject",
      "s3:PutObject"
    ],
    "Resource": "arn:aws:s3:::my-bucket/*"
  }]
}
```

## Create Role

```bash
# Create role with trust policy
aws iam create-role \
  --role-name EC2AppRole \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'

# Attach policy
aws iam attach-role-policy \
  --role-name EC2AppRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
```

## Service-Linked Roles

```bash
# For services like ECS, RDS
aws iam create-service-linked-role \
  --aws-service-name ecs.amazonaws.com
```

## Best Practices

```yaml
security_practices:
  - Use roles, not long-term credentials
  - Implement least privilege
  - Enable MFA
  - Regular access reviews
  - Use IAM Access Analyzer
  - Implement SCPs for organizations
```

## Policy Conditions

```json
{
  "Condition": {
    "StringEquals": {
      "aws:RequestedRegion": "us-east-1"
    },
    "Bool": {
      "aws:MultiFactorAuthPresent": "true"
    }
  }
}
```

## Best Practices

- Follow least privilege
- Use IAM roles for applications
- Enable CloudTrail for auditing
- Regular credential rotation
- Use permission boundaries

## Related Skills

- [terraform-aws](../terraform-aws/) - IaC deployment
- [access-review](../../../compliance/governance/access-review/) - Access auditing
