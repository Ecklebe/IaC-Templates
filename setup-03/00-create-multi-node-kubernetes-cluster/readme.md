# Setup a kubernetes cluster with vagrant and ansible

Taken over from the blog (1), updated to Ubuntu focal and modified so that an execution from a windows host can be done.

Needed adaptations for the deprecation of Dockershim (2) & (3) & (4) in Kubernetes
1.24.0 are also covered.

## Steps to verify a working cluster

```shell
# Connect to the master node
vagrant ssh k8s-master

# Get state of the nodes in the cluster
kubectl get nodes
```

## Troubleshooting

```shell
# Connect to the master node
vagrant ssh k8s-master

# Get more details over the node states
kubectl describe nodes
```

## Linked references
1. https://kubernetes.io/blog/2019/03/15/kubernetes-setup-using-ansible-and-vagrant/
2. https://kubernetes.io/blog/2020/12/08/kubernetes-1-20-release-announcement/#dockershim-deprecation
3. https://kubernetes.io/blog/2020/12/02/dont-panic-kubernetes-and-docker/
4. https://kubernetes.io/blog/2022/02/17/dockershim-faq/