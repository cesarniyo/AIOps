resource "aws_db_subnet_group" "postgres" {
  name       = "postgres"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "postgres"
  }
}

resource "aws_db_parameter_group" "postgres" {
  name   = "postgres"
  family = "postgres17"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}


# To find engine - engine version combination use: aws rds describe-db-engine-versions --default-only --engine postgres
resource "aws_db_instance" "postgres" {
  identifier             = "postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp3"
  engine                 = "postgres"
  engine_version         = "17.11"
  username               = "postgres"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = var.aws_security_group
  #parameter_group_name   = aws_db_parameter_group.postgres.name
  publicly_accessible    = false
  skip_final_snapshot    = true
}