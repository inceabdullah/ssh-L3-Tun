#!/bin/bash

DEF_ROUTE_ONLY=false

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
    --def-route-only)
    DEF_ROUTE_ONLY=true
    shift
    ;;
    *)
    echo "Unknown option: $key"
    exit 1
    ;;
  esac
done


if [ "$DEF_ROUTE_ONLY" = false ]; then
  ip r d $REMOTE_IP/32 2>/dev/null || true
  ip r a $REMOTE_IP/32 via $VETH_ADDR dev $VPEER
fi


# Def route

ip r r default via $SSH_TUN_IP dev $SSH_TUN_DEV
