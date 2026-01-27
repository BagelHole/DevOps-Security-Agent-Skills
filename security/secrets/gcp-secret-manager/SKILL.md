---
name: gcp-secret-manager
description: Secure secrets in Google Cloud Secret Manager. Configure IAM policies, integrate with GKE, and manage secret versions. Use when managing secrets in GCP environments.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# GCP Secret Manager

Store and manage secrets securely in Google Cloud Platform.

## When to Use This Skill

Use this skill when:
- Managing secrets in GCP
- Integrating with GKE workloads
- Storing API keys and credentials
- Implementing secret rotation

## Prerequisites

- GCP project
- gcloud CLI configured
- Secret Manager API enabled

## Basic Operations

```bash
# Create secret
echo -n "secret123" | gcloud secrets create db-password --data-file=-

# Access secret
gcloud secrets versions access latest --secret=db-password

# Add new version
echo -n "newsecret" | gcloud secrets versions add db-password --data-file=-

# List secrets
gcloud secrets list
```

## Application Integration

```python
from google.cloud import secretmanager

client = secretmanager.SecretManagerServiceClient()
name = f"projects/my-project/secrets/db-password/versions/latest"
response = client.access_secret_version(request={"name": name})
secret = response.payload.data.decode("UTF-8")
```

## GKE Integration

```yaml
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: gcp-secrets
spec:
  provider: gcp
  parameters:
    secrets: |
      - resourceName: "projects/my-project/secrets/db-password/versions/latest"
        path: "db-password"
```

## Best Practices

- Use Workload Identity for GKE
- Implement IAM least-privilege
- Enable audit logging
- Use secret versions for rollback
- Integrate with Cloud KMS for encryption

## Related Skills

- [hashicorp-vault](../hashicorp-vault/) - Multi-cloud secrets
- [gcp-gke](../../../infrastructure/cloud-gcp/gcp-gke/) - GKE integration
