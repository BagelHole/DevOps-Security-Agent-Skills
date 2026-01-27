---
name: gcp-compute
description: Manage Compute Engine instances and instance templates. Configure managed instance groups and preemptible VMs. Use when deploying compute resources on GCP.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# GCP Compute Engine

Deploy and manage Compute Engine instances.

## Create Instance

```bash
gcloud compute instances create web-server \
  --machine-type=e2-medium \
  --zone=us-central1-a \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --boot-disk-size=20GB \
  --tags=http-server

# Create from instance template
gcloud compute instance-templates create web-template \
  --machine-type=e2-medium \
  --image-family=debian-11 \
  --image-project=debian-cloud

gcloud compute instance-groups managed create web-group \
  --template=web-template \
  --size=3 \
  --zone=us-central1-a
```

## Best Practices

- Use managed instance groups
- Implement preemptible VMs for cost savings
- Use custom images for consistency
- Enable shielded VMs
