# use google-beta in place of google because github is not available.
provider "google-beta" {
  project = var.project_id
  region  = var.region
}
