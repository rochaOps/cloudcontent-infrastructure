# ManagedInstanceCore grants GetParameter(s) on *. Restrict them to this lab.
resource "aws_iam_role_policy" "parameter_boundary" {
  name = "restrict-cicd-parameter-read"
  role = aws_iam_role.ec2.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect      = "Deny"
      Action      = ["ssm:GetParameter", "ssm:GetParameters"]
      NotResource = "arn:${data.aws_partition.current.partition}:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter${var.parameter_name}"
    }]
  })
}
