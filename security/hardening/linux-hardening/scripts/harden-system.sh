#!/bin/bash
# Linux System Hardening Script
# Usage: ./harden-system.sh [--apply]
# Run without --apply to see what changes would be made

set -euo pipefail

APPLY="${1:-}"

if [ "$APPLY" != "--apply" ]; then
    echo "DRY RUN MODE - No changes will be made"
    echo "Run with --apply to make changes"
    echo ""
fi

apply_change() {
    if [ "$APPLY" == "--apply" ]; then
        eval "$1"
        echo "  [APPLIED] $2"
    else
        echo "  [WOULD APPLY] $2"
    fi
}

echo "========================================="
echo "Linux System Hardening"
echo "========================================="
echo ""

# 1. Update system
echo "1. System Updates"
echo "-----------------"
apply_change "apt-get update && apt-get upgrade -y" "Update all packages"

# 2. Disable unused filesystems
echo ""
echo "2. Disable Unused Filesystems"
echo "------------------------------"
FILESYSTEMS="cramfs freevxfs jffs2 hfs hfsplus squashfs udf"
for fs in $FILESYSTEMS; do
    apply_change "echo 'install $fs /bin/true' >> /etc/modprobe.d/disable-filesystems.conf" "Disable $fs"
done

# 3. Kernel parameters
echo ""
echo "3. Kernel Hardening (sysctl)"
echo "----------------------------"
SYSCTL_CONF="/etc/sysctl.d/99-hardening.conf"
cat << 'EOF' > /tmp/sysctl-hardening.conf
# Network security
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_syncookies = 1

# IPv6 (disable if not needed)
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1

# Kernel hardening
kernel.randomize_va_space = 2
kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
kernel.yama.ptrace_scope = 1
EOF
apply_change "cp /tmp/sysctl-hardening.conf $SYSCTL_CONF && sysctl -p $SYSCTL_CONF" "Apply kernel hardening parameters"

# 4. SSH hardening
echo ""
echo "4. SSH Hardening"
echo "----------------"
SSH_CONF="/etc/ssh/sshd_config.d/hardening.conf"
cat << 'EOF' > /tmp/ssh-hardening.conf
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
X11Forwarding no
AllowAgentForwarding no
PermitEmptyPasswords no
EOF
apply_change "cp /tmp/ssh-hardening.conf $SSH_CONF" "Apply SSH hardening"

# 5. File permissions
echo ""
echo "5. File Permissions"
echo "-------------------"
apply_change "chmod 600 /etc/shadow" "Secure /etc/shadow"
apply_change "chmod 644 /etc/passwd" "Secure /etc/passwd"
apply_change "chmod 600 /etc/gshadow" "Secure /etc/gshadow"
apply_change "chmod 644 /etc/group" "Secure /etc/group"

# 6. Remove unnecessary packages
echo ""
echo "6. Remove Unnecessary Services"
echo "------------------------------"
REMOVE_PKGS="telnet rsh-client rsh-redone-client"
for pkg in $REMOVE_PKGS; do
    apply_change "apt-get remove -y $pkg 2>/dev/null || true" "Remove $pkg"
done

# 7. Configure firewall
echo ""
echo "7. Enable Firewall"
echo "------------------"
apply_change "ufw default deny incoming && ufw default allow outgoing && ufw allow ssh && ufw --force enable" "Configure UFW firewall"

# 8. Enable automatic updates
echo ""
echo "8. Automatic Security Updates"
echo "-----------------------------"
apply_change "apt-get install -y unattended-upgrades && dpkg-reconfigure -plow unattended-upgrades" "Enable unattended upgrades"

echo ""
echo "========================================="
echo "Hardening script complete"
if [ "$APPLY" != "--apply" ]; then
    echo "Run with --apply to make changes"
fi
echo "========================================="
