# Setup a kubernetes cluster with vagrant and ansible

---
**NOTE**

Different parts of this setup in this folder comes from different sources and are slightly modified and combined in a 
different way. So I want to say thanks for there work. As best a possible I try to link where I took parts from. 

1. Vagrant Kubernetes Setup
   - Taken over from the blog (1) and the following adaptations are done: 
     - updated to Ubuntu focal
     - modified so that an execution from a windows host can be done.
     - added adaptations for the deprecation of Dockershim (2) & (3) & (4) in Kubernetes 1.24.0
2. Packer Box Build
   - Taken over from the bento project (6) and reduced to the virtualbox part.

---

## Setup of the kubernetes cluster

Switch to the folder for the ubuntu base box and build the box for virtualbox
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
