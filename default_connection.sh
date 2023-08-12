source helpers.sh

set -e

CONFIG_FILE=config.yaml

# Reading config.yaml
info_log_await "Reading config...\n$CONFIG_FILE:"

eval $(parse_yaml $CONFIG_FILE)
cat $CONFIG_FILE

# Router settings ns
info_log_await "Setting routing in ns..."

ip netns e $local_NS_name bash tunnel_router.sh \
    --veth-addr $local_veth_IP \
    --vpeer $local_NS_dev \
    --def-route-only \
    --def-config
    

# Remove old tun and route
info_log_await "Romoving old ssh tun/tap dev and route..."

if [ -n "$remote_IP" ]; then
  pkill -9 -f "ssh.*\-w.*$remote_IP" 2>/dev/null || true
  ip netns exec "$local_NS_name" ip route delete "$remote_IP/32" 2>/dev/null || true
fi


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

external_ip=$(get_external_ip "$local_NS_name")
if [ $? -eq 0 ]; then
    echo "External IP: $external_ip"
    exit 0
else
    echo "Failed to retrieve the external IP."
    exit 1
fi
