# Query the client configuration for our current service account, which should
# have permission to talk to the GKE cluster since it created it.
data "google_client_config" "current" {}

# GKE cluster
resource "google_container_cluster" "master_node" {
  provider                 = google-beta
  name                     = "stbotolphs-gke"
  project                  = var.project_id
  location                 = var.region
  networking_mode          = "VPC_NATIVE"
  remove_default_node_pool = false
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  # Configuration for cluster IP allocation. As of now, only pre-allocated
  # subnetworks (custom type with secondary ranges) are supported. This will
  # activate IP aliases.
  ip_allocation_policy {
  }

  node_config {
    machine_type    = "e2-micro"
    image_type      = "UBUNTU"
    service_account = google_service_account.gke-account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/sqlservice.admin",
      "https://www.googleapis.com/auth/devstorage.full_control"
    ]

  }
  # Disable basic authentication and cert-based authentication.
  master_auth {
    username = "" #var.gke_username
    password = "" #var.gke_password

    client_certificate_config {
      issue_client_certificate = false
    }
  }
  # Enable Workload Identity
  workload_identity_config {
    identity_namespace = "${var.project_id}.svc.id.goog"
  }
  # terraform timeout
  #timeouts {
  #create = "30m"
  #update = "40m"
  #}
  depends_on = [google_project_iam_member.service-account, google_compute_network.vpc, google_compute_subnetwork.subnet]
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  provider = google
  name     = "stbotolphs-gke-pool"
  project  = var.project_id
  location = var.region
  management {
    auto_repair  = false
    auto_upgrade = false
  }
  cluster    = google_container_cluster.master_node.name
  node_count = 1

  node_config {
    preemptible     = true
    machine_type    = "e2-medium"
    image_type      = "UBUNTU"
    service_account = google_service_account.gke-account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/sqlservice.admin",
      "https://www.googleapis.com/auth/devstorage.full_control"
    ]
  }
  depends_on = [google_project_iam_member.service-account, google_container_cluster.master_node]
}
