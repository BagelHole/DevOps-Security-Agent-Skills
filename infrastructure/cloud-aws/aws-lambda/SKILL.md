---
name: aws-lambda
description: Build and deploy serverless functions on AWS Lambda. Configure triggers, manage permissions, and optimize performance. Use when implementing serverless applications.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# AWS Lambda

Build serverless applications with AWS Lambda.

## Create Function

```bash
# Create function
aws lambda create-function \
  --function-name myfunction \
  --runtime python3.11 \
  --handler app.handler \
  --role arn:aws:iam::xxx:role/lambda-role \
  --zip-file fileb://function.zip

# Update code
aws lambda update-function-code \
  --function-name myfunction \
  --zip-file fileb://function.zip
```

## Function Code

```python
# app.py
import json

def handler(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Hello!'})
    }
```

## API Gateway Integration

```bash
# Create REST API
aws apigateway create-rest-api --name myapi

# Add Lambda permission
aws lambda add-permission \
  --function-name myfunction \
  --statement-id apigateway \
  --action lambda:InvokeFunction \
  --principal apigateway.amazonaws.com
```

## Environment & Configuration

```bash
# Set environment variables
aws lambda update-function-configuration \
  --function-name myfunction \
  --environment "Variables={DB_HOST=xxx,API_KEY=yyy}"

# Set memory and timeout
aws lambda update-function-configuration \
  --function-name myfunction \
  --memory-size 256 \
  --timeout 30
```

## Best Practices

- Minimize cold starts
- Use layers for dependencies
- Implement proper error handling
- Use provisioned concurrency for latency-sensitive functions
- Monitor with CloudWatch

## Related Skills

- [terraform-aws](../terraform-aws/) - IaC deployment
- [aws-iam](../aws-iam/) - Execution roles
