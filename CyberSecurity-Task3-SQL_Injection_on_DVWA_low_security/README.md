# Task 3 — SQL Injection on DVWA (Low Security)

## What is SQL Injection?
SQL Injection (SQLi) is a code injection technique where unsanitized user input is
concatenated directly into a SQL query, allowing an attacker to alter the query's logic
and read, modify, or extract data from the underlying database. It has remained in the
OWASP Top 10 (Injection, A03:2021) for over two decades and has been the root cause of
major real-world breaches, including Heartland Payment Systems (2008) and TalkTalk
(2015).

## Why SQL Injection Matters
A single unsanitized input field can lead to full database compromise — authentication
bypass, credential theft, or complete data exfiltration — without the attacker needing
any other foothold on the system. Understanding how it works at the query-construction
level is essential to writing (and recognizing) secure code, not just to attacking it.

## Ethical Use Guidelines
This task was performed exclusively against DVWA (Damn Vulnerable Web Application)
running in an isolated VirtualBox lab environment, owned and controlled by me, and bound
to `127.0.0.1` so it was unreachable from any external network. No external, production,
or third-party systems were targeted. Unauthorized SQL injection testing against systems
without explicit permission may violate laws such as the Computer Fraud and Abuse Act
(US) or the Information Technology Act (India), even without data being altered or
destroyed.

## Environment
- Attacker/Target machine: Kali Linux (VirtualBox VM) — DVWA hosted locally on the same
  VM for isolation
- Stack: Apache2, MariaDB, PHP (native LAMP install, not Docker)
- Network mode: NAT Network — Apache explicitly bound to `127.0.0.1:80` so the app was
  reachable only from within the VM itself
- Database access: a dedicated, least-privilege `dvwauser` account scoped only to the
  `dvwa` database (not the `root` MySQL account), to demonstrate the same least-privilege
  principle discussed in the Findings section below
- DVWA Security Level: **Low**

## Installation
DVWA was installed via a native LAMP stack rather than Docker, cloned from the official
source and pointed at a dedicated, least-privilege database user:
    sudo apt install -y apache2 mariadb-server php php-mysqli php-gd libapache2-mod-php
    sudo git clone https://github.com/digininja/DVWA.git /var/www/html/dvwa
Apache was explicitly restricted to loopback only:
    Listen 127.0.0.1:80
Verified with:
    sudo ss -tlnp | grep :80   # confirmed 127.0.0.1:80, not 0.0.0.0:80

## Injection Point
DVWA's Low-security SQL Injection module accepts a `User ID` and inserts it directly into
a SQL query with no sanitization:
    $id = $_REQUEST['id'];
    $query = "SELECT first_name, last_name FROM users WHERE user_id = '$id';";
Because `$id` is concatenated straight into the query string, any SQL syntax typed into
the field becomes part of the executed query.

## Exploitation Steps Performed

### 1. Baseline Test
    User ID: 1
Returned a single user (first name / surname), confirming normal expected behavior
before any injection was attempted.

### 2. Confirming the Injection
    1' OR '1'='1
Because `'1'='1'` is always true, the `WHERE` clause matched every row instead of just
one. This returned all 5 users in the database (admin, Gordon Brown, Hack Me, Pablo
Picasso, Bob Smith) from a single User ID field — proof the input was being executed as
SQL rather than treated as data.

### 3. Determining Column Count
    1' ORDER BY 1-- -
    1' ORDER BY 2-- -
    1' ORDER BY 3-- -
`ORDER BY 1` and `ORDER BY 2` succeeded; `ORDER BY 3` returned an "Unknown column" error,
confirming the underlying query selects exactly **2 columns** — a required piece of
information before a UNION SELECT injection can succeed, since UNION requires matching
column counts on both sides.

### 4. UNION-Based Recon
    1' UNION SELECT database(), version()-- -
Returned the active database name and MySQL/MariaDB version string in place of a normal
name, confirming the UNION injection was working correctly with the right column count.

### 5. Table Enumeration
    1' UNION SELECT table_name, table_schema FROM information_schema.tables WHERE table_schema=database()-- -
`information_schema.tables` is a built-in, read-only metadata table present on every
MySQL/MariaDB server. Querying it revealed all table names in the `dvwa` database,
including `users` and `guestbook`, without needing to guess any names.

### 6. Column Enumeration
    1' UNION SELECT column_name, data_type FROM information_schema.columns WHERE table_name='users'-- -
Returned every column name and type in the `users` table, including `user` and
`password` — the exact fields needed for credential extraction.

### 7. Credential Extraction
    1' UNION SELECT user, password FROM users-- -
Returned all usernames paired with their password hashes (unsalted MD5 at Low security)
directly from the `users` table — the same table that authenticates logins on the
application. This is the real-world impact of the vulnerability: a single injectable
field escalated from "return one name" to "dump every credential in the database."

## Findings & Risk Analysis

| Injection Point | Technique | Risk Level | Notes |
|---|---|---|---|
| `User ID` field, SQL Injection module | UNION-based SQLi | Critical | No input sanitization, no parameterization; direct string concatenation into the query allowed full database read access |
| `information_schema` access | Metadata enumeration | High | Application's database user could read schema metadata for every table, not just its own — a least-privilege violation |
| `users` table | Credential exposure | Critical | Password hashes stored as unsalted MD5, making any exposed hash trivially crackable with common wordlists |

## Root Cause
The vulnerability exists because the application failed to separate **code** from
**data**: user input was concatenated directly into the SQL query string before being
sent to the database, so the database could not distinguish "a string containing SQL
syntax" from "an actual SQL command."

## Mitigations (Not Applied Here — Documented for Comparison)
- **Parameterized queries / prepared statements** — sends the query structure and user
  data to the database separately, so input can never be reinterpreted as SQL syntax
  regardless of its content. This is the primary, most effective fix.
- **Least-privilege database accounts** — the application's DB user should not have
  permission to read `information_schema` or any database beyond what it needs.
- **Input validation** — e.g., casting `User ID` to an integer before use, since it is
  only ever expected to be numeric.
- **Salted password hashing** (e.g., bcrypt/Argon2) — even if SQLi is fixed, unsalted MD5
  leaves any historically-exposed data trivially crackable.

