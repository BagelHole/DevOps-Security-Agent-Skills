#!/bin/bash
# iptables Firewall Rules Template
# Customize and apply with: bash iptables-rules.sh

set -euo pipefail

# Flush existing rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

# Set default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

#------------------------------------------------------------------------------
# LOOPBACK
#------------------------------------------------------------------------------
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

#------------------------------------------------------------------------------
# ESTABLISHED CONNECTIONS
#------------------------------------------------------------------------------
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

#------------------------------------------------------------------------------
# INVALID PACKETS
#------------------------------------------------------------------------------
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

#------------------------------------------------------------------------------
# ICMP (Ping)
#------------------------------------------------------------------------------
# Allow ping (optional - comment out to disable)
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT

#------------------------------------------------------------------------------
# SSH (Rate Limited)
#------------------------------------------------------------------------------
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --set --name SSH
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 4 --name SSH -j DROP
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

#------------------------------------------------------------------------------
# WEB SERVICES (Uncomment as needed)
#------------------------------------------------------------------------------
# HTTP
# iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# HTTPS
# iptables -A INPUT -p tcp --dport 443 -j ACCEPT

#------------------------------------------------------------------------------
# APPLICATION PORTS (Customize)
#------------------------------------------------------------------------------
# Application (example: 8080)
# iptables -A INPUT -p tcp --dport 8080 -j ACCEPT

# From specific network only
# iptables -A INPUT -s 10.0.0.0/8 -p tcp --dport 8080 -j ACCEPT

#------------------------------------------------------------------------------
# DATABASE (Internal Only)
#------------------------------------------------------------------------------
# PostgreSQL from internal network
# iptables -A INPUT -s 10.0.0.0/8 -p tcp --dport 5432 -j ACCEPT

# MySQL from internal network
# iptables -A INPUT -s 10.0.0.0/8 -p tcp --dport 3306 -j ACCEPT

#------------------------------------------------------------------------------
# MONITORING
#------------------------------------------------------------------------------
# Prometheus metrics
# iptables -A INPUT -s 10.0.0.0/8 -p tcp --dport 9090 -j ACCEPT

# Node exporter
# iptables -A INPUT -s 10.0.0.0/8 -p tcp --dport 9100 -j ACCEPT

#------------------------------------------------------------------------------
# LOGGING
#------------------------------------------------------------------------------
# Log dropped packets (before final DROP)
iptables -A INPUT -j LOG --log-prefix "iptables-dropped: " --log-level 4 -m limit --limit 5/min

#------------------------------------------------------------------------------
# FINAL DROP (Implicit with policy, but explicit for clarity)
#------------------------------------------------------------------------------
iptables -A INPUT -j DROP

#------------------------------------------------------------------------------
# SAVE RULES
#------------------------------------------------------------------------------
echo "Saving rules..."
iptables-save > /etc/iptables/rules.v4 2>/dev/null || iptables-save > /tmp/iptables-rules.v4

echo "Firewall configured successfully!"
iptables -L -n -v
