terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.5"
    }
  }
}

provider "google" {
  credentials = file(var.key)
  project = var.project_id
  region = var.region
}

# Storage Bucket
resource "google_storage_bucket" "real_estate_analytics_bucket" {
  name = var.bucket_name
  location = var.location
  force_destroy = true
}

# Bigquery Dataset
resource "google_bigquery_dataset" "uk_real_estate_analytics" {
  dataset_id = var.bq_dataset_id
  description = "This is the UK real estate analytics dataset"
  location = var.location
}