resource "google_secret_manager_secret" "database_url" {
  secret_id = "${var.app_name}-db-url-${var.environment}"

  replication {
    auto {}
  }

  depends_on = [google_project_service.apis]
}

resource "google_secret_manager_secret_version" "database_url_version" {
  secret      = google_secret_manager_secret.database_url.id
  secret_data = "postgresql://${google_sql_user.db_user.name}:${random_password.db_password.result}@localhost:5432/${google_sql_database.database.name}?host=/cloudsql/${google_sql_database_instance.postgres.connection_name}"
}

resource "random_password" "rails_master_key" {
  length  = 32
  special = false
}

resource "google_secret_manager_secret" "rails_master_key" {
  secret_id = "${var.app_name}-rails-master-key-${var.environment}"

  replication {
    auto {}
  }

  depends_on = [google_project_service.apis]
}

resource "google_secret_manager_secret_version" "rails_master_key_version" {
  secret      = google_secret_manager_secret.rails_master_key.id
  secret_data = random_password.rails_master_key.result
}
