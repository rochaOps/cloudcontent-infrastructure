data "aws_iam_policy_document" "ecr_pull" {
  statement {
    sid       = "GetAuthorizationToken"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid = "PullApplicationImage"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = [aws_ecr_repository.app.arn]
  }
}

resource "aws_iam_policy" "ecr_pull" {
  name   = "${local.name_prefix}-ecr-pull"
  policy = data.aws_iam_policy_document.ecr_pull.json
  tags   = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ec2_ecr_pull" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ecr_pull.arn
}
