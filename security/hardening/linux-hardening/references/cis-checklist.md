# CIS Linux Hardening Checklist

## 1. Initial Setup

### 1.1 Filesystem Configuration
- [ ] Disable unused filesystems (cramfs, freevxfs, jffs2, hfs, hfsplus, squashfs, udf)
- [ ] Ensure `/tmp` is configured with nodev, nosuid, noexec
- [ ] Ensure `/var`, `/var/tmp`, `/var/log`, `/var/log/audit` are separate partitions
- [ ] Ensure `/home` is separate partition with nodev

### 1.2 Configure Software Updates
- [ ] Ensure package manager repositories are configured
- [ ] Ensure GPG keys are configured
- [ ] Ensure automatic updates are enabled

### 1.3 Filesystem Integrity
- [ ] Ensure AIDE is installed
- [ ] Ensure filesystem integrity is regularly checked

## 2. Services

### 2.1 Special Purpose Services
- [ ] Ensure time synchronization is configured (chrony/ntp)
- [ ] Ensure X Window System is not installed
- [ ] Ensure rsync service is not installed or masked
- [ ] Ensure Avahi Server is not installed
- [ ] Ensure CUPS is not installed
- [ ] Ensure DHCP Server is not installed
- [ ] Ensure LDAP server is not installed
- [ ] Ensure NFS is not installed
- [ ] Ensure DNS Server is not installed
- [ ] Ensure FTP Server is not installed
- [ ] Ensure HTTP Server is not installed
- [ ] Ensure IMAP and POP3 server is not installed
- [ ] Ensure Samba is not installed
- [ ] Ensure SNMP Server is not installed

### 2.2 Service Clients
- [ ] Ensure NIS Client is not installed
- [ ] Ensure rsh client is not installed
- [ ] Ensure talk client is not installed
- [ ] Ensure telnet client is not installed
- [ ] Ensure LDAP client is not installed
- [ ] Ensure RPC is not installed

## 3. Network Configuration

### 3.1 Network Parameters (Host Only)
- [ ] Ensure IP forwarding is disabled
- [ ] Ensure packet redirect sending is disabled

### 3.2 Network Parameters (Host and Router)
- [ ] Ensure source routed packets are not accepted
- [ ] Ensure ICMP redirects are not accepted
- [ ] Ensure secure ICMP redirects are not accepted
- [ ] Ensure suspicious packets are logged
- [ ] Ensure broadcast ICMP requests are ignored
- [ ] Ensure bogus ICMP responses are ignored
- [ ] Ensure Reverse Path Filtering is enabled
- [ ] Ensure TCP SYN Cookies is enabled

### 3.3 Firewall Configuration
- [ ] Ensure firewall is installed (iptables, nftables, or firewalld)
- [ ] Ensure default deny firewall policy
- [ ] Ensure loopback traffic is configured
- [ ] Ensure outbound connections are configured

## 4. Access, Authentication and Authorization

### 4.1 Configure Shadow Suite
- [ ] Ensure password expiration is 365 days or less
- [ ] Ensure minimum days between password changes is 7 or more
- [ ] Ensure password expiration warning days is 7 or more
- [ ] Ensure inactive password lock is 30 days or less
- [ ] Ensure all users last password change date is in the past

### 4.2 Configure SSH Server
- [ ] Ensure SSH Protocol is set to 2
- [ ] Ensure SSH LogLevel is appropriate
- [ ] Ensure SSH X11 forwarding is disabled
- [ ] Ensure SSH MaxAuthTries is set to 4 or less
- [ ] Ensure SSH IgnoreRhosts is enabled
- [ ] Ensure SSH HostbasedAuthentication is disabled
- [ ] Ensure SSH root login is disabled
- [ ] Ensure SSH PermitEmptyPasswords is disabled
- [ ] Ensure SSH PermitUserEnvironment is disabled
- [ ] Ensure SSH Idle Timeout Interval is configured
- [ ] Ensure SSH LoginGraceTime is set to one minute or less
- [ ] Ensure SSH warning banner is configured
- [ ] Ensure SSH PAM is enabled
- [ ] Ensure SSH AllowTcpForwarding is disabled

### 4.3 Configure PAM
- [ ] Ensure password creation requirements are configured
- [ ] Ensure lockout for failed password attempts is configured
- [ ] Ensure password reuse is limited
- [ ] Ensure password hashing algorithm is SHA-512

## 5. Logging and Auditing

### 5.1 Configure Logging
- [ ] Ensure rsyslog is installed
- [ ] Ensure rsyslog Service is enabled
- [ ] Ensure logging is configured
- [ ] Ensure rsyslog default file permissions configured
- [ ] Ensure remote rsyslog messages only accepted on designated log hosts

### 5.2 Configure auditd
- [ ] Ensure auditing is enabled
- [ ] Ensure audit log storage size is configured
- [ ] Ensure audit logs are not automatically deleted
- [ ] Ensure changes to system administration scope are collected
- [ ] Ensure login and logout events are collected
- [ ] Ensure session initiation information is collected
- [ ] Ensure file deletion events by users are collected
- [ ] Ensure kernel module loading and unloading is collected

## 6. System Maintenance

### 6.1 File Permissions
- [ ] Ensure permissions on /etc/passwd are configured (644)
- [ ] Ensure permissions on /etc/shadow are configured (600)
- [ ] Ensure permissions on /etc/group are configured (644)
- [ ] Ensure permissions on /etc/gshadow are configured (600)
- [ ] Ensure no world writable files exist
- [ ] Ensure no unowned files or directories exist
- [ ] Ensure no ungrouped files or directories exist

### 6.2 User and Group Settings
- [ ] Ensure accounts in /etc/passwd use shadowed passwords
- [ ] Ensure no legacy "+" entries exist in /etc/passwd
- [ ] Ensure root is the only UID 0 account
- [ ] Ensure root PATH integrity
- [ ] Ensure all users' home directories exist
- [ ] Ensure users' home directories permissions are 750 or more restrictive
- [ ] Ensure users own their home directories
- [ ] Ensure no users have .forward files
- [ ] Ensure no users have .netrc files
- [ ] Ensure no users have .rhosts files
