# Incident Response Playbook

## Incident Severity Levels

| Level | Name | Description | Response Time | Example |
|-------|------|-------------|---------------|---------|
| SEV1 | Critical | Active breach, data exfiltration | Immediate | Ransomware, active attacker |
| SEV2 | High | Confirmed compromise, contained | 1 hour | Malware, credential theft |
| SEV3 | Medium | Suspicious activity, potential threat | 4 hours | Phishing success, anomaly |
| SEV4 | Low | Minor security event | 24 hours | Policy violation |

## Response Phases

### 1. Detection & Triage (0-15 minutes)

```
□ Confirm the incident is real (not false positive)
□ Assess initial scope and severity
□ Assign Incident Commander
□ Open incident channel (#incident-YYYY-MM-DD)
□ Start incident timeline documentation
```

**Key Questions:**
- What systems are affected?
- Is the threat active?
- What data may be compromised?
- Is it contained or spreading?

### 2. Containment (15-60 minutes)

**Short-term Containment:**
```
□ Isolate affected systems (network/firewall)
□ Block malicious IPs/domains
□ Disable compromised accounts
□ Preserve evidence before changes
```

**Commands:**
```bash
# Network isolation
iptables -I INPUT -s <malicious-ip> -j DROP
iptables -I OUTPUT -d <malicious-ip> -j DROP

# Account disable
usermod -L <username>
passwd -l <username>

# Service isolation
systemctl stop <compromised-service>
```

### 3. Investigation (1-4 hours)

```
□ Collect evidence (logs, memory, disk)
□ Identify attack vector
□ Determine scope of compromise
□ Document findings in timeline
```

**Log Sources:**
- Authentication: /var/log/auth.log, CloudTrail
- Application: Application logs, APM
- Network: Firewall logs, VPC Flow Logs
- System: syslog, journald

### 4. Eradication (1-24 hours)

```
□ Remove malware/backdoors
□ Patch vulnerabilities
□ Reset compromised credentials
□ Update security controls
□ Verify complete removal
```

### 5. Recovery (1-48 hours)

```
□ Restore systems from clean backups
□ Validate system integrity
□ Monitor for re-infection
□ Gradually restore services
□ Communicate status updates
```

### 6. Post-Incident (1-2 weeks)

```
□ Conduct blameless post-mortem
□ Document lessons learned
□ Create action items
□ Update runbooks and detection
□ Report to stakeholders
□ File regulatory notifications (if required)
```

## Communication Templates

### Internal Notification
```
SECURITY INCIDENT - [SEV LEVEL]

Status: Active/Contained/Resolved
Incident Commander: [Name]
Channel: #incident-YYYY-MM-DD

Summary: [Brief description]

Impact:
- Systems: [List]
- Data: [Type if applicable]
- Users: [Count/scope]

Current Actions:
- [Action 1]
- [Action 2]

Next Update: [Time]
```

### External Notification (if required)
```
Subject: Security Incident Notification

We are writing to inform you of a security incident 
that occurred on [DATE].

What Happened: [Description]
Data Involved: [Types]
Actions Taken: [Response measures]
What You Can Do: [Recommendations]
Contact: [Security team contact]
```

## Escalation Contacts

| Role | Primary | Secondary |
|------|---------|-----------|
| Incident Commander | [Name] | [Name] |
| Security Lead | [Name] | [Name] |
| Engineering Lead | [Name] | [Name] |
| Legal/Compliance | [Name] | [Name] |
| Communications | [Name] | [Name] |
| Executive Sponsor | [Name] | [Name] |
