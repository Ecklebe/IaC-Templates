#!/bin/bash

set -eu -o pipefail

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.1/aio/deploy/recommended.yaml
kubectl apply -f dashboard-adminuser.yaml
kubectl apply -f dashboard-cluster-role-binding.yaml
kubectl create token admin-user -n kubernetes-dashboard
