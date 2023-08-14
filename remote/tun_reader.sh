#!/bin/bash

file_to_read="$1"
timeout=$2
counter=0

# Loop until the file exists and has at least one line or until the timeout is reached
while true; do
  if [ -f "$file_to_read" ] && [ -s "$file_to_read" ]; then
    # Read the first line of the file and exit the loop
    read -r first_line < "$file_to_read"
    echo "$first_line"
    exit 0
  fi
  
  # Increment the counter and check for timeout
  ((counter++))
  if [ $counter -ge $timeout ]; then
    echo "Timeout reached!"
    exit 1
  fi
  
  # Wait for a short period before checking again
  sleep 1
done
