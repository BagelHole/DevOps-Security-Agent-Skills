---
name: cloudformation
description: Deploy AWS resources with CloudFormation templates. Create stacks, use nested stacks, and implement drift detection. Use when deploying AWS-native IaC.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# CloudFormation

Deploy AWS infrastructure with native CloudFormation templates.

## Template Structure

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: Web application stack

Parameters:
  Environment:
    Type: String
    AllowedValues: [dev, staging, prod]
    
Resources:
  WebServer:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: !Ref AMI
      InstanceType: t3.micro
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-web'
          
Outputs:
  InstanceId:
    Value: !Ref WebServer
    Export:
      Name: !Sub '${Environment}-WebServerId'
```

## Stack Operations

```bash
# Create stack
aws cloudformation create-stack \
  --stack-name myapp \
  --template-body file://template.yaml \
  --parameters ParameterKey=Environment,ParameterValue=prod

# Update stack
aws cloudformation update-stack \
  --stack-name myapp \
  --template-body file://template.yaml

# Delete stack
aws cloudformation delete-stack --stack-name myapp

# Detect drift
aws cloudformation detect-stack-drift --stack-name myapp
```

## Intrinsic Functions

```yaml
# Reference
!Ref MyResource

# Get attribute
!GetAtt MyResource.Arn

# Substitute
!Sub 'arn:aws:s3:::${BucketName}/*'

# Conditional
!If [CreateProdResources, 't3.large', 't3.micro']

# Join
!Join ['-', [!Ref Environment, 'app', 'bucket']]
```

## Best Practices

- Use change sets before updates
- Implement stack policies
- Use nested stacks for modularity
- Enable termination protection
- Use cfn-lint for validation

## Related Skills

- [terraform-aws](../terraform-aws/) - Alternative IaC
- [aws-iam](../aws-iam/) - IAM resources
