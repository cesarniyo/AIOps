variable "my_home_ip_cidr" {
  type        = string
  description = "Home IP address in CIDR notation allowed to SSH into the Bastion host"
}

variable "bastion_public_key_string" {
  type        = string
  description = "The raw contents of your local SSH public key"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the production VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "Two Availability Zones for high availability"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_1_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "private_subnet_1_cidr" {
  type    = string
  default = "10.0.3.0/24"
}

variable "private_subnet_2_cidr" {
  type    = string
  default = "10.0.4.0/24"
}
