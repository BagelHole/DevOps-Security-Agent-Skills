# Azure VM Operations Reference

## VM Management

```bash
# Create VM
az vm create \
  --resource-group myRG \
  --name myVM \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --generate-ssh-keys \
  --size Standard_B2s

# Start/Stop/Delete
az vm start --resource-group myRG --name myVM
az vm stop --resource-group myRG --name myVM
az vm deallocate --resource-group myRG --name myVM
az vm delete --resource-group myRG --name myVM --yes

# List VMs
az vm list --resource-group myRG -o table
az vm list-ip-addresses --resource-group myRG -o table
```

## VM Sizes

| Size | vCPU | Memory | Use Case |
|------|------|--------|----------|
| Standard_B1s | 1 | 1 GB | Dev/Test |
| Standard_B2s | 2 | 4 GB | Light workloads |
| Standard_D2s_v3 | 2 | 8 GB | General |
| Standard_F2s_v2 | 2 | 4 GB | Compute |
| Standard_E2s_v3 | 2 | 16 GB | Memory |

```bash
# List available sizes
az vm list-sizes --location eastus -o table

# Resize VM
az vm resize --resource-group myRG --name myVM --size Standard_D4s_v3
```

## Images

```bash
# List images
az vm image list --output table
az vm image list --publisher Canonical --all --output table

# Create image from VM
az vm deallocate --resource-group myRG --name myVM
az vm generalize --resource-group myRG --name myVM
az image create --resource-group myRG --name myImage --source myVM
```

## Custom Script Extension

```bash
az vm extension set \
  --resource-group myRG \
  --vm-name myVM \
  --name customScript \
  --publisher Microsoft.Azure.Extensions \
  --settings '{"commandToExecute":"apt-get update && apt-get install -y nginx"}'
```

## Terraform

```hcl
resource "azurerm_linux_virtual_machine" "main" {
  name                = "myVM"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B2s"
  admin_username      = "azureuser"
  
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]
}
```
