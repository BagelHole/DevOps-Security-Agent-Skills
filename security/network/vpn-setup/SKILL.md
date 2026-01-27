---
name: vpn-setup
description: Configure WireGuard, OpenVPN, and cloud VPNs. Implement secure remote access and site-to-site connectivity. Use when setting up secure network tunnels.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# VPN Setup

Configure secure VPN tunnels for remote access and site connectivity.

## WireGuard

```bash
# Generate keys
wg genkey | tee privatekey | wg pubkey > publickey

# Server config (/etc/wireguard/wg0.conf)
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = <server-private-key>

[Peer]
PublicKey = <client-public-key>
AllowedIPs = 10.0.0.2/32

# Enable
wg-quick up wg0
systemctl enable wg-quick@wg0
```

## OpenVPN

```bash
# Install
apt install openvpn easy-rsa

# Generate certificates
cd /etc/openvpn/easy-rsa
./easyrsa init-pki
./easyrsa build-ca
./easyrsa gen-req server nopass
./easyrsa sign-req server server
./easyrsa gen-dh
```

## AWS Site-to-Site VPN

```bash
aws ec2 create-vpn-gateway --type ipsec.1
aws ec2 create-customer-gateway \
  --type ipsec.1 \
  --bgp-asn 65000 \
  --public-ip <on-prem-ip>
aws ec2 create-vpn-connection \
  --type ipsec.1 \
  --customer-gateway-id cgw-xxx \
  --vpn-gateway-id vgw-xxx
```

## Best Practices

- Use WireGuard for modern deployments
- Implement MFA for VPN access
- Regular key rotation
- Monitor VPN connections
- Segment VPN access by role

## Related Skills

- [zero-trust](../zero-trust/) - Modern access patterns
- [ssl-tls-management](../ssl-tls-management/) - Certificate management
