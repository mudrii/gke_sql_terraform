# GKE variables
variable "gke_num_nodes" {
  default = {
    prod = 3
    dev  = 1
  }

  description = "Number of nodes in each GKE cluster zone"
}

variable "gke_master_user" {
  default     = "k8s_admin"
  description = "Username to authenticate with the k8s master"
}

variable "gke_master_pass" {
  description = "Username to authenticate with the k8s master"
}

variable "gke_node_machine_type" {
  default     = "n1-standard-1"
  description = "Machine type of GKE nodes"
}

# k8s variables
variable k8s_num_wp_replicas {
  default = {
    prod = 3
    dev  = 1
  }

  description = "Number of WordPress frontend replicas"
}
