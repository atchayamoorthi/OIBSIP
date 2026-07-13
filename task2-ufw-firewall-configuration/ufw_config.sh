#!/bin/bash
 
# my ufw setup for task 2
# ssh has to be allowed before turning the firewall on or you can lock yourself out
 
set -e
 
if [ "$EUID" -ne 0 ]; then
    echo "run with sudo"
    exit 1
fi
 
echo "setting default rules"
ufw default deny incoming
ufw default allow outgoing
 
echo "allowing ssh (rate limited so it blocks brute force attempts)"
ufw limit ssh
 
echo "turning on ufw"
ufw --force enable
 
echo "adding rules"
ufw allow https
ufw deny http
ufw deny 23
ufw allow from 10.0.2.0/24 to any port 3389
 
echo "final rules:"
ufw status numbered
