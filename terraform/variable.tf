############################################################
# Declaring variables to be used under main.tf or Globally #
############################################################

#-----------------------------------------------------------
# Global variables
#-----------------------------------------------------------
# variable "AWS_ACCESS_KEY_ID" {}
# variable "AWS_SECRET_ACCESS_KEY" {}


# NOTE: Values for this variables can be set using default value, in local.tf or in *.auto.tfvars using exact same names
#       In CICD tfvars can be used as follows:
#       - name: Terraform Plan
#         run: terraform plan -var-file={env}-auto.tfvars

#       - name: Terraform Apply
#         run: terraform apply -var-file={env}-auto.tfvars-auto-approve



variable "rds_password" {
  type      = string
  sensitive = true
}

variable "django_app_secret_key" {
  type      = string
  sensitive = true
}

variable "stripe_public_key" {
  type      = string
  sensitive = true
}

variable "stripe_secret_key" {
  type      = string
  sensitive = true
}

variable "email_host_user" {
  type      = string
  sensitive = true
}

variable "email_host_password" {
  type      = string
  sensitive = true
}


variable "my_home_ip_cidr" {
  type = string
}

variable "bastion_public_key_string" {
  type = string
}
