# Common Network Security Threats — Research Report

## Introduction

Modern organizations depend on networks for nearly everything: customer transactions, internal communication, cloud infrastructure, and critical services like healthcare and finance. That dependency is exactly what makes network security threats so dangerous — a single vulnerability in traffic handling, name resolution, or address verification can be leveraged to take down services, steal data, or silently redirect users to malicious destinations. Understanding how these attacks work, not just that they exist, is what lets a defender build meaningful mitigations instead of relying on a single point of failure. This report examines four major categories of network threats: Denial of Service, Man-in-the-Middle, IP Spoofing, and DNS Poisoning.

## 1. Denial-of-Service (DoS) and Distributed Denial-of-Service (DDoS) Attacks

**How it works:** A DoS attack tries to make a system or service unavailable to legitimate users by exhausting a limited resource — bandwidth, CPU cycles, memory, or connection-table capacity. A single attacker sending a flood of malformed or excessive requests (for example, a SYN flood that exhausts a server's table of half-open TCP connections) is a classic DoS attack. A DDoS attack does the same thing, but the traffic originates from many distributed sources at once, usually a botnet of compromised devices, which makes the attack far harder to stop by simply blocking one source IP. A particularly powerful variant is the **amplification/reflection attack**, where an attacker sends a small, spoofed request to a misconfigured public server (DNS, NTP, or Memcached servers are common targets) and the server sends a much larger reply to the spoofed victim address — turning a small amount of attacker bandwidth into a massive flood aimed at the victim.

**Real-world example:** On October 21, 2016, the Mirai botnet — built by scanning the internet for IoT devices (routers, DVRs, IP cameras) still using factory-default passwords — was used to flood Dyn, a major DNS provider, with DDoS traffic. Because dozens of major platforms (Twitter, GitHub, Netflix, PayPal, Reddit, Spotify) all depended on Dyn for DNS resolution, those sites became unreachable for hours across the US and Europe, even though none of them were directly attacked. A second notable example is the February 2018 attack on GitHub, which peaked at a then-record 1.35 Tbps. Attackers exploited misconfigured, internet-exposed Memcached servers by sending them small requests with GitHub's IP address spoofed as the source; the servers replied with responses tens of thousands of times larger, all directed at GitHub.

**Impact:** Both incidents caused hours of service disruption, reputational damage, and — in Dyn's case — a measurable loss of customers who switched DNS providers afterward. The Mirai case also demonstrated how insecure consumer IoT devices can become weapons against unrelated third parties.

**Mitigation strategies:**
1. Deploy rate limiting and traffic-anomaly detection at the network edge, and use a DDoS scrubbing/mitigation service (e.g., a CDN or dedicated anti-DDoS provider) for internet-facing services.
2. Harden and patch internet-exposed services so they cannot be abused as amplification reflectors (e.g., disable unauthenticated UDP on services like Memcached, restrict access to trusted networks).
3. Avoid single points of failure by using multiple DNS providers/redundant infrastructure so an attack on one provider does not take down the whole service.

## 2. Man-in-the-Middle (MITM) Attacks

**How it works:** In a MITM attack, the attacker secretly positions themselves between two communicating parties who believe they are talking directly to each other, allowing the attacker to eavesdrop on, or even alter, the traffic. Common techniques include ARP spoofing on a local network (tricking devices into sending traffic through the attacker's machine), rogue/"evil twin" Wi-Fi access points that mimic a trusted network name, and HTTPS/SSL spoofing, where the attacker presents a forged certificate so the victim's device is tricked into trusting an encrypted connection that is actually being intercepted.

**Real-world example:** In 2015, Lenovo was found to have shipped consumer laptops with pre-installed "Superfish" adware that silently installed its own self-signed root certificate on every device. That certificate allowed the software to intercept and decrypt HTTPS traffic in order to inject advertisements — and because the certificate's private key was identical across all affected devices, researchers quickly showed that anyone who extracted it could perform the same interception on any Superfish-equipped laptop, turning a marketing feature into a mass MITM vulnerability.

**Impact:** The Superfish case exposed potentially millions of users to undetectable interception of supposedly secure (HTTPS) traffic, including banking and login credentials, and led to an FTC settlement against Lenovo. More broadly, MITM attacks are especially damaging against financial and healthcare services, where intercepted data includes credentials, transaction details, and personal health information.

**Mitigation strategies:**
1. Enforce HTTPS everywhere with HSTS (HTTP Strict Transport Security) so browsers refuse to downgrade to unencrypted HTTP.
2. Use certificate pinning in applications so they only trust a specific, known certificate rather than any certificate signed by any trusted authority.
3. Avoid untrusted/public Wi-Fi for sensitive transactions, and use a VPN when it cannot be avoided; on internal networks, use dynamic ARP inspection and port security to prevent ARP spoofing.

## 3. IP Spoofing

**How it works:** IP spoofing means forging the source IP address field of a packet so it appears to originate from a different, often trusted, host. This works because the base IP protocol was not designed with sender authentication — routers generally forward packets based on destination address only. Spoofing is rarely the end goal by itself; it's a technique that enables other attacks, most notably reflection/amplification DDoS (as described above) and bypassing simple IP-based access controls.

**Real-world example:** The GitHub Memcached attack described earlier is also the clearest example of IP spoofing in action. The entire amplification technique only worked because attackers could forge GitHub's IP address as the source of their requests to vulnerable Memcached servers, tricking those servers into directing their oversized replies at GitHub instead of the attacker. Security researchers at the time noted that this is only possible because IP spoofing remains permitted on much of the internet.

**Impact:** Beyond enabling record-breaking DDoS attacks, IP spoofing undermines any security control that relies on trusting a source address, and it makes attack traffic much harder to trace back to its true origin.

**Mitigation strategies:**
1. Implement network ingress/egress filtering (BCP38) at the ISP and network edge, so packets with forged source addresses that couldn't legitimately originate from a given network are dropped before they reach the internet.
2. Use Unicast Reverse Path Forwarding (uRPF) on routers to verify that incoming packets arrive on a plausible path for their claimed source address.
3. Require authentication for internet-exposed UDP services (or disable UDP support entirely where not needed) so they cannot be abused as amplification reflectors.

## 4. DNS Poisoning / DNS Spoofing

**How it works:** DNS poisoning (also called DNS cache poisoning) corrupts a DNS resolver's cache with a forged record, causing it to return an attacker-controlled IP address for a legitimate domain name. Because DNS traditionally runs over UDP and resolvers validate replies using only a transaction ID and source port, an attacker who can guess or brute-force those values can inject a forged response before the legitimate authoritative server's answer arrives.

**Real-world example:** The most significant case is the 2008 "Kaminsky bug," discovered by researcher Dan Kaminsky. He found that most DNS resolvers relied on only a 16-bit transaction ID (about 65,536 possible values) combined with a fixed source port, which was a small enough search space to brute-force in minutes. An attacker could flood a resolver with queries for random, non-existent subdomains and race forged replies against the real ones; once a single guess matched, the forged record would be cached — silently redirecting every user of that resolver to an attacker-controlled server until the cache entry expired. The discovery was serious enough to trigger a coordinated, simultaneous emergency patch across virtually every major DNS vendor.

**Impact:** Because DNS underpins nearly every other internet service, a poisoned cache can redirect victims to phishing pages, malware distribution sites, or fraudulent banking portals — all while the URL bar shows the correct, trusted domain name, since the hostname itself was never fake, only where it resolved to.

**Mitigation strategies:**
1. Deploy DNSSEC, which cryptographically signs DNS records so resolvers can detect and reject forged responses.
2. Use source port randomization and randomized transaction IDs on resolvers (the direct fix for the Kaminsky bug) to make blind guessing computationally infeasible.
3. Restrict recursive DNS resolution to trusted clients only, and monitor for anomalous spikes in NXDOMAIN queries, which can indicate an in-progress poisoning attempt.

## Comparison Table

| Threat | Attack Vector | Who Is At Risk | Difficulty to Execute | Ease of Mitigation |
|---|---|---|---|---|
| DoS/DDoS | Resource exhaustion via traffic flooding or amplification | Any internet-facing service; especially shared infrastructure like DNS providers | Low (DDoS-for-hire services exist) to Medium (amplification setup) | Moderate — requires scrubbing services/redundancy, not a single fix |
| MITM | Interception via ARP spoofing, rogue Wi-Fi, or forged certificates | Users on untrusted networks; mobile apps with weak certificate validation | Low on open/public networks | Moderate — HSTS and certificate pinning are effective but require adoption |
| IP Spoofing | Forging source IP address | Any UDP-based service that can be abused as a reflector | Low | Depends on ISP-level adoption of ingress filtering (BCP38) |
| DNS Poisoning | Forging DNS responses to corrupt resolver cache | Users of a compromised recursive resolver | Medium (post-Kaminsky fixes raise the bar) | High — DNSSEC largely solves it, but adoption is still incomplete |

## Conclusion — Key Takeaways for a Network Administrator

1. **Shared infrastructure is a force multiplier for attackers.** The Dyn and DNS poisoning cases both show that compromising one widely-relied-upon service (a DNS provider, a resolver) can cascade into outages or redirections far beyond the original target. Redundancy in critical infrastructure like DNS is not optional.
2. **Weak defaults are the common thread.** Default IoT passwords enabled Mirai; unauthenticated, internet-exposed UDP services enabled the GitHub attack; a fixed transaction ID space enabled the Kaminsky DNS bug. Hardening default configurations closes a disproportionate share of real-world attack paths.
3. **No single control is sufficient — defense-in-depth is required.** Each threat in this report has multiple layered mitigations (filtering, authentication, cryptographic validation, redundancy) because relying on one control alone has repeatedly failed in real incidents.



References

Wikipedia — Denial-of-service attack. https://en.wikipedia.org/wiki/Denial-of-service_attack
YouTube (Computerphile) — The Attack That Could Disrupt The Whole Internet. https://www.youtube.com/watch?v=BcDZS7iYNsA
Wikipedia — Man-in-the-middle attack. https://en.wikipedia.org/wiki/Man-in-the-middle_attack
YouTube (Computerphile) — Man in the Middle Attacks & Superfish. https://www.youtube.com/watch?v=-enHfpHMBo4
Wikipedia — IP address spoofing. https://en.wikipedia.org/wiki/IP_address_spoofing
YouTube — Module 7: What is IP Spoofing?. https://www.youtube.com/watch?v=zopRwR0yhlg
Wikipedia — DNS spoofing. https://en.wikipedia.org/wiki/DNS_spoofing
YouTube (Computerphile) — DNS Cache Poisoning. https://www.youtube.com/watch?v=7MT1F0O3_Yw
Google Search — used to locate the Wikipedia and YouTube sources above.

