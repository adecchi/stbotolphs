provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
provider "kubernetes" {
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
