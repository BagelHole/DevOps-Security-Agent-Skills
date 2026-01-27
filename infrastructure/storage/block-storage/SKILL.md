---
name: block-storage
description: Manage block storage volumes and LVM. Configure cloud block storage and local disks. Use when managing disk storage.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Block Storage

Manage block storage volumes and LVM.

## LVM Management

```bash
# Create physical volume
pvcreate /dev/sdb

# Create volume group
vgcreate data_vg /dev/sdb

# Create logical volume
lvcreate -L 50G -n app_lv data_vg

# Format and mount
mkfs.ext4 /dev/data_vg/app_lv
mount /dev/data_vg/app_lv /data

# Extend volume
lvextend -L +10G /dev/data_vg/app_lv
resize2fs /dev/data_vg/app_lv
```

## AWS EBS

```bash
# Create volume
aws ec2 create-volume \
  --availability-zone us-east-1a \
  --size 100 \
  --volume-type gp3

# Attach to instance
aws ec2 attach-volume \
  --volume-id vol-xxx \
  --instance-id i-xxx \
  --device /dev/xvdf
```

## Best Practices

- Use LVM for flexibility
- Implement RAID for redundancy
- Monitor disk I/O
- Regular disk health checks
