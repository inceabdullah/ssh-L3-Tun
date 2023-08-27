#!/bin/bash

# Check if sufficient arguments are provided
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <remote_host> <local_path> <remote_path>"
  exit 1
fi
echo "\$@: $@"
# Remote server details
REMOTE_HOST="$1"

LOCAL_PATH="$2"
REMOTE_PATH="$3"

# Check if the command exists on the remote machine
scp \
    -o "StrictHostKeyChecking=no" \
    -o "UserKnownHostsFile=/dev/null" \
    $LOCAL_PATH \
    "root@${REMOTE_HOST}:$REMOTE_PATH"

# Check the exit status
if [ $? -eq 0 ]; then
  echo "scp successful."
else
  echo "scp successful."
  exit 1
fi
