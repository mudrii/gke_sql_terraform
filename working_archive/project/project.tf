terraform {
  backend "gcs" {
    bucket = "terraform-admin-mmm"
    prefix = "/terraform-project.tfstate"
  }
}

provider "google" {
  version = "~> 1.12"
  region  = "${var.region}"
}

provider "random" {}

resource "random_id" "id" {
  byte_length = 8
  prefix      = "terraform-${var.project_name[terraform.workspace]}-"

  #	prefix      = "terraform-${terraform.workspace}-"
}

resource "google_project" "project" {
  #	name             = "terraform-${terraform.workspace}"
  name            = "terraform-${var.project_name[terraform.workspace]}"
  project_id      = "${random_id.id.hex}"
  billing_account = "${var.billing_account}"
  org_id          = "${var.org_id}"
}

resource "google_project_services" "project" {
  project = "${google_project.project.project_id}"

  services = [
    "compute.googleapis.com",
  ]
}
