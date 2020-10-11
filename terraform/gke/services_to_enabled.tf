# Enable required services on the project
resource "google_project_service" "project" {
  count   = length(var.gc_services)
  project = var.project_id
  service = var.gc_services[count.index]
  # Do not disable the service on destroy. On destroy, we are going to
  # destroy the project, but we need the APIs available to destroy the
  # underlying resources.
  disable_on_destroy = false
}
