# Kubernetes setup

This folder takes care of the basic setup for kubernetes. Basic custom resource definitions (CRD) are applied here so
that future setup steps can use these definitions. Terraform needs them be applied separately as the
command ``terraform plan`` will connect to the kubernetes api to get the CRD(s).

There are different ways to apply CRD(s) to kubernetes:

- The first way would be applying them with ``kubectl apply -f some.yml``
- The second way is using the terraform named resource ``kubernetes_manifest``
  . This is also the reason why we need this pre-setup step here.