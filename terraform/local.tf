###########################################
# Declaring and defining locals
###########################################
data "aws_caller_identity" "current" {}

locals {
  use_case = "test"
  product  = "aiops"

  account_id    = data.aws_caller_identity.current.account_id
  region        = "us-east-2"

  _environment_name = {
    "927765266034"  = "dev"
    "123456789999"  = "qa"
    "111111111111"  = "prod"
  }
  environment_name = local._environment_name[local.account_id]


  _region_abr = {
    "us-east-2" = "use2"
  }
  region_abr = local._region_abr[local.region]


  name_prefix = "${local.use_case}-${local.product}-${local.region_abr}"

  tag = {
    use_case = local.use_case
    product  = local.product
    env      = local.environment_name
    createdby= "terraform"
  }

}
