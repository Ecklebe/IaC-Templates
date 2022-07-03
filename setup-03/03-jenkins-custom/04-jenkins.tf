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

Windows command line + (1)
kubectl get secret -n jenkins jenkins -o jsonpath="{.data.jenkins-admin-password}"

(1) https://github.com/jenkinsci/helm-charts/blob/main/charts/jenkins/VALUES_SUMMARY.md#jenkins-plugins
(2) https://hands-on-tech.github.io/2020/03/15/k8s-jenkins-example.html
(3) https://github.com/jenkinsci/docker/blob/master/README.md
(4) https://www.base64decode.org/
*/

# Variable declaration
variable "domain" {
  description = "Path to the kubernetes config"
  type        = string
}
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
variable "jenkins_controller_origin_image_name" {
  type        = string
  description = "Name of the origin docker image that should be used for the jenkins controller"
}
variable "jenkins_controller_custom_image_name" {
  type        = string
  description = "Name of the docker image that will be build through terraform"
}
variable "jenkins_controller_origin_image_version" {
  type        = string
  description = "Name of the origin docker image that should be used for the jenkins controller"
}
variable "jenkins_controller_custom_image_version" {
  type        = string
  description = "Name of the docker image that will be build through terraform"
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
    capacity           = {
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
    labels      = {
      "kubernetes.io/bootstrapping" : "rbac-defaults"
    }
    name        = "jenkins"
  }
  rule {
    api_groups = ["*"]
    verbs      = [
      "create",
      "get",
      "watch",
      "delete",
      "list",
      "patch",
      "update"
    ]
    resources  = [
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
    verbs      = [
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
    labels      = {
      "kubernetes.io/bootstrapping" : "rbac-defaults"
    }
    name        = "jenkins"
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

resource "docker_image" "jenkins" {
  name       = var.jenkins_controller_custom_image_name
  build {
    path      = "../../docker-based-service-templates/jenkins"
    tag       = [join("", [var.jenkins_controller_custom_image_name, ":", var.jenkins_controller_custom_image_version])]
    build_arg = {
      parent_image : join("", [
        var.jenkins_controller_origin_image_name, ":", var.jenkins_controller_origin_image_version
      ])
    }
  }
  provisioner "local-exec" {
    command = join("", [
      "docker push ", var.jenkins_controller_custom_image_name, ":", var.jenkins_controller_custom_image_version
    ])
  }
}

data "template_file" "jenkins_values" {
  template = file("./templates/jenkins-values.yml")

  vars       = {
    JENKINS_SERVICE_ACCOUNT = kubernetes_service_account.jenkins.metadata.0.name
    STORAGE_CLASS           = kubernetes_persistent_volume.jenkins-pv.metadata.0.name

    INGRESS_HOSTNAME = "jenkins.${var.domain}"
    INGRESS_ENABLED  = true

    # For minikube, set this to NodePort, elsewhere use LoadBalancer
    # Use ClusterIP if your setup includes ingress controller
    SERVICE_TYPE = "ClusterIP"

    # The name of the docker image to use for the jenkins controller
    CONTROLLER_IMAGE_NAME    = var.jenkins_controller_custom_image_name
    CONTROLLER_IMAGE_VERSION = var.jenkins_controller_custom_image_version
  }
  depends_on = [docker_image.jenkins]
}

resource "helm_release" "jenkins" {

  name         = var.jenkins_chart_name
  repository   = var.jenkins_chart_repo
  chart        = var.jenkins_chart_name
  #version    = var.jenkins_chart_version
  namespace    = kubernetes_namespace.jenkins.metadata.0.name
  timeout      = 2400
  force_update = true
  values       = [
    data.template_file.jenkins_values.rendered
  ]

  depends_on = [
    kubernetes_namespace.jenkins,
    kubernetes_persistent_volume.jenkins-pv,
    kubernetes_service_account.jenkins,
    data.template_file.jenkins_values
  ]
}
