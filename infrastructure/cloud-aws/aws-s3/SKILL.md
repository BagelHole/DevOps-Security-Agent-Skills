---
name: aws-s3
description: Configure S3 buckets, policies, and lifecycle rules. Implement versioning, replication, and security. Use when managing object storage on AWS.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# AWS S3

Manage object storage with Amazon S3.

## Create Bucket

```bash
aws s3api create-bucket \
  --bucket my-bucket \
  --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket my-bucket \
  --versioning-configuration Status=Enabled

# Block public access
aws s3api put-public-access-block \
  --bucket my-bucket \
  --public-access-block-configuration '{
    "BlockPublicAcls": true,
    "IgnorePublicAcls": true,
    "BlockPublicPolicy": true,
    "RestrictPublicBuckets": true
  }'
```

## Bucket Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "EnforceHTTPS",
    "Effect": "Deny",
    "Principal": "*",
    "Action": "s3:*",
    "Resource": [
      "arn:aws:s3:::my-bucket",
      "arn:aws:s3:::my-bucket/*"
    ],
    "Condition": {
      "Bool": {"aws:SecureTransport": "false"}
    }
  }]
}
```

## Lifecycle Rules

```bash
aws s3api put-bucket-lifecycle-configuration \
  --bucket my-bucket \
  --lifecycle-configuration '{
    "Rules": [{
      "ID": "Archive old objects",
      "Status": "Enabled",
      "Filter": {"Prefix": "logs/"},
      "Transitions": [{
        "Days": 30,
        "StorageClass": "GLACIER"
      }],
      "Expiration": {"Days": 365}
    }]
  }'
```

## Best Practices

- Enable versioning
- Block public access
- Use encryption (SSE-S3 or SSE-KMS)
- Implement lifecycle policies
- Enable access logging

## Related Skills

- [terraform-aws](../terraform-aws/) - IaC deployment
- [aws-iam](../aws-iam/) - Access policies
