---
name: aws-secrets-manager
description: Store and rotate secrets in AWS Secrets Manager. Configure automatic rotation, access policies, and application integration. Use when managing secrets in AWS environments or requiring automatic credential rotation.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# AWS Secrets Manager

Securely store, manage, and rotate secrets in AWS.

## When to Use This Skill

Use this skill when:
- Storing database credentials
- Managing API keys in AWS
- Implementing automatic secret rotation
- Integrating secrets with AWS services

## Prerequisites

- AWS account
- AWS CLI configured
- IAM permissions for Secrets Manager

## Basic Operations

```bash
# Create secret
aws secretsmanager create-secret \
  --name myapp/database \
  --secret-string '{"username":"admin","password":"secret123"}'

# Get secret
aws secretsmanager get-secret-value --secret-id myapp/database

# Update secret
aws secretsmanager put-secret-value \
  --secret-id myapp/database \
  --secret-string '{"username":"admin","password":"newpassword"}'

# Delete secret
aws secretsmanager delete-secret --secret-id myapp/database --recovery-window-in-days 7
```

## Automatic Rotation

```bash
# Enable rotation with Lambda
aws secretsmanager rotate-secret \
  --secret-id myapp/database \
  --rotation-lambda-arn arn:aws:lambda:region:account:function:rotation-function \
  --rotation-rules AutomaticallyAfterDays=30
```

## Application Integration

```python
import boto3
import json

def get_secret(secret_name):
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId=secret_name)
    return json.loads(response['SecretString'])

# Usage
creds = get_secret('myapp/database')
db_connect(creds['username'], creds['password'])
```

## Best Practices

- Enable automatic rotation
- Use resource-based policies
- Enable encryption with KMS
- Implement least-privilege access
- Use versioning for rollback

## Related Skills

- [hashicorp-vault](../hashicorp-vault/) - Multi-cloud secrets
- [aws-iam](../../../infrastructure/cloud-aws/aws-iam/) - IAM policies
