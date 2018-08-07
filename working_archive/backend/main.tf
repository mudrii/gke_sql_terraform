provider "google" {
  version = "~> 1.2"
  project = "${var.project_name}"
  region  = "${var.region}"
}

resource "google_storage_bucket" "backend" {
  name     = "${var.bucket_name}"
  location = "${var.location}"

  versioning = {
    enabled = "true"
  }
}
