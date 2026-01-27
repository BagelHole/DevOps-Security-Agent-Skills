---
name: arm-templates
description: Deploy Azure resources with ARM templates and Bicep. Create modular deployments and manage dependencies. Use when deploying Azure-native IaC.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# ARM Templates & Bicep

Deploy Azure infrastructure with ARM templates and Bicep.

## Bicep Example

```bicep
param location string = resourceGroup().location
param vmName string

resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    osProfile: {
      computerName: vmName
      adminUsername: 'azureuser'
    }
  }
}

output vmId string = vm.id
```

## Deployment

```bash
# Deploy Bicep
az deployment group create \
  --resource-group mygroup \
  --template-file main.bicep \
  --parameters vmName=myvm

# Deploy ARM
az deployment group create \
  --resource-group mygroup \
  --template-file template.json \
  --parameters @parameters.json
```

## Best Practices

- Use Bicep over JSON ARM
- Implement modules for reusability
- Use parameter files per environment
- Validate before deployment
