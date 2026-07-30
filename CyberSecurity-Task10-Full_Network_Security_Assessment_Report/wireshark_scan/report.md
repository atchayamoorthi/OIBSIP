# Phase 2 — Traffic Analysis Report (Wireshark)
**Task 10: Full Network Security Assessment**

## Capture Details
- **Interface:** eth0 (Kali attacker VM, NAT network 10.0.2.0/24)
- **Target activity generated:** Browsing to a test web application (`testaspnet.vulnweb.com`, a known intentionally-vulnerable ASP.NET test site) and submitting its login form
- **Filters applied:** `dns`, `http`, `tcp`
- **Evidence file:** `wireshark_capture.pcapng`
- **Date/time:** 30 July 2026, ~13:45–13:47

## Findings

| ID | Filter/Protocol | Description | Severity | Recommended Fix |
|----|-----------------|-------------|----------|-----------------|
| F013 | DNS | A DNS query for the target domain (`testaspnet.vulnweb.com`) was captured in fully readable plaintext (standard query, transaction ID `0xbc77`). Any host on the same network segment can passively see which sites are being resolved/visited. | Low–Medium | Use DNS-over-HTTPS/TLS (DoH/DoT) where supported; not fixable at the application layer alone |
| F014 | HTTP | A `POST /login.aspx` request was captured with the full login form submitted in cleartext: `tbUsername=admin`, `tbPassword=password123`. Both fields are visible byte-for-byte in the packet payload. | **Critical** | Enforce HTTPS for all authentication endpoints; never allow login forms to submit over plain HTTP |
| F015 | HTTP/TCP | The application accepts login submissions over **port 80 (HTTP)** even though an HTTPS listener exists on the same host (confirmed in Phase 1, port 443). This means encryption is optional rather than enforced. | High | Redirect all HTTP traffic to HTTPS (HSTS); disable plaintext submission of the login form entirely |
| F016 | TCP | Several TLSv1.2 conversations were observed to external IPs (e.g. `151.101.1.91`, `34.120.237.76`) alongside the lab traffic. This traffic is encrypted and appears unrelated to the target VM under test. | Info | Re-scope future captures to the NAT interface only, or filter by target IP (`ip.addr==10.0.2.15`) to avoid mixing unrelated background traffic into evidence |

## Key Evidence

- **Credential exposure (F014):** The captured HTTP POST body contained the literal values `Username=admin` and `Password=password123` in cleartext — this is the same weakness the Phase 1 findings register flagged conceptually (cleartext-auth services); this capture provides direct proof rather than inference.
- **DNS leakage (F013):** The plaintext DNS query confirms that even before any HTTP traffic occurs, the destination hostname is already exposed to passive observers on the network.

## Risk Observations
1. **Confirmed, not theoretical:** Phase 1 flagged multiple cleartext-authentication *services* (FTP, POP3, IMAP). Phase 2 now provides direct packet-level proof that at least one web login flow shares the same weakness — a credential was captured with zero effort beyond opening a filter.
2. **HTTPS availability ≠ HTTPS enforcement:** having port 443 open is meaningless if the application still accepts and processes sensitive submissions on port 80.
3. **Capture hygiene:** unrelated encrypted traffic to external IPs appeared in the capture, which should be excluded from the evidence set or explicitly noted as out-of-scope noise, to keep the report's findings defensible.

