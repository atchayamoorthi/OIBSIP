# Phase 3 — Web Vulnerability Scan Report (Nikto)
**Task 10: Full Network Security Assessment**

## Scan Details
- **Tool:** Nikto v2.6.0
- **Command:** `nikto -h http://127.0.0.1/dvwa/ -o nikto_scan_result.txt`
- **Target:** 127.0.0.1:80 (DVWA — Damn Vulnerable Web Application, running on the target's Apache/XAMPP stack)
- **Date/time:** 30 July 2026, ~13:51
- **Note on target:** DVWA is an intentionally vulnerable training application by design (per its own homepage disclaimer); findings below reflect real misconfigurations but are expected in a deliberately insecure teaching app rather than a production system.

## Findings Register

| Finding ID | Description | Severity | Affected Asset | Recommended Fix |
|---|---|---|---|---|
| F017 | `.git` repository is web-accessible (`/dvwa/.git/index`, `/dvwa/.git/HEAD`, `/dvwa/.git/config` all return data) — full commit history and source code could potentially be reconstructed from this. | Critical | http://127.0.0.1/dvwa/.git/ | Remove `.git` from the web root entirely, or block access to any `.git*` path at the web server config level |
| F018 | Directory indexing (listing) is enabled on `/dvwa/config/` and `/dvwa/database/`, exposing configuration and database directory contents, which commonly include DB credentials and schema files. | Critical | http://127.0.0.1/dvwa/config/, /dvwa/database/ | Disable directory listing (`Options -Indexes` in Apache); move config/DB files outside the web root where possible |
| F019 | Directory indexing enabled on `/dvwa/tests/` and `/dvwa/docs/`, exposing internal test files and documentation. | Medium | http://127.0.0.1/dvwa/tests/, /dvwa/docs/ | Disable directory listing site-wide; restrict access to non-production paths |
| F020 | `.gitignore` and `.dockerignore` files are web-accessible, revealing internal directory/build structure that aids an attacker in mapping the application. | Low | http://127.0.0.1/dvwa/.gitignore, /dvwa/.dockerignore | Remove these files from the deployed web root; they belong only in the source repo, not the served application |
| F021 | Missing `Strict-Transport-Security` (HSTS) header — the browser is never instructed to prefer HTTPS for this site. | Medium | http://127.0.0.1/dvwa/ | Add HSTS header; serve the application over HTTPS with HTTP redirecting to it |
| F022 | Missing `Content-Security-Policy` header — no restriction on script/resource sources, increasing impact of any XSS found elsewhere in the app. | Medium | http://127.0.0.1/dvwa/ | Implement a Content-Security-Policy appropriate to the app's actual resource needs |
| F023 | Missing `X-Content-Type-Options` header — browser may MIME-sniff responses, enabling certain content-type confusion attacks. | Medium | http://127.0.0.1/dvwa/ | Add `X-Content-Type-Options: nosniff` |
| F024 | Missing `Referrer-Policy` and `Permissions-Policy` headers — reduces control over information leakage and browser feature access. | Low | http://127.0.0.1/dvwa/ | Add both headers with sensible restrictive defaults |
| F025 | `X-Frame-Options` is either missing or using a deprecated approach for clickjacking protection instead of the modern CSP `frame-ancestors` directive. | Low | http://127.0.0.1/dvwa/ | Set `Content-Security-Policy: frame-ancestors 'none'` (or `'self'` if framing is needed) |
| F026 | Admin login page is publicly discoverable at `/dvwa/login.php` with no apparent rate limiting observed. | Info | http://127.0.0.1/dvwa/login.php | Add login rate-limiting/lockout and monitor for brute-force attempts (ties into the F014 cleartext-credential finding from Phase 2) |

## Risk Observations
1. **F017 and F018 are the most severe findings of the whole assessment so far** — an exposed `.git` folder and indexable config/database directories can hand an attacker source code and potentially live database credentials with zero authentication required.
2. **Header findings (F021–F025) are individually low-impact but compound risk** — missing CSP in particular directly amplifies the impact of any XSS vulnerability DVWA is designed to demonstrate.
3. **This scan targets a deliberately vulnerable app** — in a real engagement these findings would be flagged with full severity; here they double as a live teaching example of *why* these misconfigurations matter.

