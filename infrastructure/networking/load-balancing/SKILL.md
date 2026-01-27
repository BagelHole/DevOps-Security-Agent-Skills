---
name: load-balancing
description: Configure load balancers and traffic distribution. Implement health checks and SSL termination. Use when distributing traffic across servers.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Load Balancing

Distribute traffic across application servers.

## nginx Load Balancer

```nginx
upstream backend {
    least_conn;
    server backend1:8080 weight=3;
    server backend2:8080;
    server backend3:8080 backup;
}

server {
    listen 80;
    
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## HAProxy

```
frontend http_front
    bind *:80
    default_backend http_back

backend http_back
    balance roundrobin
    option httpchk GET /health
    server web1 10.0.0.1:8080 check
    server web2 10.0.0.2:8080 check
```

## AWS ALB

```bash
aws elbv2 create-load-balancer \
  --name my-alb \
  --subnets subnet-xxx subnet-yyy \
  --security-groups sg-xxx \
  --type application
```

## Best Practices

- Implement health checks
- Use sticky sessions when needed
- Enable connection draining
- Monitor backend health
