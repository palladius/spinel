output "cloud_run_url" {
  description = "URL of the Spinel Rails 8 API service"
  value       = google_cloud_run_v2_service.api_service.uri
}

output "cloud_sql_instance_connection_name" {
  description = "Cloud SQL instance connection name"
  value       = google_sql_database_instance.postgres.connection_name
}

output "cloud_sql_database_name" {
  description = "Name of the PostgreSQL database"
  value       = google_sql_database.database.name
}

output "service_account_email" {
  description = "Service Account email running Cloud Run"
  value       = google_service_account.api_sa.email
}
