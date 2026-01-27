# AWS Secrets Manager Patterns

## Basic Operations

```bash
# Create secret
aws secretsmanager create-secret \
  --name myapp/database \
  --secret-string '{"username":"admin","password":"secret123"}'

# Get secret
aws secretsmanager get-secret-value --secret-id myapp/database

# Update secret
aws secretsmanager update-secret \
  --secret-id myapp/database \
  --secret-string '{"username":"admin","password":"newsecret"}'

# Delete secret
aws secretsmanager delete-secret --secret-id myapp/database --force-delete-without-recovery
```

## Automatic Rotation

```python
# Lambda rotation function
def lambda_handler(event, context):
    secret_id = event['SecretId']
    token = event['ClientRequestToken']
    step = event['Step']
    
    if step == "createSecret":
        create_secret(secret_id, token)
    elif step == "setSecret":
        set_secret(secret_id, token)
    elif step == "testSecret":
        test_secret(secret_id, token)
    elif step == "finishSecret":
        finish_secret(secret_id, token)
```

## Terraform

```hcl
resource "aws_secretsmanager_secret" "db" {
  name = "myapp/database"
  
  tags = {
    Environment = "production"
  }
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.db.result
  })
}

# Rotation
resource "aws_secretsmanager_secret_rotation" "db" {
  secret_id           = aws_secretsmanager_secret.db.id
  rotation_lambda_arn = aws_lambda_function.rotation.arn
  
  rotation_rules {
    automatically_after_days = 30
  }
}
```

## Application Integration

### Python (boto3)
```python
import boto3
import json

def get_secret(secret_name):
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId=secret_name)
    return json.loads(response['SecretString'])

# Usage
creds = get_secret('myapp/database')
connection = connect(
    host=creds['host'],
    user=creds['username'],
    password=creds['password']
)
```

### ECS Task Definition
```json
{
  "containerDefinitions": [{
    "secrets": [{
      "name": "DATABASE_PASSWORD",
      "valueFrom": "arn:aws:secretsmanager:us-east-1:123456789:secret:myapp/database:password::"
    }]
  }]
}
```

### Lambda
```yaml
# SAM template
Environment:
  Variables:
    SECRET_ARN: !Ref DatabaseSecret
    
Policies:
  - AWSSecretsManagerGetSecretValuePolicy:
      SecretArn: !Ref DatabaseSecret
```
