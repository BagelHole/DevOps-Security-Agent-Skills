---
name: windows-hardening
description: Harden Windows servers per security baselines and CIS benchmarks. Configure Group Policy, Windows Defender, and security features. Use when securing Windows Server environments.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Windows Hardening

Secure Windows servers following Microsoft security baselines and CIS benchmarks.

## When to Use This Skill

Use this skill when:
- Hardening Windows servers
- Implementing security baselines
- Meeting compliance requirements
- Configuring Windows security features

## Security Baseline

```powershell
# Download Microsoft Security Baseline
# Apply via Group Policy or LGPO tool

# Install Security Compliance Toolkit
Install-Module -Name SecurityPolicyDsc
```

## Account Policies

```powershell
# Password policy via Group Policy
# Computer Configuration > Policies > Windows Settings > Security Settings

# PowerShell alternative
net accounts /minpwlen:14 /maxpwage:90 /minpwage:1 /uniquepw:24

# Disable Administrator account
Rename-LocalUser -Name "Administrator" -NewName "LocalAdmin"
Disable-LocalUser -Name "Guest"
```

## Windows Firewall

```powershell
# Enable firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

# Default deny
Set-NetFirewallProfile -DefaultInboundAction Block -DefaultOutboundAction Allow

# Allow specific rules
New-NetFirewallRule -DisplayName "Allow RDP" -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Allow
```

## Audit Configuration

```powershell
# Enable advanced audit policy
auditpol /set /subcategory:"Logon" /success:enable /failure:enable
auditpol /set /subcategory:"Account Lockout" /success:enable /failure:enable
auditpol /set /subcategory:"Security Group Management" /success:enable

# Enable PowerShell logging
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -Value 1
```

## Windows Defender

```powershell
# Enable real-time protection
Set-MpPreference -DisableRealtimeMonitoring $false

# Enable cloud protection
Set-MpPreference -MAPSReporting Advanced

# Configure scans
Set-MpPreference -ScanScheduleDay Everyday
Set-MpPreference -ScanScheduleTime 02:00:00
```

## Best Practices

- Apply security baselines
- Enable Windows Defender ATP
- Configure AppLocker
- Disable SMBv1
- Enable Credential Guard
- Regular Windows updates
- Implement LAPS for local admin passwords

## Related Skills

- [cis-benchmarks](../cis-benchmarks/) - Compliance scanning
- [windows-server](../../../infrastructure/servers/windows-server/) - Server administration
