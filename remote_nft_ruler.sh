#!/bin/bash

nft delete chain ip nat prerouting_ssh
nft delete chain ip nat postrouting_ssh

inet_iface_name=$(ip -4 addr show | grep -v 'inet 127.' | grep -oP '(?<=\d: )\w+' | grep -v 'lo' | head -n 1)

nft add table ip nat
nft add chain ip nat prerouting_ssh { type nat hook prerouting priority 0 \; policy accept \; }
nft add chain ip nat postrouting_ssh { type nat hook postrouting priority 100 \; policy accept \; }
nft add rule ip nat postrouting_ssh oifname "${inet_iface_name}" masquerade

