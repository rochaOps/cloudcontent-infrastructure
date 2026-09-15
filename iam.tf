data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "app_pod_identity_trust" {
  statement {
    sid    = "AllowEksPodIdentity"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    principals {
      type = "Service"

      identifiers = [
        "pods.eks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "app" {
  name = "cloudcontent-app"

  assume_role_policy = data.aws_iam_policy_document.app_pod_identity_trust.json

  tags = {
    Name    = "cloudcontent-app"
    Project = "CloudContent"
  }
}

data "aws_iam_policy_document" "app_rds_connection_permission" {
  statement {
    sid    = "AllowRdsIamAuthentication"
    effect = "Allow"

    actions = [
      "rds-db:connect"
    ]

    resources = [
      "arn:aws:rds-db:ap-northeast-1:${data.aws_caller_identity.current.account_id}:dbuser:${var.rds_resource_id}/${var.app_db_username}"
    ]
  }
}

resource "aws_iam_policy" "app_rds_connection_permission" {
  name        = "cloudcontent-app-rds-connect"
  description = "Allows the CloudContent application to connect to PostgreSQL using IAM database authentication"

  policy = data.aws_iam_policy_document.app_rds_connection_permission.json

  tags = {
    Name    = "cloudcontent-app-rds-connect"
    Project = "CloudContent"
  }
}

resource "aws_iam_role_policy_attachment" "app_rds_connection_permission" {
  role       = aws_iam_role.app.name
  policy_arn = aws_iam_policy.app_rds_connection_permission.arn
}