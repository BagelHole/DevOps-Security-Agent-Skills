# ARM Template Syntax Reference

## Template Structure

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "environment": {
      "type": "string",
      "allowedValues": ["dev", "staging", "prod"]
    }
  },
  "variables": {
    "storageAccountName": "[concat('storage', uniqueString(resourceGroup().id))]"
  },
  "resources": [],
  "outputs": {}
}
```

## Functions

```json
// Concatenation
"[concat('prefix-', parameters('name'), '-suffix')]"

// Unique string
"[uniqueString(resourceGroup().id)]"

// Resource ID
"[resourceId('Microsoft.Storage/storageAccounts', variables('storageName'))]"

// Reference (runtime)
"[reference(resourceId('Microsoft.Storage/storageAccounts', variables('storageName'))).primaryEndpoints.blob]"

// Conditions
"[if(equals(parameters('environment'), 'prod'), 'Standard_GRS', 'Standard_LRS')]"
```

## Resource Example

```json
{
  "type": "Microsoft.Storage/storageAccounts",
  "apiVersion": "2021-09-01",
  "name": "[variables('storageAccountName')]",
  "location": "[resourceGroup().location]",
  "sku": {
    "name": "[variables('storageSku')]"
  },
  "kind": "StorageV2",
  "properties": {
    "supportsHttpsTrafficOnly": true,
    "minimumTlsVersion": "TLS1_2"
  }
}
```

## Dependencies

```json
{
  "type": "Microsoft.Web/sites",
  "dependsOn": [
    "[resourceId('Microsoft.Web/serverfarms', variables('appServicePlanName'))]"
  ]
}
```

## Deployment

```bash
# Create resource group
az group create --name myRG --location eastus

# Deploy template
az deployment group create \
  --resource-group myRG \
  --template-file template.json \
  --parameters @parameters.json

# What-if (preview changes)
az deployment group what-if \
  --resource-group myRG \
  --template-file template.json
```

## Bicep (Recommended)

```bicep
param location string = resourceGroup().location
param environment string

var storageAccountName = 'st${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: environment == 'prod' ? 'Standard_GRS' : 'Standard_LRS'
  }
  kind: 'StorageV2'
}

output storageEndpoint string = storageAccount.properties.primaryEndpoints.blob
```
