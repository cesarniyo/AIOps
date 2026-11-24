terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.9.0"
    }
    # docker = { #  when creating docker images with terraform
    #   source  = "kreuzwerker/docker"
    #   version = "2.15.0"
    # }
  }
}
