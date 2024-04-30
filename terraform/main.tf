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

# Custom Network for VM
resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_network
  auto_create_subnetworks = false  # Important for creating custom subnetworks
}

resource "google_compute_subnetwork" "custom_subnetwork" {
  name          = "custom-subnetwork"
  network       = google_compute_network.vpc_network.name
  ip_cidr_range = "10.0.0.0/16"
  region        = var.region
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "ssh-and-icmp"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "internal_traffic" {
  name    = "internal-traffic"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "all"
  }

  source_ranges = ["10.0.0.0/8"]
}


# VM Instance
resource "google_compute_instance" "uk-real-estate-analytics-vm" {
  name = var.vm_instance_name
  machine_type = var.vm_machine_type
  zone = var.vm_zone

  boot_disk {
    initialize_params {
      image = var.vm_image
    }
  }

  network_interface {
    network    = "projects/personal-projects-420210/global/networks/real-estate-vpc-network"
    subnetwork = google_compute_subnetwork.custom_subnetwork.self_link
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

  metadata_startup_script = file(var.vm_startup_script_path)
}