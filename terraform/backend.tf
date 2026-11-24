# Terraform state location
#==========================================================

# terraform {
#   backend "local" {
#     path = "./ftstate/terraform.tfstate"
#   }
# }


terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "cesarorganization"

    # workspaces {  
    #   name = "dealstands-local"
    #   #name = "dealstands-dev"
    #   # prefix = "dealstands-"   
    # }
  }
}

# When the prefix is used here - we will need to set FT_WORKSPACE variable as env variable (for dev,qa,prd) in our CICD
# The name of the workspace on TFC is as follows: cesarworkspace-dev


# terraform {
#   backend "s3" {
#     bucket = "cesar5000"
#     key    = "tf_backend/terraform.tf_state"
#     region = "us-east-2"
#   }
# }

