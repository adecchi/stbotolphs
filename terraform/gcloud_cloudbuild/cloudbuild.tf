resource "google_cloudbuild_trigger" "stbotolphs" {
  provider    = google-beta
  project     = var.project_id
  description = "Push to any branch"
  filename    = "cloudbuild.yaml"
  github {
    owner = "adecchi"
    name  = "stbotolphs"
    push {
      branch = ".*"
    }
  }
}
