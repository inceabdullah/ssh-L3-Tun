#!/bin/bash

export $(grep -v '^#' .env | xargs -0)

scp setup.sh helpers.sh nft_host.sh nft_revert_host.sh root@$TEST_SERVER_IP:$TEST_SERVER_PROJECT_PATH
