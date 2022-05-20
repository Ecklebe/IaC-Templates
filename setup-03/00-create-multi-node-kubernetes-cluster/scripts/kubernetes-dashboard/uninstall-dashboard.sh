#!/usr/bin/env /bin/bash

set -eu -o pipefail

kubectl delete -f dashboard-cluster-role-binding.yaml
kubectl delete -f dashboard-adminuser.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.1/aio/deploy/recommended.yaml
