data "aws_iam_policy_document" "terraform_backend" {
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
    sid    = "ReadWriteFoundationState"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
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

resource "aws_iam_policy" "terraform_backend" {
  name        = "cloudcontent-terraform-backend"
  description = "Allows GitHub Actions to access the CloudContent Terraform foundation state"

  policy = data.aws_iam_policy_document.terraform_backend.json

  tags = {
    Name    = "cloudcontent-terraform-backend"
    Project = "CloudContent"
  }
}

resource "aws_iam_role_policy_attachment" "terraform_backend" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.terraform_backend.arn
}