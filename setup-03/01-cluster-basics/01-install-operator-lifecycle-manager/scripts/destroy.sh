#!/usr/bin/env bash

# https://operator-framework.github.io/olm-book/docs/uninstall-olm.html

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

OLM_VERSION="$1"

kubectl delete apiservices.apiregistration.k8s.io v1.packages.operators.coreos.com
kubectl delete -f "https://github.com/operator-framework/operator-lifecycle-manager/releases/download/${OLM_VERSION}/crds.yaml"
kubectl delete -f "https://github.com/operator-framework/operator-lifecycle-manager/releases/download/${OLM_VERSION}/olm.yaml"
exit 0