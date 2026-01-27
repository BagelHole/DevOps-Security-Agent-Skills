#!/bin/bash
# Security Incident Evidence Collection Script
# Usage: ./collect-evidence.sh [incident-id]

set -euo pipefail

INCIDENT_ID="${1:-incident-$(date +%Y%m%d-%H%M%S)}"
EVIDENCE_DIR="/tmp/evidence-$INCIDENT_ID"
HOSTNAME=$(hostname)

mkdir -p "$EVIDENCE_DIR"

echo "========================================="
echo "Security Incident Evidence Collection"
echo "Incident ID: $INCIDENT_ID"
echo "Host: $HOSTNAME"
echo "Time: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "Output: $EVIDENCE_DIR"
echo "========================================="
echo ""

# Create metadata file
cat > "$EVIDENCE_DIR/metadata.txt" << EOF
Incident ID: $INCIDENT_ID
Collection Time: $(date -u '+%Y-%m-%d %H:%M:%S UTC')
Hostname: $HOSTNAME
Kernel: $(uname -a)
Collector: $(whoami)
EOF

# System information
echo "Collecting system information..."
mkdir -p "$EVIDENCE_DIR/system"
uname -a > "$EVIDENCE_DIR/system/uname.txt"
cat /etc/os-release > "$EVIDENCE_DIR/system/os-release.txt" 2>/dev/null || true
uptime > "$EVIDENCE_DIR/system/uptime.txt"
date -u > "$EVIDENCE_DIR/system/date.txt"

# Running processes
echo "Collecting process information..."
mkdir -p "$EVIDENCE_DIR/processes"
ps auxf > "$EVIDENCE_DIR/processes/ps-auxf.txt"
ps -eo pid,ppid,user,cmd --sort=-pid > "$EVIDENCE_DIR/processes/ps-sorted.txt"
pstree -p > "$EVIDENCE_DIR/processes/pstree.txt" 2>/dev/null || true

# Network connections
echo "Collecting network information..."
mkdir -p "$EVIDENCE_DIR/network"
ss -tlnp > "$EVIDENCE_DIR/network/listening-tcp.txt"
ss -ulnp > "$EVIDENCE_DIR/network/listening-udp.txt"
ss -anp > "$EVIDENCE_DIR/network/all-connections.txt"
ip addr > "$EVIDENCE_DIR/network/ip-addr.txt"
ip route > "$EVIDENCE_DIR/network/ip-route.txt"
iptables -L -n -v > "$EVIDENCE_DIR/network/iptables.txt" 2>/dev/null || true
cat /etc/hosts > "$EVIDENCE_DIR/network/hosts.txt"

# User information
echo "Collecting user information..."
mkdir -p "$EVIDENCE_DIR/users"
cat /etc/passwd > "$EVIDENCE_DIR/users/passwd.txt"
cat /etc/group > "$EVIDENCE_DIR/users/group.txt"
who > "$EVIDENCE_DIR/users/who.txt"
w > "$EVIDENCE_DIR/users/w.txt"
last -100 > "$EVIDENCE_DIR/users/last.txt"
lastlog > "$EVIDENCE_DIR/users/lastlog.txt" 2>/dev/null || true

# Authentication logs
echo "Collecting authentication logs..."
mkdir -p "$EVIDENCE_DIR/logs"
tail -1000 /var/log/auth.log > "$EVIDENCE_DIR/logs/auth.log" 2>/dev/null || true
tail -1000 /var/log/secure > "$EVIDENCE_DIR/logs/secure.log" 2>/dev/null || true
tail -1000 /var/log/syslog > "$EVIDENCE_DIR/logs/syslog.txt" 2>/dev/null || true
journalctl -u sshd --since "1 day ago" > "$EVIDENCE_DIR/logs/sshd.log" 2>/dev/null || true

# Scheduled tasks
echo "Collecting scheduled tasks..."
mkdir -p "$EVIDENCE_DIR/scheduled"
crontab -l > "$EVIDENCE_DIR/scheduled/crontab-current.txt" 2>/dev/null || true
ls -la /etc/cron.* > "$EVIDENCE_DIR/scheduled/cron-dirs.txt" 2>/dev/null || true
cat /etc/crontab > "$EVIDENCE_DIR/scheduled/etc-crontab.txt" 2>/dev/null || true
systemctl list-timers > "$EVIDENCE_DIR/scheduled/systemd-timers.txt" 2>/dev/null || true

# File system
echo "Collecting filesystem information..."
mkdir -p "$EVIDENCE_DIR/filesystem"
df -h > "$EVIDENCE_DIR/filesystem/df.txt"
mount > "$EVIDENCE_DIR/filesystem/mounts.txt"
find /tmp /var/tmp -type f -mtime -1 -ls > "$EVIDENCE_DIR/filesystem/recent-tmp.txt" 2>/dev/null || true

# Package hashes
echo "Collecting hash information..."
if command -v sha256sum &>/dev/null; then
    find /usr/bin /usr/sbin -type f -executable 2>/dev/null | head -100 | xargs sha256sum > "$EVIDENCE_DIR/filesystem/binary-hashes.txt" 2>/dev/null || true
fi

# Create archive
echo ""
echo "Creating evidence archive..."
ARCHIVE="/tmp/$INCIDENT_ID-evidence.tar.gz"
tar -czf "$ARCHIVE" -C /tmp "evidence-$INCIDENT_ID"

echo ""
echo "========================================="
echo "Evidence collection complete"
echo "Archive: $ARCHIVE"
echo "Size: $(du -h "$ARCHIVE" | cut -f1)"
echo ""
echo "SHA256: $(sha256sum "$ARCHIVE" | cut -d' ' -f1)"
echo "========================================="
