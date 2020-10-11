resource "google_storage_bucket" "storage-bucket" {
  name          = "gke-minio-bucket"
  location      = var.location
  force_destroy = true
  depends_on    = [google_project_iam_member.service-account, google_container_cluster.master_node, google_container_node_pool.primary_preemptible_nodes]
}

resource "google_storage_bucket_iam_binding" "storage-bucket-binding" {
  bucket = google_storage_bucket.storage-bucket.name
  role   = "roles/storage.objectViewer"

  members = [
    "allUsers",
  ]
  depends_on = [google_storage_bucket.storage-bucket]
}
