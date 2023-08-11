#!/bin/bash

REMOTE_IP=$1

TIMEOUT=60 # Timeout in seconds
SLEEP_INTERVAL=5 # Sleep interval in seconds
COUNTER=0

pkill -9 -f "ssh.*\-w.*$REMOTE_IP" 2>/dev/null || true
sleep 2
autossh -M 0 -f -N -w0:1 $REMOTE_IP


# Wait for the tun0 device to be created
while true; do
  # Check if the tun0 device exists
  if ip link show tun0 > /dev/null 2>&1; then
    echo "SSH connection to $REMOTE_IP established, tun0 device created."
    break
  else
    echo "Waiting for SSH connection to $REMOTE_IP and tun0 device creation..."
    sleep $SLEEP_INTERVAL
    COUNTER=$((COUNTER + SLEEP_INTERVAL))
    if [ $COUNTER -ge $TIMEOUT ]; then
      echo "Timeout reached. SSH connection or tun0 device creation failed."
      exit 1
    fi
  fi
done

