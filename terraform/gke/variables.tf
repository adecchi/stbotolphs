variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
}

variable "gke_num_nodes" {
  default     = 2
  description = "number of gke nodes"
}

variable "gc_services" {
  description = "services to enabled"
  default = [
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "secretmanager.googleapis.com",
    "sqladmin.googleapis.com",
  ]
}

variable "service_account_iam_roles" {
  type = list(string)
  default = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/container.developer",
    "roles/storage.admin",
    "roles/cloudsql.admin",
    "roles/compute.admin",
    #"roles/storage.objectViewer",
    #"roles/storage.objectCreator",
    "roles/secretmanager.secretAccessor",
    "roles/editor",
  ]
  description = "List of IAM roles to assign to the service account."
}

# Variables for Google SQL
variable "instance_name" {
  type    = string
  default = "webapp"
}

variable "db_name" {
  default     = "cms"
  description = "Database name"
  type        = string
}

variable "db_username_root" {
  default = "root"
  type    = string
}

variable "db_username_web" {
  default = "webapp"
  type    = string
}


variable "db_password" {
  default = "somepass"
  type    = string
}

variable "location" {
  default = "EU"
  type    = string
}
variable "helm_version" {
  default = "v2.9.1"
}
