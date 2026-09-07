variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
  default     = "spinel-cloud-dev"
}

variable "region" {
  description = "GCP Region for Cloud SQL and Cloud Run"
  type        = string
  default     = "europe-west1"
}

variable "app_name" {
  description = "Base application name"
  type        = string
  default     = "spinel"
}

variable "environment" {
  description = "Deployment environment (dev/staging/prod)"
  type        = string
  default     = "dev"
}

variable "db_tier" {
  description = "Cloud SQL machine tier"
  type        = string
  default     = "db-f1-micro"
}

variable "container_image" {
  description = "Container image for Rails 8 API service"
  type        = string
  default     = "gcr.io/cloudrun/hello" # Fallback placeholder until first deployment
}
