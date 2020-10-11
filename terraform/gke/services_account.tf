# Create the gke service account
resource "google_service_account" "gke-account" {
  account_id   = "gke-account"
  display_name = "gke account"
  project      = var.project_id
}

# Add the service account to our project
resource "google_project_iam_member" "service-account" {
  count      = length(var.service_account_iam_roles)
  project    = var.project_id
  role       = element(var.service_account_iam_roles, count.index)
  member     = "serviceAccount:${google_service_account.gke-account.email}"
  depends_on = [google_service_account.gke-account]
}

resource "google_service_account" "cloudsql-proxy" {
  account_id   = "cloudsql-proxy"
  display_name = "cloudsql-proxy"
}

data "google_service_account" "cloudsql-proxy" {
  account_id = "cloudsql-proxy"
}

resource "google_project_iam_binding" "cloudsql-proxy-binding" {
  project = var.project_id
  role    = "roles/cloudsql.client"

  members = [
    "serviceAccount:${google_service_account.cloudsql-proxy.email}",
  ]
}


# Services Account for Bucket
#resource "google_service_account" "bucket-account" {
#  account_id   = "bucket-account"
#  display_name = "Bucket Account"
#  project      = var.project_id
#}


resource "google_storage_hmac_key" "bucket-key" {
  service_account_email = google_service_account.gke-account.email
}
