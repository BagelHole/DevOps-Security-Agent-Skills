# Indicator of Compromise (IOC) Hunting Guide

## Common IOC Types

| Type | Description | Example |
|------|-------------|---------|
| IP Address | Malicious source/destination | 192.168.1.100 |
| Domain | C2 or phishing domain | malware.evil.com |
| File Hash | Malware signature | SHA256:abc123... |
| File Path | Suspicious file location | /tmp/.hidden |
| Process | Malicious process name | cryptominer |
| User | Compromised account | admin |

## Log Hunting Queries

### SSH Brute Force Detection
```bash
# Failed SSH attempts
grep "Failed password" /var/log/auth.log | \
  awk '{print $(NF-3)}' | sort | uniq -c | sort -rn | head

# Successful logins after failures
grep -E "Accepted|Failed" /var/log/auth.log | \
  grep -B5 "Accepted" | grep "Failed"
```

### Suspicious Process Activity
```bash
# Processes running from /tmp
ps aux | grep -E "^.*/tmp/|^.*/dev/shm/"

# Hidden processes
ps aux | awk '$11 ~ /^\./'

# Processes with deleted binaries
ls -la /proc/*/exe 2>/dev/null | grep deleted

# Unusual parent-child relationships
ps -eo pid,ppid,cmd | grep -E "bash.*-c|sh.*-c"
```

### Network IOCs
```bash
# Connections to known bad ports
ss -anp | grep -E ":4444|:5555|:6666|:31337"

# Outbound connections from unusual processes
ss -anp | grep -v -E "chrome|firefox|curl|wget" | grep ESTAB

# DNS queries to suspicious domains
grep -E "query.*\.(tk|ml|ga|cf|gq)$" /var/log/syslog

# Large outbound transfers
ss -anp | awk '$3 > 1000000'
```

### File System IOCs
```bash
# Recently modified files in sensitive locations
find /etc /usr/bin /usr/sbin -mtime -1 -ls 2>/dev/null

# Files with suspicious permissions
find / -perm -4000 -o -perm -2000 -ls 2>/dev/null

# Hidden files
find / -name ".*" -type f -ls 2>/dev/null | head -50

# World-writable files
find / -perm -002 -type f -ls 2>/dev/null
```

### User Activity IOCs
```bash
# Recent sudo usage
grep sudo /var/log/auth.log | tail -50

# Users logged in from multiple IPs
last | awk '{print $1, $3}' | sort | uniq -c | sort -rn

# SSH keys added recently
find /home -name "authorized_keys" -mtime -7 -ls

# Unusual cron jobs
for user in $(cut -d: -f1 /etc/passwd); do
  crontab -l -u $user 2>/dev/null | grep -v "^#"
done
```

## AWS CloudTrail Hunting

```bash
# Console logins from unusual locations
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=ConsoleLogin \
  --query 'Events[*].[CloudTrailEvent]' --output text | jq '.'

# Root account usage
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=Username,AttributeValue=root

# Security group changes
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=AuthorizeSecurityGroupIngress
```

## YARA Rule Example

```yara
rule Suspicious_Shell_Script {
    meta:
        description = "Detects suspicious shell scripts"
        severity = "medium"
    strings:
        $s1 = "curl" ascii
        $s2 = "wget" ascii
        $s3 = "/dev/tcp/" ascii
        $s4 = "base64 -d" ascii
        $s5 = "chmod +x" ascii
    condition:
        3 of them
}
```

## Response Actions

### Block IOC
```bash
# Block IP
iptables -I INPUT -s <IP> -j DROP
iptables -I OUTPUT -d <IP> -j DROP

# Block domain (via hosts)
echo "127.0.0.1 malicious.domain.com" >> /etc/hosts

# Kill process
kill -9 <PID>
```

### Preserve Evidence
```bash
# Capture process memory
gcore <PID>

# Copy suspicious file
cp --preserve=all /path/to/file /evidence/

# Capture network traffic
tcpdump -i any -w /evidence/capture.pcap &
```
