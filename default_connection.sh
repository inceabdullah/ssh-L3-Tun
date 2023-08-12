source helpers.sh

set -e

# Reading config.yaml
info_log_await "Reading config...\n$CONFIG_FILE:"

eval $(parse_yaml $CONFIG_FILE)
cat $CONFIG_FILE

OLD_TUN_DEV=$local_TUN_dev
OLD_SSH_TUN_ADDR=$local_TUN_IP

# Router settings ns
info_log_await "Setting routing in ns..."

ip netns e $local_NS_name bash tunnel_router.sh \
    --remote-ip $REMOTE_IP \
    --veth-addr $local_veth_IP \
    --vpeer $local_NS_dev \
    --ssh-tun-ip $NEW_SSH_TUN_ADDR \
    --ssh-tun-dev $NEW_TUN_DEV \
    --def-route-only \
    --def-config
    

# Remove old tun and route
info_log_await "Romoving old ssh tun/tap dev and route..."

pkill -9 -f "ssh.*\-w.*$remote_IP" 2>/dev/null || true
ip netns e $local_NS_name ip r d $remote_IP/32 2>/dev/null || true

# Save config
info_log_await "Saving config..."

cat <<EOF > config.yaml
local:
  NS:
    name: "$local_NS_name"
    dev: $local_NS_dev
  veth:
    IP: "$local_veth_IP"
EOF
