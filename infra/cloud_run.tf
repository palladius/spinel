resource "google_service_account" "api_sa" {
  account_id   = "${var.app_name}-api-${var.environment}"
  display_name = "Spinel Rails 8 API Service Account"
}

resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.api_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "db_url_accessor" {
  secret_id = google_secret_manager_secret.database_url.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.api_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "rails_key_accessor" {
  secret_id = google_secret_manager_secret.rails_master_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.api_sa.email}"
}

resource "google_cloud_run_v2_service" "api_service" {
  name     = "${var.app_name}-api-${var.environment}"
  location = var.region

  template {
    service_account = google_service_account.api_sa.email

    scaling {
      min_instance_count = 0
      max_instance_count = 10
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [google_sql_database_instance.postgres.connection_name]
      }
    }

    containers {
      image = var.container_image

      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }

      env {
        name  = "RAILS_ENV"
        value = var.environment == "prod" ? "production" : "development"
      }

      env {
        name  = "RAILS_LOG_TO_STDOUT"
        value = "true"
      }

      env {
        name = "DATABASE_URL"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.database_url.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "RAILS_MASTER_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.rails_master_key.secret_id
            version = "latest"
          }
        }
      }
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  depends_on = [
    google_sql_database_instance.postgres,
    google_secret_manager_secret_version.database_url_version,
    google_secret_manager_secret_version.rails_master_key_version,
    google_project_service.apis
  ]
}

# Allow unauthenticated invocations for public API (with application-level bearer auth)
resource "google_cloud_run_v2_service_iam_member" "public_access" {
  name     = google_cloud_run_v2_service.api_service.name
  location = google_cloud_run_v2_service.api_service.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
