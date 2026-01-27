---
name: user-management
description: Manage users, groups, and permissions on Linux systems. Configure sudo and access controls. Use when managing system access.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# User Management

Manage users, groups, and permissions.

## User Operations

```bash
# Create user
useradd -m -s /bin/bash username
passwd username

# Delete user
userdel -r username

# Modify user
usermod -aG sudo username
usermod -s /bin/zsh username
```

## Group Management

```bash
# Create group
groupadd developers

# Add user to group
usermod -aG developers username
gpasswd -a username developers

# Remove from group
gpasswd -d username developers
```

## Sudo Configuration

```bash
# /etc/sudoers.d/developers
%developers ALL=(ALL) NOPASSWD: /usr/bin/docker
username ALL=(ALL) NOPASSWD: ALL
```

## File Permissions

```bash
chmod 755 file        # rwxr-xr-x
chmod u+x file        # Add execute for user
chown user:group file # Change ownership
chown -R user:group dir/

# ACLs
setfacl -m u:user:rx file
getfacl file
```

## Best Practices

- Use groups for access control
- Minimal sudo privileges
- Regular access reviews
- Strong password policies
