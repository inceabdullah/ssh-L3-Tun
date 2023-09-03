#!/bin/bash

# Declare an associative array to store used subnets
declare -A usedSubnets

# Get IPs from the first argument and split them into an array
IFS=' ' read -ra ADDR <<< "$1"

# Store the subnets in the associative array
for ip in "${ADDR[@]}"; do
  echo "Given IP Address: $ip"
  # Extract the /24 subnet from the IP
  subnet="${ip%.*}.0"
  usedSubnets["$subnet"]=1
done

# Function to check if a subnet is used
isSubnetUsed() {
  [[ -n "${usedSubnets[$1]}" ]]
}

# Find the minimum unused subnet in 10.a.b.0/24
for a in {0..255}; do
  for b in {0..255}; do
    subnet="10.$a.$b.0"
    if ! isSubnetUsed "$subnet"; then
      echo "Minimum unused subnet: $subnet/24"
      exit 0
    fi
  done
done

echo "No unused subnet found in 10.a.b.0/24"
