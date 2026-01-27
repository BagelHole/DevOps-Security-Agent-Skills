# iptables Reference Guide

## Chain Overview

```
                    PREROUTING
                        │
                        ▼
                   ┌─────────┐
                   │ ROUTING │
                   └────┬────┘
                        │
           ┌────────────┼────────────┐
           │            │            │
           ▼            ▼            ▼
        INPUT      FORWARD       OUTPUT
           │            │            │
           ▼            │            ▼
      Local Process     │      Local Process
                        │
                        ▼
                   POSTROUTING
```

## Tables

| Table | Purpose | Chains |
|-------|---------|--------|
| filter | Default, packet filtering | INPUT, FORWARD, OUTPUT |
| nat | Network Address Translation | PREROUTING, OUTPUT, POSTROUTING |
| mangle | Packet alteration | All chains |
| raw | Connection tracking exemption | PREROUTING, OUTPUT |

## Basic Commands

```bash
# List rules
iptables -L -n -v                    # All filter rules
iptables -L INPUT -n -v              # INPUT chain only
iptables -t nat -L -n -v             # NAT table

# Add rules
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT  # Insert at position 1

# Delete rules
iptables -D INPUT -p tcp --dport 22 -j ACCEPT
iptables -D INPUT 3                  # Delete rule #3

# Flush rules
iptables -F                          # Flush all filter rules
iptables -t nat -F                   # Flush NAT rules

# Set policy
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
```

## Common Rules

### Allow Established Connections
```bash
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
```

### Allow Loopback
```bash
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
```

### Allow SSH
```bash
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Rate limit SSH
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --set
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 4 -j DROP
```

### Allow Web Traffic
```bash
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
```

### Allow from Specific IP/Network
```bash
iptables -A INPUT -s 192.168.1.0/24 -j ACCEPT
iptables -A INPUT -s 10.0.0.5 -p tcp --dport 5432 -j ACCEPT
```

### Block IP
```bash
iptables -A INPUT -s 1.2.3.4 -j DROP
```

### Log Dropped Packets
```bash
iptables -A INPUT -j LOG --log-prefix "IPTables-Dropped: " --log-level 4
iptables -A INPUT -j DROP
```

## NAT Rules

### SNAT (Source NAT)
```bash
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

### DNAT (Destination NAT / Port Forwarding)
```bash
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.1.10:8080
```

## Save/Restore

```bash
# Save rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

# Restore rules
iptables-restore < /etc/iptables/rules.v4
ip6tables-restore < /etc/iptables/rules.v6
```
