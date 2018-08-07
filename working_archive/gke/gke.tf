resource "google_container_cluster" "primary" {
  name               = "test-gke-${terraform.workspace}-cluster"
  zone               = "${var.region}-a"
  initial_node_count = "${var.gke_num_nodes[terraform.workspace]}"

  /*
              additional_zones = [
                "${var.region}-b",
              ]
            */
  master_auth {
    username = "${var.gke_master_user}"
    password = "${var.gke_master_pass}"
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    disk_size_gb = 10
    machine_type = "${var.gke_node_machine_type}"
    tags         = ["gke-node"]
  }
}
