inet_iface_name=$1

nft add table ip nat
nft add chain ip nat prerouting_ssh { type nat hook prerouting priority 0 \; policy accept \; }
nft add chain ip nat postrouting_ssh { type nat hook postrouting priority 100 \; policy accept \; }
nft add rule ip nat postrouting_ssh oifname "${inet_iface_name}" masquerade
