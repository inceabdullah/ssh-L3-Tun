#!/bin/bash

# Display help message
display_help() {
    echo "Usage: $0 --remote-ip <REMOTE_IP>"
    echo
    echo "Check if a command exists on a remote machine."
    echo
    echo "  --remote-ip   IP address of the remote machine"
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
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Get the full path of the current script
SCRIPT_PATH="$(readlink -f "$0")"

# Extract the directory of the script
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
echo "SCRIPT_DIR: $SCRIPT_DIR"


# SCRIPTS
## helpers
### Define the relative path to the helpers directory
HELPERS_DIR="$SCRIPT_DIR/../helpers.sh"

# ##Canonicalize the relative path to get the absolute path
### This step is optional and is useful if you need the absolute path
HELPERS_DIR_ABS="$(readlink -f "$HELPERS_DIR")"

## check_remote_command.sh
### Define the relative path to the helpers directory
CHECK_REMOTE_COMMAND_FILE_PATH="$SCRIPT_DIR/../remote/check_remote_command.sh"
# ##Canonicalize the relative path to get the absolute path
### This step is optional and is useful if you need the absolute path
CHECK_REMOTE_COMMAND_FILE_PATH_ABS="$(readlink -f "$CHECK_REMOTE_COMMAND_FILE_PATH")"
echo "CHECK_REMOTE_COMMAND_FILE_PATH_ABS: $CHECK_REMOTE_COMMAND_FILE_PATH_ABS"

source $HELPERS_DIR_ABS




# Check remote quincy-server and quincy-users
## Run check_remote_command.sh and capture the result
REMOTE_QUINCY_COMMAND="quincy-server"
result=$(bash $CHECK_REMOTE_COMMAND_FILE_PATH_ABS $REMOTE_IP $REMOTE_QUINCY_COMMAND || true)
echo "result: $result"
## Check the result to see if the command exists
if [[ $result == *"exists"* ]]; then
  echo "The command exists on the remote machine."
else
  echo "The command does not exist on the remote machine."
fi
