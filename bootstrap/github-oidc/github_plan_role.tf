data "aws_iam_policy_document" "github_plan_trust" {
  statement {
    sid    = "AllowCloudContentPullRequestPlan"
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

      values = [
        "repo:${var.github_owner}@${var.github_owner_id}/${var.github_repository}@${var.github_repository_id}:pull_request"
      ]
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

resource "aws_iam_role" "github_plan" {
  name = "cloudcontent-github-plan"

  assume_role_policy = data.aws_iam_policy_document.github_plan_trust.json

  tags = {
    Name    = "cloudcontent-github-plan"
    Project = "CloudContent"
  }
}