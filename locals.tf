locals {
  common_tags = {
    Project = var.project_name
  }

  app_subnet_ids = values(
    module.vpc.subnet_ids_by_role["app"]
  )

  database_subnet_ids = values(
    module.vpc.subnet_ids_by_role["database"]
  )

  app_route_table_ids = [
    for key, route_table_id in module.vpc.route_table_ids_by_type_by_az["private"] :
    route_table_id
    if startswith(key, "app/")
  ]

  interface_endpoint_services = {
    ecr_api              = "ecr.api"
    ecr_dkr              = "ecr.dkr"
    ec2                  = "ec2"
    elasticloadbalancing = "elasticloadbalancing"
    eks                  = "eks"
    eks_auth             = "eks-auth"
    logs                 = "logs"
    ssm                  = "ssm"
    ssmmessages          = "ssmmessages"
  }
}
