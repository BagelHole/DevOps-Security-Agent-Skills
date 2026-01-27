---
name: nfs-storage
description: Configure NFS servers and clients. Implement network file sharing for Linux systems. Use when setting up shared storage.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# NFS Storage

Configure NFS for network file sharing.

## Server Configuration

```bash
# Install
apt install nfs-kernel-server

# Configure exports
# /etc/exports
/data 10.0.0.0/24(rw,sync,no_subtree_check,no_root_squash)
/shared *(ro,sync,no_subtree_check)

# Apply changes
exportfs -ra

# Start service
systemctl enable --now nfs-kernel-server
```

## Client Configuration

```bash
# Install
apt install nfs-common

# Mount
mount -t nfs server:/data /mnt/data

# /etc/fstab
server:/data /mnt/data nfs defaults,_netdev 0 0
```

## Kubernetes NFS

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: nfs-server.example.com
    path: /data
```

## Best Practices

- Use proper export options
- Implement firewall rules
- Monitor NFS performance
- Use NFSv4 for security
