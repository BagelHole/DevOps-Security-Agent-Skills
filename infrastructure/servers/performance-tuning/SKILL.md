---
name: performance-tuning
description: Optimize Linux system performance. Configure kernel parameters, analyze bottlenecks, and tune resources. Use when improving system performance.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Performance Tuning

Optimize Linux system performance.

## System Monitoring

```bash
top / htop                # Process monitoring
vmstat 1                  # Memory statistics
iostat -x 1               # Disk I/O
sar -n DEV 1              # Network statistics
perf top                  # CPU profiling
```

## Kernel Parameters

```bash
# /etc/sysctl.d/99-performance.conf
vm.swappiness = 10
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65535
fs.file-max = 2097152
vm.dirty_ratio = 40
vm.dirty_background_ratio = 10
```

## File Descriptor Limits

```bash
# /etc/security/limits.conf
* soft nofile 65535
* hard nofile 65535
* soft nproc 65535
* hard nproc 65535
```

## Disk I/O

```bash
# Change scheduler
echo noop > /sys/block/sda/queue/scheduler

# Enable trim for SSDs
fstrim -av
```

## Network Tuning

```bash
# Increase buffers
sysctl -w net.core.rmem_max=134217728
sysctl -w net.core.wmem_max=134217728
```

## Best Practices

- Profile before optimizing
- Change one parameter at a time
- Monitor impact of changes
- Document all tuning
