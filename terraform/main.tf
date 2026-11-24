# MAINTAINER Cesar NIYO "email@gmail.com"

# -----------------------------------------------------------
# Role Creation
# -----------------------------------------------------------
module "iam" {
  source      = "./modules/iam"
  name_prefix = local.name_prefix
}

# -----------------------------------------------------------
# Network
# -----------------------------------------------------------
module "network" {
  source                    = "./modules/network"
  my_home_ip_cidr           = var.my_home_ip_cidr
  bastion_public_key_string = var.bastion_public_key_string
}

# -----------------------------------------------------------
# DB Creation: RDS
# -----------------------------------------------------------
module "rds" {
  source             = "./modules/rds"
  db_password        = "12345678"
  subnet_ids         = module.network.subnet_id_private
  aws_security_group = module.network.aws_security_group
}

# -----------------------------------------------------------
# EKS Cluster
# -----------------------------------------------------------
module "eks" {
  source           = "./modules/eks"
  cluster_name     = "${local.name_prefix}-eks"
  cluster_role_arn = module.iam.eks_cluster_role_arn
  node_role_arn    = module.iam.eks_node_role_arn
  subnet_ids       = module.network.subnet_id_private
}
