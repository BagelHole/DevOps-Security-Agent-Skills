---
name: gcp-cloud-functions
description: Deploy serverless functions on Google Cloud Functions. Configure triggers and manage deployments. Use when implementing serverless workloads on GCP.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# GCP Cloud Functions

Build serverless applications with Cloud Functions.

## Deploy Function

```bash
# Deploy HTTP function
gcloud functions deploy hello \
  --runtime=python311 \
  --trigger-http \
  --allow-unauthenticated \
  --entry-point=hello_http

# Deploy Pub/Sub triggered function
gcloud functions deploy process-message \
  --runtime=python311 \
  --trigger-topic=my-topic \
  --entry-point=process
```

## Function Code

```python
# main.py
def hello_http(request):
    return 'Hello, World!'

def process(event, context):
    import base64
    data = base64.b64decode(event['data']).decode('utf-8')
    print(f"Received: {data}")
```

## Best Practices

- Use 2nd gen functions for better performance
- Implement proper error handling
- Use environment variables for configuration
- Monitor with Cloud Logging
