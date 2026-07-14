# Task 1 — Basic Network Scanning with Nmap

## What is Nmap?
Nmap ("Network Mapper") is an open-source tool used to discover hosts and services on a
network by sending crafted packets and analysing the responses. It's used both for
offensive reconnaissance and defensive asset inventory.

## Why Network Scanning Matters
You can't secure a system if you don't know what's running on it. Every open port is a
potential entry point for an attacker, so scanning is the first step in understanding
what needs to be protected, patched, or closed off.

## Ethical Use Guidelines
This task was performed exclusively against a Windows 10 virtual machine running in an
isolated VirtualBox lab environment, owned and controlled by me. No external,
production, or third-party systems were scanned. Unauthorized scanning of systems
without explicit permission can violate laws like the Computer Fraud and Abuse Act (US)
or the IT Act (India), even without any exploitation taking place.

## Environment
- Attacker machine: Kali Linux (VirtualBox VM)
- Target machine: Windows 10 (VirtualBox VM)
- Network: NAT Network (10.0.2.0/24) — both VMs on the same subnet
- Target IP: 10.0.2.15

## Installation
Nmap comes pre-installed on Kali Linux. Verified with:
    nmap --version

## Scans Performed

### 1. Basic Scan
    nmap 10.0.2.15
Scans the 1000 most common TCP ports and reports which are open, closed, or filtered.

### 2. Service Version Scan
    nmap -sV 10.0.2.15
Adds a version fingerprint on top of the basic scan — identifies the exact service
running on each open port instead of just the port number.

### 3. OS Detection Scan
    sudo nmap -O 10.0.2.15
Analyses how the target's TCP/IP stack responds to crafted packets to guess the
operating system. Needs sudo because it requires crafting raw packets, which is a
privileged operation on Linux.

## Findings & Risk Analysis

| Port | Service | Risk Level | Notes |
|------|---------|-----------|-------|
| 135/tcp | MSRPC | Medium | Used for Windows internal RPC communication. Historically exploited by worms (e.g. Blaster in 2003). Shouldn't be exposed to untrusted networks. |
| 139/tcp | NetBIOS-ssn | Medium | Legacy file/printer sharing protocol. Can leak hostname and domain info to unauthenticated queries. Mostly kept for backward compatibility. |
| 445/tcp | Microsoft-DS (SMB) | High (pending patch verification) | Used for Windows file sharing. This is the exact port targeted by MS17-010/EternalBlue, the exploit behind WannaCry and NotPetya. Recommend verifying patch status before treating this as safe. |

## OS Fingerprint Result
Detected: Microsoft Windows 10 (build range 1709–21H2)

The result is a range and not an exact build because OS fingerprinting works by
analysing TCP/IP stack behaviour (TTL, window size, packet handling quirks), not
application-level details. Microsoft doesn't change core network stack behaviour
between most feature updates, so Nmap can confidently say "Windows 10" but can't
pinpoint the exact build from network traffic alone.


