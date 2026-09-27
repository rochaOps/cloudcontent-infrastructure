module "vpc" {
  source  = "aws-ia/vpc/aws"
  version = "4.9.0"

  name       = local.name_prefix
  cidr_block = var.vpc_cidr

  azs = [
    "${var.aws_region}a",
  ]

  vpc_enable_dns_support   = true
  vpc_enable_dns_hostnames = true

  subnets = {
    app = {
      cidrs = var.app_subnet_cidrs

      connect_to_public_natgw = false
    }
  }

  tags = local.common_tags
}
