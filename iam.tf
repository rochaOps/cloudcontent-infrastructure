# -----------------------------------------------------------------------------
# EKS Pod Identity trust
# -----------------------------------------------------------------------------

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

  tags = merge(local.common_tags, {
    Name = "cloudcontent-app"
  })
}


# -----------------------------------------------------------------------------
# RDS IAM Database Authentication
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "app_rds_connection_permission" {
  statement {
    sid    = "AllowRdsIamAuthentication"
    effect = "Allow"

    actions = [
      "rds-db:connect"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${module.rds.db_instance_resource_id}/${var.app_db_username}"
    ]
  }
}

resource "aws_iam_policy" "app_rds_connection_permission" {
  name        = "cloudcontent-app-rds-connect"
  description = "Allows CloudContent application to connect to PostgreSQL using IAM database authentication"

  policy = data.aws_iam_policy_document.app_rds_connection_permission.json

  tags = merge(local.common_tags, {
    Name = "cloudcontent-app-rds-connect"
  })
}

resource "aws_iam_role_policy_attachment" "app_rds_connection_permission" {
  role       = aws_iam_role.app.name
  policy_arn = aws_iam_policy.app_rds_connection_permission.arn
}


# -----------------------------------------------------------------------------
# S3 Content
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "app_s3_content_permission" {
  statement {
    sid    = "ListContentBuckets"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      aws_s3_bucket.free_content.arn,
      aws_s3_bucket.premium_content.arn
    ]
  }

  statement {
    sid    = "ReadWriteContentObjects"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.free_content.arn}/*",
      "${aws_s3_bucket.premium_content.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "app_s3_content_permission" {
  name        = "cloudcontent-app-s3-content"
  description = "Allows CloudContent application to read and write content objects"

  policy = data.aws_iam_policy_document.app_s3_content_permission.json

  tags = merge(local.common_tags, {
    Name = "cloudcontent-app-s3-content"
  })
}

resource "aws_iam_role_policy_attachment" "app_s3_content_permission" {
  role       = aws_iam_role.app.name
  policy_arn = aws_iam_policy.app_s3_content_permission.arn
}