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

# Firewall
resource "google_compute_firewall" "allow_ssh_http_https" {
  name    = "allow-ssh-http-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["data-pipeline"]
}

# VM Instance
resource "google_compute_instance" "uk-real-estate-analytics-vm" {
  name = var.vm_instance_name
  machine_type = var.vm_machine_type
  zone = var.vm_zone

  boot_disk {
    initialize_params {
      image = var.vm_image
      size = 50
    }
  }

  network_interface {
    network = "default"
    access_config {
      
    }
  }

  service_account {
    email = var.vm_service_account_email
    scopes = [
      "https://www.googleapis.com/auth/bigquery",
      "https://www.googleapis.com/auth/devstorage.read_write"
    ]
  }

  deletion_protection = false
  project = var.project_id

  metadata_startup_script =  templatefile("./vm-startup-script.sh", {})
  tags = ["data-pipeline"]
}