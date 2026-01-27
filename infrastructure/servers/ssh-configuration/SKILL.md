---
name: ssh-configuration
description: Configure SSH servers and clients securely. Manage keys, tunnels, and config files. Use when setting up secure remote access.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# SSH Configuration

Secure SSH server and client configuration.

## Key Management

```bash
# Generate key
ssh-keygen -t ed25519 -C "user@example.com"

# Copy to server
ssh-copy-id user@server

# Add to agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

## SSH Config (~/.ssh/config)

```
Host production
  HostName prod.example.com
  User deploy
  IdentityFile ~/.ssh/prod_key
  Port 22

Host bastion
  HostName bastion.example.com
  User admin
  
Host internal
  HostName 10.0.0.5
  User admin
  ProxyJump bastion
```

## Secure Server Config

```bash
# /etc/ssh/sshd_config
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
MaxAuthTries 3
AllowUsers deploy admin
```

## Tunneling

```bash
# Local port forward
ssh -L 8080:internal:80 bastion

# Remote port forward
ssh -R 8080:localhost:80 server

# SOCKS proxy
ssh -D 1080 server
```

## Best Practices

- Use ed25519 keys
- Disable password auth
- Use SSH agent forwarding carefully
- Implement jump hosts/bastions
