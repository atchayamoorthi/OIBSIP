# Task 5 — Research Report: Social Engineering Attacks

## Introduction

Social engineering is the practice of manipulating people — rather than machines — into
taking an action or revealing information that compromises security. Where a technical
exploit targets a flaw in software, social engineering targets a "flaw" in human decision-making:
our tendency to trust authority, to want to be helpful, to act quickly under perceived
urgency, and to reciprocate favors.

It is widely considered one of the most effective attack vectors in cybersecurity because
it routinely sidesteps expensive technical controls. An organisation can deploy next-generation
firewalls, endpoint detection, and email filtering, and still be breached because one employee
opened an attachment or trusted a phone call. Industry data backs this up consistently:

- Verizon's 2025 Data Breach Investigations Report ties roughly **60% of confirmed breaches**
  to the human element.
- Independent industry analysis puts social engineering's share of cyberattacks at **98%**
  when counted broadly (i.e. almost every attack chain has a social engineering component
  somewhere in it, even if only for initial access).
- Phishing alone accounts for roughly **65%** of social-engineering-driven initial access
  incidents.
- Vishing (voice-based social engineering) grew by **442%** according to CrowdStrike's 2025
  threat reporting, showing attackers are diversifying beyond email.
- Pretexting now drives **over 50%** of social engineering incidents, having nearly doubled
  in prevalence in recent years as attackers combine it with business email compromise (BEC).

These numbers matter for a simple reason: no amount of patching fixes a person being deceived.
Defense has to include people and process, not just technology.

---

## Phishing

### What It Is
Phishing is the use of fraudulent communications — most commonly email — that appear to come
from a trusted source, designed to trick the recipient into revealing credentials, transferring
money, or executing malicious code.

### Types
- **Spear phishing** — highly targeted, personalised to a specific individual using researched
  details (job title, colleagues, ongoing projects).
- **Whaling** — spear phishing aimed specifically at senior executives (CEOs, CFOs), often to
  authorise fraudulent wire transfers.
- **Vishing** — phishing conducted over voice calls, often impersonating IT support, banks, or
  executives; has surged with the availability of AI voice cloning.
- **Smishing** — phishing delivered via SMS text message, frequently impersonating delivery
  services, banks, or toll authorities.

### How It Works
The attacker crafts a message that looks legitimate (spoofed sender address, cloned branding,
urgent subject line), then relies on a call to action — "verify your account," "review this
invoice," "your package couldn't be delivered" — to get the victim to click a link, open an
attachment, or reply with sensitive information before they stop to scrutinise it.

### Real-World Case Study: The 2011 RSA SecurID Breach
Attackers sent two small batches of spear-phishing emails to low-profile RSA/EMC employees
over a two-day period, with the subject line "2011 Recruitment Plan." One employee retrieved
the email from their junk folder and opened the attached Excel file, "2011 Recruitment
plan.xls," which contained a zero-day exploit targeting an Adobe Flash vulnerability
(CVE-2011-0609). This gave attackers a backdoor into RSA's network. From there they moved
laterally, escalated privileges, and ultimately exfiltrated data related to the seed values
underpinning RSA's SecurID two-factor authentication tokens — a breach serious enough that
RSA later had to replace tokens for government and defense-sector customers.

The case is a textbook example of how a single low-privilege employee, not a system
administrator, was enough of an entry point to compromise a major security vendor.

### Prevention Recommendations
1. Deploy email authentication standards (SPF, DKIM, DMARC) to reduce spoofed sender domains.
2. Run regular, simulated phishing campaigns with immediate feedback so employees learn to
   recognise red flags in a low-stakes setting.
3. Enforce multi-factor authentication (MFA) everywhere, so a stolen password alone is not
   sufficient for account takeover.
4. Establish a clear, easy "report suspicious email" mechanism (e.g. a single-click report
   button) and make reporting a rewarded behaviour, not a source of embarrassment.

---

## Pretexting

### What It Is
Pretexting is a social engineering technique where the attacker fabricates a false but
plausible scenario ("pretext") — impersonating a vendor, auditor, IT technician, or
executive — to manipulate a target into handing over information or taking an action they
otherwise wouldn't.

### How an Attacker Builds a False Scenario
Effective pretexting relies on preparation: researching the target organisation's vendors,
org chart, and normal business processes, then constructing supporting "evidence" — forged
invoices, fake email domains that closely resemble a real partner's, cloned letterhead and
corporate stamps — so that the request looks like routine business, not fraud. The goal is to
make the victim feel they are simply doing their job, not being deceived.

### Real-World Case Study: The Evaldas Rimasauskas / Google–Facebook Fraud
Between 2013 and 2015, Lithuanian national Evaldas Rimasauskas orchestrated a scheme that
defrauded Google and Facebook out of more than $100 million. He incorporated a shell company
in Latvia using the same name as Quanta Computer, a real Taiwanese hardware supplier that both
tech companies actually did business with. He then sent fabricated invoices, contracts, and
letters — complete with forged signatures and fake corporate stamps — to accounts-payable
staff at both companies, who processed the payments as legitimate vendor transactions. The
scheme wasn't detected for two years and relied entirely on convincing paperwork and
impersonation rather than any technical exploit. Rimasauskas was later extradited to the US,
pleaded guilty to wire fraud, and was sentenced to five years in prison.

### Prevention Measures
1. Require out-of-band verification (a phone call to a known, pre-verified number — not one
   provided in the suspicious email) for any request to change payment details or move funds.
2. Implement dual-approval / segregation-of-duties for wire transfers and vendor payment
   changes above a defined threshold.
3. Train finance and procurement staff specifically — they are the highest-value pretexting
   targets — to treat urgency and confidentiality requests ("don't loop in your manager") as
   red flags rather than normal instructions.

---

## Baiting

### What It Is
Baiting lures a victim with the promise of something enticing — a free item, a "lost" storage
device, a too-good-to-be-true download — to get them to compromise their own system.

### Physical and Digital Baiting
- **Physical baiting:** infected USB drives left in parking lots, lobbies, or restrooms,
  sometimes labelled "Confidential" or "Salary Data" to increase pickup odds.
- **Digital baiting:** fake "free download" offers (pirated software, movies, games) bundled
  with malware, or fake ads promising prizes that lead to credential-harvesting pages.

### Case Study: The University of Illinois USB Drop Study
Researchers from Google, the University of Illinois Urbana-Champaign, and the University of
Michigan dropped 297 USB drives across a university campus to test whether people would plug
in a found device. They found the attack effective, with roughly 48% of the dropped drives
plugged into a computer, and the first drive connected to the network in under six minutes.
Follow-up studies presented at Black Hat found similar results — of drives that were picked
up, a large majority of finders opened files on them, often within the first hour. This
research is frequently cited because it demonstrates, empirically, that curiosity and a
desire to "find the owner" reliably overrides caution — even among a technically literate
population.

### Prevention Measures
1. Disable auto-run/auto-execute for removable media at the OS/endpoint level.
2. Enforce a policy that unknown USB devices are never plugged into corporate machines —
   instead handed to IT/security for inspection in an isolated environment.
3. Use endpoint protection that can detect and block USB-based HID (keystroke injection)
   attacks, not just traditional file-based malware.

---

## Quid Pro Quo (Bonus)

### Explanation
Quid pro quo ("something for something") is a variant of baiting where the attacker offers a
service or benefit in direct exchange for information or access — for example, calling
random employees pretending to be IT support offering to "fix an issue," and asking the
employee to disable antivirus or provide their password so the "fix" can be applied. Unlike
generic baiting, quid pro quo involves direct interaction and an explicit (fake) exchange.

### Prevention
Verify the identity of anyone offering unsolicited technical help through an independent
channel (e.g., call the IT helpdesk's published number back) before granting any access,
disabling any security control, or sharing credentials — genuine IT support will never ask
for your password.

---

## Comparison Table

| Attack Type | Primary Target | Psychological Lever Exploited | Best Countermeasure |
|---|---|---|---|
| Phishing | Any employee (mass) or specific individual (spear) | Urgency, authority, fear of missing a deadline | MFA + email authentication (SPF/DKIM/DMARC) + simulated training |
| Pretexting | Finance, HR, procurement, executive assistants | Trust in routine process, desire to be helpful/compliant | Out-of-band verification + dual approval for financial changes |
| Baiting | Anyone with physical/network access | Curiosity, desire to return a "lost" item, greed | Disable auto-run + strict removable-media policy |
| Quid Pro Quo | Employees needing IT help | Reciprocity, trust in "helpful" authority figures | Callback verification through official channels |

---

## Organisational Recommendations: 5-Point Security Awareness Training Checklist

1. **Run recurring, unannounced phishing simulations** (not a one-time onboarding video) with
   immediate, judgment-free feedback for anyone who clicks.
2. **Train role-specific scenarios** — finance staff should specifically drill pretexting/BEC
   wire-fraud scenarios; frontline/reception staff should drill physical tailgating and
   baiting scenarios.
3. **Establish and publicise a one-click "report suspicious activity" process**, and publicly
   recognise employees who report real attempts to reinforce the behaviour.
4. **Mandate out-of-band verification** for any request involving money movement, credential
   resets, or access changes — no exceptions, regardless of who appears to be asking.
5. **Measure and report metrics to leadership** — phishing simulation click rates, report
   rates, and time-to-report — so awareness training is treated as a measurable control, not
   a checkbox exercise.

---

## References

*YouTube (Cyber Security tutorials)
*Wikipedia (Social Engineering)
*Google Search / Web Browsing
*CISA (Cybersecurity and Infrastructure Security Agency)
*Verizon Data Breach Investigations Report (DBIR)
*CrowdStrike Global Threat Report
*Online Cybersecurity Articles and Blogs
