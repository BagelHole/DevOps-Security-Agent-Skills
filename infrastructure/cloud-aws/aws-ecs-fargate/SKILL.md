---
name: aws-ecs-fargate
description: Deploy containers on ECS and Fargate. Configure task definitions, services, and load balancing. Use when running containerized workloads on AWS.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# AWS ECS & Fargate

Run containerized applications on Amazon ECS with Fargate.

## Task Definition

```json
{
  "family": "myapp",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::xxx:role/ecsTaskExecutionRole",
  "containerDefinitions": [{
    "name": "myapp",
    "image": "xxx.dkr.ecr.region.amazonaws.com/myapp:latest",
    "portMappings": [{
      "containerPort": 8080,
      "protocol": "tcp"
    }],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/myapp",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }]
}
```

## Create Service

```bash
aws ecs create-service \
  --cluster my-cluster \
  --service-name myapp \
  --task-definition myapp:1 \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration '{
    "awsvpcConfiguration": {
      "subnets": ["subnet-xxx"],
      "securityGroups": ["sg-xxx"],
      "assignPublicIp": "ENABLED"
    }
  }' \
  --load-balancers '[{
    "targetGroupArn": "arn:aws:elasticloadbalancing:...",
    "containerName": "myapp",
    "containerPort": 8080
  }]'
```

## Deployment

```bash
# Update service
aws ecs update-service \
  --cluster my-cluster \
  --service myapp \
  --task-definition myapp:2 \
  --force-new-deployment
```

## Best Practices

- Use ECR for images
- Implement service discovery
- Configure health checks
- Use secrets manager for secrets
- Enable container insights

## Related Skills

- [docker-management](../../../devops/containers/docker-management/) - Container basics
- [container-registries](../../../devops/containers/container-registries/) - ECR
