# Terraform How To

## 1st step is to authenticate to gcloud

```sh
# follow gcloud init and select default Zone Ex. asia-south1
gcloud init

# in cli you can check available Zones and Regions
gcloud compute regions list
gcloud compute zones list
```

## 2nd step setup Terraform Admin project and service account

### Managing GCP Projects with Terraform

* Create a Terraform Admin Project for the service account and remote state bucket.
* Grant Organization-level permissions to the service account.
* Configure the remote state in GCS.
* Use Terraform to provision a new project and an instance in that project.

#### Set up the environment

NOTE: replace ENV_VAR

```sh
export TF_VAR_org_id=YOUR_ORG_ID
export TF_VAR_billing_account=YOUR_BILLING_ACCOUNT_ID
export TF_ADMIN=terraform-admin-example
export TF_CREDS=~/.config/gcloud/terraform-admin.json
```

Find the values for YOUR_ORG_ID and YOUR_BILLING_ACCOUNT_ID

```sh
gcloud organizations list
gcloud beta billing accounts list
```

#### Create the Terraform Admin Project

```sh
# Create a new project and link it to your billing account:
gcloud projects create ${TF_ADMIN} \
  --organization ${TF_VAR_org_id} \
  --set-as-default

gcloud beta billing projects link ${TF_ADMIN} \
  --billing-account ${TF_VAR_billing_account}
```

#### Create the Terraform service account

```sh
# Create the service account in the Terraform admin project and download the JSON credentials:
gcloud iam service-accounts create terraform \
  --display-name "Terraform admin account"

gcloud iam service-accounts keys create ${TF_CREDS} \
  --iam-account terraform@${TF_ADMIN}.iam.gserviceaccount.com
  
# Grant the service account permission to view the Admin Project and manage Cloud Storage:  
gcloud projects add-iam-policy-binding ${TF_ADMIN} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/viewer

gcloud projects add-iam-policy-binding ${TF_ADMIN} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/storage.admin

# enabled API
gcloud services enable cloudresourcemanager.googleapis.com && \
gcloud services enable cloudbilling.googleapis.com && \
gcloud services enable iam.googleapis.com && \
gcloud services enable compute.googleapis.com
```

#### Add organization/folder-level permissions

```sh
# Grant the service account permission to create projects and assign billing accounts:
gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/resourcemanager.projectCreator

gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/billing.user
```

#### Set up remote state in Cloud Storage

```sh
# Create the remote backend bucket in Cloud Storage and the backend.tf file for storage of the terraform.tfstate file:
gsutil mb -p ${TF_ADMIN} gs://${TF_ADMIN}

# Enable versioning for said remote bucket:
gsutil versioning set on gs://${TF_ADMIN}

# Configure your environment for the Google Cloud Terraform provider:
export GOOGLE_APPLICATION_CREDENTIALS=${TF_CREDS}
```

#### Use Terraform to create a new project and Compute Engine instance

```sh
# project.tf file:
variable "project_name" {}
variable "billing_account" {}
variable "org_id" {}
variable "region" {}

provider "google" {
 region = "${var.region}"
}

resource "random_id" "id" {
 byte_length = 4
 prefix      = "${var.project_name}-"
}

resource "google_project" "project" {
 name            = "${var.project_name}"
 project_id      = "${random_id.id.hex}"
 billing_account = "${var.billing_account}"
 org_id          = "${var.org_id}"
}

resource "google_project_services" "project" {
 project = "${google_project.project.project_id}"

 services = [
   "compute.googleapis.com"
 ]
}

output "project_id" {
 value = "${google_project.project.project_id}"
}

# The compute.tf file:
data "google_compute_zones" "available" {}

resource "google_compute_instance" "default" {
 project = "${google_project_services.project.project}"
 zone = "${data.google_compute_zones.available.names[0]}"
 name = "tf-compute-1"
 machine_type = "f1-micro"

 boot_disk {
   initialize_params {
     image = "ubuntu-1604-xenial-v20170328"
   }
 }

 network_interface {
   network = "default"
   access_config {
   }
 }
}

output "instance_id" {
 value = "${google_compute_instance.default.self_link}"
}

# Set the name of the project you want to create and the region you want to create the resources in:
export TF_VAR_project_name=${USER}-test-compute
export TF_VAR_region=us-central1

# Preview the Terraform changes:
terraform plan

# Apply the Terraform changes:
terraform apply

# SSH into the instance created:
export instance_id=$(terraform output instance_id)
export project_id=$(terraform output project_id)

gcloud compute ssh ${instance_id} --project ${project_id}
```

#### Cleaning up if is not needed anymore

```sh
# Destroy the resources created by Terraform:
terraform destroy

# Delete the Terraform Admin project and all of its resources:
gcloud projects delete ${TF_ADMIN}

# Remove the organization level IAM permissions for the service account:
gcloud organizations remove-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/resourcemanager.projectCreator

gcloud organizations remove-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/billing.user
```






## terraform authentication

```sh
# required information:
# get project ID
gcloud projects list

# get service account needed for terraform to access:
gcloud container clusters list

# NOTE: terraform service account already was created but if doesn't exists follow below steps
gcloud iam service-accounts create <NAME>
gcloud projects add-iam-policy-binding [PROJECT_ID] --member "serviceAccount:[NAME]@[PROJECT_ID].iam.gserviceaccount.com" --role "roles/owner"
gcloud iam service-accounts keys create [FILE_NAME].json --iam-account [NAME]@[PROJECT_ID].iam.gserviceaccount.com

# if account exists just follow below
gcloud iam service-accounts keys create ~/.config/gcloud/terraform.json --iam-account terraform@tranquil-scion-203706.iam.gserviceaccount.com

# list created key
gcloud iam service-accounts keys list --iam-account terraform@tranquil-scion-203706.iam.gserviceaccount.com

# delete key Ex.
gcloud iam service-accounts keys delete 0cfdfdc0ed650920b9c096c7bee5dd55baa7c564 --iam-account terraform@tranquil-scion-203706.iam.gserviceaccount.com

# make sure you have environment variable GOOGLE_CREDENTIALS point to terraform.json
export GOOGLE_CREDENTIALS=~/.config/gcloud/terraform.json
```

## Working with terraform

```sh
# add to .gitingnore below changes
*.tfstate
*.tfstate.backup
*.tfvars
.terraform
tfplan
```

### terraform shared state

```sh
# NOTE bucket was already created and this step can be skipped if try to apply will get error from gcloud on bucker already exists
# terraform is using share state file to keep the state of the generated infrastructure this file by default in written in local directory.
# in case team is working on the same terraform project state file can be share among team member using terraform back-end drivers that support multiple cloud providers
# cd into back-end folder where main.tf will create state file on storage drive.
cd platform/terraform/gcloud/backend

# initialize and pull terraform cloud specific dependencies
terraform init

# terraform plan will simulate what terraform changes will be done on cloud provider
terraform plan

# create bucket
terraform apply
```

### terraform apply changes for underling infrastructure

```sh
# below implementation will create gke cluster and MySql db
# cd into the folder where tf file is located
cd platform/terraform/gcloud/

# initialize and pull terraform cloud specific dependencies
terraform init

# current terraform setup allows to run same infrastructure code for diff environments Ex prod dev etc.
# in order to segregate tfstate files between environment not only code should accommodate but also use concept of the workspace
# 1st check if already available workspace
terraform workspace list

# create new workspace
terraform workspace new dev
terraform workspace new prod

# select workspace Ex. de
terraform workspace select dev

# terraform plan will simulate what terraform changes will be done on cloud provider
terraform plan

# apply changes for infrastructure
terraform apply

# NOTE you can use tflint to check syntax of the tf files
tflint

# destroy all applied changes to the cloud
terraform destroy
```
