# Configure the Google Cloud tfstate file location
terraform {
  backend "gcs" {
    bucket = "terraform-admin-mmm"
    prefix = "terraform-project"
  }
}
