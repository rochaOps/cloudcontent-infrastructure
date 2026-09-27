# -----------------------------------------------------------------------------
# Amazon Linux 2023 AMI
# -----------------------------------------------------------------------------

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"

    values = [
      "al2023-ami-2023.*-x86_64"
    ]
  }

  filter {
    name = "architecture"

    values = [
      "x86_64"
    ]
  }

  filter {
    name = "root-device-type"

    values = [
      "ebs"
    ]
  }

  filter {
    name = "virtualization-type"

    values = [
      "hvm"
    ]
  }
}


# -----------------------------------------------------------------------------
# Application EC2
# -----------------------------------------------------------------------------

resource "aws_instance" "app" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"

  subnet_id = local.app_subnet_ids[0]

  vpc_security_group_ids = [
    aws_security_group.app.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ec2.name

  associate_public_ip_address = false

  user_data                   = file("${path.module}/templates/bootstrap.sh")
  user_data_replace_on_change = true

  # Package repositories are reached through S3 before bootstrap starts.
  depends_on = [
    aws_vpc_endpoint.s3,
    aws_vpc_endpoint.interface,
    aws_vpc_security_group_egress_rule.app_to_s3_gateway,
    aws_vpc_security_group_egress_rule.app_to_vpc_endpoints,
    aws_vpc_security_group_ingress_rule.app_to_vpc_endpoints,
    aws_iam_role_policy_attachment.ec2_ssm,
    aws_iam_role_policy_attachment.ec2_ecr_pull,
    aws_iam_role_policy_attachment.ec2_ansible_artifacts_read,
  ]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 16
    encrypted   = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ec2"
  })
}
