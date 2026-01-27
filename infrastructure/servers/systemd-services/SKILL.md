---
name: systemd-services
description: Create and manage systemd services and timers. Configure service dependencies and resource limits. Use when managing system services.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Systemd Services

Manage system services with systemd.

## Service Unit File

```ini
# /etc/systemd/system/myapp.service
[Unit]
Description=My Application
After=network.target

[Service]
Type=simple
User=myapp
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/bin/start
ExecStop=/opt/myapp/bin/stop
Restart=always
RestartSec=5
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
```

## Service Management

```bash
systemctl daemon-reload
systemctl start myapp
systemctl stop myapp
systemctl restart myapp
systemctl enable myapp
systemctl status myapp
journalctl -u myapp -f
```

## Timer (Cron Replacement)

```ini
# /etc/systemd/system/backup.timer
[Unit]
Description=Daily backup

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

## Resource Limits

```ini
[Service]
MemoryLimit=512M
CPUQuota=50%
```

## Best Practices

- Use Type=notify for better tracking
- Implement proper restart policies
- Use timers instead of cron
- Set resource limits
