# Roles for the homelab-devops repository (Proxmox lab, self-hosted runner).
# They reuse this account's GitHub OIDC provider and Terraform state bucket,
# and only grant access to the homelab state key and its native lockfile.

locals {
  # Both subject formats are listed until the repository's OIDC subject
  # customization is confirmed; each one is bound to this repository only.
  homelab_subject_prefixes = [
    "repo:${var.github_owner}@${var.github_owner_id}/${var.homelab_repository}@${var.homelab_repository_id}",
    "repo:${var.github_owner}/${var.homelab_repository}",
  ]

  homelab_state_bucket_arn = "arn:${data.aws_partition.current.partition}:s3:::${var.terraform_state_bucket}"
  homelab_state_object_arn = "${local.homelab_state_bucket_arn}/${var.homelab_state_key}"
  homelab_state_lock_arn   = "${local.homelab_state_object_arn}.tflock"
}

# -----------------------------------------------------------------------------
# Plan: pull requests opened by the repository owner
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "homelab_plan_trust" {
  statement {
    sid    = "AllowHomelabPullRequestPlan"
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github_actions.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [for prefix in local.homelab_subject_prefixes : "${prefix}:pull_request"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:actor_id"

      values = [
        var.github_owner_id
      ]
    }
  }
}

resource "aws_iam_role" "homelab_github_plan" {
  name = "homelab-github-plan"

  assume_role_policy = data.aws_iam_policy_document.homelab_plan_trust.json

  tags = {
    Name    = "homelab-github-plan"
    Project = "Homelab"
  }
}

data "aws_iam_policy_document" "homelab_plan_backend" {
  statement {
    sid    = "ListHomelabState"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      local.homelab_state_bucket_arn
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:prefix"

      values = [
        var.homelab_state_key
      ]
    }
  }

  statement {
    sid    = "ReadHomelabState"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      local.homelab_state_object_arn
    ]
  }

  statement {
    sid    = "ManageHomelabStateLock"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      local.homelab_state_lock_arn
    ]
  }
}

resource "aws_iam_policy" "homelab_plan_backend" {
  name        = "homelab-terraform-plan-backend"
  description = "Allows homelab pull request plans to read the homelab Terraform state"

  policy = data.aws_iam_policy_document.homelab_plan_backend.json

  tags = {
    Name    = "homelab-terraform-plan-backend"
    Project = "Homelab"
  }
}

resource "aws_iam_role_policy_attachment" "homelab_plan_backend" {
  role       = aws_iam_role.homelab_github_plan.name
  policy_arn = aws_iam_policy.homelab_plan_backend.arn
}

# -----------------------------------------------------------------------------
# Apply: jobs bound to the homelab GitHub Environment
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "homelab_apply_trust" {
  statement {
    sid    = "AllowHomelabEnvironmentApply"
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github_actions.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [for prefix in local.homelab_subject_prefixes : "${prefix}:environment:${var.homelab_environment}"]
    }
  }
}

resource "aws_iam_role" "homelab_github_apply" {
  name = "homelab-github-apply"

  assume_role_policy = data.aws_iam_policy_document.homelab_apply_trust.json

  tags = {
    Name    = "homelab-github-apply"
    Project = "Homelab"
  }
}

data "aws_iam_policy_document" "homelab_apply_backend" {
  statement {
    sid    = "ListHomelabState"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      local.homelab_state_bucket_arn
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:prefix"

      values = [
        var.homelab_state_key
      ]
    }
  }

  statement {
    sid    = "ReadWriteHomelabState"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      local.homelab_state_object_arn
    ]
  }

  statement {
    sid    = "ManageHomelabStateLock"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      local.homelab_state_lock_arn
    ]
  }
}

resource "aws_iam_policy" "homelab_apply_backend" {
  name        = "homelab-terraform-apply-backend"
  description = "Allows homelab applies to read and write the homelab Terraform state"

  policy = data.aws_iam_policy_document.homelab_apply_backend.json

  tags = {
    Name    = "homelab-terraform-apply-backend"
    Project = "Homelab"
  }
}

resource "aws_iam_role_policy_attachment" "homelab_apply_backend" {
  role       = aws_iam_role.homelab_github_apply.name
  policy_arn = aws_iam_policy.homelab_apply_backend.arn
}
