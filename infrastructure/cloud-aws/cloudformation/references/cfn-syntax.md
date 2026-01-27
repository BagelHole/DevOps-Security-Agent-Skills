# CloudFormation Syntax Reference

## Template Structure

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: My CloudFormation Template

Parameters:
  Environment:
    Type: String
    AllowedValues: [dev, staging, prod]

Mappings:
  RegionMap:
    us-east-1:
      AMI: ami-12345678

Conditions:
  IsProd: !Equals [!Ref Environment, prod]

Resources:
  MyBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub '${AWS::StackName}-bucket'

Outputs:
  BucketName:
    Value: !Ref MyBucket
    Export:
      Name: !Sub '${AWS::StackName}-bucket'
```

## Intrinsic Functions

```yaml
# Reference
!Ref MyResource

# GetAtt
!GetAtt MyResource.Arn

# Sub (string substitution)
!Sub '${AWS::StackName}-resource'
!Sub 
  - 'arn:aws:s3:::${Bucket}/*'
  - Bucket: !Ref MyBucket

# Join
!Join ['-', [!Ref Environment, app]]

# Select
!Select [0, !GetAZs '']

# Split
!Split [',', 'a,b,c']

# If
!If [IsProd, 3, 1]

# ImportValue
!ImportValue ExportedValue
```

## Common Patterns

### Cross-Stack References
```yaml
# Stack A - Export
Outputs:
  VpcId:
    Value: !Ref VPC
    Export:
      Name: SharedVPC

# Stack B - Import
Resources:
  Subnet:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !ImportValue SharedVPC
```

### Nested Stacks
```yaml
Resources:
  VPCStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: https://s3.amazonaws.com/bucket/vpc.yaml
      Parameters:
        Environment: !Ref Environment
```

### DependsOn
```yaml
Resources:
  MyInstance:
    Type: AWS::EC2::Instance
    DependsOn: MySecurityGroup
```

## CLI Commands

```bash
# Create stack
aws cloudformation create-stack \
  --stack-name mystack \
  --template-body file://template.yaml \
  --parameters ParameterKey=Environment,ParameterValue=prod

# Update stack
aws cloudformation update-stack \
  --stack-name mystack \
  --template-body file://template.yaml

# Delete stack
aws cloudformation delete-stack --stack-name mystack

# Validate template
aws cloudformation validate-template --template-body file://template.yaml
```
