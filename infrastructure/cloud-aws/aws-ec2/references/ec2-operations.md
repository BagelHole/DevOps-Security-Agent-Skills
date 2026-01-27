# EC2 Operations Reference

## Instance Management

```bash
# Launch instance
aws ec2 run-instances \
  --image-id ami-12345678 \
  --instance-type t3.micro \
  --key-name mykey \
  --security-group-ids sg-12345678 \
  --subnet-id subnet-12345678

# Start/Stop/Terminate
aws ec2 start-instances --instance-ids i-12345678
aws ec2 stop-instances --instance-ids i-12345678
aws ec2 terminate-instances --instance-ids i-12345678

# Describe instances
aws ec2 describe-instances \
  --filters "Name=tag:Environment,Values=prod"
```

## AMI Management

```bash
# Create AMI from instance
aws ec2 create-image \
  --instance-id i-12345678 \
  --name "MyApp-$(date +%Y%m%d)"

# Copy AMI to another region
aws ec2 copy-image \
  --source-image-id ami-12345678 \
  --source-region us-east-1 \
  --region us-west-2 \
  --name "MyApp-copy"
```

## Instance Types

| Type | vCPU | Memory | Use Case |
|------|------|--------|----------|
| t3.micro | 2 | 1 GB | Dev/Test |
| t3.small | 2 | 2 GB | Light apps |
| m5.large | 2 | 8 GB | General |
| c5.large | 2 | 4 GB | Compute |
| r5.large | 2 | 16 GB | Memory |

## User Data

```bash
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "Hello World" > /var/www/html/index.html
```

## Instance Metadata

```bash
# IMDSv2
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/

# Common endpoints
/latest/meta-data/instance-id
/latest/meta-data/local-ipv4
/latest/meta-data/public-ipv4
/latest/meta-data/iam/security-credentials/role-name
```

## Terraform

```hcl
resource "aws_instance" "app" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  
  vpc_security_group_ids = [aws_security_group.app.id]
  subnet_id              = aws_subnet.private.id
  
  iam_instance_profile = aws_iam_instance_profile.app.name
  
  user_data = base64encode(file("userdata.sh"))
  
  root_block_device {
    volume_size = 20
    encrypted   = true
  }
  
  tags = {
    Name = "app-server"
  }
}
```
