# Setup Three

This template describes the setup inside the build-in kubernetes cluster from Docker Desktop on Windows.

Prerequisites:

1. Terraform executable downloaded and added to the system path
2. Helm executable downloaded and added to the system path
3. Docker Desktop on Windows installed
4. Kubernetes setup and running
   1. either in Docker Desktop active and running
   2. or created as Azure Kubernetes Service (AKS) << here only the creation of the aks is tested
5. WSL 2 activated in Docker Desktop and set to default on the system.
6. A Windows operating system if that was until now not clear

## Create Cluster Basics

After all prerequisites are fulfilled the next two mandatory steps can be executed. With this steps the basic cluster
setup will be done and basic services will be applied.

### First Step

In the first step we will apply the basic setup like custom resource definitions (CRD) to the kubernetes cluster. To do
this, change your working directory to the sub-folder ``01-kubernetes-setup`` and copy the file
"terraform.tfvars.tmp" to "terraform.tfvars". Reconfigure the parameters if needed and run the terraform commands
(``terraform init`` & ``terraform apply``) afterwards. Further details to the steps can be found in the folder readme.

### Second Step

In the second step further basic services will be applied to the cluster. To do so change again, like in the first step,
your working directory now to the sub-folder ``02-basic-services``. Copy the file "terraform.tfvars.tmp" to
"terraform.tfvars" and configure in the copy the parameters to your needs. After this run the terraform
commands (``terraform init`` & ``terraform apply``). Further details to the steps can here also be found in the folder
readme.

## Service Setup(s)

Depending on your need you can run one of the following services in your cluster after the cluster basics setup:

1. Jenkins
    - Custom instance of a Jenkins
2. Whoami

To find out what in detailed is needed for each service setup, please take a look in the corresponding folder readme.

## Help

Sometimes it is needed to debug some parts more. In these cases the following two environment variables can be useful:

- HELM_DEBUG=1
- TF_LOG=TRACE

## Troubleshooting

If the apply fails
with ``x509: certificate signed by unknown authority (possibly because of "crypto/rsa: verification error" while trying to verify candidate authority certificate "kubernetes")``
then check if your copied kube config is up-to-date. It can be that after a update of Docker Desktop this error will
appear. Another error can also be that the WSL that is running the OLM installation as no connection to the kubectl.