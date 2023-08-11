source helpers.sh

REMOTE_IP=$1
CONFIG_FILE=config.yaml

# Reading config.yaml
info_log_await "Reading config...\n$CONFIG_FILE:"

eval $(parse_yaml $CONFIG_FILE)
cat $CONFIG_FILE

OLD_TUN_DEV=$local_TUN_dev

NEW_TUN_DEV=$(set_new_tun_dev "$OLD_TUN_DEV")
if [ $? -eq 0 ]; then
  echo "Old tunnel device: $OLD_TUN_DEV"
  echo "New tunnel device: $NEW_TUN_DEV"
else
  echo "An error occurred."
fi

OLD_SSH_TUN_ADDR=$local_TUN_IP

NEW_SSH_TUN_ADDR=$(set_new_ssh_tun_addr "$OLD_SSH_TUN_ADDR")

if [ $? -eq 0 ]; then
  echo "Old SSH tunnel address: $OLD_SSH_TUN_ADDR"
  echo "New SSH tunnel address: $NEW_SSH_TUN_ADDR"
else
  echo "An error occurred."
fi

