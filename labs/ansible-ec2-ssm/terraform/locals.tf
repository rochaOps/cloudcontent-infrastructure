locals {
  name_prefix = "${lower(var.project_name)}-ansible-ec2-ssm"

  common_tags = {
    Project = var.project_name
    Lab     = "ansible-ec2-ssm"
  }

  app_subnet_ids = values(
    module.vpc.subnet_ids_by_role["app"]
  )

  app_route_table_ids = [
    for key, route_table_id in module.vpc.route_table_ids_by_type_by_az["private"] :
    route_table_id
    if startswith(key, "app/")
  ]

  interface_endpoint_services = {
    ssm         = "ssm"
    ssmmessages = "ssmmessages"
  }
}
