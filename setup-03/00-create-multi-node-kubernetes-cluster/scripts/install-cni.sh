#!/usr/bin/env bash

set -eu -o pipefail

CNI_VERSION=$1
CNI_CONFIG_DIR=/etc/cni/net.d
ARCHITECTURE=$2
OS_TYPE=$3

wget -P /tmp/downloads/cni https://github.com/containernetworking/plugins/releases/download/v"$CNI_VERSION"/cni-plugins-"$OS_TYPE"-"$ARCHITECTURE"-v"$CNI_VERSION".tgz
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin /tmp/downloads/cni/cni-plugins-"$OS_TYPE"-"$ARCHITECTURE"-v"$CNI_VERSION".tgz
rm -rf /tmp/downloads/cni

mkdir -p $CNI_CONFIG_DIR
cat << EOF | tee $CNI_CONFIG_DIR/10-containerd-net.conflist
{
 "cniVersion": "0.4.0",
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
           "subnet": "2001:db8:4860::/64"
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