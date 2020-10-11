resource "google_sql_database_instance" "postgresql-server" {
  database_version = "POSTGRES_9_6"
  name             = "postgres-instance-${random_id.random.hex}"
  region           = var.region
  project          = var.project_id

  lifecycle {
    prevent_destroy = false
  }
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
    }
  }
  # Manually disable public IP since `ipv4_enabled = false` seems to bear no effect, contrary to the docs:
  #provisioner "local-exec" {
  # command = "gcloud sql instances patch ${google_sql_database_instance.postgresql-server.name} --no-assign-ip"
  #}

  depends_on = [google_project_iam_member.service-account, google_compute_network.vpc, google_container_cluster.master_node]
}

resource "google_sql_user" "webapp" {
  instance   = google_sql_database_instance.postgresql-server.name
  name       = var.db_username_web
  password   = random_password.webapp.result
  depends_on = [google_sql_database.cms]
}

resource "google_sql_user" "root" {
  instance   = google_sql_database_instance.postgresql-server.name
  name       = var.db_username_root
  password   = random_password.root.result
  depends_on = [google_sql_database.cms]
}


resource "google_sql_database" "cms" {
  name       = var.db_name
  instance   = google_sql_database_instance.postgresql-server.name
  depends_on = [google_sql_database_instance.postgresql-server]

}
