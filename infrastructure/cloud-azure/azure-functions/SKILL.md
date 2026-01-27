---
name: azure-functions
description: Build serverless applications on Azure Functions. Configure triggers, bindings, and deployment. Use when implementing serverless workloads on Azure.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Azure Functions

Build serverless applications with Azure Functions.

## Create Function App

```bash
az functionapp create \
  --resource-group mygroup \
  --consumption-plan-location eastus \
  --runtime python \
  --runtime-version 3.11 \
  --functions-version 4 \
  --name myfunctionapp \
  --storage-account mystorageaccount
```

## Function Code

```python
import azure.functions as func

def main(req: func.HttpRequest) -> func.HttpResponse:
    return func.HttpResponse("Hello, World!")
```

## Deployment

```bash
# Deploy using Core Tools
func azure functionapp publish myfunctionapp

# Deploy using ZIP
az functionapp deployment source config-zip \
  --resource-group mygroup \
  --name myfunctionapp \
  --src function.zip
```

## Best Practices

- Use consumption plan for variable workloads
- Implement Durable Functions for orchestration
- Use managed identity for authentication
- Monitor with Application Insights
