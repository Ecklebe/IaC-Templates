#!/usr/bin/env bash

apt-add-repository -y ppa:ansible/ansible
apt-get update && apt-get install -y ansible python3-pip
pip3 install pywinrm pyvmomi ansible
python3 --version