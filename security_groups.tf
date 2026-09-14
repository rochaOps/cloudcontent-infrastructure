# File: /repo/CloudContent/security_groups.tf

resource "aws_security_group" "app" {
  name        = "cloudcontent-app"
  description = "Security group for CloudContent application workloads"
  vpc_id      = module.vpc.vpc_attributes.id

  tags = {
    Name    = "cloudcontent-app"
    Project = "CloudContent"
  }
}

resource "aws_security_group" "rds" {
  name        = "cloudcontent-rds"
  description = "Security group for CloudContent RDS workloads"
  vpc_id      = module.vpc.vpc_attributes.id

  tags = {
    Name    = "cloudcontent-rds"
    Project = "CloudContent"
  }
}

resource "aws_vpc_security_group_egress_rule" "app_to_rds" {
  security_group_id = aws_security_group.app.id

  referenced_security_group_id = aws_security_group.rds.id

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "app_to_rds" {
  security_group_id = aws_security_group.rds.id

  referenced_security_group_id = aws_security_group.app.id

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"
}