---
name: gcp-networking
description: Configure VPCs, firewall rules, and Cloud NAT. Implement shared VPC and private service connect. Use when designing GCP network infrastructure.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# GCP Networking

Design and implement GCP network infrastructure.

## Create VPC

```bash
gcloud compute networks create my-vpc --subnet-mode=custom

gcloud compute networks subnets create my-subnet \
  --network=my-vpc \
  --region=us-central1 \
  --range=10.0.0.0/24
```

## Firewall Rules

```bash
gcloud compute firewall-rules create allow-http \
  --network=my-vpc \
  --allow=tcp:80,tcp:443 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=http-server

gcloud compute firewall-rules create allow-internal \
  --network=my-vpc \
  --allow=tcp,udp,icmp \
  --source-ranges=10.0.0.0/8
```

## Cloud NAT

```bash
gcloud compute routers create my-router \
  --network=my-vpc \
  --region=us-central1

gcloud compute routers nats create my-nat \
  --router=my-router \
  --region=us-central1 \
  --nat-all-subnet-ip-ranges \
  --auto-allocate-nat-external-ips
```

## Best Practices

- Use Shared VPC for multi-project
- Implement Cloud Armor for DDoS
- Use Private Google Access
- Enable VPC Flow Logs
