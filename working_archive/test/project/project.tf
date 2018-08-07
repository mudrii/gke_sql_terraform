provider "google" {
  region = "asia-southeast1"
}

provider "random" {}

resource "random_id" "id" {
  byte_length = 4
  prefix      = "terraform-"
}

resource "google_project" "project" {
  name            = "${random_id.id.hex}"
  project_id      = "${random_id.id.hex}"
  billing_account = "0133B9-CC7D8E-EFEE6A"
  org_id          = "607570441838"
}

resource "google_project_services" "project" {
  project = "${google_project.project.project_id}"

  services = [
    "compute.googleapis.com",
    "oslogin.googleapis.com",
  ]
}
