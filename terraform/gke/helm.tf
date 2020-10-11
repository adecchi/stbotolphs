resource "kubernetes_service_account" "helm_account" {
  depends_on = [google_container_cluster.master_node]
  metadata {
    name      = "helm-account"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "helm_role_binding" {
  metadata {
    name = kubernetes_service_account.helm_account.metadata.0.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.helm_account.metadata.0.name
    namespace = "kube-system"
  }
  provisioner "local-exec" {
    command = "sleep 15"
  }
}

provider "helm" {
  kubernetes {
    insecure         = false
    load_config_file = false
    host             = google_container_cluster.master_node.endpoint
    cluster_ca_certificate = base64decode(
      google_container_cluster.master_node.master_auth[0].cluster_ca_certificate,
    )
    client_key = base64decode(
      google_container_cluster.master_node.master_auth[0].client_key,
    )
    client_certificate = base64decode(
      google_container_cluster.master_node.master_auth[0].client_certificate,
    )
    token = data.google_client_config.current.access_token
  }
}

# Install Nginx Ingress
resource "helm_release" "nginx-ingress" {
  name       = "nging-ingress"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "nginx-ingress"


  cleanup_on_fail = true

  set {
    name  = "rbac.create"
    value = true
  }

  set {
    name  = "podSecurityPolicy.enabled"
    value = true
  }

  set {
    name  = "controller.publishService.enabled"
    value = true
  }
  depends_on = [kubernetes_namespace.stbotolphs]
}
