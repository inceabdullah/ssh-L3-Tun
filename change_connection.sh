source helpers.sh

set -e


REMOTE_IP=$1
CONFIG_FILE=config.yaml

# Reading config.yaml
info_log_await "Reading config...\n$CONFIG_FILE:"

eval $(parse_yaml $CONFIG_FILE)
cat $CONFIG_FILE

OLD_TUN_DEV=$local_TUN_dev

if [ -z "$OLD_TUN_DEV" ]; then
  NEW_TUN_DEV="tun0"
else
  NEW_TUN_DEV=$(set_new_tun_dev "$OLD_TUN_DEV")
  if [ $? -eq 0 ]; then
    echo "Old tunnel device: $OLD_TUN_DEV"
    echo "New tunnel device: $NEW_TUN_DEV"
  else
    echo "An error occurred."
  fi
fi




OLD_SSH_TUN_ADDR=$local_TUN_IP

if [ -z "$OLD_SSH_TUN_ADDR" ]; then
    NEW_SSH_TUN_ADDR="10.0.1.1"
    NEW_SSH_TUN_ADDR_REMOTE="10.0.1.2"
else
    NEW_SSH_TUN_ADDR=$(set_new_ssh_tun_addr "$OLD_SSH_TUN_ADDR")
    NEW_SSH_TUN_ADDR_REMOTE=$(increment_last_octet "$NEW_SSH_TUN_ADDR")
fi


if [ $? -eq 0 ]; then
    if [ -z "$OLD_SSH_TUN_ADDR" ]; then
        echo "Old SSH tunnel address is not assigned."
    else
        echo "Old SSH tunnel address: $OLD_SSH_TUN_ADDR"
    fi
  echo "New SSH tunnel address: $NEW_SSH_TUN_ADDR"
  echo "New SSH tunnel remote address: $NEW_SSH_TUN_ADDR_REMOTE"
else
  echo "An error occurred."
fi

# Add remote ssh route
info_log_await "Adding ssh route via default..."

ip netns e $local_NS_name ip r d $REMOTE_IP/32 2>/dev/null || true
ip netns e $local_NS_name ip r a $REMOTE_IP/32 via $local_veth_IP dev $local_NS_dev


# Make ssh tun
info_log_await "Making L3 ssh tunnel..."

# Execute the command and capture its output
output=$(ip netns e $local_NS_name bash ssh_l3_tunnel.sh $REMOTE_IP $NEW_TUN_DEV)

# Extract the value of REMOTE_AVAILABLE_TUN_DEV_ID from the output
REMOTE_AVAILABLE_TUN_DEV_ID=$(echo "$output" | grep "REMOTE_AVAILABLE_TUN_DEV_ID=" | awk -F'=' '{print $2}')

# Set ssh tun dev addr ns
info_log_await "Setting ssh tun/tap dev addr and up in ns..."

ip netns e $local_NS_name ip a a $NEW_SSH_TUN_ADDR/31 peer $NEW_SSH_TUN_ADDR_REMOTE  dev $NEW_TUN_DEV
ip netns e $local_NS_name ip l s $NEW_TUN_DEV up

# Set ssh tun dev addr remote
info_log_await "Setting ssh tun/tap dev addr and up remote..."

ssh $REMOTE_IP /usr/sbin/ip a a $NEW_SSH_TUN_ADDR_REMOTE/31 peer $NEW_SSH_TUN_ADDR dev tun$REMOTE_AVAILABLE_TUN_DEV_ID
ssh $REMOTE_IP /usr/sbin/ip l s tun$REMOTE_AVAILABLE_TUN_DEV_ID up

ip netns e $local_NS_name ping -c1 -W5 $NEW_SSH_TUN_ADDR_REMOTE

if [ $? -ne 0 ]; then
  echo -e "\e[1;31mPing failed\e[0m" # Bold red
  exit 1
  # Handle the error here
else
  echo -e "\e[1;32mPing succeeded\e[0m" # Bold green
  # Continue with the script
fi

# Remote NFT rules
info_log_await "Setting nft rules in remote..."

REMOTE_NFT_RULER_FILE=remote_nft_ruler.sh

scp $REMOTE_NFT_RULER_FILE $REMOTE_IP:/tmp
ssh $REMOTE_IP bash /tmp/$REMOTE_NFT_RULER_FILE

# Router settings ns
info_log_await "Setting routing in ns..."

parse_yaml $CONFIG_FILE

    ip netns e $local_NS_name bash tunnel_router.sh \
        --remote-ip $REMOTE_IP \
        --veth-addr $local_veth_IP \
        --vpeer $local_NS_dev \
        --ssh-tun-ip $NEW_SSH_TUN_ADDR \
        --ssh-tun-dev $NEW_TUN_DEV \
        --def-route-only



# Remove old tun and route
info_log_await "Romoving old ssh tun/tap dev and route..."

if [ -z "$OLD_SSH_TUN_ADDR" ]; then
    echo "Remote tun IP is not assigned."
else
    ip netns e $local_NS_name ip r d $remote_IP/32 2>/dev/null || true
    pkill -9 -f "ssh.*\-w.*$remote_IP" 2>/dev/null || true
fi



# Save config
info_log_await "Saving config..."

cat <<EOF > config.yaml
remote:
  IP: "$REMOTE_IP"
local:
  TUN:
    IP: "$NEW_SSH_TUN_ADDR"
    dev: $NEW_TUN_DEV
  NS:
    name: "$local_NS_name"
    dev: $local_NS_dev
  veth:
    IP: "$local_veth_IP"
EOF

external_ip=$(get_external_ip "$local_NS_name")
if [ $? -eq 0 ]; then
    echo "External IP: $external_ip"
    exit 0
else
    echo "Failed to retrieve the external IP."
    exit 1
fi
