# How to setup a Jenkins in a Kubernetes Cluster

This template describes the setup of a Jenkins inside a kubernetes cluster behind the loadbalancer and proxy Traefik.

Prerequisites:

1. Terraform executable downloaded and added to the system path
2. Helm executable downloaded and added to the system path
3. Docker Desktop on Windows installed
4. Kubernetes inside Docker Desktop active and running
5. WSL 2 activated in Docker Desktop

## First Step

Copy the file "terraform.tfvars.tmp" to "terraform.tfvars" and configure in the copy the parameters to your needs.

## Second Step

Create the folder that you defined for the parameter "jenkins_persistent_volume_host_path". This will be done otherwise
also by Terraform, but then the access rights are not in the way that the Jenkins installation wizard can use the
directory.

## Third Step

Open a commandline window and change the working directory to this folder here. Execute then "terraform init"

## Fourth Step

Execute "terraform plan" to check if the config is valid. If so execute further with "terraform apply". This will start
the setup process of the Jenkins, Traefik and further more the needed account, namespaces and ingressroutes.

## Five's Step

If the setup is done and succesful, you should reach the Jenkins under
"jenkins.<your defined domain>". For the login credentials you need to extract this from the installation. A way how to
do this can be found on the offical jenkins installation page for Kubernetes.

# Debug

HELM_DEBUG=1 TF_LOG=TRACE