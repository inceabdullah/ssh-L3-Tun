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

# Wait for the ${SSH_TUN_DEV} device to be created
while true; do
    # echo "ip link show"
    # ip link show
    pkill -9 -f "ssh.*\-w.*$REMOTE_IP" 2>/dev/null || true
    echo "killed."
    autossh -M 0 -f -N -o "ServerAliveInterval=10" \
        -o "ServerAliveCountMax=1" \
        -w$SSH_TUN_DEV_ID:1 $REMOTE_IP
    echo "connection triggered."
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

