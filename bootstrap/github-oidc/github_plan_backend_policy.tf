data "aws_iam_policy_document" "terraform_plan_backend" {
  statement {
    sid    = "ListFoundationState"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${var.terraform_state_bucket}"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:prefix"

      values = [
        var.terraform_foundation_state_key
      ]
    }
  }

  statement {
    sid    = "ReadFoundationState"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${var.terraform_state_bucket}/${var.terraform_foundation_state_key}"
    ]
  }

  statement {
    sid    = "ManageFoundationStateLock"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${var.terraform_state_bucket}/${var.terraform_foundation_state_key}.tflock"
    ]
  }
}

resource "aws_iam_policy" "terraform_plan_backend" {
  name        = "cloudcontent-terraform-plan-backend"
  description = "Allows GitHub Actions pull request plans to read the CloudContent Terraform state"

  policy = data.aws_iam_policy_document.terraform_plan_backend.json

  tags = {
    Name    = "cloudcontent-terraform-plan-backend"
    Project = "CloudContent"
  }
}

resource "aws_iam_role_policy_attachment" "terraform_plan_backend" {
  role       = aws_iam_role.github_plan.name
  policy_arn = aws_iam_policy.terraform_plan_backend.arn
}