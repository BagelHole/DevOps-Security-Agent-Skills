---
name: aws-ec2
description: Manage EC2 instances, AMIs, and auto-scaling groups. Configure security groups, key pairs, and instance types. Use when deploying compute resources on AWS.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# AWS EC2

Deploy and manage Amazon EC2 compute instances.

## Launch Instance

```bash
aws ec2 run-instances \
  --image-id ami-0abcdef1234567890 \
  --instance-type t3.micro \
  --key-name my-key \
  --security-group-ids sg-12345678 \
  --subnet-id subnet-12345678 \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-server}]'
```

## Auto Scaling

```bash
# Create launch template
aws ec2 create-launch-template \
  --launch-template-name web-template \
  --version-description v1 \
  --launch-template-data '{
    "ImageId": "ami-xxx",
    "InstanceType": "t3.micro"
  }'

# Create ASG
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name web-asg \
  --launch-template LaunchTemplateName=web-template \
  --min-size 2 --max-size 10 --desired-capacity 2 \
  --vpc-zone-identifier "subnet-xxx,subnet-yyy"
```

## User Data

```bash
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
```

## Instance Management

```bash
# List instances
aws ec2 describe-instances --filters "Name=tag:Name,Values=web*"

# Stop/Start
aws ec2 stop-instances --instance-ids i-xxx
aws ec2 start-instances --instance-ids i-xxx

# Create AMI
aws ec2 create-image --instance-id i-xxx --name "my-ami"
```

## Best Practices

- Use launch templates
- Implement auto-scaling
- Use spot instances for cost savings
- Regular AMI updates
- Instance metadata service v2

## Related Skills

- [terraform-aws](../terraform-aws/) - IaC deployment
- [aws-vpc](../aws-vpc/) - Networking
