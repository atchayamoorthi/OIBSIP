# Phase 1 — Reconnaissance Report (Nmap)
**Task 10: Full Network Security Assessment**

## Scope
- **Target:** 10.0.2.15 (Windows 10, VirtualBox VM)
- **Attacker host:** Kali Linux (VirtualBox VM)
- **Network:** Isolated VirtualBox NAT Network, 10.0.2.0/24
- **Date/time:** 30 July 2026, 03:36–03:36 UTC
- **Command used:** `nmap -sV -O 10.0.2.15 -oN nmap_results.txt`
- **Authorization:** Personal lab, both VMs owned and controlled by the assessor. No external or production systems touched.

## Summary
The target is running a Windows 10 host with a XAMPP stack (Apache, MariaDB, FileZilla FTP, Mercury Mail) providing web, mail, file transfer, and database services simultaneously. 12 open ports were identified across web, mail, file-sharing, and database services. Several services use legacy protocols with cleartext authentication, and one database service is exposed to the network without any indication of access restriction.

## Findings

| ID | Port/Proto | Service | Description | Severity | Recommended Fix |
|----|-----------|---------|-------------|----------|-----------------|
| F001 | 21/tcp | FTP (FileZilla ftpd 0.9.41 beta) | Beta-version FTP server; FTP transmits credentials and data in cleartext by default | High | Disable if unused; if required, switch to SFTP/FTPS and upgrade to a stable release |
| F002 | 25/tcp | SMTP (Mercury/32) | Legacy mail server exposed; potential relay/spoofing risk if not restricted | Medium | Restrict to intended clients only; verify relay is not open |
| F003 | 79/tcp | Finger (Mercury/32 fingerd) | Deprecated protocol; can leak valid usernames for further attacks | Medium | Disable — no modern use case justifies keeping it open |
| F004 | 80/tcp | HTTP (Apache 2.4.58, PHP 8.2.12) | Web server reachable over unencrypted HTTP | Low/Info | Redirect all HTTP to HTTPS (443) |
| F005 | 106/tcp | POP3 password service (Mercury poppass) | Legacy password-change service over cleartext | Medium | Disable unless actively required |
| F006 | 110/tcp | POP3 (Mercury pop3d) | Cleartext email retrieval protocol; credentials sent in the clear | Medium | Migrate to POP3S or disable |
| F007 | 135/tcp | MSRPC | Standard Windows RPC endpoint mapper; historically linked to several RCE vulnerabilities | Medium | Firewall from untrusted networks; keep OS patched |
| F008 | 139/tcp | NetBIOS-ssn | Legacy file/print sharing protocol; used in several lateral-movement techniques | Medium | Disable NetBIOS over TCP/IP if SMB direct (445) is sufficient |
| F009 | 143/tcp | IMAP (Mercury imapd 4.62) | Cleartext email access protocol | Medium | Migrate to IMAPS or disable |
| F010 | 443/tcp | HTTPS (Apache 2.4.58, OpenSSL 3.1.3) | Encrypted web service — expected and lower risk | Info | Verify TLS config/cert validity in Phase 3 |
| F011 | 445/tcp | Microsoft-DS (SMB) | Windows file-sharing port; historically the vector for major worms (e.g. EternalBlue/MS17-010) | High (pending patch verification) | Confirm SMBv1 is disabled and patches for known SMB CVEs are applied |
| F012 | 3306/tcp | MySQL/MariaDB (unauthorized) | Database service reachable directly over the network | High | Bind to localhost only or firewall to application server; never expose DB ports directly |

## OS Fingerprint
- **Detected:** Microsoft Windows 10, build range **1709–22H2**
- Nmap's OS detection compares TCP/IP stack behaviour (window size, option ordering, ISN patterns) against a fingerprint database — this identifies the OS *family*, not an exact build, since many builds share identical network-stack behaviour. Treat this as a probable estimate, not confirmed fact.

## Key Risk Observations
1. **Too many services, too little segmentation** — a single host running web, mail, FTP, and database services multiplies the attack surface unnecessarily.
2. **Cleartext protocols dominate** (FTP, SMTP, Finger, POP3, IMAP) — any attacker on the same network segment could passively capture credentials (to be verified in Phase 2 traffic analysis).
3. **Database directly reachable** (3306) — this should never be internet/network-facing without strict access controls.
4. **SMB exposure** — requires patch-level verification before being downgraded from "High."

