output "kubernetes_cluster_name" {
  value       = google_container_cluster.master_node.name
  description = "GKE Cluster Name"
}

output "Region" {
  value       = var.region
  description = "region"
}

output "Master_Host" {
  value     = google_container_cluster.master_node.endpoint
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = base64decode(google_container_cluster.master_node.master_auth.0.cluster_ca_certificate)
  sensitive = true
}

output "GKE_Master_Username" {
  value     = google_container_cluster.master_node.master_auth.0.username
  sensitive = true
}

output "GKE_Master_Password" {
  value     = google_container_cluster.master_node.master_auth.0.password
  sensitive = true
}

output "CMS_DB_User" {
  value     = google_sql_user.webapp.name
  sensitive = true
}

output "CMS_DB_Password" {
  value     = google_sql_user.webapp.password
  sensitive = true
}

output "SQL_DB_User" {
  value     = google_sql_user.root.name
  sensitive = true
}

output "SQL_DB_Password" {
  value     = google_sql_user.root.password
  sensitive = true
}

output "SQL_DB_Connection_Name" {
  value     = google_sql_database_instance.postgresql-server.connection_name
  sensitive = true
}

output "bucket_link" {
  value     = google_storage_bucket.storage-bucket.self_link
  sensitive = true
}

output "bucket_secret_key" {
  value     = google_storage_hmac_key.bucket-key.secret
  sensitive = true
}

output "bucket_access_key" {
  value     = google_storage_hmac_key.bucket-key.access_id
  sensitive = true
}
