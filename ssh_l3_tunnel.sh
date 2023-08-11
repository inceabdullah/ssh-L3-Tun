#!/bin/bash

REMOTE_IP=$1
SSH_TUN_DEV="$2"

if [ -z "$SSH_TUN_DEV" ]; then
    SSH_TUN_DEV="tun0"
fi

TIMEOUT=60 # Timeout in seconds
SLEEP_INTERVAL=10 # Sleep interval in seconds
COUNTER=0

# Wait for the ${SSH_TUN_DEV} device to be created
while true; do
    pkill -9 -f "ssh.*\-w.*$REMOTE_IP" 2>/dev/null || true
    sleep 2
    autossh -M 0 -f -N -w0:1 $REMOTE_IP
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

