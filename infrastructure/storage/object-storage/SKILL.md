---
name: object-storage
description: Configure object storage with S3, GCS, and MinIO. Implement lifecycle policies and access controls. Use when managing object storage.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Object Storage

Configure and manage object storage solutions.

## AWS S3

```bash
# Create bucket
aws s3 mb s3://my-bucket

# Upload/Download
aws s3 cp file.txt s3://my-bucket/
aws s3 sync ./local s3://my-bucket/remote

# Configure lifecycle
aws s3api put-bucket-lifecycle-configuration \
  --bucket my-bucket \
  --lifecycle-configuration file://lifecycle.json
```

## MinIO (Self-Hosted)

```bash
# Deploy
docker run -d \
  -p 9000:9000 -p 9001:9001 \
  -e MINIO_ROOT_USER=admin \
  -e MINIO_ROOT_PASSWORD=password \
  -v /data:/data \
  minio/minio server /data --console-address ":9001"

# Configure mc client
mc alias set myminio http://localhost:9000 admin password
mc mb myminio/mybucket
```

## Best Practices

- Enable versioning
- Implement lifecycle policies
- Use server-side encryption
- Configure access logging
- Implement bucket policies
