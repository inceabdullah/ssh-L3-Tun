#!/bin/bash

exec 9< "$0"

if ! flock -n -x 9; then
  echo "$$/$0 cannot get flock"
  exit 1
fi

# Function to show usage
usage() {
  echo "Usage: $0 --mode [default|change] [other parameters]"
  echo "  --mode default: Run default_connection.sh with the given parameters"
  echo "  --mode change: Run change_connection.sh with the given parameters"
  exit 1
}

# Check for the correct number of arguments
if [ "$#" -lt 2 ]; then
  usage
fi

# Parse the mode
if [ "$1" == "--mode" ]; then
  shift
  MODE="$1"
  shift
else
  usage
fi

# Check the mode and run the corresponding script
case "$MODE" in
  default)
    bash default_connection.sh "$@"
    ;;
  change)
    bash change_connection.sh "$@"
    ;;
  *)
    echo "Invalid mode: $MODE"
    usage
    ;;
esac
flock --unlock 9