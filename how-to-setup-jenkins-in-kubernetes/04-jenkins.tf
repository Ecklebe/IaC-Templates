/*
Get your 'admin' user password by running:
$ jsonpath="{.data.jenkins-admin-password}"
$ secret=$(kubectl get secret -n jenkins jenkins -o jsonpath=$jsonpath)
$ echo $(echo $secret | base64 --decode)


Get the Jenkins URL to visit by running these commands in the same shell:

$ jsonpath="{.spec.ports[0].nodePort}"
$ NODE_PORT=$(kubectl get -n jenkins -o jsonpath="{.spec.ports[0].nodePort}" services jenkins)
$ jsonpath="{.items[0].status.addresses[0].address}"
$ NODE_IP=$(kubectl get nodes -n jenkins -o jsonpath=$jsonpath)
$ echo http://$NODE_IP:$NODE_PORT/login

http://
*/

# Variable declaration
variable "jenkins_chart_name" {
  type        = string
  description = "Jenkins Helm chart name."
}
variable "jenkins_chart_repo" {
  type        = string
  description = "Jenkins Helm repository name."
}
variable "jenkins_chart_version" {
  type        = string
  description = "Jenkins Helm repository version."
}
variable "jenkins_persistent_volume_host_path" {
  type        = string
  description = "Path to the place where to store the jenkins volume"
}

variable "jenkins_admin_username" {
  type        = string
  description = "Name of the service acount for the jenkins admin"
}

resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"

    labels = {
      name        = "jenkins"
      description = "jenkins"
    }
  }
}

/*
https://stackoverflow.com/a/63524931
*/
resource "kubernetes_persistent_volume" "jenkins-pv" {
  metadata {
    name = "jenkins-pv"
  }
  spec {
    capacity = {
      storage = "8Gi"
    }
    storage_class_name = "jenkins-pv"
    access_modes       = ["ReadWriteOnce"]
    persistent_volume_source {
      host_path {
        path = var.jenkins_persistent_volume_host_path
        type = "DirectoryOrCreate"
      }
    }
  }
  depends_on = [
    kubernetes_namespace.jenkins
  ]
}


resource "kubernetes_service_account" "jenkins" {
  metadata {
    name      = var.jenkins_admin_username
    namespace = kubernetes_namespace.jenkins.metadata.0.name
  }
}

resource "kubernetes_cluster_role" "jenkins" {
  metadata {
    annotations = {
      "rbac.authorization.kubernetes.io/autoupdate" : "true"
    }
    labels = {
      "kubernetes.io/bootstrapping" : "rbac-defaults"
    }
    name = "jenkins"
  }
  rule {
    api_groups = ["*"]
    verbs = [
      "create",
      "get",
      "watch",
      "delete",
      "list",
      "patch",
      "update"
    ]
    resources = [
      "statefulsets",
      "services",
      "replicationcontrollers",
      "replicasets",
      "podtemplates",
      "podsecuritypolicies",
      "pods",
      "pods/log",
      "pods/exec",
      "podpreset",
      "poddisruptionbudget",
      "persistentvolumes",
      "persistentvolumeclaims",
      "jobs",
      "endpoints",
      "deployments",
      "deployments/scale",
      "daemonsets",
      "cronjobs",
      "configmaps",
      "namespaces",
      "events",
      "secrets",
    ]
  }
  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs = [
      "get",
      "list",
      "watch",
      "update"
    ]
  }
}

resource "kubernetes_cluster_role_binding" "jenkins" {
  metadata {
    annotations = {
      "rbac.authorization.kubernetes.io/autoupdate" : "true"
    }
    labels = {
      "kubernetes.io/bootstrapping" : "rbac-defaults"
    }
    name = "jenkins"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "jenkins"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = "system:serviceaccounts:jenkins"
  }
}

data "template_file" "jenkins_values" {
  template = file("./templates/jenkins-values.yml")

  vars = {
    JENKINS_SERVICE_ACCOUNT = kubernetes_service_account.jenkins.metadata.0.name
    STORAGE_CLASS           = kubernetes_persistent_volume.jenkins-pv.metadata.0.name

    INGRESS_HOSTNAME = "jenkins.${var.domain}"
    INGRESS_ENABLED  = true

    # For minikube, set this to NodePort, elsewhere use LoadBalancer
    # Use ClusterIP if your setup includes ingress controller
    SERVICE_TYPE = "ClusterIP"
  }
}

resource "helm_release" "jenkins" {

  name       = var.jenkins_chart_name
  repository = var.jenkins_chart_repo
  chart      = var.jenkins_chart_name
  #version    = var.jenkins_chart_version
  namespace = kubernetes_namespace.jenkins.metadata.0.name
  timeout   = 600
  values = [
    data.template_file.jenkins_values.rendered
  ]

  depends_on = [
    kubernetes_namespace.jenkins,
    kubernetes_persistent_volume.jenkins-pv,
    kubernetes_service_account.jenkins
  ]
}

