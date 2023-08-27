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
### This step is optional and is useful if you need the absolute path
CHECK_REMOTE_COMMAND_FILE_PATH_ABS="$(readlink -f "$CHECK_REMOTE_COMMAND_FILE_PATH")"
echo "CHECK_REMOTE_COMMAND_FILE_PATH_ABS: $CHECK_REMOTE_COMMAND_FILE_PATH_ABS"

## scp.sh
SCP_FILE_PATH="$SCRIPT_DIR/../remote/scp.sh"
### This step is optional and is useful if you need the absolute path
SCP_FILE_PATH_ABS="$(readlink -f "$SCP_FILE_PATH")"

## run_remote_command.sh
RUN_REMOTE_COMMAND_FILE_PATH="$SCRIPT_DIR/../remote/run_remote_command.sh"
RUN_REMOTE_COMMAND_FILE_PATH_ABS="$(readlink -f "$RUN_REMOTE_COMMAND_FILE_PATH")"

source $HELPERS_DIR_ABS




# Check remote quincy-server and quincy-users
## Run check_remote_command.sh and capture the result
REMOTE_QUINCY_COMMAND="quincy-server"
REMOTE_PATH="/usr/local/bin"
LOCAL_BIN_PREFIX="$REMOTE_PATH"
LOCAL_QUINCY_BIN_PATHS="quincy-server quincy-users"

result=$(bash $CHECK_REMOTE_COMMAND_FILE_PATH_ABS $REMOTE_IP $REMOTE_QUINCY_COMMAND || true)
echo "result: $result"
## Check the result to see if the command exists
if [[ $result == *"exists"* ]]; then
  echo "The command exists on the remote machine."
else
  echo "The command does not exist on the remote machine."
  info_log_await "copy quincy-server and quincy-users to remote $REMOTE_IP"
    for local_bin in $LOCAL_QUINCY_BIN_PATHS; do
        info_log "send $local_bin to the remote $REMOTE_IP in the path $REMOTE_PATH"
        bash $SCP_FILE_PATH_ABS $REMOTE_IP $LOCAL_BIN_PREFIX/$local_bin $REMOTE_PATH
    done
  # send conf files
  ## mkdir conf folder /root/.quincy
  REMOTE_CONF_DIR="/root/.quincy"
  REMOTE_COMMAND="mkdir -p $REMOTE_CONF_DIR"
  bash $RUN_REMOTE_COMMAND_FILE_PATH_ABS --remote-ip $REMOTE_IP --command "$REMOTE_COMMAND"
  ## send confs
  CONF_PATHS="server.toml cert users"
    for conf_path in $CONF_PATHS; do
        info_log "send $conf_path to the remote $REMOTE_IP in the path $REMOTE_CONF_DIR"
        bash $SCP_FILE_PATH_ABS $REMOTE_IP $SCRIPT_DIR/$conf_path $REMOTE_CONF_DIR
    done


fi

#TODO cp server conf end examples users file, then send it to remote
# when sending binaries. to /root/.quincy dir
# Check quincy server binary if running on remote, if it does, check port the binary of it, then reconf client config
# Not forget that: /etc/hosts config