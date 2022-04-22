#!/usr/bin/env bash

# install docker
# https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script
apt-get install -y curl
curl -fsSL https://get.docker.com -o get-docker.sh
sh ./get-docker.sh