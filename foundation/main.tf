module "vpc" {
  source  = "aws-ia/vpc/aws"
  version = "4.9.0"

  name       = var.project_name
  cidr_block = "10.20.0.0/16"

  azs = [
    "ap-northeast-1a",
    "ap-northeast-1c"
  ]

  vpc_enable_dns_support   = true
  vpc_enable_dns_hostnames = true

  subnets = {
    app = {
      cidrs = var.app_subnet_cidrs

      connect_to_public_natgw = false
    }

    database = {
      cidrs = var.database_subnet_cidrs

      connect_to_public_natgw = false
    }
  }

  tags = local.common_tags
}

resource "aws_internet_gateway" "cloudfront_vpc_origin" {
  vpc_id = module.vpc.vpc_attributes.id

  tags = merge(local.common_tags, {
    Name = "cloudcontent-cloudfront-vpc-origin"
  })
}