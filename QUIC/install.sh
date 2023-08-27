#!bin/bash


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


REPO_DIR="$SCRIPT_DIR/quincy"
echo "REPO_DIR: $REPO_DIR"
QUINCY_REPO="https://github.com/M0dEx/quincy.git"
QUINCY_COMMIT_HASH="46c4728b07de7999e0ceca1864334a93761f0845"

# Check if the directory is empty or not
if [ -z "$(ls -A $REPO_DIR)" ]; then
  info_log_await "$REPO_DIR is empty. Cloning..."
  mkdir -p "$REPO_DIR"
  git clone -n "$QUINCY_REPO" "$REPO_DIR"
  cd "$REPO_DIR"
  git checkout $QUINCY_COMMIT_HASH


else
  info_log_await "$REPO_DIR is not empty."
fi

# rust check
# Check if 'cargo' command is available
if command -v cargo >/dev/null 2>&1; then
  echo "Cargo is already installed."
else
  echo "Cargo is not installed. Installing Rust..."
  # Install Rust using rustup
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  # Add cargo to PATH for the current session
  source $HOME/.cargo/env
fi

