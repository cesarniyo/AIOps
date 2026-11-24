variable "db_password" {
  description = "RDS root user password"
  type        = string
  sensitive   = true
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to deploy the RDS instance in (usually private subnets)"
}

variable "aws_security_group" {
  type        = list(string)
  description = "Security group ID to associate with the RDS instance for controlling inbound/outbound access"
}
