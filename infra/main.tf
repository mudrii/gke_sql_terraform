# Configure the Google Cloud provider

data "terraform_remote_state" "project_id" {
  backend   = "gcs"
  workspace = "${terraform.workspace}"

  config {
    bucket = "${var.bucket_name}"
    prefix = "terraform-project"
  }
}

provider "google" {
  version = "~> 1.16"
  project = "${data.terraform_remote_state.project_id.project_id}"
  region  = "${var.region}"
}

module "vpc" {
  source = "./backend/vpc"
}

module "subnet" {
  source      = "./backend/subnet"
  region      = "${var.region}"
  vpc_name     = "${module.vpc.vpc_name}"
  subnet_cidr = "${var.subnet_cidr}"
}

module "firewall" {
  source        = "./backend/firewall"
  vpc_name       = "${module.vpc.vpc_name}"
  ip_cidr_range = "${module.subnet.ip_cidr_range}"
}

module "cloudsql" {
  source                     = "./cloudsql"
  region                     = "${var.region}"
  availability_type          = "${var.availability_type}"
  sql_instance_size          = "${var.sql_instance_size}"
  sql_disk_type              = "${var.sql_disk_type}"
  sql_disk_size              = "${var.sql_disk_size}"
  sql_require_ssl            = "${var.sql_require_ssl}"
  sql_master_zone            = "${var.sql_master_zone}"
  sql_connect_retry_interval = "${var.sql_connect_retry_interval}"
  sql_replica_zone           = "${var.sql_replica_zone}"
  sql_user                   = "${var.sql_user}"
  sql_pass                   = "${var.sql_pass}"
}

module "gke" {
  source                = "./gke"
  region                = "${var.region}"
  min_master_version    = "${var.min_master_version}"
  node_version          = "${var.node_version}"
  gke_num_nodes         = "${var.gke_num_nodes}"
  vpc_name              = "${module.vpc.vpc_name}"
  subnet_name           = "${module.subnet.subnet_name}"
  gke_master_user       = "${var.gke_master_user}"
  gke_master_pass       = "${var.gke_master_pass}"
  gke_node_machine_type = "${var.gke_node_machine_type}"
  gke_label             = "${var.gke_label}"
}
