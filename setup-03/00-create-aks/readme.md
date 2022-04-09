# Create Azure Kubernetes Service

This setup covers the creation of a kubernetes service (4) in the Azure Cloud.

## Prerequisites

- a Azure subscription
- the Azure cli installed (1)
- a service principal (2)
- a ssh key (3)

## Troubleshooting

To get the available virtual machines in your location and for your subscription:

````
az vm list-skus --location "germanywestcentral" --output table --resource-type virtualMachines --subscription <id> 
````

## Linked references

(1) https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
(
2) https://docs.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure?tabs=bash#create-a-service-principal
(3) https://docs.microsoft.com/en-us/azure/virtual-machines/linux/ssh-from-windows#create-an-ssh-key-pair
(4) https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks
