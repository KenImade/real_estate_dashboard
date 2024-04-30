variable "project_id" {
    description = "Google Project ID"
    default = "personal-projects-420210" # Replace with your Google Project ID
}

variable "key" {
    description = "Path to Google Service Account"
    default = "../keys/my-creds.json"
}

variable "region" {
    description = "Project region"
    default = "us-central1"
}

variable "bucket_name" {
    description = "Google Storage Bucket"
    default = "uk-real-estate-analytics-bucket-personal-projects-420210"
}

variable "location" {
    description = "Location"
    default = "US"
}

variable "bq_dataset_id" {
    description = "BigQuery Dataset ID"
    default = "uk_real_estate_analytics_bq_dataset_personal_projects_420210" 
}

variable "bq_dataset_friendly_name" {
    description = "BigQuery Dataset Friendly Name"
    default = "uk-real-estate-analytics-dataset"
}

variable "vpc_network" {
    description = "VPC Network"
    default = "real-estate-vpc-network"
}

variable "vm_instance_name" {
    description = "VM Instance Name"
    default = "uk-real-estate-analytics-vm"
}

variable "vm_machine_type" {
    description = "VM Machine Type"
    default = "e2-medium"
}

variable "vm_zone" {
    description = "VM Zone"
    default = "us-central1-a"
}

variable "vm_image" {
    description = "VM Boot Disk Image"
    default = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "vm_startup_script_path" {
    description = "VM Startup Script Path"
    default = "vm-startup-script.sh"
}

variable "vm_service_account_email" {
    description = "VM Service Account Email"
    default = "uk-real-estate-analytics-vm@personal-projects-420210.iam.gserviceaccount.com" # Replace with email for service account for vm.
}