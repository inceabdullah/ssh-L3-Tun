#!/bin/bash

# The name of the binary to check
BINARY_NAME="$1"

# Check if the binary is running
pgrep -f "$BINARY_NAME" >/dev/null 2>&1

# Check the exit status
if [ $? -eq 0 ]; then
  echo "$BINARY_NAME is running."

  # Get the Process ID (PID) of the running binary
  PID=$(pgrep -f "$BINARY_NAME")

  # Find out which port the binary is listening on
  PORT=$(lsof -Pan -p $PID -i | grep -i "listen" | awk '{ print $9 }' | cut -d':' -f2)

  if [ -n "$PORT" ]; then
    echo "$BINARY_NAME is listening on port(s): $PORT"
  else
    echo "$BINARY_NAME is not listening on any port."
  fi

else
  echo "$BINARY_NAME is not running."
fi
