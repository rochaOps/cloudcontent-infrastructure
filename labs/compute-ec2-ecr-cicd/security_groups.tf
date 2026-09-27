resource "aws_security_group" "app" {
  name        = "${local.name_prefix}-ec2"
  description = "Security group for CloudContent application workloads"
  vpc_id      = module.vpc.vpc_attributes.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ec2"
  })
}

resource "aws_vpc_security_group_egress_rule" "app_to_s3_gateway" {
  security_group_id = aws_security_group.app.id

  prefix_list_id = aws_vpc_endpoint.s3.prefix_list_id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  description = "Allow application workloads to access S3 through the Gateway VPC Endpoint"
}

resource "aws_vpc_security_group_egress_rule" "app_to_vpc_endpoints" {
  security_group_id = aws_security_group.app.id

  referenced_security_group_id = aws_security_group.vpc_endpoints.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  description = "Allow HTTPS from lab EC2 to interface VPC endpoints"
}

resource "aws_security_group" "vpc_endpoints" {
  name        = "${local.name_prefix}-vpc-endpoints"
  description = "Security group for CloudContent interface VPC endpoints"
  vpc_id      = module.vpc.vpc_attributes.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc-endpoints"
  })
}

resource "aws_vpc_security_group_ingress_rule" "app_to_vpc_endpoints" {
  security_group_id = aws_security_group.vpc_endpoints.id

  referenced_security_group_id = aws_security_group.app.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  description = "Allow HTTPS from lab EC2 security group"
}
