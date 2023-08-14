#!/bin/bash

WAIT_FOR_RD=1


info_log() {
  echo -e "\e[1;33m$@\e[0m"
}

info_log_await() {
  info_log $@
  sleep $WAIT_FOR_RD
}

function parse_yaml { #https://stackoverflow.com/a/21189044
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

set_new_tun_dev() {
  OLD_TUN_DEV="$1"

  if [ "$OLD_TUN_DEV" == "tun0" ]; then
    echo "tun2"
  elif [ "$OLD_TUN_DEV" == "tun2" ]; then
    echo "tun0"
  else
    echo "Invalid tunnel device: $OLD_TUN_DEV" >&2
    return 1
  fi
}

set_new_ssh_tun_addr() {
  OLD_SSH_TUN_ADDR="$1"

  if [ "$OLD_SSH_TUN_ADDR" == "10.0.1.1" ]; then
    echo "10.0.2.1"
  elif [ "$OLD_SSH_TUN_ADDR" == "10.0.2.1" ]; then
    echo "10.0.1.1"
  else
    echo "Invalid SSH tunnel address: $OLD_SSH_TUN_ADDR" >&2
    return 1
  fi
}

increment_last_octet() {
  IP="$1"
  # Split the IP address into its octets
  IFS='.' read -ra OCTETS <<< "$IP"
  # Increment the last octet
  LAST_OCTET=$((OCTETS[3] + 1))
  # Reassemble the IP address with the incremented last octet
  NEW_IP="${OCTETS[0]}.${OCTETS[1]}.${OCTETS[2]}.${LAST_OCTET}"
  echo "$NEW_IP"
}

tun_dev_id() {
  TUN_DEV="$1"
  NUMBER="${TUN_DEV#tun}"
  echo "$NUMBER"
}

get_external_ip() {
  local TUN_NS_NAME="$1"
  local external_ip

  external_ip=$(ip netns exec "${TUN_NS_NAME}" curl -sS --max-time 5 ifconfig.me)

  # Check if the command was successful
  if [ $? -ne 0 ]; then
    echo "An error occurred while fetching the external IP." >&2
    return 1
  fi

  echo "$external_ip"
  return 0
}

generate_uuid() {
  local N B T

  # Generate 16 random hex digits
  for (( N=0; N<16; ++N ))
  do
    B=$(($RANDOM%256))

    # In the 7th byte, force the high nibble to 0x40 to set the version to 4
    if [ $N -eq 6 ]; then
      B=$(($B & 0x0F | 0x40))
    fi

    # In the 9th byte, force the high nibble to 0x80 to set the variant to 1
    if [ $N -eq 8 ]; then
      B=$(($B & 0x3F | 0x80))
    fi

    printf -v T '%02x' $B
    UUID+=$T
  done

  # Insert dashes at the appropriate positions
  echo ${UUID:0:8}-${UUID:8:4}-${UUID:12:4}-${UUID:16:4}-${UUID:20:12}
}