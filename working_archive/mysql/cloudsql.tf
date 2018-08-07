resource "google_sql_database_instance" "sql_master" {
  name = "wp-${terraform.workspace}-master"

  region           = "${var.region}"
  database_version = "MYSQL_5_7"

  settings {
    tier            = "${var.sql_instance_size}"
    disk_type       = "${var.sql_disk_type}"
    disk_size       = "${var.sql_disk_size}"
    disk_autoresize = true

    ip_configuration {
      authorized_networks = {
        value = "0.0.0.0/0"
      }

      require_ssl  = "${var.sql_require_ssl}"
      ipv4_enabled = true
    }

    location_preference {
      zone = "${var.region}-${var.sql_master_zone}"
    }

    backup_configuration {
      binary_log_enabled = true
      enabled            = true
      start_time         = "00:00"
    }
  }
}

resource "google_sql_database_instance" "sql_replica" {
  name  = "wp-${terraform.workspace}-replica"
  count = "${terraform.workspace == "prod" ? 1 : 0}"

  region               = "${var.region}"
  database_version     = "MYSQL_5_7"
  master_instance_name = "${google_sql_database_instance.sql_master.name}"

  replica_configuration {
    connect_retry_interval = "${var.sql_connect_retry_interval}"
    failover_target        = true
  }

  settings {
    tier            = "${var.sql_instance_size}"
    disk_type       = "${var.sql_disk_type}"
    disk_size       = "${var.sql_disk_size}"
    disk_autoresize = true

    location_preference {
      zone = "${var.region}-${var.sql_replica_zone}"
    }
  }
}

resource "google_sql_user" "sql_user" {
  instance = "${google_sql_database_instance.sql_master.name}"
  host     = "%"
  name     = "${var.sql_user}"
  password = "${var.sql_pass}"
}
