#!/bin/bash

# Check if sufficient arguments are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <remote_host> <command_to_check>"
  exit 1
fi

# Remote server details
REMOTE_HOST="$1"

# Command to check
COMMAND_TO_CHECK="$2"

# Check if the command exists on the remote machine
ssh "root@${REMOTE_HOST}" "command -v ${COMMAND_TO_CHECK} >/dev/null 2>&1"

# Check the exit status
if [ $? -eq 0 ]; then
  echo "The command ${COMMAND_TO_CHECK} exists on the remote machine ${REMOTE_HOST}."
else
  echo "The command ${COMMAND_TO_CHECK} does not exist on the remote machine ${REMOTE_HOST}."
fi
