#!/bin/bash

export $(grep -v '^#' ../.env | xargs -0)
source ../helpers.sh


REMOTE_IP=$TEST_SERVER_IP_US
timeout=20
TUN_NAME_FILE_PATH=/tmp/$(generate_uuid).txt
echo -e "remote TUN_NAME_FILE_PATH: $TUN_NAME_FILE_PATH\n"
REMOTE_MANAGERFILE=ssh_tunnel_remote_manager.sh
scp ../remote/$REMOTE_MANAGERFILE $REMOTE_IP:/tmp
ssh $REMOTE_IP chmod +x /tmp/$REMOTE_MANAGERFILE
ssh $REMOTE_IP "nohup /tmp/$REMOTE_MANAGERFILE $timeout >> $TUN_NAME_FILE_PATH 2>&1 &"
# ssh $REMOTE_IP "/tmp/$REMOTE_MANAGERFILE"
min_available_tun=$(ssh $REMOTE_IP 'bash -s' < ../remote/tun_reader.sh $TUN_NAME_FILE_PATH $timeout)
echo -e "min_available_tun: $min_available_tun"
