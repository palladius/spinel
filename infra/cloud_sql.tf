resource "random_id" "db_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "postgres" {
  name             = "${var.app_name}-pg-${var.environment}-${random_id.db_suffix.hex}"
  database_version = "POSTGRES_16"
  region           = var.region

  deletion_protection = var.environment == "prod" ? true : false

  settings {
    tier              = var.db_tier
    availability_type = var.environment == "prod" ? "REGIONAL" : "ZONAL"
    disk_size         = 10
    disk_type         = "PD_SSD"
    disk_autoresize   = true

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = var.environment == "prod" ? true : false
      start_time                     = "03:00"
    }

    ip_configuration {
      ipv4_enabled = true
      ssl_mode     = "ENCRYPTED_ONLY"
    }

    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }
  }

  depends_on = [google_project_service.apis]
}

resource "google_sql_database" "database" {
  name     = "${var.app_name}_${var.environment}"
  instance = google_sql_database_instance.postgres.name
}

resource "random_password" "db_password" {
  length  = 24
  special = false
}

resource "google_sql_user" "db_user" {
  name     = "${var.app_name}_app"
  instance = google_sql_database_instance.postgres.name
  password = random_password.db_password.result
}
