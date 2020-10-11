# Secrets for k8s
resource "google_service_account_key" "cloudsql-proxy-key" {
  service_account_id = google_service_account.cloudsql-proxy.name
  depends_on         = [google_project_iam_member.service-account, google_container_cluster.master_node]
}

resource "kubernetes_secret" "cloudsql-instance-credentials" {
  metadata {
    name      = "cloudsql-instance-credentials"
    namespace = "stbotolphs"
  }
  data = {
    "credentials.json" = base64decode(google_service_account_key.cloudsql-proxy-key.private_key)
  }
  depends_on = [google_service_account_key.cloudsql-proxy-key, kubernetes_namespace.stbotolphs]
}

resource "kubernetes_secret" "cloudsql-db-credentials" {
  metadata {
    name      = "cloudsql-db-credentials"
    namespace = "stbotolphs"
  }
  data = {
    "username" = var.db_username_root
    "password" = random_password.root.result
  }
  depends_on = [google_service_account_key.cloudsql-proxy-key, kubernetes_namespace.stbotolphs]
}

# Create Namespace
resource "kubernetes_namespace" "stbotolphs" {
  metadata {
    name = "stbotolphs"
  }
  depends_on = [google_project_iam_member.service-account, google_container_cluster.master_node, google_container_node_pool.primary_preemptible_nodes]
}
