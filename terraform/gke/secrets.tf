resource "google_secret_manager_secret" "postgres-db" {
  secret_id = "POSTGRES_DB"
  project   = var.project_id
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "postgres-user" {
  secret_id = "POSTGRES_USER"
  project   = var.project_id
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "postgres-password" {
  secret_id = "POSTGRES_PASSWORD"
  project   = var.project_id
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "django-db-host" {
  secret_id = "DJANGO_DB_HOST"
  project   = var.project_id
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "django-aws-access-key-id" {
  secret_id = "DJANGO_AWS_ACCESS_KEY_ID"
  project   = var.project_id
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "django-aws-secret-access-key" {
  secret_id = "DJANGO_AWS_SECRET_ACCESS_KEY"
  project   = var.project_id
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "django-aws-s3-endpoint-url" {
  secret_id = "DJANGO_AWS_S3_ENDPOINT_URL"
  project   = var.project_id
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "django-aws-s3-bucket-name" {
  secret_id = "DJANGO_AWS_STORAGE_BUCKET_NAME"
  project   = var.project_id
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "django-aws-s3-region-name" {
  secret_id = "DJANGO_AWS_S3_REGION_NAME"
  project   = var.project_id
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "django-aws-s3-host" {
  secret_id = "DJANGO_AWS_S3_HOST"
  project   = var.project_id
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "django-db-password" {
  secret_id = "DJANGO_DB_PASSWORD"
  project   = var.project_id
  replication {
    automatic = true
  }
}
resource "google_secret_manager_secret" "django-db-user" {
  secret_id = "DJANGO_DB_USER"
  project   = var.project_id
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "django-db-name" {
  secret_id = "DJANGO_DB_NAME"
  project   = var.project_id
  replication {
    automatic = true
  }
}

# Define the secrets

resource "google_secret_manager_secret_version" "postgres-db" {
  secret      = google_secret_manager_secret.postgres-db.id
  secret_data = "cms"
  depends_on  = [google_sql_user.root]
}

resource "google_secret_manager_secret_version" "postgres-user" {
  secret      = google_secret_manager_secret.postgres-user.id
  secret_data = var.db_username_root
  depends_on  = [google_sql_user.webapp]
}

resource "google_secret_manager_secret_version" "postgres-password" {
  secret      = google_secret_manager_secret.postgres-password.id
  secret_data = random_password.root.result
  depends_on  = [google_sql_user.root]
}

resource "google_secret_manager_secret_version" "django-aws-s3-endpoint-url" {
  secret      = google_secret_manager_secret.django-aws-s3-endpoint-url.id
  secret_data = "https://storage.googleapis.com/"
  #google_storage_bucket.storage-bucket.self_link
  depends_on = [google_storage_bucket.storage-bucket]
}

resource "google_secret_manager_secret_version" "django-aws-secret-access-key" {
  secret      = google_secret_manager_secret.django-aws-secret-access-key.id
  secret_data = google_storage_hmac_key.bucket-key.secret
  depends_on  = [google_storage_bucket.storage-bucket]
}

resource "google_secret_manager_secret_version" "django-aws-access-key-id" {
  secret      = google_secret_manager_secret.django-aws-access-key-id.id
  secret_data = google_storage_hmac_key.bucket-key.access_id
  depends_on  = [google_storage_bucket.storage-bucket]
}

resource "google_secret_manager_secret_version" "django-db-host" {
  secret      = google_secret_manager_secret.django-db-host.id
  secret_data = "localhost"
  depends_on  = [google_sql_user.webapp]
}

resource "google_secret_manager_secret_version" "django-aws-s3-bucket-name" {
  secret      = google_secret_manager_secret.django-aws-s3-bucket-name.id
  secret_data = google_storage_bucket.storage-bucket.name
  depends_on  = [google_storage_bucket.storage-bucket]
}

resource "google_secret_manager_secret_version" "django-aws-s3-region-name" {
  secret      = google_secret_manager_secret.django-aws-s3-region-name.id
  secret_data = var.location
  depends_on  = [google_storage_bucket.storage-bucket]
}

resource "google_secret_manager_secret_version" "django-aws-s3-host" {
  secret      = google_secret_manager_secret.django-aws-s3-host.id
  secret_data = "Google GCP"
  depends_on  = [google_storage_bucket.storage-bucket]
}

resource "google_secret_manager_secret_version" "django-db-name" {
  secret      = google_secret_manager_secret.django-db-name.id
  secret_data = "cms"
  depends_on  = [google_sql_user.webapp]
}

resource "google_secret_manager_secret_version" "django-db-user" {
  secret      = google_secret_manager_secret.django-db-user.id
  secret_data = var.db_username_web
  depends_on  = [google_sql_user.webapp]
}

resource "google_secret_manager_secret_version" "django-db-password" {
  secret      = google_secret_manager_secret.django-db-password.id
  secret_data = random_password.webapp.result
  depends_on  = [google_sql_user.webapp]
}
