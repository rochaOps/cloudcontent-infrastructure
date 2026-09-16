# -----------------------------------------------------------------------------
# Application Load Balancer
# -----------------------------------------------------------------------------

resource "aws_security_group" "alb" {
  name        = "cloudcontent-alb"
  description = "Security group for the CloudContent internal ALB"
  vpc_id      = module.vpc.vpc_attributes.id

  tags = merge(local.common_tags, {
    Name = "cloudcontent-alb"
  })
}

resource "aws_vpc_security_group_ingress_rule" "cloudfront_to_alb" {
  security_group_id = aws_security_group.alb.id

  prefix_list_id = data.aws_ec2_managed_prefix_list.cloudfront_origin_facing.id

  ip_protocol = "tcp"
  from_port   = var.alb_listener_port
  to_port     = var.alb_listener_port

  description = "Allow CloudFront origin-facing traffic to the internal ALB"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id = aws_security_group.alb.id

  referenced_security_group_id = aws_security_group.app.id

  ip_protocol = "tcp"
  from_port   = var.app_port
  to_port     = var.app_port

  description = "Allow ALB traffic to CloudContent application workloads"
}


# -----------------------------------------------------------------------------
# Application
# -----------------------------------------------------------------------------

resource "aws_security_group" "app" {
  name        = "cloudcontent-app"
  description = "Security group for CloudContent application workloads"
  vpc_id      = module.vpc.vpc_attributes.id

  tags = merge(local.common_tags, {
    Name = "cloudcontent-app"
  })
}

resource "aws_vpc_security_group_ingress_rule" "alb_to_app" {
  security_group_id = aws_security_group.app.id

  referenced_security_group_id = aws_security_group.alb.id

  ip_protocol = "tcp"
  from_port   = var.app_port
  to_port     = var.app_port

  description = "Allow traffic from the internal ALB to application workloads"
}

resource "aws_vpc_security_group_egress_rule" "app_to_rds" {
  security_group_id = aws_security_group.app.id

  referenced_security_group_id = aws_security_group.rds.id

  ip_protocol = "tcp"
  from_port   = 5432
  to_port     = 5432

  description = "Allow application workloads to connect to PostgreSQL"
}

resource "aws_vpc_security_group_egress_rule" "app_to_vpc_endpoints" {
  security_group_id = aws_security_group.app.id

  referenced_security_group_id = aws_security_group.vpc_endpoints.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  description = "Allow application workloads to access interface VPC endpoints"
}


# -----------------------------------------------------------------------------
# RDS
# -----------------------------------------------------------------------------

resource "aws_security_group" "rds" {
  name        = "cloudcontent-rds"
  description = "Security group for CloudContent PostgreSQL"
  vpc_id      = module.vpc.vpc_attributes.id

  tags = merge(local.common_tags, {
    Name = "cloudcontent-rds"
  })
}

resource "aws_vpc_security_group_ingress_rule" "app_to_rds" {
  security_group_id = aws_security_group.rds.id

  referenced_security_group_id = aws_security_group.app.id

  ip_protocol = "tcp"
  from_port   = 5432
  to_port     = 5432

  description = "Allow PostgreSQL connections from application workloads"
}


# -----------------------------------------------------------------------------
# Interface VPC Endpoints
# -----------------------------------------------------------------------------

resource "aws_security_group" "vpc_endpoints" {
  name        = "cloudcontent-vpc-endpoints"
  description = "Security group for CloudContent interface VPC endpoints"
  vpc_id      = module.vpc.vpc_attributes.id

  tags = merge(local.common_tags, {
    Name = "cloudcontent-vpc-endpoints"
  })
}

resource "aws_vpc_security_group_ingress_rule" "app_subnets_to_vpc_endpoints" {
  for_each = toset(var.app_subnet_cidrs)

  security_group_id = aws_security_group.vpc_endpoints.id

  cidr_ipv4   = each.value
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  description = "Allow HTTPS from CloudContent application subnets"
}