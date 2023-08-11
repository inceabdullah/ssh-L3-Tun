#!/bin/bash
#//TODO add save config yaml file and tun new and change def
source helpers.sh

REMOTE_IP=$1

WAIT_FOR_RD=1
TUN_NS_NAME=vpn
VETH="veth"
VPEER="vpeer"
VETH_ADDR="10.0.0.1"
VPEER_ADDR="10.0.0.2"

# ----
SSH_TUN_ADDR="10.0.1.1"
SSH_TUN_ADDR_REMOTE="10.0.1.2"


# Removing old veth
info_log "Removing old veth..."
sleep $WAIT_FOR_RD

ip l d ${VETH} 2>/dev/null || true


# Get the name of the network interface with an assigned IPv4 address, excluding the loopback interface
inet_iface_name=$(ip -4 addr show | grep -v 'inet 127.' | grep -oP '(?<=\d: )\w+' | grep -v 'lo' | head -n 1)




info_log "Interface name: $inet_iface_name"

# Create namespace
info_log "Creating new ns..."
sleep $WAIT_FOR_RD

ip netns d $TUN_NS_NAME 2>/dev/null || true
ip netns a $TUN_NS_NAME

info_log "Created.\nns list:"
ip netns
sleep $WAIT_FOR_RD


# Create veth link.
info_log "Creating veth peers..."
sleep $WAIT_FOR_RD

ip l d ${VETH} 2>/dev/null || true
ip l a ${VETH} type veth peer name ${VPEER}



# Add peer-1 to NS.
info_log "Adding peer to ns..."
sleep $WAIT_FOR_RD

ip l s ${VPEER} netns $TUN_NS_NAME


# Assigning IP address of ${VETH}.
info_log "Setting up veth and up..."
sleep $WAIT_FOR_RD

ip a a ${VETH_ADDR}/24 dev ${VETH}
ip l s ${VETH} up


#  Set interfaces up.
info_log "Setting ns ifaces up..."
sleep $WAIT_FOR_RD

ip netns e $TUN_NS_NAME ip l s ${VPEER} up
ip netns e $TUN_NS_NAME ip l s lo up


# Addr
info_log "Assigning IP address of ns iface..."
sleep $WAIT_FOR_RD

ip netns e $TUN_NS_NAME ip a a ${VPEER_ADDR}/24 dev ${VPEER}


# Route
## in VPN
info_log "Setting routing in ns..."
sleep $WAIT_FOR_RD

ip netns e $TUN_NS_NAME ip r a default via ${VETH_ADDR}

# NFT NAT Rules
info_log "Setting NAT rules..."
sleep $WAIT_FOR_RD

bash nft_revert_host.sh 2>/dev/null || true
bash nft_host.sh $inet_iface_name

# Checking internet in ns
info_log "Checking internet in ns..."
sleep $WAIT_FOR_RD

ip netns e $TUN_NS_NAME ping -c1 -W2 x.co

if [ $? -ne 0 ]; then
  echo -e "\e[1;31mPing failed\e[0m" # Bold red
  # Handle the error here
else
  echo -e "\e[1;32mPing succeeded\e[0m" # Bold green
  # Continue with the script
fi

# Ssh tun/tap tunnel ns
info_log "Making ssh tun/tap tunnel in ns..."
sleep $WAIT_FOR_RD

ip netns e $TUN_NS_NAME bash ssh_l3_tunnel.sh $REMOTE_IP


# Set ssh tun dev addr ns
info_log "Setting ssh tun/tap dev addr and up in ns..."
sleep $WAIT_FOR_RD

ip netns e $TUN_NS_NAME ip a a $SSH_TUN_ADDR/31 peer $SSH_TUN_ADDR_REMOTE  dev tun0
ip netns e $TUN_NS_NAME ip l s tun0 up


# Router settings ns
info_log "Setting routing in ns..."
sleep $WAIT_FOR_RD

ip netns e $TUN_NS_NAME bash tunnel_router.sh \
    --remote-ip $REMOTE_IP \
    --veth-addr $VETH_ADDR \
    --vpeer $VPEER \
    --ssh-tun-ip $SSH_TUN_ADDR \
    --ssh-tun-dev tun0

# Set ssh tun dev addr remote
info_log "Setting ssh tun/tap dev addr and up remote..."
sleep $WAIT_FOR_RD

ssh $REMOTE_IP /usr/sbin/ip a a $SSH_TUN_ADDR_REMOTE/31 peer $SSH_TUN_ADDR dev tun1
ssh $REMOTE_IP /usr/sbin/ip l s tun1 up

ip netns e $TUN_NS_NAME ping -c1 -W2 $SSH_TUN_ADDR_REMOTE

if [ $? -ne 0 ]; then
  echo -e "\e[1;31mPing failed\e[0m" # Bold red
  # Handle the error here
else
  echo -e "\e[1;32mPing succeeded\e[0m" # Bold green
  # Continue with the script
fi

# Remote NFT rules
info_log "Setting nft rules in remote..."
sleep $WAIT_FOR_RD

REMOTE_NFT_RULER_FILE=remote_nft_ruler.sh

scp $REMOTE_NFT_RULER_FILE $REMOTE_IP:/tmp
ssh $REMOTE_IP bash /tmp/$REMOTE_NFT_RULER_FILE

# Save config
info_log "Saving config..."
sleep $WAIT_FOR_RD

cat <<EOF > config.yaml
remote:
  IP: "$REMOTE_IP"
local:
  TUN:
    IP: "$SSH_TUN_ADDR"
    dev: tun0
  NS:
    name: "$TUN_NS_NAME"
    dev: $VPEER
  veth:
    IP: "$VETH_ADDR"
EOF