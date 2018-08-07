# remote state output
output "data_out" {
  value = "${data.terraform_remote_state.project_id.project_id}"
}

# network VPC output
output "vpc_name" {
  value       = "${module.vpc.vpc_name}"
  description = "The unique name of the network"
}

# subnet cidr ip range
output "ip_cidr_range" {
  value       = "${module.subnet.ip_cidr_range}"
  description = "Export created CICDR range"
}

/*
# cloud SQL postgresql outputs
output "master_instance_sql_ipv4" {
  value       = "${google_sql_database_instance.sql_master.ip_address.0.ip_address}"
  description = "The IPv4 address assigned for master"
}

# GKE outputs
output "endpoint" {
  value       = "${google_container_cluster.primary.endpoint}"
  description = "Endpoint for accessing the master node"
}
*/

