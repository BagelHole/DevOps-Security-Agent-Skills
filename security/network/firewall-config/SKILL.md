---
name: firewall-config
description: Configure iptables, nftables, and cloud firewalls. Implement network segmentation and traffic filtering. Use when securing network perimeters or implementing security zones.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Firewall Configuration

Configure host-based and cloud firewalls for network security.

## iptables

```bash
# Default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow established connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# Allow SSH
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP/HTTPS
iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT

# Save rules
iptables-save > /etc/iptables/rules.v4
```

## nftables

```bash
#!/usr/sbin/nft -f
flush ruleset

table inet filter {
  chain input {
    type filter hook input priority 0; policy drop;
    ct state established,related accept
    iif "lo" accept
    tcp dport { 22, 80, 443 } accept
  }
  
  chain forward {
    type filter hook forward priority 0; policy drop;
  }
  
  chain output {
    type filter hook output priority 0; policy accept;
  }
}
```

## AWS Security Groups

```bash
aws ec2 create-security-group --group-name web-sg --description "Web server SG"

aws ec2 authorize-security-group-ingress \
  --group-name web-sg \
  --protocol tcp --port 443 \
  --cidr 0.0.0.0/0
```

## Best Practices

- Default deny policy
- Minimal rule sets
- Regular rule audits
- Log denied traffic
- Document all rules

## Related Skills

- [linux-hardening](../../hardening/linux-hardening/) - System security
- [aws-vpc](../../../infrastructure/cloud-aws/aws-vpc/) - AWS networking
