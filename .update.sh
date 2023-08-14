#!/bin/bash

export $(grep -v '^#' .env | xargs -0)

scp -r setup.sh helpers.sh nft_host.sh nft_revert_host.sh ssh_l3_tunnel.sh tunnel_router.sh remote_nft_ruler.sh \
    change_connection.sh \
    default_connection.sh \
    tests \
    remote \
    .env \
    root@$TEST_SERVER_IP:$TEST_SERVER_PROJECT_PATH
