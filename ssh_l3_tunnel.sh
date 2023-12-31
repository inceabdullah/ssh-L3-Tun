#!/bin/bash

source helpers.sh

REMOTE_IP=$1
SSH_TUN_DEV="$2"


if [ -z "$SSH_TUN_DEV" ]; then
    SSH_TUN_DEV="tun0"
fi

SSH_TUN_DEV_ID=$(tun_dev_id "$SSH_TUN_DEV")

TIMEOUT=60 # Timeout in seconds
SLEEP_INTERVAL=10 # Sleep interval in seconds
COUNTER=0

info_log_await "Local ssh tun/tap dev id: $SSH_TUN_DEV_ID"

#-----------Get available tun-----------
timeout=20
TUN_NAME_FILE_PATH=/tmp/$(generate_uuid).txt
REMOTE_MANAGERFILE=ssh_tunnel_remote_manager.sh
scp -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" remote/$REMOTE_MANAGERFILE $REMOTE_IP:/tmp
ssh -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" $REMOTE_IP chmod +x /tmp/$REMOTE_MANAGERFILE
info_log_await "remote TUN_NAME_FILE_PATH: $TUN_NAME_FILE_PATH\n"
ssh -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" $REMOTE_IP "nohup /tmp/$REMOTE_MANAGERFILE $timeout >> $TUN_NAME_FILE_PATH 2>&1 &"
min_available_tun=$(ssh -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" $REMOTE_IP 'bash -s' < remote/tun_reader.sh $TUN_NAME_FILE_PATH $timeout)
#-----------Get available tun-----------
REMOTE_AVAILABLE_TUN_DEV_ID=$(tun_dev_id "$min_available_tun")
echo "REMOTE_AVAILABLE_TUN_DEV_ID=$REMOTE_AVAILABLE_TUN_DEV_ID"

# kill same host tun dev TODO if PIDs are in the same ns
pkill -9 -f "ssh.*\-w$SSH_TUN_DEV_ID+:[0-9]+.*" 2>/dev/null || true

# Wait for the ${SSH_TUN_DEV} device to be created
while true; do
    # echo "ip link show"
    # ip link show
    # pkill -9 -f "ssh.*\-w[0-9]+:$REMOTE_AVAILABLE_TUN_DEV_ID.*$REMOTE_IP" 2>/dev/null || true
    #     pgrep -f "ssh.*-w[0-9]+:[0-9]+.*$REMOTE_IP" | 
    #     while read -r pid; do
    #         # Get the command line for the process
    #         cmdline=$(cat /proc/$pid/cmdline)
            
    #         # Check if it matches the exclusion pattern
    #         if [[ ! $cmdline =~ ssh.*-w[0-9]+:$REMOTE_AVAILABLE_TUN_DEV_ID.*$remote_IP ]]; then
    #             # Kill the process if it doesn't match the exclusion pattern
    #             kill -9 $pid
    #         fi
    #     done
    # echo "killed."
    autossh -M 0 -f -N -o "ServerAliveInterval=10" \
        -o "ServerAliveCountMax=1" \
        -o "StrictHostKeyChecking=no" \
        -o "UserKnownHostsFile=/dev/null" \
        -w$SSH_TUN_DEV_ID:$REMOTE_AVAILABLE_TUN_DEV_ID $REMOTE_IP
    echo "connection triggered."
    AUTOSSH_PID=$(pgrep -f "autossh.*\-w$SSH_TUN_DEV_ID:$REMOTE_AVAILABLE_TUN_DEV_ID.*$REMOTE_IP")
    echo -e "AUTOSSH_PID:\t$AUTOSSH_PID"
    sleep $SLEEP_INTERVAL

  # Check if the ${SSH_TUN_DEV} device exists
  if ip link show $SSH_TUN_DEV > /dev/null 2>&1; then
    echo "SSH connection to $REMOTE_IP established, $SSH_TUN_DEV device created."
    break
  else
    echo "Waiting for SSH connection to $REMOTE_IP and $SSH_TUN_DEV device creation..."
    COUNTER=$((COUNTER + SLEEP_INTERVAL))
    if [ $COUNTER -ge $TIMEOUT ]; then
      echo "Timeout reached. SSH connection or $SSH_TUN_DEV device creation failed."
      exit 1
    fi
  fi
done

#TODO bug: reserved IP subdomain. If there are multiple connection on remote server tun0, and tun1, client 10.0.1.1 and 
# other client 10.0.0.1, remote tun0 and tun1 10.0.0.2 and 10.0.0.2. It is a bug.
# empty subdomain should be calculated when empty tun dev id is getting.