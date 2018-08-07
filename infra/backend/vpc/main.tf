# Create VPC
resource "google_compute_network" "vpc" {
  name                    = "${terraform.workspace}-vpc"
  auto_create_subnetworks = "false"
}
