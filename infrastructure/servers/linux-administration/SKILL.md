---
name: linux-administration
description: System administration for Linux servers. Manage packages, services, and system configuration. Use when administering Linux systems.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Linux Administration

Core Linux system administration skills.

## Package Management

```bash
# Debian/Ubuntu
apt update && apt upgrade -y
apt install nginx
apt remove nginx
apt autoremove

# RHEL/CentOS
dnf update
dnf install nginx
dnf remove nginx
```

## System Information

```bash
uname -a           # Kernel info
hostnamectl        # System info
lscpu              # CPU info
free -h            # Memory usage
df -h              # Disk usage
ip addr            # Network interfaces
```

## Log Management

```bash
journalctl -u nginx          # Service logs
journalctl -f                # Follow logs
tail -f /var/log/syslog      # System logs
dmesg                        # Kernel messages
```

## Process Management

```bash
ps aux | grep nginx
top / htop
kill -9 <pid>
pgrep nginx
pkill nginx
```

## Best Practices

- Regular updates
- Minimal installed packages
- Proper file permissions
- Log rotation configuration
- Automated backups
