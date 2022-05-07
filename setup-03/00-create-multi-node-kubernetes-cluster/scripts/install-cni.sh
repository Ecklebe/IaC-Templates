#!/usr/bin/env bash

set -eu -o pipefail

CNI_CONFIG_DIR=/etc/cni/net.d

wget -P /tmp/downloads/cni https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin /tmp/downloads/cni/cni-plugins-linux-amd64-v1.1.1.tgz
rm -rf /tmp/downloads/cni

mkdir -p $CNI_CONFIG_DIR
cat << EOF | tee $CNI_CONFIG_DIR/10-containerd-net.conflist
{
  "cniVersion": "1.1.1",
  "name": "containerd-net",
  "plugins": [
    {
      "type": "bridge",
      "bridge": "cni0",
      "isGateway": true,
      "ipMasq": true,
      "promiscMode": true,
      "ipam": {
        "type": "host-local",
        "ranges": [
          [{
            "subnet": "10.88.0.0/16"
          }],
          [{
            "subnet": "2001:4860:4860::/64"
          }]
        ],
        "routes": [
          { "dst": "0.0.0.0/0" },
          { "dst": "::/0" }
        ]
      }
    },
    {
      "type": "portmap",
      "capabilities": {"portMappings": true}
    }
  ]
}
EOF