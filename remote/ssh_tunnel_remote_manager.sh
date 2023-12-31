#!/bin/bash

exec 9< "$0"
timeout=$1

flock -x 9

get_min_available_tun() {
  # Create an array to track the availability of tun devices
  declare -A tun_devices
  for i in {0..9}; do
    tun_devices["tun$i"]=0
  done

  # Check the existing tun devices
  for dev in /sys/class/net/tun*; do
    if [[ -e $dev ]]; then
      tun_name=$(basename $dev)
      tun_devices["$tun_name"]=1
    fi
  done

  # Find the minimum available tun device
  for i in {0..9}; do
    if [[ ${tun_devices["tun$i"]} -eq 0 ]]; then
      echo "tun$i"
      return 0
    fi
  done

  echo "No available tun devices found."
  return 1
}

# Example usage
tun_device=$(get_min_available_tun)
echo "$tun_device"
sleep 20