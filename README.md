# Gcloud Terraform How To

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
gcloud services enable compute.googleapis.com && \
gcloud services enable sqladmin.googleapis.com && \
gcloud services enable container.googleapis.com
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
gsutil mb -p ${TF_ADMIN} -l asia-southeast1 gs://${TF_ADMIN}

# Enable versioning for said remote bucket:
gsutil versioning set on gs://${TF_ADMIN}

# Configure your environment for the Google Cloud Terraform provider:
export GOOGLE_APPLICATION_CREDENTIALS=${TF_CREDS}
```

## 3rd step prepare and create project for dev and prod env

### prepare terraform environment

```sh
# create terraform.tfvars file in project folder and replace "XXXX" with proper data
vim terraform.tfvars
billing_account     = "XXXXXX-XXXXXX-XXXXXX"
org_id              = "XXXXXXXXXXX"

# create terraform.tfvars file in infra folder and replace "XXXX" with proper data
bucket_name         = "terraform-admin-mmm"
gke_master_pass     = "XXXXXXXXXXXXXXXXXXX"
sql_pass            = "XXXXXXXXXXXXXXXXXXX"
```

### create dev project

```sh
# cd into project folder and create workspace for dev and prod
# create dev workspace
terraform workspace new dev

# list available workspace
terraform workspace list

# select dev workspace
terraform workspace select dev

# initialize and pull terraform cloud specific dependencies
terraform init

# terraform plan will simulate what terraform changes will be done on cloud provider
terraform plan

# apply terraform plan for dev environment
terraform apply

```

### create prod project

```sh
# create prod workspace
terraform workspace new prod

# select prod workspace
terraform workspace select prod

# initialize and pull terraform cloud specific dependencies
terraform init

# terraform plan will simulate what terraform changes will be done on cloud provider
terraform plan

# apply terraform plan for dev environment
terraform apply
```

## 4th step is to use same sequence of commands for infra

## More info on working with terraform

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


# initialize and pull terraform cloud specific dependencies
terraform init

# terraform plan will simulate what terraform changes will be done on cloud provider
terraform plan

# create bucket
terraform apply

# terraform show environment
terraform show

# refresh terraform
terraform refresh

# list and show terraform state file
terraform state list
terraform state show

# NOTE you can use tflint to check syntax of the tf files
tflint

# destroy all applied changes to the cloud
terraform destroy

# destroy only selected module Ex.
terraform destroy --target=module.cloudsql
```
