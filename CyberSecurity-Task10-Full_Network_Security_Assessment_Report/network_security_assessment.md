# Executive Summary
## Network Security Assessment — Risk Posture Overview

**Assessment scope:** A structured, three-phase security review of a test environment (network scan, live traffic review, and web application scan), conducted in an isolated lab.

---

### Overall Risk Rating: **HIGH**

The environment currently has several serious weaknesses that would give an attacker an easy path in if this setup were ever exposed to a real network. Nothing found required advanced skill to exploit — most issues stem from default settings, outdated software, and missing basic protections.

---

### What We Found, In Plain Terms

**1. Too many services running on one machine, several of them outdated.**
The test system runs a web server, email server, file transfer service, and database all at once. Some of these are old versions that send passwords and data in plain, readable text instead of encrypting them.

**2. We proved the risk is real, not theoretical.**
While simply watching normal network traffic, we captured a real username and password being typed into a login page — in full, readable text. This means anyone else on the same network could do the same thing without needing to "hack" anything.

**3. A test web application had critical exposure.**
A scan of a web application on the system revealed that internal source code and version-control history were publicly retrievable, along with folders that should never be browsable (including ones that typically hold database configuration). This is one of the most serious findings in the assessment — it can hand over the "blueprint" of an application to anyone who looks.

**4. Basic protective settings are missing across the board.**
Standard web security safeguards (things that block common attack techniques like clickjacking) were absent, indicating these systems were set up with defaults rather than a security-conscious configuration.

---

### Top 3 Priorities

| Priority | Issue | Why It Matters |
|---|---|---|
| 1 | Exposed source code / repository files on the web application | Could expose credentials or business logic to anyone |
| 2 | Passwords sent in plain text over the network | Credentials can be stolen passively, with no advanced hacking required |
| 3 | Database and configuration folders publicly browsable | Direct path to sensitive data and system settings |

---

### Bottom Line

None of these issues require a skilled attacker — they require only that someone is looking. The good news: every issue identified has a straightforward, well-understood fix (covered in the accompanying Technical Report and Remediation Roadmap). Addressing the top 3 priorities above would meaningfully reduce risk in the near term, with the remaining items following as part of routine hardening.
