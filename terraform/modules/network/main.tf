# ==========================================
# 1. VPC & SUBNETS
# ==========================================
resource "aws_vpc" "production-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "production-vpc"
  }
}

# Public Subnets
resource "aws_subnet" "public-subnet-1" {
  cidr_block              = var.public_subnet_1_cidr
  vpc_id                  = aws_vpc.production-vpc.id
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name                     = "public-subnet-1"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "public-subnet-2" {
  cidr_block              = var.public_subnet_2_cidr
  vpc_id                  = aws_vpc.production-vpc.id
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = {
    Name                     = "public-subnet-2"
    "kubernetes.io/role/elb" = "1"
  }
}

# Private Subnets (Shared by EKS Worker Nodes & RDS)
resource "aws_subnet" "private-subnet-1" {
  cidr_block        = var.private_subnet_1_cidr
  vpc_id            = aws_vpc.production-vpc.id
  availability_zone = var.availability_zones[0]

  tags = {
    Name                              = "private-subnet-1"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "private-subnet-2" {
  cidr_block        = var.private_subnet_2_cidr
  vpc_id            = aws_vpc.production-vpc.id
  availability_zone = var.availability_zones[1]

  tags = {
    Name                              = "private-subnet-2"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# ==========================================
# 2. GATEWAYS & ROUTING
# ==========================================
resource "aws_internet_gateway" "production-igw" {
  vpc_id = aws_vpc.production-vpc.id

  tags = {
    Name = "production-igw"
  }
}

# NAT Gateway so private EKS nodes can reach the EKS control plane and ECR
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "production-nat-eip"
  }
}

resource "aws_nat_gateway" "production_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public-subnet-1.id

  tags = {
    Name = "production-nat-gw"
  }

  depends_on = [aws_internet_gateway.production-igw]
}

# Route Tables
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.production-vpc.id

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.production-vpc.id

  tags = {
    Name = "private-route-table"
  }
}

# Routes
resource "aws_route" "public-internet-igw-route" {
  route_table_id         = aws_route_table.public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.production-igw.id
}

resource "aws_route" "private-nat-route" {
  route_table_id         = aws_route_table.private-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.production_nat.id
}

# Route Table Associations
resource "aws_route_table_association" "public-route-1-association" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet-1.id
}

resource "aws_route_table_association" "public-route-2-association" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet-2.id
}

resource "aws_route_table_association" "private-route-1-association" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private-subnet-1.id
}

resource "aws_route_table_association" "private-route-2-association" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private-subnet-2.id
}

# ==========================================
# 3. SECURITY GROUPS
# ==========================================
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-host-sg"
  description = "Allows SSH traffic strictly from home IP address range"
  vpc_id      = aws_vpc.production-vpc.id

  ingress {
    description = "SSH from home network"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_home_ip_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Bastion Host Security Group"
  }
}

resource "aws_security_group" "rds_postgres_sg" {
  name        = "rds-postgres-sg"
  description = "Security group for PostgreSQL RDS"
  vpc_id      = aws_vpc.production-vpc.id

  ingress {
    description     = "Allow PostgreSQL access strictly from the Bastion host"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    description = "Allow internal VPC nodes (including EKS pods) access to DB"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.production-vpc.cidr_block]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS PostgreSQL Security Group"
  }
}

# ==========================================
# 4. BASTION HOST
# ==========================================
resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion-ssh-key"
  public_key = var.bastion_public_key_string
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public-subnet-1.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = aws_key_pair.bastion_key.key_name

  tags = {
    Name = "RDS-Jump-Bastion"
  }
}

resource "aws_eip" "bastion_eip" {
  domain   = "vpc"
  instance = aws_instance.bastion.id

  tags = {
    Name = "bastion-static-ip"
  }
}
