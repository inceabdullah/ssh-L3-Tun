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


# Build quincy

info_log_await "quincy has been building..."

cd "$REPO_DIR"
cargo build --release --manifest-path="$REPO_DIR/Cargo.toml"

# Rm all bynaries for quincy
## List of binary names to remove
BINARY_NAMES="quincy-client quincy-server quincy-users"

## Directories to search for binaries
directories=($(echo $PATH | tr ":" " "))

## Loop through each directory and remove binaries if found
for dir in "${directories[@]}"; do
  # Skip directories that start with /root
  if [[ "$dir" == /root* ]]; then
    continue
  fi
  for binary in $BINARY_NAMES; do
    info_log "rm binary: $binary in $dir"
    if [ -e "$dir/$binary" ]; then
      echo "Removing $binary from $dir"
      sudo rm "$dir/$binary"
    fi
  done
done

# cp binaries to /usr/local/bin
USR_BIN_DIR="/usr/local/bin"
for binary in $BINARY_NAMES; do
    info_log "cp $binary to $USR_BIN_DIR"
    cp "$REPO_DIR/target/release/$binary" "$USR_BIN_DIR"
done

# cp client config
info_log_await "cp client config"
cp -f "$REPO_DIR/examples/client.toml" "$SCRIPT_DIR"

CLIENT_CONFIG_FILE_PATH="$SCRIPT_DIR/client.toml"

info_log_await "def conf:"
cat "$CLIENT_CONFIG_FILE_PATH"


# reconf
## Generate a random password using OpenSSL and base64 encoding
random_username="l3-tun-$(generate_uuid)"
echo -e "\n\trandom_username: $random_username"
random_password=$(openssl rand -base64 32)
echo -e "\n\trandom_password: $random_password"


## File to edit
config_file="$CLIENT_CONFIG_FILE_PATH"

## Use sed to replace mtu and password values
sed -i "s/\(mtu = \).*/\1 1000/" "$config_file"
sed -i "s/\(username = \).*/\1 \"$random_username\"/" "$config_file"
sed -i "s|\(password = \).*|\1 \"$random_password\"|" "$config_file"

info_log_await "new conf:"
cat "$CLIENT_CONFIG_FILE_PATH"
