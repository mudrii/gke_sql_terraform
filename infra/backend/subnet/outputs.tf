# network subnet output

output "ip_cidr_range" {
  value       = "${google_compute_subnetwork.subnet.ip_cidr_range}"
  description = "Export created CICDR range"
}

output "subnet_name" {
  value       = "${google_compute_subnetwork.subnet.name}"
  description = "Export created CICDR range"
}