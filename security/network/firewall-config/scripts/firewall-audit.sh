#!/bin/bash
# Firewall Configuration Audit Script
# Usage: ./firewall-audit.sh

set -euo pipefail

echo "========================================="
echo "Firewall Configuration Audit"
echo "========================================="
echo ""

# Detect firewall type
if command -v ufw &>/dev/null; then
    FIREWALL="ufw"
elif command -v firewall-cmd &>/dev/null; then
    FIREWALL="firewalld"
elif command -v nft &>/dev/null; then
    FIREWALL="nftables"
else
    FIREWALL="iptables"
fi

echo "Detected Firewall: $FIREWALL"
echo ""

case "$FIREWALL" in
    ufw)
        echo "UFW Status:"
        echo "----------"
        ufw status verbose
        echo ""
        echo "UFW Rules (numbered):"
        echo "--------------------"
        ufw status numbered
        echo ""
        echo "UFW Application Profiles:"
        echo "------------------------"
        ufw app list
        ;;
        
    firewalld)
        echo "Firewalld Status:"
        echo "----------------"
        firewall-cmd --state
        echo ""
        echo "Active Zones:"
        echo "-------------"
        firewall-cmd --get-active-zones
        echo ""
        echo "Default Zone: $(firewall-cmd --get-default-zone)"
        echo ""
        echo "All Zone Rules:"
        echo "--------------"
        for zone in $(firewall-cmd --get-zones); do
            echo "--- Zone: $zone ---"
            firewall-cmd --zone=$zone --list-all 2>/dev/null || true
            echo ""
        done
        ;;
        
    nftables)
        echo "nftables Ruleset:"
        echo "----------------"
        nft list ruleset
        ;;
        
    iptables)
        echo "iptables Rules (Filter):"
        echo "-----------------------"
        iptables -L -n -v --line-numbers
        echo ""
        echo "iptables Rules (NAT):"
        echo "--------------------"
        iptables -t nat -L -n -v --line-numbers 2>/dev/null || true
        echo ""
        echo "ip6tables Rules:"
        echo "---------------"
        ip6tables -L -n -v --line-numbers 2>/dev/null || true
        ;;
esac

echo ""
echo "========================================="
echo "Open Ports (listening):"
echo "========================================="
ss -tlnp 2>/dev/null || netstat -tlnp

echo ""
echo "========================================="
echo "Audit complete"
echo "========================================="
