#---------------------------------------------------------------
# AWS VPC
#---------------------------------------------------------------
output "vpc_arn" {
  description = "Amazon Resource Name (ARN) of VPC"
  value       = element(concat(aws_vpc.production-vpc.*.arn, [""]), 0)
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = element(concat(aws_vpc.production-vpc.*.id, [""]), 0)
}


output "subnet_id_private" {
  description = "subnet_id"
  # value       = element(concat(aws_subnet.private-subnet-1.*.id, [""]), 0)
  value       = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]
}


output "subnet_id_public" {
  description = "subnet_id"
  value       = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]
}


#---------------------------------------------------------------
# Security group
#---------------------------------------------------------------
output "aws_security_group" {
  description = "The ID of the security group"
  #value       = aws_security_group.allow_tls.id
  #value       = ["${aws_security_group.allow_tls.*.id}"]
  # value       = element(concat(aws_security_group.allow_tls.*.id, [""]), 0)
  value       = aws_security_group.rds_postgres_sg[*].id
}


#---------------------------------------------------------------
# Bestion
#---------------------------------------------------------------
output "bastion_public_ip" {
  value       = aws_eip.bastion_eip.public_ip
  description = "The permanent static IP address of your Bastion Host for tunneling"
}