#!/bin/bash

export $(grep -v '^#' ../.env | xargs -0)


REMOTE_IP=$TEST_SERVER_IP_US

REMOTE_MANAGERFILE=ssh_tunnel_remote_manager.sh
scp remote/$REMOTE_MANAGERFILE $REMOTE_IP:/tmp
ssh $REMOTE_IP chmod +x /tmp/$REMOTE_MANAGERFILE
min_available_tun=$(ssh $REMOTE_IP /tmp/$REMOTE_MANAGERFILE)
echo -e "min_available_tun: $min_available_tun"
