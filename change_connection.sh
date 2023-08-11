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
  echo "New tunnel device: $NEW_TUN_DEV"
else
  echo "An error occurred."
fi

