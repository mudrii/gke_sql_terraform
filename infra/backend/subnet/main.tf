# Create Subnet

resource "google_compute_subnetwork" "subnet" {
  name          = "${terraform.workspace}-subnet"
  ip_cidr_range = "${var.subnet_cidr[terraform.workspace]}"
  network       = "${var.network}"
  region        = "${var.region}"
}
