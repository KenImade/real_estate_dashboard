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
    default = "uk-real-estate-analytics-bucket-personal-projects-420210" # Replace this with your unique name
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