# Configure the Google Cloud provider

data "terraform_remote_state" "project" {
  backend = "gcs"

  #  workspace = "default"

  config {
    bucket = "terraform-admin-mmm"
    prefix = "/terraform-project"
  }
}

provider "google" {
  #	project     = "${data.terraform_remote_state.project.test_project_id}"
  region = "asia-southeast1"
}

output "data_out" {
  value = "${data.terraform_remote_state.project.test_project_id}"
}

/*
resource "google_compute_network" "vpc" {
	name = "my-vpc"
	project = "${data.terraform_remote_state.project.google_project.project.project_id}"
#	project = "${data.terraform_remote_state.project.test_project_id}"
# 	auto_create_subnetworks = "false"
}
*/

