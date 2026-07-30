# Task 10 — Full Network Security Assessment

**OASIS InfoByte Cyber Security Internship — Final Task**

## Overview
This project is a structured, end-to-end security assessment of an isolated test network, combining reconnaissance, live traffic analysis, and web vulnerability scanning into a single professional report package. It was conducted entirely within a personal, isolated VirtualBox lab — no external, production, or third-party systems were touched.

## Objective
Conduct a multi-phase security assessment using industry-standard tools, correlate findings across all phases, score risk consistently, and produce a report suitable for two audiences: a non-technical manager and a technical team responsible for remediation.

## Environment
- **Attacker machine:** Kali Linux (VirtualBox VM)
- **Target machine:** Windows 10 running a XAMPP stack (Apache, MariaDB, FileZilla FTP, Mercury Mail)
- **Network mode:** NAT Network (10.0.2.0/24) — both VMs on the same isolated subnet
- **Secondary target (Phase 3 only):** DVWA (Damn Vulnerable Web Application), run locally for web-scan demonstration

## Methodology
The assessment followed a three-phase structure aligned with common industry frameworks (referencing the [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/) and [PTES](http://www.pentest-standard.org/)):

| Phase | Tool | Purpose |
|---|---|---|
| 1 — Reconnaissance | Nmap (`-sV -O`) | Discover open ports, services, versions, and OS |
| 2 — Traffic Analysis | Wireshark | Passively capture live traffic; identify unencrypted/sensitive data in transit |
| 3 — Web Vulnerability Scan | Nikto | Identify web-layer misconfigurations and exposures |

Findings from all three phases were consolidated into one register, scored by severity (informed by [CVSS](https://www.first.org/cvss/)), and used to build a prioritised remediation roadmap.

## Key Findings Summary
- **26 total findings** across network, traffic, and web layers (F001–F026)
- **Critical:** Exposed `.git` repository and browsable config/database directories on the web application — could expose source code and credentials with no authentication required
- **High:** Cleartext-authentication services (FTP, POP3, IMAP, Finger) and a network-exposed database port
- **Confirmed in practice:** A live login credential was captured in plaintext during traffic analysis, proving the cleartext-auth risk rather than just inferring it
- **Medium/Low:** Missing HTTP security headers (HSTS, CSP, X-Content-Type-Options, etc.)

Full detail is in the Technical Report; a plain-language summary is in the Executive Summary.

## Tools Used
- Nmap 7.99
- Wireshark
- Nikto v2.6.0
- Markdown for reporting

## Ethical Use Statement
This assessment was performed exclusively against systems owned and controlled by the author, within an isolated VirtualBox lab environment. No external, production, or third-party systems were scanned or accessed. Unauthorized scanning or traffic interception of systems without explicit permission may violate laws such as the Computer Fraud and Abuse Act (US) or the Information Technology Act, 2000 (India), regardless of whether exploitation occurs.

## VEDIO CAPTURED: 
chick here : https://www.linkedin.com/posts/atchaya-moorthi-j-263300382_cybersecurity-oasisinfobyte-internship-ugcPost-7488549320884142080-Cfuv/?utm_source=share&utm_medium=member_desktop&rcm=ACoAAF5fhWsBgX0SZVxvEtQfxjLRWLlC29hIxpQ
