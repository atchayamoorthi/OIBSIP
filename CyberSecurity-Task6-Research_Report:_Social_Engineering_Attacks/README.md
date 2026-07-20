# Task 6 — Research Report: The Importance of Patch Management

## What is Patch Management?
Patch management is the ongoing organizational process of identifying, prioritizing,
testing, deploying, and verifying software updates that fix bugs, close security
vulnerabilities, and improve stability. It is one of the highest-leverage — and most
frequently neglected — practices in cybersecurity, because most large breaches trace
back not to unknown "zero-day" flaws, but to known vulnerabilities for which a fix
already existed and simply wasn't applied in time.

## Why This Task Matters
[Write 2-3 sentences in your own words: why does a fix existing not automatically mean
a system is safe? Think about the gap between "patch released" and "patch installed."]

## Objective
Write a report explaining what patch management is, why unpatched systems represent one
of the largest attack surfaces in cybersecurity, and how organizations should implement
an effective patching strategy — grounded in real-world evidence rather than general
advice.

## Deliverable
- Report saved as `patch_management_report.md` in this folder
- No demo video required for this task

## Tech Stack / Tools
- Markdown (for the report)
- GitHub (for submission)

## Research Sources Used
- **NIST SP 800-40 Rev. 4** — *Guide to Enterprise Patch Management Planning* — the
  definitive free federal guide to enterprise patching
- **CVE Database (cve.mitre.org / NVD)** — used to reference and explain
  `CVE-2017-5638`, the Apache Struts flaw behind the Equifax breach
- **CVSS v4.0 Specification (FIRST.org)** — used to explain how vulnerability severity
  is scored and how that score drives patch prioritization
- **IBM Cost of a Data Breach Report 2025** — used for current breach cost statistics
- Full reference list with links is included at the end of `patch_management_report.md`

## Report Structure
The report covers, in order:
1. **Introduction** — defines patch management and its place in the vulnerability
   lifecycle (Discovery → Disclosure/CVE → Scoring/CVSS → Patch release → Exploitation
   window)
2. **Why Patches Matter** — explains CVE/CVSS, then walks through two real breaches:
   - WannaCry / EternalBlue (2017) — a patch existed a month before the worm hit
     200,000+ machines in 150+ countries
   - Equifax (2017) — a same-day patch for `CVE-2017-5638` went unapplied, leading to a
     147-million-record breach
3. **Consequences of Not Patching** — breach costs, ransomware, compliance/regulatory
   exposure, and reputational damage, backed by IBM's 2025 breach-cost data
4. **Patch Management Lifecycle** — Discovery → Assessment → Testing → Deployment →
   Verification, with a plain-language explanation of what each phase does and why it
   can't be skipped
5. **Best Practices** — a prioritized 7-step checklist an organization can actually
   follow
6. **Challenges** — legacy systems, downtime concerns, and testing/change-control
   requirements, each paired with a practical mitigation
7. **Conclusion** — ties the case studies back to the checklist
8. **References** — 6 credible, primary sources (NIST, CISA, MITRE/NVD, FIRST.org, IBM,
   and a U.S. House Oversight investigative report)

## Key Takeaway
[1-2 sentences: what did researching WannaCry and Equifax teach you about the
difference between a vulnerability existing and a vulnerability being exploited? What
role does organizational process — not just technology — play in closing that gap?]

## How to Review This Report
Open [`patch_management_report.md`](./patch_management_report.md) to read the full
report.


