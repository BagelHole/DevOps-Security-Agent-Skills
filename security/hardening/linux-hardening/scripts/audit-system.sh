#!/bin/bash
# Linux Security Audit Script
# Usage: ./audit-system.sh [--verbose]

set -euo pipefail

VERBOSE="${1:-}"
PASS=0
WARN=0
FAIL=0

check() {
    local status="$1"
    local message="$2"
    case "$status" in
        PASS) echo -e "\e[32m[PASS]\e[0m $message"; ((PASS++)) ;;
        WARN) echo -e "\e[33m[WARN]\e[0m $message"; ((WARN++)) ;;
        FAIL) echo -e "\e[31m[FAIL]\e[0m $message"; ((FAIL++)) ;;
    esac
}

echo "========================================="
echo "Linux Security Audit"
echo "========================================="
echo ""

# 1. System Updates
echo "1. System Updates"
echo "-----------------"
UPDATES=$(apt-get -s upgrade 2>/dev/null | grep -c "^Inst" || echo 0)
if [ "$UPDATES" -eq 0 ]; then
    check "PASS" "System is up to date"
else
    check "FAIL" "$UPDATES packages need updating"
fi

# 2. SSH Configuration
echo ""
echo "2. SSH Configuration"
echo "--------------------"
if grep -q "^PermitRootLogin no" /etc/ssh/sshd_config* 2>/dev/null; then
    check "PASS" "Root login disabled"
else
    check "FAIL" "Root login may be enabled"
fi

if grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config* 2>/dev/null; then
    check "PASS" "Password authentication disabled"
else
    check "WARN" "Password authentication may be enabled"
fi

# 3. User Accounts
echo ""
echo "3. User Accounts"
echo "----------------"
EMPTY_PASS=$(awk -F: '($2 == "") {print $1}' /etc/shadow 2>/dev/null | wc -l)
if [ "$EMPTY_PASS" -eq 0 ]; then
    check "PASS" "No accounts with empty passwords"
else
    check "FAIL" "$EMPTY_PASS accounts with empty passwords"
fi

ROOT_ACCOUNTS=$(awk -F: '($3 == 0) {print $1}' /etc/passwd | wc -l)
if [ "$ROOT_ACCOUNTS" -eq 1 ]; then
    check "PASS" "Only root has UID 0"
else
    check "FAIL" "$ROOT_ACCOUNTS accounts have UID 0"
fi

# 4. File Permissions
echo ""
echo "4. File Permissions"
echo "-------------------"
SHADOW_PERMS=$(stat -c %a /etc/shadow 2>/dev/null)
if [ "$SHADOW_PERMS" = "600" ] || [ "$SHADOW_PERMS" = "640" ]; then
    check "PASS" "/etc/shadow permissions: $SHADOW_PERMS"
else
    check "FAIL" "/etc/shadow permissions: $SHADOW_PERMS (should be 600)"
fi

WORLD_WRITABLE=$(find /etc -type f -perm -002 2>/dev/null | wc -l)
if [ "$WORLD_WRITABLE" -eq 0 ]; then
    check "PASS" "No world-writable files in /etc"
else
    check "FAIL" "$WORLD_WRITABLE world-writable files in /etc"
fi

# 5. Network Security
echo ""
echo "5. Network Security"
echo "-------------------"
if sysctl -n net.ipv4.tcp_syncookies 2>/dev/null | grep -q "1"; then
    check "PASS" "TCP SYN cookies enabled"
else
    check "WARN" "TCP SYN cookies not enabled"
fi

if sysctl -n net.ipv4.conf.all.rp_filter 2>/dev/null | grep -q "1"; then
    check "PASS" "Reverse path filtering enabled"
else
    check "WARN" "Reverse path filtering not enabled"
fi

# 6. Firewall
echo ""
echo "6. Firewall Status"
echo "------------------"
if command -v ufw &>/dev/null && ufw status | grep -q "active"; then
    check "PASS" "UFW firewall is active"
elif command -v firewalld &>/dev/null && systemctl is-active firewalld &>/dev/null; then
    check "PASS" "firewalld is active"
elif iptables -L -n 2>/dev/null | grep -q "DROP\|REJECT"; then
    check "PASS" "iptables has rules configured"
else
    check "FAIL" "No firewall appears to be active"
fi

# 7. Services
echo ""
echo "7. Running Services"
echo "-------------------"
LISTENING=$(ss -tlnp 2>/dev/null | grep -c LISTEN || echo 0)
check "WARN" "$LISTENING services listening on ports"

# Summary
echo ""
echo "========================================="
echo "Audit Summary"
echo "========================================="
echo -e "Passed: \e[32m$PASS\e[0m"
echo -e "Warnings: \e[33m$WARN\e[0m"
echo -e "Failed: \e[31m$FAIL\e[0m"
echo ""

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
