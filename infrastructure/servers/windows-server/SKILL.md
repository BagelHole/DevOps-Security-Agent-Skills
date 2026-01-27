---
name: windows-server
description: Administer Windows Server systems. Manage IIS, Active Directory, and PowerShell automation. Use when administering Windows infrastructure.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Windows Server Administration

Windows Server management and PowerShell automation.

## Server Roles

```powershell
# Install IIS
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

# Install AD DS
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# List installed features
Get-WindowsFeature | Where-Object Installed
```

## System Information

```powershell
Get-ComputerInfo
Get-Process
Get-Service
Get-EventLog -LogName System -Newest 50
```

## IIS Management

```powershell
# Create website
New-Website -Name "MyApp" -Port 80 -PhysicalPath "C:\inetpub\myapp"

# Create app pool
New-WebAppPool -Name "MyAppPool"

# Start/Stop
Start-Website -Name "MyApp"
Stop-Website -Name "MyApp"
```

## Best Practices

- Use Server Core when possible
- Implement Windows Admin Center
- Regular Windows Update
- PowerShell remoting over WinRM
- Active Directory best practices
