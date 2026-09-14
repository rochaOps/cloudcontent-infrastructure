module "vpc" {
  source  = "aws-ia/vpc/aws"
  version = "4.9.0"

  name       = "CloudContent"
  cidr_block = "10.20.0.0/16"

  azs = [
    "ap-northeast-1a",
    "ap-northeast-1c"
  ]

  vpc_enable_dns_support   = true
  vpc_enable_dns_hostnames = true

  subnets = {
    app = {
      cidrs = [
        "10.20.10.0/24",
        "10.20.20.0/24"
      ]

      connect_to_public_natgw = false
    }
  }

  tags = {
    Project = "CloudContent"
  }
}