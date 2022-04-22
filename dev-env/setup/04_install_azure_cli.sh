#!/usr/bin/env bash

ARCH=$(dpkg --print-architecture)
RELEASE=$(lsb_release -cs)

curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
apt-add-repository "deb [arch=$ARCH] https://packages.microsoft.com/repos/azure-cli/ $RELEASE main"
apt-get update
apt-get install -y azure-cli