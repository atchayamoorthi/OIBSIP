Common Network Security Threats — Research Report


Introduction

Modern organizations depend on networks for nearly everything: customer transactions, internal communication, cloud infrastructure, and critical services like healthcare and finance. That dependency is exactly what makes network security threats so dangerous — a single vulnerability in traffic handling, name resolution, or address verification can be leveraged to take down services, steal data, or silently redirect users to malicious destinations. Understanding how these attacks work, not just that they exist, is what lets a defender build meaningful mitigations instead of relying on a single point of failure. This report examines four major categories of network threats: Denial of Service(Dos), Man-in-the-Middle(MitM), IP Spoofing, and DNS Poisoning.



Denial-of-Service (DoS) and Distributed Denial-of-Service (DDoS) Attacks:

How it works:
A DoS attack tries to make a system or service unavailable to legitimate users by exhausting a limited resource — bandwidth, CPU cycles, memory, or connection-table capacity. A single attacker sending a flood of malformed or excessive requests (for example, a SYN flood that exhausts a server's table of half-open TCP connections) is a classic DoS attack. A DDoS attack does the same thing, but the traffic originates from many distributed sources at once, usually a botnet of compromised devices, which makes the attack far harder to stop by simply blocking one source IP. A particularly powerful variant is the amplification/reflection attack, where an attacker sends a small, spoofed request to a misconfigured public server (DNS, NTP, or Memcached servers are common targets) and the server sends a much larger reply to the spoofed victim address — turning a small amount of attacker bandwidth into a massive flood aimed at the victim.
