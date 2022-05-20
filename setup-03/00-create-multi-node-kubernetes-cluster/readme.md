# Setup a kubernetes cluster with vagrant and ansible

Taken over from the blog (1), updated to Ubuntu focal and modified so that an execution from a windows host can be done.

Needed adaptations for the deprecation of Dockershim (2) & (3) & (4) in Kubernetes
1.24.0 are also covered.
## Setup the cluster

Switch to the folder for the ubuntu base and build the box
```shell
cd packer_templates\ubuntu
packer build -only=virtualbox-iso ubuntu-20.04-amd64.json
```

Then add the box to vagrant so that the vagrant up is recognizing the box.
```shell
vagrant box add my-cluster-box file:///C:/git_repo/IaC-Templates/setup-03/00-create-multi-node-kubernetes-cluster/builds/ubuntu-20.04.virtualbox.box
```

Then return to the folder where the vagrantfile is stored and bring the cluster up.
```shell
cd ../../
vagrant up
```

## Steps to verify a working cluster

### Option 1

Connect from the host to the cluster
```shell
kubectl --kubeconfig .\.temp\config get nodes
```

```shell
kubectl --kubeconfig .\.temp\config get pods --all-namespaces
```

### Option 2

Connect to the master via ssh
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
5. https://www.digitalocean.com/community/tutorials/how-to-create-a-kubernetes-cluster-using-kubeadm-on-ubuntu-20-04
6. https://github.com/chef/bento
