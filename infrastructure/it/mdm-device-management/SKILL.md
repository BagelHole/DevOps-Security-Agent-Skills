---
name: mdm-device-management
description: Manage and secure company devices with MDM solutions — enroll macOS, Windows, iOS, and Android devices, enforce security policies, and automate software deployment. Use when setting up device management for a growing team.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Mobile Device Management (MDM) for Startups & Small Teams

A practical guide to enrolling, securing, and managing company devices across
macOS, Windows, iOS, and Android — from zero-touch onboarding to remote wipe.

---

## 1. When to Use MDM

MDM becomes essential when any of the following apply:

- **Team size crosses ~10 people** — manual laptop setup no longer scales.
- **Compliance requirements** — SOC 2, HIPAA, ISO 27001, or customer security
  questionnaires demand proof that endpoints are encrypted and patched.
- **Remote / hybrid workforce** — you cannot walk over to someone's desk to
  fix a configuration or verify disk encryption.
- **Contractor or BYOD devices** — you need a way to separate corporate data
  from personal data and revoke access on offboarding.
- **Insurance or investor due diligence** — cyber-insurance carriers and VCs
  increasingly ask for evidence of endpoint management.

If you are still under 10 people and everyone is in-office, a simple checklist
plus a configuration management tool (Ansible) may suffice — but plan for MDM
early so enrollment is painless when you scale.

---

## 2. MDM Platform Comparison

| Platform | Best For | Pricing Model | Open Source | Key Strength |
|----------|----------|---------------|-------------|--------------|
| **Jamf Pro** | macOS / iOS fleets | Per-device/yr | No | Deepest Apple integration, DEP/ADE native |
| **Microsoft Intune** | Windows + M365 shops | Bundled w/ M365 E3/E5 | No | Seamless Azure AD + Autopilot |
| **Kandji** | macOS-first startups | Per-device/yr | No | Pre-built compliance templates, fast setup |
| **Mosyle** | Education & SMB Apple | Per-device/yr | No | Apple School/Business Manager integration |
| **Fleet** | Cross-platform, eng-led | Free (OSS) / paid cloud | Yes | osquery-powered, GitOps-friendly, API-first |
| **SimpleMDM** | Small Apple-only teams | Per-device/mo | No | Simple UI, quick onboarding |

### Decision heuristic

```text
if (team < 50 AND engineering-led AND multi-OS):
    consider Fleet (open-source, osquery-native)
elif (team is macOS-dominant AND compliance-heavy):
    consider Kandji or Jamf
elif (team is Windows-dominant AND already on M365):
    consider Intune (likely already licensed)
else:
    evaluate Fleet or Kandji based on OS mix
```

---

## 3. Fleet (Open Source MDM) — Self-Hosted Deployment

Fleet is the leading open-source MDM. It uses osquery under the hood and
supports macOS, Windows, Linux, iOS, and Android.

### 3.1 Docker Compose deployment

```yaml
# docker-compose.yml
version: "3.8"

services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: "${FLEET_MYSQL_ROOT_PASSWORD}"
      MYSQL_DATABASE: fleet
      MYSQL_USER: fleet
      MYSQL_PASSWORD: "${FLEET_MYSQL_PASSWORD}"
    volumes:
      - mysql-data:/var/lib/mysql
    ports:
      - "3306:3306"
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  fleet:
    image: fleetdm/fleet:v4.47.0
    depends_on:
      mysql:
        condition: service_healthy
      redis:
        condition: service_started
    environment:
      FLEET_MYSQL_ADDRESS: mysql:3306
      FLEET_MYSQL_DATABASE: fleet
      FLEET_MYSQL_USERNAME: fleet
      FLEET_MYSQL_PASSWORD: "${FLEET_MYSQL_PASSWORD}"
      FLEET_REDIS_ADDRESS: redis:6379
      FLEET_SERVER_TLS: "true"
      FLEET_SERVER_TLS_COMPATIBILITY: modern
      FLEET_SERVER_CERT: /tls/fleet.crt
      FLEET_SERVER_KEY: /tls/fleet.key
      FLEET_LOGGING_JSON: "true"
    volumes:
      - ./tls:/tls:ro
    ports:
      - "8080:8080"

volumes:
  mysql-data:
```

### 3.2 Initial setup

```bash
# Generate TLS certs (use real certs in production)
mkdir -p tls
openssl req -x509 -newkey rsa:4096 -sha256 -days 365 \
  -nodes -keyout tls/fleet.key -out tls/fleet.crt \
  -subj "/CN=fleet.yourcompany.com"

# Start services
docker compose up -d

# Create admin account
docker compose exec fleet fleet prepare db
docker compose exec fleet fleet setup \
  --email admin@yourcompany.com \
  --name "IT Admin" \
  --password "${FLEET_ADMIN_PASSWORD}" \
  --org-name "YourCompany"
```

### 3.3 Enroll a macOS host with fleetctl

```bash
# Install fleetctl
brew install fleetdm/tap/fleetctl

# Authenticate
fleetctl config set --address https://fleet.yourcompany.com:8080
fleetctl login --email admin@yourcompany.com

# Generate an installer package for macOS
fleetctl package --type pkg \
  --fleet-url https://fleet.yourcompany.com:8080 \
  --enroll-secret "$(fleetctl get enroll-secret)" \
  --fleet-certificate tls/fleet.crt

# The .pkg file can be distributed via Apple Business Manager or manually
```

### 3.4 Enroll a Windows host

```powershell
# Download the Fleet osquery MSI installer
fleetctl package --type msi `
  --fleet-url https://fleet.yourcompany.com:8080 `
  --enroll-secret "$(fleetctl get enroll-secret)" `
  --fleet-certificate tls/fleet.crt

# Install silently
msiexec /i fleet-osquery.msi /quiet /norestart
```

### 3.5 osquery policy examples in Fleet

```yaml
# fleet-policies.yml — apply with: fleetctl apply -f fleet-policies.yml
apiVersion: v1
kind: policy
spec:
  name: FileVault enabled (macOS)
  query: >
    SELECT 1 FROM disk_encryption
    WHERE user_uuid IS NOT '' AND encrypted = 1;
  description: Ensures FileVault disk encryption is enabled.
  resolution: "Enable FileVault: System Settings > Privacy & Security > FileVault."
  platform: darwin

---
apiVersion: v1
kind: policy
spec:
  name: BitLocker enabled (Windows)
  query: >
    SELECT 1 FROM bitlocker_info
    WHERE protection_status = 1;
  description: Ensures BitLocker drive encryption is active.
  resolution: "Enable BitLocker via Settings > Privacy & Security > Device Encryption."
  platform: windows

---
apiVersion: v1
kind: policy
spec:
  name: Firewall enabled (macOS)
  query: >
    SELECT 1 FROM alf WHERE global_state >= 1;
  description: macOS Application Layer Firewall must be on.
  resolution: "Enable firewall: System Settings > Network > Firewall."
  platform: darwin

---
apiVersion: v1
kind: policy
spec:
  name: OS up to date (macOS)
  query: >
    SELECT 1 FROM os_version
    WHERE platform = 'darwin' AND major >= 14;
  description: Requires macOS 14 (Sonoma) or later.
  resolution: "Update macOS via System Settings > General > Software Update."
  platform: darwin
```

---

## 4. macOS Enrollment

### 4.1 Apple Business Manager (ABM) / Automated Device Enrollment

```bash
# In ABM (business.apple.com):
# 1. Settings > MDM Servers > Add MDM Server
# 2. Upload the public key from your MDM (Fleet, Jamf, Kandji)
# 3. Download the ABM token and upload it to your MDM
# 4. Assign devices to the MDM server by serial number

# Verify DEP assignment with fleetctl (Fleet)
fleetctl get mdm-apple
```

### 4.2 Manual MDM profile enrollment (non-DEP devices)

```bash
# Generate enrollment profile URL (Fleet example)
fleetctl get enrollment-profile > enrollment.mobileconfig

# Distribute to user — they open the .mobileconfig file
# Then approve in System Settings > Profiles
```

### 4.3 Enforce FileVault via MDM configuration profile

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>PayloadContent</key>
    <array>
        <dict>
            <key>PayloadType</key>
            <string>com.apple.MCX.FileVault2</string>
            <key>PayloadIdentifier</key>
            <string>com.yourcompany.filevault</string>
            <key>PayloadUUID</key>
            <string>A1B2C3D4-E5F6-7890-ABCD-EF1234567890</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
            <key>Enable</key>
            <string>On</string>
            <key>Defer</key>
            <true/>
            <key>DeferForceAtUserLoginMaxBypassAttempts</key>
            <integer>0</integer>
            <key>ShowRecoveryKey</key>
            <false/>
            <key>UseRecoveryKey</key>
            <true/>
        </dict>
    </array>
    <key>PayloadDisplayName</key>
    <string>FileVault Enforcement</string>
    <key>PayloadIdentifier</key>
    <string>com.yourcompany.filevault.profile</string>
    <key>PayloadType</key>
    <string>Configuration</string>
    <key>PayloadUUID</key>
    <string>F1E2D3C4-B5A6-7890-FEDC-BA0987654321</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
</dict>
</plist>
```

### 4.4 macOS firewall enforcement

```bash
# Enable firewall via MDM command or script
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned enable
```

---

## 5. Windows Enrollment

### 5.1 Azure AD Join + Intune auto-enrollment

```powershell
# Check current join status
dsregcmd /status

# Join Azure AD (user will be prompted for credentials)
Start-Process "ms-settings:workplace"

# Verify Intune enrollment
Get-WmiObject -Namespace "root\cimv2\mdm\dmmap" `
  -Class "MDM_DevDetail_Ext01" | Select DeviceID
```

### 5.2 Windows Autopilot hardware hash collection

```powershell
# Collect hardware hash for Autopilot registration
Install-Script -Name Get-WindowsAutoPilotInfo -Force
Get-WindowsAutoPilotInfo -OutputFile C:\temp\autopilot.csv

# Upload autopilot.csv to Intune > Devices > Windows Enrollment > Devices
```

### 5.3 BitLocker enforcement via Group Policy or Intune

```powershell
# Enable BitLocker on the OS drive with TPM
Enable-BitLocker -MountPoint "C:" `
  -EncryptionMethod XtsAes256 `
  -TpmProtector

# Add a recovery password and back it up to Azure AD
Add-BitLockerKeyProtector -MountPoint "C:" -RecoveryPasswordProtector
BackupToAAD-BitLockerKeyProtector -MountPoint "C:" `
  -KeyProtectorId (Get-BitLockerVolume -MountPoint "C:").KeyProtector[1].KeyProtectorId

# Verify encryption status
Get-BitLockerVolume | Select-Object MountPoint, VolumeStatus, EncryptionPercentage
```

### 5.4 Windows Firewall baseline

```powershell
# Ensure all profiles are enabled
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

# Block all inbound by default, allow outbound
Set-NetFirewallProfile -Profile Domain,Public,Private `
  -DefaultInboundAction Block `
  -DefaultOutboundAction Allow

# Allow specific inbound rules (example: RDP only from VPN subnet)
New-NetFirewallRule -DisplayName "Allow RDP from VPN" `
  -Direction Inbound -Protocol TCP -LocalPort 3389 `
  -RemoteAddress 10.0.0.0/8 -Action Allow
```

---

## 6. Security Policies — Cross-Platform

### 6.1 Password / passcode requirements

```xml
<!-- macOS configuration profile — password policy -->
<dict>
    <key>PayloadType</key>
    <string>com.apple.mobiledevice.passwordpolicy</string>
    <key>minLength</key>
    <integer>12</integer>
    <key>requireAlphanumeric</key>
    <true/>
    <key>maxInactivity</key>
    <integer>5</integer>
    <key>maxPINAgeInDays</key>
    <integer>90</integer>
</dict>
```

```json
// Intune Windows password policy (JSON for Graph API)
{
  "@odata.type": "#microsoft.graph.windows10GeneralConfiguration",
  "passwordRequired": true,
  "passwordMinimumLength": 12,
  "passwordRequiredType": "alphanumeric",
  "passwordMinutesOfInactivityBeforeScreenTimeout": 5,
  "passwordExpirationDays": 90,
  "passwordBlockSimple": true
}
```

### 6.2 Screen lock enforcement

```bash
# macOS — require password after sleep/screensaver (via script or profile)
sudo defaults write /Library/Preferences/com.apple.screensaver askForPassword -int 1
sudo defaults write /Library/Preferences/com.apple.screensaver askForPasswordDelay -int 0
sudo defaults write /Library/Preferences/com.apple.screensaver idleTime -int 300
```

```powershell
# Windows — lock screen after 5 minutes of inactivity
powercfg /change monitor-timeout-ac 5
# Registry-based enforcement
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
  -Name "InactivityTimeoutSecs" -Value 300
```

### 6.3 Encryption enforcement summary

| OS | Tool | Verify Command |
|----|------|----------------|
| macOS | FileVault | `fdesetup status` |
| Windows | BitLocker | `manage-bde -status C:` |
| Linux | LUKS | `lsblk -o NAME,FSTYPE,MOUNTPOINT \| grep crypt` |
| iOS | Native (always-on with passcode) | Managed via MDM profile |
| Android | Native | `adb shell getprop ro.crypto.state` |

---

## 7. Software Deployment

### 7.1 macOS — Homebrew Bundle

```ruby
# Brewfile — deploy via MDM script or Git checkout
tap "homebrew/bundle"

# Core tools
brew "git"
brew "gh"
brew "jq"
brew "wget"
brew "gnupg"

# Security
brew "1password-cli"
cask "1password"
cask "tailscale"
cask "cloudflare-warp"

# Development
cask "visual-studio-code"
cask "iterm2"
cask "docker"
brew "node"
brew "python@3.12"

# Communication
cask "slack"
cask "zoom"
```

```bash
# Deploy Brewfile on a new Mac
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle --file=/path/to/Brewfile --no-lock
```

### 7.2 Windows — winget / Chocolatey

```powershell
# winget import from a JSON manifest
# packages.json
@"
{
  "Sources": [{
    "Packages": [
      { "PackageIdentifier": "Git.Git" },
      { "PackageIdentifier": "Microsoft.VisualStudioCode" },
      { "PackageIdentifier": "Docker.DockerDesktop" },
      { "PackageIdentifier": "SlackTechnologies.Slack" },
      { "PackageIdentifier": "Zoom.Zoom" },
      { "PackageIdentifier": "Tailscale.Tailscale" },
      { "PackageIdentifier": "AgileBits.1Password" },
      { "PackageIdentifier": "OpenJS.NodeJS.LTS" },
      { "PackageIdentifier": "Python.Python.3.12" }
    ],
    "SourceDetails": {
      "Name": "winget",
      "Type": "Microsoft.Winget.Source.Type.Microsoft"
    }
  }]
}
"@ | Out-File -FilePath packages.json -Encoding utf8

winget import -i packages.json --accept-package-agreements --accept-source-agreements
```

### 7.3 Automatic update enforcement

```bash
# macOS — enable automatic updates via MDM or command
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool true
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool true
sudo softwareupdate --schedule on
```

```powershell
# Windows — configure Windows Update via registry
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" `
  -Name "NoAutoUpdate" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" `
  -Name "AUOptions" -Value 4  # 4 = Auto download and schedule install
```

---

## 8. Compliance Checks with osquery

These queries work with Fleet, osquery standalone, or any osquery-compatible
platform.

```sql
-- Check disk encryption on macOS
SELECT de.encrypted, de.type, du.username
FROM disk_encryption de
JOIN disk_util du ON de.name = du.name
WHERE du.mountpoint = '/' AND de.encrypted = 1;

-- Check disk encryption on Windows
SELECT drive_letter, protection_status, conversion_status
FROM bitlocker_info
WHERE drive_letter = 'C:' AND protection_status = 1;

-- Verify firewall is enabled (macOS)
SELECT global_state, stealth_enabled, logging_enabled
FROM alf;

-- Verify firewall is enabled (Windows)
SELECT name, enabled FROM windows_firewall_profiles
WHERE enabled = 1;

-- Check OS version (macOS)
SELECT name, version, major, minor, patch
FROM os_version
WHERE major >= 14;

-- Check OS version (Windows)
SELECT name, version, build
FROM os_version
WHERE build >= '22631';

-- List users with admin privileges (macOS)
SELECT u.username, u.uid
FROM users u
JOIN user_groups ug ON u.uid = ug.uid
JOIN groups g ON ug.gid = g.gid
WHERE g.groupname = 'admin';

-- Detect unencrypted removable drives (Windows)
SELECT device_id, drive_letter, protection_status
FROM bitlocker_info
WHERE protection_status = 0;

-- Check screen lock timeout (macOS)
SELECT domain, key, value FROM preferences
WHERE domain = 'com.apple.screensaver'
  AND key = 'idleTime';

-- Verify automatic updates are enabled (macOS)
SELECT domain, key, value FROM preferences
WHERE domain = 'com.apple.SoftwareUpdate'
  AND key = 'AutomaticCheckEnabled';
```

---

## 9. Remote Wipe & Lock

### 9.1 macOS remote wipe (Fleet)

```bash
# Lock a device immediately with a 6-digit PIN
fleetctl mdm lock --host "serial=C02X12345678"

# Wipe a device (factory reset) — DESTRUCTIVE
fleetctl mdm erase --host "serial=C02X12345678"

# Or via the Fleet API
curl -X POST https://fleet.yourcompany.com/api/v1/fleet/hosts/42/wipe \
  -H "Authorization: Bearer ${FLEET_API_TOKEN}"
```

### 9.2 Windows remote wipe (Intune)

```powershell
# Via Microsoft Graph API
$body = @{
    keepEnrollmentData = $false
    keepUserData       = $false
} | ConvertTo-Json

Invoke-MgGraphRequest -Method POST `
  -Uri "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/{deviceId}/wipe" `
  -Body $body -ContentType "application/json"
```

### 9.3 Lost device runbook

```text
1. Employee reports device lost/stolen via Slack #it-help or PagerDuty.
2. IT admin verifies identity (video call or manager confirmation).
3. Immediately issue remote lock command (wipe only if data-sensitive).
4. Rotate any credentials cached on the device:
   - Revoke SSO sessions (Okta/Google Workspace admin console)
   - Rotate API keys stored on the device
   - Revoke VPN certificates
5. File a police report if theft is suspected.
6. Remove device from MDM after 30 days or once replacement is shipped.
7. Update asset inventory and notify finance for insurance claim.
```

---

## 10. Onboarding Automation — Zero-Touch Enrollment

### 10.1 macOS zero-touch flow

```bash
#!/usr/bin/env bash
# onboard-mac.sh — runs as a post-enrollment script via MDM
set -euo pipefail

LOG="/var/log/onboarding.log"
exec > >(tee -a "$LOG") 2>&1

echo "=== Starting onboarding $(date) ==="

# 1. Install Rosetta 2 on Apple Silicon
if [[ "$(uname -m)" == "arm64" ]]; then
    softwareupdate --install-rosetta --agree-to-license
fi

# 2. Install Homebrew
if ! command -v brew &>/dev/null; then
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 3. Install standard tooling from Brewfile
curl -fsSL https://internal.yourcompany.com/brewfile -o /tmp/Brewfile
brew bundle --file=/tmp/Brewfile --no-lock

# 4. Configure Git defaults
git config --global init.defaultBranch main
git config --global pull.rebase true

# 5. Enable FileVault (will prompt at next login)
sudo fdesetup enable -defer /var/db/FileVaultDeferred.plist \
  -forceatlogin 0 -dontaskatlogout

# 6. Enable firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

# 7. Set screen lock
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
defaults write com.apple.screensaver idleTime -int 300

# 8. Enroll in Tailscale VPN
open -a "Tailscale"

echo "=== Onboarding complete $(date) ==="
```

### 10.2 Windows zero-touch flow (Autopilot + Intune)

```powershell
# deploy.ps1 — assigned as an Intune PowerShell script
$ErrorActionPreference = "Stop"
$logFile = "C:\ProgramData\onboarding.log"
Start-Transcript -Path $logFile -Append

Write-Host "=== Starting onboarding $(Get-Date) ==="

# 1. Install winget packages
$packages = @(
    "Git.Git",
    "Microsoft.VisualStudioCode",
    "Docker.DockerDesktop",
    "SlackTechnologies.Slack",
    "Tailscale.Tailscale",
    "AgileBits.1Password"
)

foreach ($pkg in $packages) {
    Write-Host "Installing $pkg..."
    winget install --id $pkg --accept-package-agreements --accept-source-agreements --silent
}

# 2. Enable BitLocker
Enable-BitLocker -MountPoint "C:" -EncryptionMethod XtsAes256 -TpmProtector
Add-BitLockerKeyProtector -MountPoint "C:" -RecoveryPasswordProtector

# 3. Configure firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
Set-NetFirewallProfile -Profile Domain,Public,Private `
  -DefaultInboundAction Block -DefaultOutboundAction Allow

# 4. Set power and lock settings
powercfg /change monitor-timeout-ac 5
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
  -Name "InactivityTimeoutSecs" -Value 300

# 5. Enable automatic updates
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" `
  -Name "AUOptions" -Value 4

Write-Host "=== Onboarding complete $(Get-Date) ==="
Stop-Transcript
```

### 10.3 Onboarding checklist (for IT automation)

```yaml
# onboarding-checklist.yml — track in your ticketing system or Fleet
new_hire_onboarding:
  pre_day_one:
    - Purchase and ship device via CDW/Apple Business Manager
    - Assign device to MDM server in ABM/Autopilot
    - Create accounts: Google Workspace / M365, Okta SSO, GitHub, Slack
    - Generate VPN invite (Tailscale, WireGuard)
    - Prepare welcome documentation link

  day_one_automated:
    - Device powers on and auto-enrolls in MDM (zero-touch)
    - MDM pushes security profiles (encryption, firewall, password policy)
    - Software bundle installs automatically
    - User signs into SSO — all apps authenticate via SAML/OIDC
    - Compliance policies begin evaluation

  day_one_manual:
    - IT schedules 15-min welcome call to verify setup
    - Employee confirms disk encryption enabled (fdesetup status / manage-bde)
    - Employee joins #it-help Slack channel
    - Employee completes security awareness training link

  week_one_verification:
    - Fleet/MDM dashboard shows device as compliant
    - All critical policies passing (encryption, firewall, OS version)
    - VPN connectivity verified
    - MFA enrolled on all critical services
```

---

## Quick Reference

| Task | macOS Command | Windows Command |
|------|---------------|-----------------|
| Check encryption | `fdesetup status` | `manage-bde -status C:` |
| Enable firewall | `socketfilterfw --setglobalstate on` | `Set-NetFirewallProfile -Enabled True` |
| Force OS update | `softwareupdate -ia` | `usoclient StartInstallD` |
| Lock screen now | `pmset displaysleepnow` | `rundll32.exe user32.dll,LockWorkStation` |
| List MDM profiles | `profiles show -type enrollment` | `dsregcmd /status` |
| Check compliance | `fleetctl get hosts --query "..."` | `fleetctl get hosts --query "..."` |
