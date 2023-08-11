#!/bin/bash

while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    --remote-ip)
    REMOTE_IP="$2"
    shift
    shift
    ;;
    --veth-addr)
    VETH_ADDR="$2"
    shift
    shift
    ;;
    --vpeer)
    VPEER="$2"
    shift
    shift
    ;;
    --ssh-tun-ip)
    SSH_TUN_IP="$2"
    shift
    shift
    ;;
    --ssh-tun-dev)
    SSH_TUN_DEV="$2"
    shift
    shift
    ;;
    *)
    echo "Unknown option: $key"
    exit 1
    ;;
  esac
done


ip r d $REMOTE_IP/32 2>/dev/null || true
ip r a $REMOTE_IP/32 via $VETH_ADDR dev $VPEER

# Def route

ip r r default via $SSH_TUN_IP dev $SSH_TUN_DEV
