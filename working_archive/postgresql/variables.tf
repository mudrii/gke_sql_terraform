# Cloud SQL variables
variable "sql_instance_size" {
  default     = "db-f1-micro"
  description = "Size of Cloud SQL instances"
}

variable "sql_disk_type" {
  default     = "PD_SSD"
  description = "Cloud SQL instance disk type"
}

variable "sql_disk_size" {
  default     = "10"
  description = "Storage size in GB"
}

variable "sql_require_ssl" {
  default     = "false"
  description = "Enforce SSL connections"
}

variable "sql_connect_retry_interval" {
  default     = 60
  description = "The number of seconds between connect retries."
}

variable "sql_master_zone" {
  default     = "a"
  description = "Zone of the Cloud SQL master (a, b, ...)"
}

variable "sql_replica_zone" {
  default     = "b"
  description = "Zone of the Cloud SQL replica (a, b, ...)"
}

variable "sql_user" {
  default     = "admin"
  description = "Username of the host to access the database"
}

variable "sql_pass" {
  description = "Password of the host to access the database"
}
