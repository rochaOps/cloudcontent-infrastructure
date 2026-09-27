locals {
  association_arn = var.enable_workload ? aws_ssm_association.ansible[0].arn : null
  subjects = {
    publish = var.publish_subject
    deploy  = var.deploy_subject
  }
}
resource "aws_ssm_parameter" "image" {
  count           = var.enable_workload ? 1 : 0
  name            = var.parameter_name
  description     = "Desired image digest owned by the approved delivery pipeline"
  type            = "String"
  tier            = "Standard"
  value           = var.initial_image_digest
  allowed_pattern = "^sha256:[a-f0-9]{64}$"
  lifecycle {
    ignore_changes = [value]
    precondition {
      condition     = var.initial_image_digest != null
      error_message = "Set initial_image_digest from the first ECR publication before enabling the workload."
    }
  }
}
data "aws_iam_policy_document" "trust" {
  for_each = local.subjects
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [each.value]
    }
  }
}
resource "aws_iam_role" "github" {
  for_each             = local.subjects
  name                 = "cloudcontent-lab-${each.key}"
  assume_role_policy   = data.aws_iam_policy_document.trust[each.key].json
  max_session_duration = 3600
}
data "aws_iam_policy_document" "publish" {
  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"] # This API does not support repository resource scoping.
  }
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability", "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart", "ecr:CompleteLayerUpload", "ecr:PutImage",
      "ecr:DescribeImages"
    ]
    resources = [aws_ecr_repository.app.arn]
  }
}
data "aws_iam_policy_document" "deploy" {
  count = var.enable_workload ? 1 : 0
  statement {
    actions   = ["ecr:DescribeImages"]
    resources = [aws_ecr_repository.app.arn]
  }
  statement {
    actions   = ["ssm:GetParameter", "ssm:PutParameter"]
    resources = [aws_ssm_parameter.image[0].arn]
  }
  statement {
    actions   = ["ssm:StartAssociationsOnce", "ssm:DescribeAssociationExecutions"]
    resources = [local.association_arn]
  }
}
resource "aws_iam_role_policy" "publish" {
  role   = aws_iam_role.github["publish"].id
  policy = data.aws_iam_policy_document.publish.json
}
resource "aws_iam_role_policy" "deploy" {
  count  = var.enable_workload ? 1 : 0
  role   = aws_iam_role.github["deploy"].id
  policy = data.aws_iam_policy_document.deploy[0].json
}
