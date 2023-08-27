#!/bin/bash

# Get the full path of the current script
SCRIPT_PATH="$(readlink -f "$0")"

# Extract the directory of the script
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
echo "SCRIPT_DIR: $SCRIPT_DIR"


# Define the relative path to the helpers directory
HELPERS_DIR="$SCRIPT_DIR/../helpers.sh"

# Canonicalize the relative path to get the absolute path
# This step is optional and is useful if you need the absolute path
HELPERS_DIR_ABS="$(readlink -f "$HELPERS_DIR")"

source $HELPERS_DIR_ABS

