#!/bin/bash

# Display help message
display_help() {
    echo "Usage: $0 --remote-ip <REMOTE_IP> --command <COMMAND>"
    echo
    echo "Run a command exists on a remote machine."
    echo
    echo "  --remote-ip   IP address of the remote machine"
    echo "  --command     command to be run on the remote machine"
}

# Parse named arguments
if [[ "$#" -eq 0 ]]; then
    display_help
    exit 1
fi

# Parse named arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --remote-ip) REMOTE_IP="$2"; shift ;;
        --command) COMMAND="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done


# Remote server details
REMOTE_HOST="$REMOTE_IP"

ssh \
    -o "StrictHostKeyChecking=no" \
    -o "UserKnownHostsFile=/dev/null" \
    "root@${REMOTE_HOST}" "${COMMAND}"

# Check the exit status
if [ $? -eq 0 ]; then
  echo "The command ${COMMAND} is run on remote machine ${REMOTE_HOST}."
else
  echo "The command ${COMMAND} is not run on the remote machine ${REMOTE_HOST}."
  exit 1
fi
