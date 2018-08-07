# GCP variables
variable "region" {
  default     = "asia-south1"
  description = "Region of resources"
}

variable "project_name" {
  description = "The ID of the Google Cloud project"
}

variable "location" {
  default     = "ASIA"
  description = "Location for google storage bucket"
}

variable "bucket_name" {
  description = "Name of the google storage bucket"
}
