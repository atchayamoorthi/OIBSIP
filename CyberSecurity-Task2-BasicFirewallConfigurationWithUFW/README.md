Task 2 — Basic Firewall Configuration with UFW

What is UFW?

UFW (Uncomplicated Firewall) is a simplified frontend for Linux's netfilter/iptables
packet filtering system. It lets you allow or deny network traffic based on port,
protocol, and source address, without writing raw iptables rules directly.

Why Firewalls Matter

[Write 2-3 sentences in your own words: what does a firewall actually protect you
from, and how does this connect to what you found in Task 1's Nmap scan?]

Ethical Use Guidelines

This task was performed exclusively on my own Kali Linux VM in an isolated VirtualBox
lab environment. No production or shared systems were modified. Firewall
misconfiguration on a remote or production system can cause outages or lockouts,
so all rule changes were tested locally first.

Environment


System: Kali Linux (VirtualBox VM)
Network: NAT Network (10.0.2.0/24), same subnet as the Task 1 Windows 10 VM


Installation

sudo apt install ufw -y

Rules Configured

RuleCommandReasonDefault deny incomingufw default deny incoming[your words]Default allow outgoingufw default allow outgoing[your words]Rate-limited SSHufw limit ssh[your words - mention brute force protection]Allow HTTPSufw allow https[your words]Deny HTTPufw deny http[your words]Deny Telnetufw deny 23[your words - mention plaintext credentials]Scoped RDPufw allow from 10.0.2.0/24 to any port 3389[your words - mention least privilege]

Verification:

sudo ufw status verbose
